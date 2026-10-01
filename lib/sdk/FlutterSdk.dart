import '../bridge/FlutterBridge.dart';


class FlutterSdk {

  static void initialize({
    required Function(String data) onDataReceived,
  }) {

    FlutterBridge.setDataReceivedHandler(
      onDataReceived,
    );
  }

  static Future<bool> saveData({
    required String key,
    required String value,
  }) {

    return FlutterBridge.saveData(
      key: key,
      value: value,
    );
  }

  static Future<String?> getData({
    required String key,
  }) {

    return FlutterBridge.getData(
      key: key,
    );
  }
}