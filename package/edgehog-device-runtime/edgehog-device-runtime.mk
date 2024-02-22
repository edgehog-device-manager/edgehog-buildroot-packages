#
# Copyright 2022-2024 SECO Mind Srl
#
# SPDX-License-Identifier: Apache-2.0
#

###############################################################################
#
# EDGEHOG_DEVICE_RUNTIME
#
################################################################################

EDGEHOG_DEVICE_RUNTIME_VERSION = v0.7.1
EDGEHOG_DEVICE_RUNTIME_SITE = https://github.com/edgehog-device-manager/edgehog-device-runtime
EDGEHOG_DEVICE_RUNTIME_SITE_METHOD = git
EDGEHOG_DEVICE_RUNTIME_LICENSE = Apache License 2.0
EDGEHOG_DEVICE_RUNTIME_LICENSE_FILES = COPYING
EDGEHOG_DEVICE_RUNTIME_DEPENDENCIES = host-sqlite

EDGEHOG_DEVICE_RUNTIME_CARGO_ENV = \
HOST_CC="$(HOSTCC)"

EDGEHOG_DEVICE_RUNTIME_FEATURES = systemd

ifeq ($(BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_FORWARDER), y)
EDGEHOG_DEVICE_RUNTIME_FEATURES += forwarder
endif

EDGEHOG_DEVICE_RUNTIME_CARGO_BUILD_OPTS= \
--features "$(EDGEHOG_DEVICE_RUNTIME_FEATURES)"

EDGEHOG_DEVICE_RUNTIME_CARGO_INSTALL_OPTS= \
--features "$(EDGEHOG_DEVICE_RUNTIME_FEATURES)"

EDGEHOG_DEVICE_RUNTIME_CONFIG_TOML_FILE= $(TARGET_DIR)/etc/edgehog/edgehog-device-runtime-config.toml
EDGEHOG_DEVICE_RUNTIME_SERVICE= $(TARGET_DIR)/usr/lib/systemd/system/edgehog-device-runtime.service
EDGEHOG_DEVICE_RUNTIME_TTYD_SERVICE= $(TARGET_DIR)/usr/lib/systemd/system/ttyd.service

define EDGEHOG_DEVICE_RUNTIME_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(BR2_EXTERNAL_EDGEHOG_PATH)/package/edgehog-device-runtime/edgehog-device-runtime.service \
		$(EDGEHOG_DEVICE_RUNTIME_SERVICE)
	@if [ '$(BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_FORWARDER)' = 'y' ]; then \
		$(INSTALL) -D -m 644 $(BR2_EXTERNAL_EDGEHOG_PATH)/package/edgehog-device-runtime/ttyd.service \
			$(EDGEHOG_DEVICE_RUNTIME_TTYD_SERVICE); \
		$(SED) 's/TTYD_COMMAND/$(BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_FORWARDER_COMMAND)/' \
			$(EDGEHOG_DEVICE_RUNTIME_TTYD_SERVICE); \
	fi
endef

ifeq ($(BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_LIBRARY_ASTARTE_MESSAGE_HUB), y)
EDGEHOG_DEVICE_RUNTIME_ASTARTE_LIBRARY = "astarte-message-hub"
else
EDGEHOG_DEVICE_RUNTIME_ASTARTE_LIBRARY = "astarte-device-sdk"
endif

define EDGEHOG_DEVICE_RUNTIME_INSTALL_CONFIG_DIR
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/etc/edgehog/

	$(BR2_EXTERNAL_EDGEHOG_PATH)/package/edgehog-device-runtime/gen_config.sh \
		$(EDGEHOG_DEVICE_RUNTIME_CONFIG_TOML_FILE) \
		$(EDGEHOG_DEVICE_RUNTIME_ASTARTE_LIBRARY) \
		$(BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_DEVICE_ID) \
		$(BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_PAIRING_BASE_URL) \
		$(BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_REALM) \
		$(BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_IGNORE_SSL) \
		$(BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_CREDENTIAL_SECRET) \
		$(BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_PAIRING_JWT) \
		$(BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_MESSAGE_HUB_ENDPOINT)

	$(SED) 's/EDGEHOG_SERIAL_NUMBER/$(BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_SERIAL_NUMBER)/' \
		$(EDGEHOG_DEVICE_RUNTIME_SERVICE)
	$(SED) 's/EDGEHOG_PART_NUMBER/$(BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_PART_NUMBER)/' \
		$(EDGEHOG_DEVICE_RUNTIME_SERVICE)
	@if [ -n '$(BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_IMAGE_VERSION)' ]; then \
		$(SED) '/IMAGE_ID/d' $(TARGET_DIR)/etc/os-release; \
		echo 'IMAGE_ID=$(BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_IMAGE_VERSION)' >> $(TARGET_DIR)/etc/os-release ; \
	fi
endef

EDGEHOG_DEVICE_RUNTIME_POST_INSTALL_TARGET_HOOKS += EDGEHOG_DEVICE_RUNTIME_INSTALL_CONFIG_DIR

$(eval $(cargo-package))
