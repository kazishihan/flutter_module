import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../bridge/flutter_bridge.dart';
import '../bridge/sdk_config.dart';

export '../bridge/sdk_config.dart';

/// Dart-side public API of the SDK. UI code talks only to this class.
class FlutterSdk {
  FlutterSdk._();

  /// Starts the bridge. [onDataReceived] receives data sent by the host,
  /// including anything sent before this call (it is buffered).
  static Future<void> initialize({void Function(String data)? onDataReceived}) {
    if (onDataReceived != null) {
      FlutterBridge.setDataHandler(onDataReceived);
    }
    return FlutterBridge.initialize();
  }

  /// Stops delivering host data (call from `State.dispose`).
  static void clearDataHandler() => FlutterBridge.setDataHandler(null);

  /// Config supplied by the host, or null if not (yet) received.
  static SdkConfig? get config => FlutterBridge.config;

  static ValueListenable<SdkConfig?> get configListenable => FlutterBridge.configNotifier;

  static Future<bool> saveData({required String key, required String value}) => FlutterBridge.saveData(key: key, value: value);

  static Future<String?> getData({required String key}) => FlutterBridge.getData(key: key);

  /// Delivers an event to the host app's listeners.
  static Future<bool> sendEvent(String name, [Map<String, dynamic>? payload]) => FlutterBridge.sendEvent(name, payload: payload);

  /// Closes the Flutter screen and returns to the host app. The host is notified through its `onClosed` callback.
  static Future<void> close() => SystemNavigator.pop();
}
