import 'dart:async';

import 'package:flutter/services.dart';

import '../models/xray_connection_status.dart';
import '../models/xray_init_options.dart';
import '../models/xray_start_request.dart';
import 'dart_xray_platform_interface.dart';

/// MethodChannel implementation backed by native platform plugins.
class MethodChannelDartXray extends DartXrayPlatform {
  static const MethodChannel _methodChannel =
      MethodChannel('dart_xray/methods');
  static const EventChannel _statusChannel = EventChannel('dart_xray/status');
  static const EventChannel _persistentChannel =
      EventChannel('dart_xray/persistent_status');

  Stream<XrayConnectionStatus>? _status;
  Stream<XrayConnectionStatus>? _persistent;

  @override
  Stream<XrayConnectionStatus> get statusStream {
    return _status ??= _statusChannel
        .receiveBroadcastStream()
        .map((dynamic raw) => XrayConnectionStatusCodec.fromWireValue('$raw'));
  }

  @override
  Stream<XrayConnectionStatus> get persistentStatusStream {
    return _persistent ??= _persistentChannel
        .receiveBroadcastStream()
        .map((dynamic raw) => XrayConnectionStatusCodec.fromWireValue('$raw'));
  }

  @override
  Future<void> init(XrayInitOptions options) {
    return _methodChannel.invokeMethod<void>('init', options.toJson());
  }

  @override
  Future<void> start(XrayStartRequest request) {
    return _methodChannel.invokeMethod<void>('start', request.toJson());
  }

  @override
  Future<void> stop() {
    return _methodChannel.invokeMethod<void>('stop');
  }

  @override
  Future<Duration?> getServerDelay(String linkOrConfig) async {
    final ms = await _methodChannel
        .invokeMethod<int>('getServerDelay', <String, Object?>{'input': linkOrConfig});
    return ms == null ? null : Duration(milliseconds: ms);
  }

  @override
  Future<Duration?> getCurrentServerDelay() async {
    final ms = await _methodChannel.invokeMethod<int>('getCurrentServerDelay');
    return ms == null ? null : Duration(milliseconds: ms);
  }

  @override
  Future<void> startPersistentStatusListener() {
    return _methodChannel.invokeMethod<void>('startPersistentStatusListener');
  }

  @override
  Future<void> stopPersistentStatusListener() {
    return _methodChannel.invokeMethod<void>('stopPersistentStatusListener');
  }
}
