#
# Copyright 2022 SECO Mind Srl
#
# SPDX-License-Identifier: Apache-2.0
#

###############################################################################
#
# EDGEHOG_ASTARTE_INTERFACE
#
################################################################################

EDGEHOG_ASTARTE_INTERFACE_VERSION = v0.8.0
EDGEHOG_ASTARTE_INTERFACE_SITE = https://github.com/edgehog-device-manager/edgehog-astarte-interfaces
EDGEHOG_ASTARTE_INTERFACE_SITE_METHOD = git
EDGEHOG_ASTARTE_INTERFACE_LICENSE = Apache License 2.0
EDGEHOG_ASTARTE_INTERFACE_LICENSE_FILES = COPYING

define EDGEHOG_ASTARTE_INTERFACE_INSTALL_TARGET_CMDS
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/usr/share/edgehog-astarte-interfaces
	$(INSTALL) -D -m 0644 $(@D)/*.json $(TARGET_DIR)/usr/share/edgehog-astarte-interfaces
endef

$(eval $(generic-package))
