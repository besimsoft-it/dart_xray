import Flutter
import UIKit

/// iOS plugin registrar for dart_xray.
///
/// Engine control/status is FFI-backed in Dart and does not use platform channels.
public class DartXrayPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    _ = DartXrayPlugin()
  }
}
