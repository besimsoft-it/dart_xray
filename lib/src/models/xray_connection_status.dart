/// Canonical connection states reported by native engines.
enum XrayConnectionStatus {
  /// Native startup or tunnel preparation is in progress.
  connecting,

  /// Session is active and traffic is flowing.
  connected,

  /// Session is fully stopped.
  disconnected,

  /// Startup or runtime failure happened.
  error,
}

extension XrayConnectionStatusCodec on XrayConnectionStatus {
  /// Converts status to the wire format used by the native ABI.
  String get wireValue => switch (this) {
        XrayConnectionStatus.connecting => 'CONNECTING',
        XrayConnectionStatus.connected => 'CONNECTED',
        XrayConnectionStatus.disconnected => 'DISCONNECTED',
        XrayConnectionStatus.error => 'ERROR',
      };

  /// Parses a wire status value into a typed enum.
  static XrayConnectionStatus fromWireValue(String value) {
    return switch (value.toUpperCase()) {
      'CONNECTING' => XrayConnectionStatus.connecting,
      'CONNECTED' => XrayConnectionStatus.connected,
      'DISCONNECTED' => XrayConnectionStatus.disconnected,
      'ERROR' => XrayConnectionStatus.error,
      _ => throw ArgumentError('Unsupported status value: $value'),
    };
  }
}
