#!/bin/bash

set -e  # Exit on error

setup_unraid() {
    echo "Setting up NFS shares using systemd..."
    sudo mkdir -p /mnt/unraid/{data,foundryvtt,vault,andrew,shared}
    
    for share in data foundryvtt vault andrew shared; do
        MOUNT_UNIT="/etc/systemd/system/mnt-unraid-${share}.mount"
        echo "Creating systemd mount unit for $share..."
        sudo bash -c "cat > $MOUNT_UNIT" <<EOF
[Unit]
Description=NFS mount for $share
After=network-online.target
Wants=network-online.target

[Mount]
What=192.168.50.3:/mnt/user/$share
Where=/mnt/unraid/$share
Type=nfs
Options=defaults,noatime,nofailt,_netdev,x-systemd.automount

[Install]
WantedBy=multi-user.target
EOF
        sudo systemctl daemon-reload
        sudo systemctl enable --now mnt-unraid-${share}.mount
    done
}

setup_hardlinks() {
    echo "Setting up hardlinks..."

    # Ensure /mnt/unraid exists
    sudo mkdir -p /mnt/unraid

    # Define paths as associative arrays (Bash 4+)
    declare -A paths=(
        ["~/Games/unraid"]="/mnt/unraid/data/media/games"
        ["~/Videos/unraid"]="/mnt/unraid/data/media/videos"
        ["~/Pictures/unraid"]="/mnt/unraid/data/media/photos"
        ["~/foundryvtt"]="/mnt/unraid/foundryvtt"
        ["~/Vault"]="/mnt/unraid/vault"
    )

    for target in "${!paths[@]}"; do
        src="${paths[$target]}"
        expanded_target=$(eval echo "$target")  # Expand ~ to absolute path

        # Ensure the target's parent directory exists
        mkdir -p "$(dirname "$expanded_target")"

        # If target exists but is not a symlink, remove it
        if [ -e "$expanded_target" ] && [ ! -L "$expanded_target" ]; then
            echo "Warning: $expanded_target exists but is not a symlink. Removing and replacing it..."
            rm -rf "$expanded_target"
        fi

        # Create symlink if it does not exist or is incorrect
        if [ -L "$expanded_target" ] && [ "$(readlink -f "$expanded_target")" == "$src" ]; then
            echo "Symlink $expanded_target already exists and is correct. Skipping..."
        else
            echo "Creating symlink: $expanded_target → $src"
            ln -s "$src" "$expanded_target"
        fi
    done

    echo "Hardlink setup complete!"
}

setup_unraid
setup_hardlinks

echo "NFS shares (systemd), hardlinks, BTRFS optimizations, and snapshots setup completed!"

