#!/bin/bash

# Function to backup existing Nextcloud installation
backup_existing_nextcloud() {
    local backup_dir="/root"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_filename="nextcloud_backup_${timestamp}.tar.gz"
    local backup_path="${backup_dir}/${backup_filename}"
    
    echo "Creating backup of existing Nextcloud installation..."
    echo "Backup location: ${backup_path}"
    
    # Create tar.gz backup
    if tar -czf "$backup_path" -C /var/www/html nextcloud/; then
        echo "✓ Backup created successfully: ${backup_path}"
        
        # Remove the original directory
        echo "Removing original Nextcloud directory..."
        rm -rf /var/www/html/nextcloud/
        echo "✓ Original directory removed"
        return 0
    else
        echo "✗ Failed to create backup!"
        return 1
    fi
}

# Check if Nextcloud directory already exists
if [ -d "/var/www/html/nextcloud" ]; then
    echo "Warning: Nextcloud directory already exists at /var/www/html/nextcloud/"
    echo -n "Do you want to backup the existing installation before proceeding? (y/N): "
    read -r response
    
    case "$response" in
        [yY]|[yY][eE][sS])
            if backup_existing_nextcloud; then
                echo "Proceeding with new installation..."
            else
                echo "Backup failed. Aborting installation."
                exit 1
            fi
            ;;
        *)
            echo "Skipping backup. The existing directory will be overwritten."
            echo -n "Are you sure you want to continue? (y/N): "
            read -r confirm
            case "$confirm" in
                [yY]|[yY][eE][sS])
                    echo "Proceeding without backup..."
                    rm -rf /var/www/html/nextcloud/
                    ;;
                *)
                    echo "Installation aborted."
                    exit 0
                    ;;
            esac
            ;;
    esac
fi

# Extract Nextcloud directly to /var/www/html/
# This will create /var/www/html/nextcloud/
echo "Extracting Nextcloud..."
tar -xjf nextcloud-31.0.4.tar.bz2 -C /var/www/html/

# Verify extraction
echo "Verifying extraction..."
ls -la /var/www/html/nextcloud/

# Set proper ownership (assuming apache/nginx user)
echo "Setting proper ownership and permissions..."
# For Apache:
chown -R apache:apache /var/www/html/nextcloud/
# For Nginx (if using nginx user):
# chown -R nginx:nginx /var/www/html/nextcloud/

# Set proper permissions
find /var/www/html/nextcloud/ -type d -exec chmod 755 {} \;
find /var/www/html/nextcloud/ -type f -exec chmod 644 {} \;

# Make the occ command executable
chmod +x /var/www/html/nextcloud/occ

# Set special permissions for data directory (if it exists)
if [ -d "/var/www/html/nextcloud/data" ]; then
    chmod 770 /var/www/html/nextcloud/data
fi

echo "✓ Nextcloud extracted to: /var/www/html/nextcloud/"
echo ""
echo "Next steps:"
echo "1. Configure your web server to point to /var/www/html/nextcloud/"
echo "2. Run the Nextcloud setup wizard via web browser"
