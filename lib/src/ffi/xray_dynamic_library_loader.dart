import 'dart:ffi';
import 'dart:io';

import '../models/xray_init_options.dart';
import 'xray_ffi_exceptions.dart';

/// Resolves and loads the libXray ABI library used by Dart FFI.
class XrayDynamicLibraryLoader {
  static const String environmentOverride = 'DART_XRAY_LIB_PATH';

  DynamicLibrary load(XrayInitOptions? initOptions) {
    final override = Platform.environment[environmentOverride];
    final candidates = <String>{
      if (override != null && override.trim().isNotEmpty) override.trim(),
      ..._candidatesFromInit(initOptions),
      ..._defaultNames(),
    }.toList();

    Object? lastError;
    for (final candidate in candidates) {
      try {
        if (candidate == '@process') {
          return DynamicLibrary.process();
        }
        return DynamicLibrary.open(candidate);
      } catch (error) {
        lastError = error;
      }
    }

    throw XrayNativeLibraryLoadException(
      'Unable to load native dart_xray ABI library.',
      details: 'Tried: ${candidates.join(', ')}. Last error: $lastError',
    );
  }

  Iterable<String> _candidatesFromInit(XrayInitOptions? options) sync* {
    final basePath = options?.nativeAssetsPath;
    if (basePath == null || basePath.isEmpty) return;
    for (final name in _defaultNames().where((name) => name != '@process')) {
      yield '$basePath${Platform.pathSeparator}$name';
    }
  }

  Iterable<String> _defaultNames() sync* {
    if (Platform.isAndroid || Platform.isLinux) {
      yield 'libgojni.so';
      return;
    }
    if (Platform.isWindows) {
      yield 'dart_xray_ffi.dll';
      return;
    }
    if (Platform.isMacOS || Platform.isIOS) {
      yield '@process';
      yield 'dart_xray_ffi.framework/dart_xray_ffi';
      yield 'libdart_xray_ffi.dylib';
      return;
    }

    throw XrayNativeLibraryLoadException(
      'Unsupported platform for dart_xray FFI.',
      details: Platform.operatingSystem,
    );
  }
}
