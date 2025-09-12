#
# Copyright 2022 SECO Mind Srl
#
# SPDX-License-Identifier: Apache-2.0
#

###############################################################################
#
# EDGEHOG_DEVICE_HARDWAREID_SERVICE
#
################################################################################

EDGEHOG_DEVICE_HARDWAREID_SERVICE_VERSION = v0.8.3
EDGEHOG_DEVICE_HARDWAREID_SERVICE_SITE = https://github.com/edgehog-device-manager/edgehog-device-runtime
EDGEHOG_DEVICE_HARDWAREID_SERVICE_SITE_METHOD = git
EDGEHOG_DEVICE_HARDWAREID_SERVICE_LICENSE = Apache License 2.0
EDGEHOG_DEVICE_HARDWAREID_SERVICE_LICENSE_FILES = COPYING

EDGEHOG_DEVICE_HARDWAREID_SERVICE_SUBDIR= hardware-id-service

define EDGEHOG_DEVICE_HARDWAREID_SERVICE_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(BR2_EXTERNAL_EDGEHOG_PATH)/package/edgehog-device-hardwareId-service/edgehog-device-hardwareId.service \
		$(TARGET_DIR)/usr/lib/systemd/system/edgehog-device-hardwareId.service
endef

define EDGEHOG_DEVICE_HARDWAREID_SERVICE_INSTALL_CONFIG_DIR
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/etc/dbus-1/system.d
	$(INSTALL) -D -m 0644 $(@D)/hardware-id-service/io.edgehog.Device.conf $(TARGET_DIR)/etc/dbus-1/system.d
endef

EDGEHOG_DEVICE_HARDWAREID_SERVICE_POST_INSTALL_TARGET_HOOKS += EDGEHOG_DEVICE_HARDWAREID_SERVICE_INSTALL_CONFIG_DIR

$(eval $(cargo-package))
