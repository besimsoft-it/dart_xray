/// Global options used to initialize the native Xray runtime.
class XrayInitOptions {
  /// Directory where runtime artifacts and logs can be written.
  final String workingDirectory;

  /// Enables verbose logging in native layers when true.
  final bool enableDebugLogs;

  /// Optional app group identifier for Apple Network Extension setups.
  final String? appleAppGroup;

  /// Optional path to platform-specific assets/binaries.
  final String? nativeAssetsPath;

  const XrayInitOptions({
    required this.workingDirectory,
    this.enableDebugLogs = false,
    this.appleAppGroup,
    this.nativeAssetsPath,
  });

  /// Converts options to a JSON map consumed by the native ABI layer.
  Map<String, Object?> toJson() => <String, Object?>{
        'workingDirectory': workingDirectory,
        'enableDebugLogs': enableDebugLogs,
        'appleAppGroup': appleAppGroup,
        'nativeAssetsPath': nativeAssetsPath,
      };
}
