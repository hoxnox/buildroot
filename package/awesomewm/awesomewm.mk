################################################################################
#
# awesomewm
#
################################################################################

AWESOMEWM_VERSION = 4.2
AWESOMEWM_SOURCE = awesome-$(AWESOMEWM_VERSION).tar.bz2
AWESOMEWM_SITE = https://github.com/awesomeWM/awesome-releases/raw/master
AWESOMEWM_INSTALL_STAGING = NO
AWESOMEWM_INSTALL_TARGET = YES
AWESOMEWM_SUPPORTS_IN_SOURCE_BUILD = NO
AWESOMEWM_DEPENDENCIES += \
    luajit \
    libxcb \
    libglib2 \
    gdk-pixbuf \
    cairo \
    pango \
    xcb-util-cursor \
    xcb-util-keysyms \
    xcb-util-wm \
    xcb-util-xrm \
    libxkbcommon \
    startup-notification \
    libxdg-basedir \
    lua-lgi
AWESOMEWM_CONF_OPTS = -DLUA_INCLUDE_DIR=$(TARGET_DIR)/usr/include -DLUA_LIBRARY=$(TARGET_DIR)/usr/lib/libluajit-5.1.so.2.0.5 -DGENERATE_DOCS=OFF
#AWESOMEWM_DEPENDENCIES = libglib2 host-pkgconf

define AWESOMEWM_FIX_LUAWRAPPER_PATHS
	$(SED) "s|@TARGET_DIR|$(TARGET_DIR)|g" $(@D)/build-utils/luawrapper.sh
endef
AWESOMEWM_POST_PATCH_HOOKS=AWESOMEWM_FIX_LUAWRAPPER_PATHS


$(eval $(cmake-package))
