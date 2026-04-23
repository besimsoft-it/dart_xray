/// Supported protocol families for Xray links.
enum XrayProtocol {
  vless,
  vmess,
  trojan,
  shadowsocks,
  socks,
  http,
}

/// Typed representation of a parsed Xray style link.
class ParsedXrayLink {
  /// Protocol inferred from URI scheme.
  final XrayProtocol protocol;

  /// Hostname or IP endpoint.
  final String host;

  /// Remote server port.
  final int port;

  /// User identity (uuid/password/method tuple encoded string).
  final String? user;

  /// Optional display remark from URI fragment.
  final String? remark;

  /// Query options such as security/transport fields.
  final Map<String, String> query;

  const ParsedXrayLink({
    required this.protocol,
    required this.host,
    required this.port,
    this.user,
    this.remark,
    this.query = const <String, String>{},
  });

  /// Converts parsed data into a minimal, normalized outbound JSON model.
  Map<String, Object?> toNormalizedConfig() {
    return <String, Object?>{
      'protocol': protocol.name,
      'host': host,
      'port': port,
      'user': user,
      'remark': remark,
      'query': query,
    };
  }
}
