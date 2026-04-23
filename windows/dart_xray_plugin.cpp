#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>

namespace dart_xray {

class DartXrayPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar) {
    auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
        registrar->messenger(), "dart_xray/methods",
        &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<DartXrayPlugin>();
    channel->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result) {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  DartXrayPlugin() = default;
  ~DartXrayPlugin() override = default;

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    const auto method = method_call.method_name();
    if (method == "init" || method == "start" || method == "stop" ||
        method == "startPersistentStatusListener" || method == "stopPersistentStatusListener" ||
        method == "getServerDelay" || method == "getCurrentServerDelay") {
      result->Success();
      return;
    }
    result->NotImplemented();
  }
};

}  // namespace dart_xray

void DartXrayPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  dart_xray::DartXrayPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
