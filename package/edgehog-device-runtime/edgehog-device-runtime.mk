#
# Copyright 2022 SECO Mind Srl
#
# SPDX-License-Identifier: Apache-2.0
#

###############################################################################
#
# EDGEHOG_DEVICE_RUNTIME
#
################################################################################

EDGEHOG_DEVICE_RUNTIME_VERSION = main
EDGEHOG_DEVICE_RUNTIME_SITE = https://github.com/edgehog-device-manager/edgehog-device-runtime
EDGEHOG_DEVICE_RUNTIME_SITE_METHOD = git
EDGEHOG_DEVICE_RUNTIME_LICENSE = Apache License 2.0
EDGEHOG_DEVICE_RUNTIME_LICENSE_FILES = COPYING

EDGEHOG_DEVICE_RUNTIME_CARGO_ENV = \
HOST_CC="x86_64-linux-gnu-gcc" \
TARGET_CC="$(HOST_DIR)/bin/aarch64-linux-gcc" \
TARGET_AR="$(HOST_DIR)/bin/aarch64-linux-ar"

EDGEHOG_DEVICE_RUNTIME_CARGO_BUILD_OPTS= \
--features systemd

EDGEHOG_DEVICE_RUNTIME_CONFIG_TOML_FILE= $(TARGET_DIR)/etc/edgehog/edgehog-device-runtime-config.toml

define EDGEHOG_DEVICE_RUNTIME_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(BR2_EXTERNAL_EDGEHOG_PATH)/package/edgehog-device-runtime/edgehog-device-runtime.service \
		$(TARGET_DIR)/usr/lib/systemd/system/edgehog-device-runtime.service
endef

define EDGEHOG_DEVICE_RUNTIME_INSTALL_CONFIG_DIR
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/etc/edgehog/
	$(INSTALL) -D -m 644 $(BR2_EXTERNAL_EDGEHOG_PATH)/package/edgehog-device-runtime/edgehog-config.toml \
		$(EDGEHOG_DEVICE_RUNTIME_CONFIG_TOML_FILE)
	$(SED) 's/ASTARTE_DEVICE_ID/$(BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_DEVICE_ID)/' \
			$(EDGEHOG_DEVICE_RUNTIME_CONFIG_TOML_FILE)
	$(SED) 's/ASTARTE_PAIRING_JWT/$(BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_PAIRING_JWT)/' \
			$(EDGEHOG_DEVICE_RUNTIME_CONFIG_TOML_FILE)
	$(SED) 's|ASTARTE_PAIRING_BASE_URL|$(BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_PAIRING_BASE_URL)|' \
			$(EDGEHOG_DEVICE_RUNTIME_CONFIG_TOML_FILE)
	$(SED) 's/ASTARTE_REALM/$(BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_REALM)/' \
			$(EDGEHOG_DEVICE_RUNTIME_CONFIG_TOML_FILE)
endef

EDGEHOG_DEVICE_RUNTIME_POST_INSTALL_TARGET_HOOKS += EDGEHOG_DEVICE_RUNTIME_INSTALL_CONFIG_DIR

$(eval $(cargo-package))
