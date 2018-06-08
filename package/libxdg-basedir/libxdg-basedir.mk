################################################################################
#
# libxdg-basedir
#
################################################################################

LIBXDG_BASEDIR_VERSION = 1.2.0
LIBXDG_BASEDIR_SOURCE = libxdg-basedir-$(LIBXDG_BASEDIR_VERSION).tar.gz
LIBXDG_BASEDIR_SITE = https://github.com/devnev/libxdg-basedir/archive
LIBXDG_BASEDIR_AUTORECONF = YES
LIBXDG_BASEDIR_INSTALL_STAGING = YES
LIBXDG_BASEDIR_INSTALL_STAGING_OPTS = DESTDIR=$(STAGING_DIR) LDFLAGS=-L$(STAGING_DIR)/usr/lib install
LIBXDG_BASEDIR_CONF_OPTS = --disable-dependency-tracking

$(eval $(autotools-package))

