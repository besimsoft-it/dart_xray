#include "include/dart_xray/dart_xray_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

struct _DartXrayPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(DartXrayPlugin, dart_xray_plugin, g_object_get_type())

static void dart_xray_plugin_handle_method_call(
    DartXrayPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;
  const gchar* method = fl_method_call_get_name(method_call);

  if (g_strcmp0(method, "init") == 0 ||
      g_strcmp0(method, "start") == 0 ||
      g_strcmp0(method, "stop") == 0 ||
      g_strcmp0(method, "startPersistentStatusListener") == 0 ||
      g_strcmp0(method, "stopPersistentStatusListener") == 0 ||
      g_strcmp0(method, "getServerDelay") == 0 ||
      g_strcmp0(method, "getCurrentServerDelay") == 0) {
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void dart_xray_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(dart_xray_plugin_parent_class)->dispose(object);
}

static void dart_xray_plugin_class_init(DartXrayPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = dart_xray_plugin_dispose;
}

static void dart_xray_plugin_init(DartXrayPlugin* self) {}

void dart_xray_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  DartXrayPlugin* plugin = DART_XRAY_PLUGIN(
      g_object_new(dart_xray_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
      fl_plugin_registrar_get_messenger(registrar),
      "dart_xray/methods",
      FL_METHOD_CODEC(codec));

  fl_method_channel_set_method_call_handler(channel,
      [](FlMethodChannel* channel, FlMethodCall* method_call, gpointer user_data) {
        dart_xray_plugin_handle_method_call(DART_XRAY_PLUGIN(user_data), method_call);
      },
      g_object_ref(plugin),
      g_object_unref);

  g_object_unref(plugin);
}
