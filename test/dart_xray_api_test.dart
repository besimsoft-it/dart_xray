import 'dart:async';

import 'package:dart_xray/dart_xray.dart';
import 'package:dart_xray/src/ffi/xray_engine_ffi.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeXrayFfiEngine extends XrayFfiEngine {
  final _controller = StreamController<XrayConnectionStatus>.broadcast();

  @override
  Stream<XrayConnectionStatus> get onStatusChanged => _controller.stream;

  @override
  Stream<XrayConnectionStatus> get persistentStatusStream => _controller.stream;

  @override
  Future<Duration?> getCurrentServerDelay() async =>
      const Duration(milliseconds: 40);

  @override
  Future<Duration?> getServerDelay(String linkOrConfig) async =>
      const Duration(milliseconds: 45);

  @override
  Future<void> init(XrayInitOptions options) async {}

  @override
  Future<void> start(XrayStartRequest request) async =>
      _controller.add(XrayConnectionStatus.connected);

  @override
  Future<void> startPersistentStatusListener() async {}

  @override
  Future<void> stop() async =>
      _controller.add(XrayConnectionStatus.disconnected);

  @override
  Future<void> stopPersistentStatusListener() async {}
}

void main() {
  test('delegates delay APIs to ffi engine', () async {
    DartXray.debugEngineOverride = FakeXrayFfiEngine();
    final delay = await DartXray.instance.getServerDelay('vless://x@y:443');
    expect(delay?.inMilliseconds, 45);
    final current = await DartXray.instance.getCurrentServerDelay();
    expect(current?.inMilliseconds, 40);
  });
}
