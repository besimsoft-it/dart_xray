import 'dart:async';
import 'dart:ffi';
import 'dart:convert';
import 'dart:math';

import 'package:ffi/ffi.dart';

import '../models/xray_connection_status.dart';
import '../models/xray_init_options.dart';
import '../models/xray_start_request.dart';
import 'xray_dynamic_library_loader.dart';
import 'xray_ffi_exceptions.dart';
import 'xray_native_bindings.dart';

const int _nativeErrorBufferLength = 2048;

/// FFI-backed engine client that talks directly to native libXray ABI exports.
class XrayFfiEngine {
  final XrayDynamicLibraryLoader _libraryLoader;
  final StreamController<XrayConnectionStatus> _statusController =
      StreamController<XrayConnectionStatus>.broadcast();
  final StreamController<XrayConnectionStatus> _persistentStatusController =
      StreamController<XrayConnectionStatus>.broadcast();

  DynamicLibrary? _library;
  XrayNativeBindings? _bindings;
  XrayInitOptions? _lastInitOptions;
  NativeCallable<XrayStatusCallbackDart>? _statusCallback;
  bool _persistentListening = false;

  XrayFfiEngine({XrayDynamicLibraryLoader? libraryLoader})
      : _libraryLoader = libraryLoader ?? XrayDynamicLibraryLoader();

  Stream<XrayConnectionStatus> get onStatusChanged => _statusController.stream;

  Stream<XrayConnectionStatus> get persistentStatusStream =>
      _persistentStatusController.stream;

  Future<void> init(XrayInitOptions options) async {
    _ensureBound(options);
    final payload = jsonEncode(options.toJson());
    _callJson(_bindings!.init, payload, 'init');
    _lastInitOptions = options;
    _statusController.add(XrayConnectionStatus.disconnected);
  }

  Future<void> start(XrayStartRequest request) async {
    _ensureBound(_lastInitOptions);
    final payload = jsonEncode(request.toJson());
    _statusController.add(XrayConnectionStatus.connecting);
    _callJson(_bindings!.start, payload, 'start');
  }

  Future<void> stop() async {
    _ensureBound(_lastInitOptions);
    _callNoArg(_bindings!.stop, 'stop');
    _statusController.add(XrayConnectionStatus.disconnected);
  }

  Future<Duration?> getServerDelay(String linkOrConfig) async {
    _ensureBound(_lastInitOptions);
    final ms = _callDelay(_bindings!.getServerDelay, linkOrConfig, 'getServerDelay');
    if (ms < 0) return null;
    return Duration(milliseconds: ms);
  }

  Future<Duration?> getCurrentServerDelay() async {
    _ensureBound(_lastInitOptions);
    final ms = _callDelay(_bindings!.getCurrentServerDelay, '', 'getCurrentServerDelay');
    if (ms < 0) return null;
    return Duration(milliseconds: ms);
  }

  Future<void> startPersistentStatusListener() async {
    _ensureBound(_lastInitOptions);
    if (_persistentListening) return;

    _statusCallback = NativeCallable<XrayStatusCallbackDart>.listener(
      _handleNativeStatus,
    );

    final errorBuffer = calloc<Utf8>(_nativeErrorBufferLength);
    try {
      final code = _bindings!.registerStatusCallback(
        _statusCallback!.nativeFunction,
        nullptr,
        errorBuffer,
        _nativeErrorBufferLength,
      );
      if (code != 0) {
        final message = errorBuffer.cast<Utf8>().toDartString();
        throw XrayNativeCallException(
          code,
          'registerStatusCallback failed',
          details: message,
        );
      }
      _persistentListening = true;
    } finally {
      calloc.free(errorBuffer);
    }
  }

  Future<void> stopPersistentStatusListener() async {
    if (!_persistentListening || _bindings == null) return;
    _callNoArg(_bindings!.unregisterStatusCallback, 'unregisterStatusCallback');
    _statusCallback?.close();
    _statusCallback = null;
    _persistentListening = false;
  }

  void dispose() {
    if (_bindings != null) {
      try {
        _callNoArg(_bindings!.destroy, 'destroy');
      } catch (_) {
        // Ignore teardown error during dispose.
      }
    }
    _statusCallback?.close();
    _statusController.close();
    _persistentStatusController.close();
  }

  void _ensureBound(XrayInitOptions? initOptions) {
    if (_bindings != null) return;
    _library = _libraryLoader.load(initOptions);
    _bindings = XrayNativeBindings(_library!);
  }

  int _callJson(int Function(Pointer<Utf8>, Pointer<Utf8>, int) call, String payload, String operation) {
    final payloadPtr = payload.toNativeUtf8();
    final errorBuffer = calloc<Utf8>(_nativeErrorBufferLength);
    try {
      final code = call(payloadPtr, errorBuffer, _nativeErrorBufferLength);
      if (code != 0) {
        final message = errorBuffer.cast<Utf8>().toDartString();
        throw XrayNativeCallException(code, '$operation failed', details: message);
      }
      return code;
    } finally {
      calloc.free(payloadPtr);
      calloc.free(errorBuffer);
    }
  }

  int _callNoArg(int Function(Pointer<Utf8>, int) call, String operation) {
    final errorBuffer = calloc<Utf8>(_nativeErrorBufferLength);
    try {
      final code = call(errorBuffer, _nativeErrorBufferLength);
      if (code != 0) {
        final message = errorBuffer.cast<Utf8>().toDartString();
        throw XrayNativeCallException(code, '$operation failed', details: message);
      }
      return code;
    } finally {
      calloc.free(errorBuffer);
    }
  }

  int _callDelay(int Function(Pointer<Utf8>, Pointer<Utf8>, int) call, String input, String operation) {
    final payloadPtr = input.toNativeUtf8();
    final errorBuffer = calloc<Utf8>(_nativeErrorBufferLength);
    try {
      final result = call(payloadPtr, errorBuffer, _nativeErrorBufferLength);
      if (result < -1) {
        final errorCode = max(result.toInt(), -2147483648);
        final message = errorBuffer.cast<Utf8>().toDartString();
        throw XrayNativeCallException(errorCode, '$operation failed', details: message);
      }
      return result;
    } finally {
      calloc.free(payloadPtr);
      calloc.free(errorBuffer);
    }
  }

  void _handleNativeStatus(int statusCode, Pointer<Utf8> message, Pointer<Void> userData) {
    final status = switch (statusCode) {
      0 => XrayConnectionStatus.connecting,
      1 => XrayConnectionStatus.connected,
      2 => XrayConnectionStatus.disconnected,
      _ => XrayConnectionStatus.error,
    };
    _statusController.add(status);
    if (_persistentListening) {
      _persistentStatusController.add(status);
    }
  }
}
