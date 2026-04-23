import 'dart:convert';

import '../models/parsed_xray_link.dart';
import '../models/xray_start_request.dart';

/// Parses Xray/V2Ray style links into normalized Dart models.
class XrayLinkParser {
  /// Returns true when [link] uses a supported protocol prefix.
  static bool isSupportedLink(String link) {
    final lower = link.toLowerCase();
    return lower.startsWith('vless://') ||
        lower.startsWith('vmess://') ||
        lower.startsWith('trojan://') ||
        lower.startsWith('ss://') ||
        lower.startsWith('socks://') ||
        lower.startsWith('http://') ||
        lower.startsWith('https://');
  }

  /// Parses one link and throws [FormatException] for malformed input.
  static ParsedXrayLink parseLink(String link) {
    if (!isSupportedLink(link)) {
      throw const FormatException('Unsupported link scheme.');
    }

    if (link.toLowerCase().startsWith('vmess://')) {
      return _parseVmess(link);
    }

    if (link.toLowerCase().startsWith('ss://')) {
      return _parseShadowsocks(link);
    }

    final uri = Uri.parse(link);
    final protocol = switch (uri.scheme.toLowerCase()) {
      'vless' => XrayProtocol.vless,
      'trojan' => XrayProtocol.trojan,
      'socks' => XrayProtocol.socks,
      'http' || 'https' => XrayProtocol.http,
      _ => throw FormatException('Unsupported scheme: ${uri.scheme}'),
    };

    return ParsedXrayLink(
      protocol: protocol,
      host: uri.host,
      port: uri.port,
      user: uri.userInfo.isEmpty ? null : uri.userInfo,
      remark: uri.fragment.isEmpty ? null : Uri.decodeComponent(uri.fragment),
      query: uri.queryParameters,
    );
  }

  /// Parses multiple links and stops on first invalid item.
  static List<ParsedXrayLink> parseLinks(List<String> links) {
    return links.map(parseLink).toList(growable: false);
  }

  /// Creates a start request from a single link.
  static XrayStartRequest requestFromLink(
    String link, {
    String mode = 'proxy',
    bool verifyConnectivity = true,
  }) {
    final parsed = parseLink(link);
    return XrayStartRequest.fromParsedLink(
      parsed,
      mode: mode,
      verifyConnectivity: verifyConnectivity,
    );
  }

  static ParsedXrayLink _parseVmess(String link) {
    final raw = link.substring('vmess://'.length);
    final normalized = raw.padRight(raw.length + ((4 - raw.length % 4) % 4), '=');
    final decoded = utf8.decode(base64.decode(normalized));
    final json = jsonDecode(decoded) as Map<String, dynamic>;

    return ParsedXrayLink(
      protocol: XrayProtocol.vmess,
      host: json['add'] as String,
      port: int.parse('${json['port']}'),
      user: json['id'] as String?,
      remark: json['ps'] as String?,
      query: json.map((k, v) => MapEntry('$k', '$v')),
    );
  }

  static ParsedXrayLink _parseShadowsocks(String link) {
    final uri = Uri.parse(link);
    String userInfo = uri.userInfo;
    if (userInfo.isEmpty) {
      final authAndHost = link.substring('ss://'.length).split('#').first;
      final left = authAndHost.split('@').first;
      final padded = left.padRight(left.length + ((4 - left.length % 4) % 4), '=');
      userInfo = utf8.decode(base64.decode(padded));
    }

    return ParsedXrayLink(
      protocol: XrayProtocol.shadowsocks,
      host: uri.host,
      port: uri.port,
      user: userInfo,
      remark: uri.fragment.isEmpty ? null : Uri.decodeComponent(uri.fragment),
      query: uri.queryParameters,
    );
  }
}
