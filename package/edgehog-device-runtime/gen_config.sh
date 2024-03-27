#!/usr/bin/env bash

set -exEuo pipefail

EDGEHOG_DEVICE_RUNTIME_CONFIG_TOML_FILE="$1"
EDGEHOG_DEVICE_RUNTIME_ASTARTE_LIBRARY="$2"
BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_DEVICE_ID="$3"
BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_PAIRING_BASE_URL="$4"
BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_REALM="$5"
BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_IGNORE_SSL="$6"
BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_CREDENTIAL_SECRET="${7:-}"
BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_PAIRING_JWT="${8:-}"
BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_MESSAGE_HUB_ENDPOINT="${9:-}"

config_device_sdk() {
    local device_id="$1"
    local pairing_url="$2"
    local realm="$3"
    local ignore_ssl="$4"

    if [ "$ignore_ssl" = 'y' ]; then
        ignore_ssl='true'
    else
        ignore_ssl='false'
    fi

    cat <<-EOF

[astarte_device_sdk]
device_id = "$device_id"
pairing_url = "$pairing_url"
realm = "$realm"
ignore_ssl = $ignore_ssl
EOF

    # Optional
    local credentials_secret="$5"
    local pairing_token="$6"

    if [[ -n $credentials_secret ]]; then
        echo "credentials_secret = \"$credentials_secret\""
    elif [[ -n $pairing_token ]]; then
        echo "pairing_token = \"$pairing_token\""
    else
        >&2 echo "No credential secret nor pairing token"
        exit 1
    fi
}

config_message_hub() {
    local endpoint="$1"

    cat <<-EOF
[astarte_message_hub]
endpoint = "$endpoint"
EOF
}

if [ "$EDGEHOG_DEVICE_RUNTIME_ASTARTE_LIBRARY" = "astarte-device-sdk" ]; then
    config=$(config_device_sdk \
        "$BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_DEVICE_ID" \
        "$BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_PAIRING_BASE_URL" \
        "$BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_REALM" \
        "$BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_IGNORE_SSL" \
        "$BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_CREDENTIAL_SECRET" \
        "$BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_PAIRING_JWT")
elif [ "$EDGEHOG_DEVICE_RUNTIME_ASTARTE_LIBRARY" = "astarte-message-hub" ]; then
    config=$(config_message_hub \
        "$BR2_PACKAGE_EDGEHOG_DEVICE_RUNTIME_ASTARTE_MESSAGE_HUB_ENDPOINT")
else
    >&2 echo "unrecognized library $EDGEHOG_DEVICE_RUNTIME_ASTARTE_LIBRARY"
    exit 1
fi

cat >"$EDGEHOG_DEVICE_RUNTIME_CONFIG_TOML_FILE" <<-EOF
#
# Copyright 2022-2024 SECO Mind Srl
#
# SPDX-License-Identifier: Apache-2.0
#

astarte_library = "$EDGEHOG_DEVICE_RUNTIME_ASTARTE_LIBRARY"
interfaces_directory = "/usr/share/edgehog-astarte-interfaces"
store_directory = "/var/lib/edgehog-device-runtime/"
download_directory = "/var/tmp/"

$config

[[telemetry_config]]
interface_name = "io.edgehog.devicemanager.SystemStatus"
enabled = true
period = 60
EOF

chmod 644 "$EDGEHOG_DEVICE_RUNTIME_CONFIG_TOML_FILE"
