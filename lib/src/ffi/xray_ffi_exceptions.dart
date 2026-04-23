/// Base exception for FFI integration failures.
class XrayFfiException implements Exception {
  final String message;
  final String? details;

  const XrayFfiException(this.message, {this.details});

  @override
  String toString() => details == null ? 'XrayFfiException: $message' : 'XrayFfiException: $message ($details)';
}

/// Thrown when the expected native artifact cannot be loaded.
class XrayNativeLibraryLoadException extends XrayFfiException {
  const XrayNativeLibraryLoadException(super.message, {super.details});
}

/// Thrown when a required symbol is missing from the loaded native artifact.
class XrayNativeSymbolException extends XrayFfiException {
  const XrayNativeSymbolException(super.message, {super.details});
}

/// Thrown when a native call reports a runtime error.
class XrayNativeCallException extends XrayFfiException {
  final int errorCode;

  const XrayNativeCallException(
    this.errorCode,
    super.message, {
    super.details,
  });
}
