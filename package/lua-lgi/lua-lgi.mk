################################################################################
#
# lua-lgi
#
################################################################################

LUA_LGI_VERSION_UPSTREAM = 0.9.2
LUA_LGI_VERSION = $(LUA_LGI_VERSION_UPSTREAM)-1
LUA_LGI_NAME_UPSTREAM = lgi
LUA_LGI_SUBDIR = lgi
LUA_LGI_LICENSE = MIT
LUA_LGI_DEPENDENCIES = gobject-introspection cairo
LUA_LGI_BUILD_OPTS = PREFIX=$(STAGING_DIR)/usr PATH=$(HOST_DIR)/bin

#LUA_LGI_BUILD_OPTS += BAR_INCDIR=$(STAGING_DIR)/usr/include
#LUA_LGI_BUILD_OPTS += BAR_LIBDIR=$(STAGING_DIR)/usr/lib

define LUA_LGI_INSTALL_TYPELIB_FILES
	$(INSTALL) -d "$(TARGET_DIR)/usr/lib/girepository-1.0"
	$(INSTALL) -D -m 0664 \
		$(wildcard $(HOST_DIR)/usr/lib/girepository-1.0/*.typelib) \
		"$(TARGET_DIR)/usr/lib/girepository-1.0"
endef

LUA_LGI_POST_BUILD_HOOKS=LUA_LGI_INSTALL_TYPELIB_FILES

$(eval $(luarocks-package))
