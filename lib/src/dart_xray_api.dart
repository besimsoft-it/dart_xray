import 'dart:async';

import 'ffi/xray_engine_ffi.dart';
import 'models/xray_connection_status.dart';
import 'models/xray_init_options.dart';
import 'models/parsed_xray_link.dart';
import 'models/xray_start_request.dart';
import 'parsing/xray_link_parser.dart';

/// Main Dart API for controlling libXray-backed sessions.
class DartXray {
  DartXray._();

  /// Singleton instance used by apps.
  static final DartXray instance = DartXray._();

  static XrayFfiEngine _engine = XrayFfiEngine();

  /// Allows tests to replace the FFI engine.
  static set debugEngineOverride(XrayFfiEngine engine) {
    _engine = engine;
  }

  /// Stream of native state transitions for the current process session.
  Stream<XrayConnectionStatus> get onStatusChanged => _engine.onStatusChanged;

  /// Long-lived stream intended for persistent listeners across restarts.
  Stream<XrayConnectionStatus> get persistentStatusStream =>
      _engine.persistentStatusStream;

  /// Initializes native engine prerequisites.
  Future<void> init(XrayInitOptions options) => _engine.init(options);


  /// Engine integration is pure FFI; VPN consent remains app-owned native setup.
  Future<bool> prepareVpnPermission() async => true;

  /// Starts proxy or TUN mode depending on [request.mode].
  Future<void> start(XrayStartRequest request) => _engine.start(request);

  /// Stops the active session and tears down native resources.
  Future<void> stop() => _engine.stop();

  /// Measures delay for a provided link or JSON config payload.
  Future<Duration?> getServerDelay(String linkOrConfig) =>
      _engine.getServerDelay(linkOrConfig);

  /// Measures delay of the currently active server.
  Future<Duration?> getCurrentServerDelay() => _engine.getCurrentServerDelay();

  /// Starts a native listener that survives repeated start/stop cycles.
  Future<void> startPersistentStatusListener() =>
      _engine.startPersistentStatusListener();

  /// Stops the long-lived native status listener.
  Future<void> stopPersistentStatusListener() =>
      _engine.stopPersistentStatusListener();

  /// Parses one Xray-compatible link.
  ParsedXrayLink parseLink(String link) => XrayLinkParser.parseLink(link);

  /// Parses many Xray-compatible links.
  List<ParsedXrayLink> parseLinks(List<String> links) =>
      XrayLinkParser.parseLinks(links);

  /// Checks if a link looks supported by the parser.
  bool isSupportedLink(String link) => XrayLinkParser.isSupportedLink(link);

  /// Convenience helper to turn a link into a start request.
  XrayStartRequest requestFromLink(
    String link, {
    String mode = 'proxy',
    bool verifyConnectivity = true,
  }) {
    return XrayLinkParser.requestFromLink(
      link,
      mode: mode,
      verifyConnectivity: verifyConnectivity,
    );
  }
}
