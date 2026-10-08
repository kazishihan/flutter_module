import 'dart:async';

import 'package:flutter/material.dart';

import 'sdk/flutter_sdk.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Handshake before the first frame so the host learns Flutter is ready
  // without waiting for the screen to be shown.
  unawaited(FlutterSdk.initialize());
  runApp(const MyFlutterApp());
}

class MyFlutterApp extends StatefulWidget {
  const MyFlutterApp({super.key});

  @override
  State<MyFlutterApp> createState() => _MyFlutterAppState();
}

class _MyFlutterAppState extends State<MyFlutterApp> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Shihan');

  String _message = 'No data';

  @override
  void initState() {
    super.initState();
    unawaited(
      FlutterSdk.initialize(
        onDataReceived: (data) {
          if (!mounted) return;
          setState(() => _message = 'From host: $data');
        },
      ),
    );
  }

  @override
  void dispose() {
    FlutterSdk.clearDataHandler();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveUserName() async {
    final success = await FlutterSdk.saveData(
      key: 'userName',
      value: _nameController.text,
    );
    if (!mounted) return;
    setState(() => _message = success ? 'User name saved' : 'Failed to save');
  }

  Future<void> _loadUserName() async {
    final value = await FlutterSdk.getData(key: 'userName');
    if (!mounted) return;
    setState(() => _message = value ?? 'No user name found');
  }

  Future<void> _sendEvent() async {
    final delivered = await FlutterSdk.sendEvent('button_tapped', {
      'userName': _nameController.text,
    });
    if (!mounted) return;
    setState(() => _message = delivered ? 'Event sent to host' : 'No host');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter SDK')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ValueListenableBuilder<SdkConfig?>(
                valueListenable: FlutterSdk.configListenable,
                builder: (context, config, _) => Text(
                  config == null
                      ? 'Config: not received'
                      : 'Env: ${config.environment} · User: ${config.userId} '
                          '· Lang: ${config.language}',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'User name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveUserName,
                child: const Text('Save User Name'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _loadUserName,
                child: const Text('Load User Name'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _sendEvent,
                child: const Text('Send Event to Host'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: FlutterSdk.close,
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
