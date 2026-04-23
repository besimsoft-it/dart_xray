import 'dart:convert';

import 'parsed_xray_link.dart';

/// Start parameters for proxy or TUN sessions.
class XrayStartRequest {
  /// Full native JSON config consumed by libXray wrappers.
  final String configJson;

  /// Connection mode. Typical values: `proxy` or `tun`.
  final String mode;

  /// Optional source link that produced this config.
  final ParsedXrayLink? sourceLink;

  /// Enables immediate health check after startup.
  final bool verifyConnectivity;

  const XrayStartRequest({
    required this.configJson,
    required this.mode,
    this.sourceLink,
    this.verifyConnectivity = true,
  });

  /// Serializes request for the native FFI ABI.
  Map<String, Object?> toJson() => <String, Object?>{
        'configJson': configJson,
        'mode': mode,
        'verifyConnectivity': verifyConnectivity,
        'sourceLink': sourceLink?.toNormalizedConfig(),
      };

  /// Creates a start request from normalized parsed link data.
  factory XrayStartRequest.fromParsedLink(
    ParsedXrayLink link, {
    String mode = 'proxy',
    bool verifyConnectivity = true,
  }) {
    final normalized = <String, Object?>{
      'log': <String, Object?>{'loglevel': 'warning'},
      'outbounds': <Object?>[
        <String, Object?>{
          'tag': 'proxy',
          'protocol': link.protocol.name,
          'settings': <String, Object?>{
            'address': link.host,
            'port': link.port,
            'user': link.user,
            'query': link.query,
          },
        },
      ],
    };

    return XrayStartRequest(
      configJson: jsonEncode(normalized),
      mode: mode,
      sourceLink: link,
      verifyConnectivity: verifyConnectivity,
    );
  }
}
