import 'dart:async';

import 'package:dart_xray/dart_xray.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: XrayDemoPage());
  }
}

class XrayDemoPage extends StatefulWidget {
  const XrayDemoPage({super.key});

  @override
  State<XrayDemoPage> createState() => _XrayDemoPageState();
}

class _XrayDemoPageState extends State<XrayDemoPage> {
  final _controller = TextEditingController(text: 'vless://80cbd2e5-ceca-4f3c-9566-e39c2cb3719f@94.177.201.17:443?security=reality&type=tcp&headerType=&flow=xtls-rprx-vision&path=&host=&sni=yandex.ru&fp=chrome&pbk=eF1_pRWT5VDYbkEY3EzHTwXDQx1qD1f7aDJcHVxLK1M&sid=6ba87f12#🛡 VieraVPN F0%9F%9A%80%20Marz%20%28260994604%29%20%5BVLESS%20-%20tcp%5D');
  XrayConnectionStatus _status = XrayConnectionStatus.disconnected;
  Duration? _delay;
  StreamSubscription<XrayConnectionStatus>? _statusSub;
  StreamSubscription<XrayConnectionStatus>? _persistentSub;

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  Future<void> _init() async {
    await DartXray.instance.init(
      const XrayInitOptions(workingDirectory: '/tmp/dart_xray'),
    );
    await DartXray.instance.startPersistentStatusListener();
    _statusSub = DartXray.instance.onStatusChanged.listen((status) {
      setState(() => _status = status);
    });
    _persistentSub = DartXray.instance.persistentStatusStream.listen((_) {});
  }

  Future<void> _prepareVpn() async {
    await DartXray.instance.prepareVpnPermission();
  }

  Future<void> _start() async {
    final request = DartXray.instance.requestFromLink(_controller.text);
    await DartXray.instance.start(request);
  }

  Future<void> _stop() async {
    await DartXray.instance.stop();
  }

  Future<void> _measure() async {
    final delay = await DartXray.instance.getServerDelay(_controller.text);
    final current = await DartXray.instance.getCurrentServerDelay();
    setState(() => _delay = current ?? delay);
  }

  @override
  void dispose() {
    unawaited(_statusSub?.cancel());
    unawaited(_persistentSub?.cancel());
    unawaited(DartXray.instance.stopPersistentStatusListener());
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('dart_xray example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Platform caveat: VPN/TUN requires native setup. See docs/platforms/*.md'),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Xray link'),
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              ElevatedButton(onPressed: _prepareVpn, child: const Text('Prepare VPN')),
              ElevatedButton(onPressed: _start, child: const Text('Start')),
              ElevatedButton(onPressed: _stop, child: const Text('Stop')),
              ElevatedButton(onPressed: _measure, child: const Text('Ping')),
            ]),
            const SizedBox(height: 16),
            Text('Status: ${_status.wireValue}'),
            Text('Delay: ${_delay?.inMilliseconds ?? '-'} ms'),
          ],
        ),
      ),
    );
  }
}
