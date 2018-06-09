################################################################################
#
# vicious
#
################################################################################

VICIOUS_VERSION = 2.3.1
VICIOUS_SOURCE = v$(VICIOUS_VERSION).tar.gz
VICIOUS_SITE = https://github.com/Mic92/vicious/archive
VICIOUS_LICENSE = GPL-2.0
VICIOUS_LICENSE_FILES = LICENSE
VICIOUS_DEPENDENCIES = awesomewm

define VICIOUS_INSTALL_TARGET_CMDS
	$(INSTALL) -d "$(TARGET_DIR)/usr/share/awesome/lib/vicious/widgets"
	$(INSTALL) -D -m 0664 \
		$(wildcard $(@D)/widgets/*.lua) \
		"$(TARGET_DIR)/usr/share/awesome/lib/vicious/widgets"
    $(INSTALL) -D -m 0644 $(@D)/helpers.lua $(@D)/init.lua  $(TARGET_DIR)/usr/share/awesome/lib/vicious
endef

$(eval $(generic-package))
