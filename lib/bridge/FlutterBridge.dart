import 'package:flutter/services.dart';


class FlutterBridge {
  static const String _channelName =
      'com.example.flutter_module/bridge';

  static const MethodChannel _channel =
  MethodChannel(_channelName);

  static Future<bool> saveData({
    required String key,
    required String value,
  }) async {
    final result = await _channel.invokeMethod(
      'saveData',
      {
        'key': key,
        'value': value,
      },
    );

    return result == true;
  }

  static Future<String?> getData({
    required String key,
  }) async {
    final result = await _channel.invokeMethod(
      'getData',
      {
        'key': key,
      },
    );

    return result as String?;
  }

  static void setDataReceivedHandler(
      Function(String data) handler,
      ) {
    _channel.setMethodCallHandler(
          (call) async {

        switch (call.method) {

          case 'receiveDataFromAndroid':

            handler(
              call.arguments.toString(),
            );

            break;

          default:
            break;
        }
      },
    );
  }
}