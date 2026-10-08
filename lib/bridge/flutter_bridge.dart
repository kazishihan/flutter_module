import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'sdk_config.dart';

class FlutterBridge {
  FlutterBridge._();

  static const MethodChannel _channel = MethodChannel('com.example.flutter_module/bridge');

  static void Function(String data)? _dataHandler;

  static final List<String> _pendingData = [];

  static final ValueNotifier<SdkConfig?> configNotifier = ValueNotifier<SdkConfig?>(null);

  static SdkConfig? get config => configNotifier.value;

  static bool _initialized = false;

  /// Initialize the Flutter bridge.
  /// Safe to call multiple times.
  static Future<void> initialize() async {
    if (_initialized) return;

    _initialized = true;
    _channel.setMethodCallHandler(_handleMethodCall);

    await _notifyHostReady();
  }

  /// Tell the native host that Flutter is ready.
  static Future<void> _notifyHostReady() async {
    try {
      final config = await _channel.invokeMapMethod<String, dynamic>(
        'flutterReady',
      );

      if (config != null) {
        _updateConfig(config);
      }
    } on MissingPluginException {
      _log('Running without a native host.');
    } on PlatformException catch (e) {
      _log('flutterReady failed: ${e.code} - ${e.message}');
    }
  }

  // ---------------------------------------------------------------------------
  // Host -> Flutter
  // ---------------------------------------------------------------------------

  /// Register a listener for data received from the native host.
  ///
  /// Any data received before the handler was registered will be delivered
  /// immediately after the handler is set.
  static void setDataHandler(void Function(String data)? handler) {
    _dataHandler = handler;

    if (handler == null || _pendingData.isEmpty) return;

    final pendingData = List<String>.from(_pendingData);
    _pendingData.clear();

    for (final data in pendingData) {
      handler(data);
    }
  }

  /// Handles method calls coming from the native host.
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'initializeSdk':
        return _handleInitializeSdk(call.arguments);

      case 'receiveDataFromHost':
        return _handleReceivedData(call.arguments);

      default:
        throw MissingPluginException(
          'Method not implemented: ${call.method}',
        );
    }
  }

  static bool _handleInitializeSdk(dynamic arguments) {
    if (arguments is! Map) {
      throw PlatformException(
        code: 'INVALID_ARGUMENT',
        message: 'initializeSdk expects a map.',
      );
    }

    _updateConfig(Map<String, dynamic>.from(arguments));
    return true;
  }

  static bool _handleReceivedData(dynamic arguments) {
    final data = arguments?.toString() ?? '';

    _log('Data received from host: $data');

    if (_dataHandler != null) {
      _dataHandler!(data);
    } else {
      _pendingData.add(data);
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // Flutter -> Host
  // ---------------------------------------------------------------------------

  /// Save data in the native host.
  static Future<bool> saveData({
    required String key,
    required String value,
  }) async {
    final result = await _invoke<bool>(
      'saveData',
      {
        'key': key,
        'value': value,
      },
    );

    return result ?? false;
  }

  /// Get data from the native host.
  static Future<String?> getData({
    required String key,
  }) {
    return _invoke<String>(
      'getData',
      {'key': key},
    );
  }

  /// Send an event to the native host.
  static Future<bool> sendEvent(
      String name, {
        Map<String, dynamic>? payload,
      }) async {
    final result = await _invoke<bool>(
      'sendEvent',
      {
        'name': name,
        'payload': payload ?? {},
      },
    );

    return result ?? false;
  }

  /// Call a native method.
  static Future<T?> _invoke<T>(
      String method,
      Map<String, dynamic> arguments,
      ) async {
    try {
      return await _channel.invokeMethod<T>(
        method,
        arguments,
      );
    } on PlatformException catch (e) {
      _log('$method failed: ${e.code} - ${e.message}');
    } on MissingPluginException {
      _log('$method: no native host attached.');
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Config
  // ---------------------------------------------------------------------------

  static void _updateConfig(Map<String, dynamic> data) {
    final newConfig = SdkConfig.fromMap(data);

    configNotifier.value = newConfig;

    _log('Config received: $newConfig');
  }

  // ---------------------------------------------------------------------------
  // Logging
  // ---------------------------------------------------------------------------

  static void _log(String message) {
    if (config?.enableLogging == true || kDebugMode) {
      debugPrint('[FlutterSdk] $message');
    }
  }

  // ---------------------------------------------------------------------------
  // Testing
  // ---------------------------------------------------------------------------

  @visibleForTesting
  static void resetForTest() {
    _initialized = false;
    _dataHandler = null;
    _pendingData.clear();
    configNotifier.value = null;
  }
}
