import 'dart:async';

import 'models/xray_connection_status.dart';
import 'models/xray_init_options.dart';
import 'models/parsed_xray_link.dart';
import 'models/xray_start_request.dart';
import 'parsing/xray_link_parser.dart';
import 'platform/dart_xray_platform_interface.dart';

/// Main Dart API for controlling libXray-backed sessions.
class DartXray {
  DartXray._();

  /// Singleton instance used by apps.
  static final DartXray instance = DartXray._();

  /// Stream of native state transitions for the current process session.
  Stream<XrayConnectionStatus> get onStatusChanged =>
      DartXrayPlatform.instance.statusStream;

  /// Long-lived stream intended for persistent listeners across restarts.
  Stream<XrayConnectionStatus> get persistentStatusStream =>
      DartXrayPlatform.instance.persistentStatusStream;

  /// Initializes native engine prerequisites.
  Future<void> init(XrayInitOptions options) {
    return DartXrayPlatform.instance.init(options);
  }

  /// Starts proxy or TUN mode depending on [request.mode].
  Future<void> start(XrayStartRequest request) {
    return DartXrayPlatform.instance.start(request);
  }

  /// Stops the active session and tears down native resources.
  Future<void> stop() {
    return DartXrayPlatform.instance.stop();
  }

  /// Measures delay for a provided link or JSON config payload.
  Future<Duration?> getServerDelay(String linkOrConfig) {
    return DartXrayPlatform.instance.getServerDelay(linkOrConfig);
  }

  /// Measures delay of the currently active server.
  Future<Duration?> getCurrentServerDelay() {
    return DartXrayPlatform.instance.getCurrentServerDelay();
  }

  /// Starts a native listener that survives repeated start/stop cycles.
  Future<void> startPersistentStatusListener() {
    return DartXrayPlatform.instance.startPersistentStatusListener();
  }

  /// Stops the long-lived native status listener.
  Future<void> stopPersistentStatusListener() {
    return DartXrayPlatform.instance.stopPersistentStatusListener();
  }

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
