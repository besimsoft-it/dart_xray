import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'xray_ffi_exceptions.dart';

typedef XrayStatusCallbackNative = Void Function(Int32, Pointer<Utf8>, Pointer<Void>);
typedef XrayStatusCallbackDart = void Function(int, Pointer<Utf8>, Pointer<Void>);

typedef _CallJsonNative = Int32 Function(Pointer<Utf8>, Pointer<Utf8>, Int32);
typedef _CallJsonDart = int Function(Pointer<Utf8>, Pointer<Utf8>, int);

typedef _CallNoArgNative = Int32 Function(Pointer<Utf8>, Int32);
typedef _CallNoArgDart = int Function(Pointer<Utf8>, int);

typedef _CallDelayNative = Int64 Function(Pointer<Utf8>, Pointer<Utf8>, Int32);
typedef _CallDelayDart = int Function(Pointer<Utf8>, Pointer<Utf8>, int);

typedef _RegisterStatusNative = Int32 Function(Pointer<NativeFunction<XrayStatusCallbackNative>>, Pointer<Void>, Pointer<Utf8>, Int32);
typedef _RegisterStatusDart = int Function(Pointer<NativeFunction<XrayStatusCallbackNative>>, Pointer<Void>, Pointer<Utf8>, int);

/// Low-level lookup table for the stable C ABI exported by native artifacts.
class XrayNativeBindings {
  final _CallJsonDart init;
  final _CallJsonDart start;
  final _CallNoArgDart stop;
  final _CallNoArgDart destroy;
  final _CallDelayDart getServerDelay;
  final _CallDelayDart getCurrentServerDelay;
  final _RegisterStatusDart registerStatusCallback;
  final _CallNoArgDart unregisterStatusCallback;

  XrayNativeBindings._({
    required this.init,
    required this.start,
    required this.stop,
    required this.destroy,
    required this.getServerDelay,
    required this.getCurrentServerDelay,
    required this.registerStatusCallback,
    required this.unregisterStatusCallback,
  });

  factory XrayNativeBindings(DynamicLibrary library) {
    T lookup<T extends Function>(String symbol, T Function(Pointer<NativeFunction<Void Function()>>) cast) {
      try {
        final raw = library.lookup<NativeFunction<Void Function()>>(symbol);
        return cast(raw);
      } catch (error) {
        throw XrayNativeSymbolException(
          'Missing required symbol: $symbol',
          details: '$error',
        );
      }
    }

    return XrayNativeBindings._(
      init: lookup('dart_xray_init', (raw) => raw.cast<NativeFunction<_CallJsonNative>>().asFunction<_CallJsonDart>()),
      start: lookup('dart_xray_start', (raw) => raw.cast<NativeFunction<_CallJsonNative>>().asFunction<_CallJsonDart>()),
      stop: lookup('dart_xray_stop', (raw) => raw.cast<NativeFunction<_CallNoArgNative>>().asFunction<_CallNoArgDart>()),
      destroy: lookup('dart_xray_destroy', (raw) => raw.cast<NativeFunction<_CallNoArgNative>>().asFunction<_CallNoArgDart>()),
      getServerDelay: lookup('dart_xray_get_server_delay', (raw) => raw.cast<NativeFunction<_CallDelayNative>>().asFunction<_CallDelayDart>()),
      getCurrentServerDelay: lookup('dart_xray_get_current_server_delay', (raw) => raw.cast<NativeFunction<_CallDelayNative>>().asFunction<_CallDelayDart>()),
      registerStatusCallback: lookup('dart_xray_register_status_callback', (raw) => raw.cast<NativeFunction<_RegisterStatusNative>>().asFunction<_RegisterStatusDart>()),
      unregisterStatusCallback: lookup('dart_xray_unregister_status_callback', (raw) => raw.cast<NativeFunction<_CallNoArgNative>>().asFunction<_CallNoArgDart>()),
    );
  }
}
