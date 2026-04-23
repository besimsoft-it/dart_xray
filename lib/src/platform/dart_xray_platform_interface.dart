import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../models/xray_connection_status.dart';
import '../models/xray_init_options.dart';
import '../models/xray_start_request.dart';
import 'method_channel_dart_xray.dart';

/// Platform abstraction for dart_xray operations.
abstract class DartXrayPlatform extends PlatformInterface {
  DartXrayPlatform() : super(token: _token);

  static final Object _token = Object();
  static DartXrayPlatform _instance = MethodChannelDartXray();

  /// Active platform implementation.
  static DartXrayPlatform get instance => _instance;

  /// Overrides platform implementation for tests.
  static set instance(DartXrayPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream<XrayConnectionStatus> get statusStream;

  Stream<XrayConnectionStatus> get persistentStatusStream;

  Future<void> init(XrayInitOptions options);

  Future<void> start(XrayStartRequest request);

  Future<void> stop();

  Future<Duration?> getServerDelay(String linkOrConfig);

  Future<Duration?> getCurrentServerDelay();

  Future<void> startPersistentStatusListener();

  Future<void> stopPersistentStatusListener();
}
