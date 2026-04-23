#ifndef FLUTTER_PLUGIN_DART_XRAY_PLUGIN_H_
#define FLUTTER_PLUGIN_DART_XRAY_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

typedef struct _DartXrayPlugin DartXrayPlugin;
typedef struct {
  GObjectClass parent_class;
} DartXrayPluginClass;

GType dart_xray_plugin_get_type();

#define DART_XRAY_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), dart_xray_plugin_get_type(), DartXrayPlugin))

void dart_xray_plugin_register_with_registrar(FlPluginRegistrar* registrar);

G_END_DECLS

#endif  // FLUTTER_PLUGIN_DART_XRAY_PLUGIN_H_
