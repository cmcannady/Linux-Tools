#!/bin/bash
###########################################################################
#
#     COPYRIGHT (C) 2025
#
###########################################################################
#
#     Author:  Casey Cannady - me@caseycannady.com
#
###########################################################################
#
#     Script:  update.sh
#     Version: 1.10
#     Created: 02/13/2024
#     Updated: 01/21/2025
#
###########################################################################

#
# _function: Get Installed Version of Ollama
#
get_installed_version() {
    local version
    version=$(ollama --version 2>/dev/null | cut -d' ' -f3)
    if [[ -n "$version" ]]; then
        echo "$version"
    else
        echo "not_installed"
    fi
}

#
# _function: Get Ollama Version
#
get_latest_version() {
    local version
    version=$(curl -s "https://api.github.com/repos/ollama/ollama/releases/latest" | \
             grep '"tag_name":' | \
             sed -E 's/.*"([^"]+)".*/\1/')
    echo "$version"
}

#
# _function: Version Compare
#
version_compare() {
    test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"
}

#
# Let's get started!
#
echo " "
echo "[*** STARTING | update.sh | `date` ***]"

#
# Run all APT commands for system updates.
#
echo " "
echo "Executing all APT update commands"
systemctl daemon-reload
apt-get update --fix-missing
apt-get full-upgrade -y --fix-missing
apt-get dist-upgrade -y --fix-missing
apt-get clean
apt-get autoremove

#
# Update all SNAP installs.
#
echo " "
echo "Updating all SNAPs"
killall snap-store
snap refresh

#
# Update ollama version to latest IF its installed.
#
INSTALLED_VERSION=$(get_installed_version)
LATEST_VERSION=$(get_latest_version)

if [ "$INSTALLED_VERSION" = "not_installed" ]; then
    echo "Ollama is not installed on this system"
elif version_compare "$INSTALLED_VERSION" "$LATEST_VERSION"; then
    echo "Ollama version $INSTALLED_VERSION meets minimum requirement of $LATEST_VERSION"
else
    echo "Ollama version $INSTALLED_VERSION needs to be updated to $LATEST_VERSION"
    curl -fsSL https://ollama.com/install.sh | sh;
fi

#
# Update local models IF ollama is installed.
#
if [ "$INSTALLED_VERSION" != "not_installed" ]; then
    ollama list | tail -n +2 | awk '{print $1}' | xargs -I {} ollama pull {};
fi

#
# Check if reboot is required and notify user.
#
echo " ";
if [ -f /var/run/reboot-required ] 
then
    echo "[*** Attention $USER: you must reboot your machine ***]"
else
    echo "[*** Attention $USER: your device has been updated ***]"
fi

#
# We're done!
#
echo " "
echo "[*** FINISHED | update.sh | `date` ***]"
echo " "
exit
