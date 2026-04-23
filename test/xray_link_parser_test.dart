import 'package:dart_xray/src/models/parsed_xray_link.dart';
import 'package:dart_xray/src/parsing/xray_link_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses vless link', () {
    final parsed = XrayLinkParser.parseLink(
      'vless://uuid@example.com:443?security=tls&type=ws#demo',
    );

    expect(parsed.protocol, XrayProtocol.vless);
    expect(parsed.host, 'example.com');
    expect(parsed.port, 443);
    expect(parsed.user, 'uuid');
    expect(parsed.remark, 'demo');
  });

  test('parses vmess base64 json link', () {
    final vmess =
        'vmess://eyJhZGQiOiJ2bWVzcy5leGFtcGxlLmNvbSIsInBvcnQiOiI0NDMiLCJpZCI6InV1aWQiLCJwcyI6InRlc3QifQ==';
    final parsed = XrayLinkParser.parseLink(vmess);

    expect(parsed.protocol, XrayProtocol.vmess);
    expect(parsed.host, 'vmess.example.com');
    expect(parsed.port, 443);
  });

  test('throws on unsupported links', () {
    expect(() => XrayLinkParser.parseLink('ftp://example.com'), throwsFormatException);
  });
}
