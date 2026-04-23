import Cocoa
import FlutterMacOS

/// macOS bridge for dart_xray.
public class DartXrayPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let methods = FlutterMethodChannel(name: "dart_xray/methods", binaryMessenger: registrar.messenger)
    let instance = DartXrayPlugin()
    registrar.addMethodCallDelegate(instance, channel: methods)

    let status = FlutterEventChannel(name: "dart_xray/status", binaryMessenger: registrar.messenger)
    status.setStreamHandler(StatusHandler())

    let persistent = FlutterEventChannel(name: "dart_xray/persistent_status", binaryMessenger: registrar.messenger)
    persistent.setStreamHandler(StatusHandler())
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "init", "start", "stop", "startPersistentStatusListener", "stopPersistentStatusListener":
      result(nil)
    case "getServerDelay", "getCurrentServerDelay":
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

private final class StatusHandler: NSObject, FlutterStreamHandler {
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    events("DISCONNECTED")
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    return nil
  }
}
