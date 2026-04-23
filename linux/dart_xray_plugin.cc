#include "include/dart_xray/dart_xray_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

struct _DartXrayPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(DartXrayPlugin, dart_xray_plugin, g_object_get_type())

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
  (void)registrar;
  g_object_unref(plugin);
}
