################################################################################
#
# xkb-switch
#
################################################################################

XKB_SWITCH_VERSION = 1.5.0
XKB_SWITCH_SOURCE = $(XKB_SWITCH_VERSION).tar.gz
XKB_SWITCH_SITE = https://github.com/ierton/xkb-switch/archive
XKB_SWITCH_LICENSE = GPL-2.0
XKB_SWITCH_LICENSE_FILES = COPYING

$(eval $(cmake-package))
