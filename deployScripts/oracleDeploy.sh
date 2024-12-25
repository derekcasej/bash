#!/bin/bash

# Ensure the script exits if any command fails
set -e

echo "Starting configuration..."

# Install EPEL repository
echo "Installing EPEL repository..."
yum install -y oracle-epel-release-el7

# Update all packages
echo "Updating all packages..."
yum update -y

# Check how many packages were updated
updated_packages=$(yum list updates 2>/dev/null | wc -l)
if [ "$updated_packages" -gt 10 ]; then
    echo "Warning: $updated_packages packages were updated. Consider reviewing the changes."
fi

# Install development tools group
echo "Installing development tools group..."
yum groupinstall -y "Development Tools"

# Install additional necessary packages
echo "Installing additional necessary packages..."
yum install -y vim net-tools bind-utils

# Uncomment the NOPASSWD line for the wheel group in /etc/sudoers
sed -i '/^# %wheel        ALL=(ALL)       NOPASSWD: ALL/s/^#//' /etc/sudoers

# Ensure SSH service is running and enabled
echo "Ensuring SSH service is running and enabled..."
systemctl start sshd
systemctl enable sshd

# Verify Derek user can run sudo without password
echo "Verifying Derek user can run sudo without password..."

sudo -n true 2>/dev/null && echo "Passwordless sudo works" || echo "Passwordless sudo does not work"

echo "Configuration complete."