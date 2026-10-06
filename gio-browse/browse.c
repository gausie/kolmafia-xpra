// Java only offers Desktop.browse() when GIO's default VFS claims http, which normally means
// gvfs, its daemons and a session bus. This VFS claims it and hands everything to the local VFS;
// actually opening a URL goes through the default x-scheme-handler, not the VFS.
#include <gio/gio.h>

typedef GVfs BrowseVfs;
typedef GVfsClass BrowseVfsClass;

G_DEFINE_DYNAMIC_TYPE(BrowseVfs, browse_vfs, G_TYPE_VFS)

static const gchar *const schemes[] = {"file", "http", "https", NULL};

static gboolean is_active(GVfs *vfs) { return TRUE; }

static GFile *get_file_for_path(GVfs *vfs, const char *path) {
  return g_vfs_get_file_for_path(g_vfs_get_local(), path);
}

static GFile *get_file_for_uri(GVfs *vfs, const char *uri) {
  return g_vfs_get_file_for_uri(g_vfs_get_local(), uri);
}

static GFile *parse_name(GVfs *vfs, const char *name) {
  return g_vfs_parse_name(g_vfs_get_local(), name);
}

static const gchar *const *get_supported_uri_schemes(GVfs *vfs) { return schemes; }

static void browse_vfs_init(BrowseVfs *vfs) {}
static void browse_vfs_class_finalize(BrowseVfsClass *klass) {}

static void browse_vfs_class_init(BrowseVfsClass *klass) {
  klass->is_active = is_active;
  klass->get_file_for_path = get_file_for_path;
  klass->get_file_for_uri = get_file_for_uri;
  klass->parse_name = parse_name;
  klass->get_supported_uri_schemes = get_supported_uri_schemes;
}

void g_io_module_load(GIOModule *module) {
  browse_vfs_register_type(G_TYPE_MODULE(module));
  g_io_extension_point_implement(G_VFS_EXTENSION_POINT_NAME, browse_vfs_get_type(), "browse", 20);
}

void g_io_module_unload(GIOModule *module) {}

char **g_io_module_query(void) {
  char *eps[] = {G_VFS_EXTENSION_POINT_NAME, NULL};
  return g_strdupv(eps);
}
