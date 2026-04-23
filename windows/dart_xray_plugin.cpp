#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace dart_xray {

class DartXrayPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar) {
    registrar->AddPlugin(std::make_unique<DartXrayPlugin>());
  }

  DartXrayPlugin() = default;
  ~DartXrayPlugin() override = default;
};

}  // namespace dart_xray

void DartXrayPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  dart_xray::DartXrayPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
