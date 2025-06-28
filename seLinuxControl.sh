#!/bin/bash

# SELinux Control Script
# Usage: ./selinux-control.sh [on|off]

# Set the action - change this to "on" or "off"
ACTION="off"

# Override with command line argument if provided
if [ $# -eq 1 ]; then
    ACTION="$1"
fi

# Validate input
if [[ "$ACTION" != "on" && "$ACTION" != "off" ]]; then
    echo "Error: Invalid argument. Use 'on' or 'off'"
    echo "Usage: $0 [on|off]"
    echo "Or edit the script and change ACTION variable to 'on' or 'off'"
    exit 1
fi

echo "=== Current SELinux Status ==="
getenforce
sestatus

echo ""
echo "=== Setting SELinux to: $ACTION ==="

if [ "$ACTION" = "off" ]; then
    # Disable SELinux
    echo "Disabling SELinux..."
    sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config
    sed -i 's/^SELINUX=permissive$/SELINUX=disabled/' /etc/selinux/config
    
    # Verify the change
    echo "Config file now shows:"
    grep "^SELINUX=" /etc/selinux/config
    
    # Temporary disable for current session
    if [ "$(getenforce)" != "Disabled" ]; then
        echo "Temporarily disabling for current session..."
        setenforce 0
    fi
    
    echo ""
    echo "=== Summary ==="
    echo "✓ SELinux config changed to disabled"
    echo "✓ Temporarily disabled for current session"
    echo "⚠ REBOOT REQUIRED to make permanent"
    echo "After reboot: getenforce should show 'Disabled'"
    
elif [ "$ACTION" = "on" ]; then
    # Enable SELinux
    echo "Enabling SELinux..."
    sed -i 's/^SELINUX=disabled$/SELINUX=enforcing/' /etc/selinux/config
    
    # Verify the change
    echo "Config file now shows:"
    grep "^SELINUX=" /etc/selinux/config
    
    # Can't enable SELinux without reboot if it was disabled
    if [ "$(getenforce)" = "Disabled" ]; then
        echo "⚠ Cannot enable SELinux in current session when fully disabled"
        echo "⚠ REBOOT REQUIRED to enable SELinux"
    else
        echo "Enabling SELinux for current session..."
        setenforce 1
    fi
    
    echo ""
    echo "=== Summary ==="
    echo "✓ SELinux config changed to enforcing"
    echo "⚠ REBOOT REQUIRED to make permanent"
    echo "After reboot: getenforce should show 'Enforcing'"
fi

echo ""
echo "Current status after changes:"
getenforce
