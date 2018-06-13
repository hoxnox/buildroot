################################################################################
#
# ssh-askpass-fullscreen
#
################################################################################

SSH_ASKPASS_FULLSCREEN_VERSION = 1.1
SSH_ASKPASS_FULLSCREEN_SOURCE = ssh-askpass-fullscreen-$(SSH_ASKPASS_FULLSCREEN_VERSION).tar.bz2
SSH_ASKPASS_FULLSCREEN_SITE = https://github.com/atj/ssh-askpass-fullscreen/releases/download/v$(SSH_ASKPASS_FULLSCREEN_VERSION)
SSH_ASKPASS_FULLSCREEN_LICENSE = GPL-2.0
SSH_ASKPASS_FULLSCREEN_LICENSE_FILES = COPYING
SSH_ASKPASS_FULLSCREEN_DEPENDENCIES = libgtk-3

$(eval $(autotools-package))
