# Parsing

`dart_xray` includes parser utilities to normalize common Xray/V2Ray style links.

## Supported formats

- `vless://`
- `vmess://` (base64 JSON)
- `trojan://`
- `ss://` (URI or base64 userinfo)
- `socks://`
- `http://` and `https://`

## Public API

- `ParsedXrayLink parseLink(String link)`
- `List<ParsedXrayLink> parseLinks(List<String> links)`
- `bool isSupportedLink(String link)`
- `XrayStartRequest requestFromLink(String link, { ... })`

## Validation behavior

- Unsupported schemes throw `FormatException`.
- Malformed VMess/SS payloads throw parser errors.
- Query parameters are preserved as strings in `query`.

## Normalization

`ParsedXrayLink` provides `toNormalizedConfig()` for native adapter translation.
