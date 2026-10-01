import 'package:flutter/material.dart';
import 'package:flutter_module/sdk/FlutterSdk.dart';


void main() {
  runApp(const MyFlutterApp());
}

class MyFlutterApp extends StatefulWidget {
  const MyFlutterApp({super.key});

  @override
  State<MyFlutterApp> createState() => _MyFlutterAppState();
}

class _MyFlutterAppState extends State<MyFlutterApp> {

  String message = 'No data';

  @override
  void initState() {
    super.initState();

    FlutterSdk.initialize(
      onDataReceived: (data) {
        setState(() {
          message = data;
        });
      },
    );
  }

  Future<void> saveUserName() async {

    final success = await FlutterSdk.saveData(
      key: 'userName',
      value: 'Shihan',
    );

    setState(() {

      message = success
          ? 'User name saved'
          : 'Failed to save';

    });
  }

  Future<void> loadUserName() async {

    final value = await FlutterSdk.getData(
      key: 'userName',
    );

    setState(() {
      message = value ?? 'No user name found';
    });
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      home: Scaffold(

        appBar: AppBar(
          title: const Text('Flutter SDK'),
        ),

        body: Center(

          child: Column(

            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [

              Text(
                message,
                style: const TextStyle(
                  fontSize: 22,
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: saveUserName,
                child: const Text(
                  'Save User Name',
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: loadUserName,
                child: const Text(
                  'Load User Name',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}