#!/bin/bash

set -e  # Exit on error

setup_nfs_shares() {
    echo "Setting up NFS shares using systemd..."
    sudo mkdir -p /mnt/nfs_shares/{data,foundryvtt,vault,andrew,shared}
    
    for share in data foundryvtt vault andrew shared; do
        MOUNT_UNIT="/etc/systemd/system/mnt-nfs_shares-${share}.mount"
        echo "Creating systemd mount unit for $share..."
        sudo bash -c "cat > $MOUNT_UNIT" <<EOF
[Unit]
Description=NFS mount for $share
After=network.target

[Mount]
What=192.169.50.3:/mnt/user/$share
Where=/mnt/nfs_shares/$share
Type=nfs
Options=defaults

[Install]
WantedBy=multi-user.target
EOF
        sudo systemctl daemon-reload
        sudo systemctl enable --now mnt-nfs_shares-${share}.mount
    done
}

setup_hardlinks() {
    echo "Setting up hardlinks..."
    sudo mkdir -p /mnt/unraid
    ln -s /mnt/user/data/games /mnt/unraid/games
    ln -s /mnt/user/data/videos /mnt/unraid/videos
    ln -s /mnt/user/data/photos /mnt/unraid/photos
    ln -s /mnt/user/data/games/emulation /mnt/unraid/emulation
}

setup_btrfs_optimizations() {
    echo "Setting up BTRFS optimizations..."
    sudo btrfs filesystem defragment -r /mnt/unraid
    sudo btrfs balance start /mnt/unraid
    sudo btrfs scrub start /mnt/unraid
}

setup_btrfs_snapshots() {
    echo "Setting up BTRFS snapshots..."
    HOSTNAME=$(hostname)
    SNAPSHOT_DIR="/mnt/unraid/vault/backup/snapshots/$HOSTNAME"
    sudo mkdir -p "$SNAPSHOT_DIR"
    sudo btrfs subvolume snapshot /mnt/unraid "$SNAPSHOT_DIR/snapshot-$(date +%Y%m%d-%H%M%S)"
}

push_snapshots_to_unraid() {
    echo "Pushing snapshots to Unraid..."
    HOSTNAME=$(hostname)
    rsync -a --delete /mnt/unraid/vault/backup/snapshots/$HOSTNAME/ 192.169.50.3:/mnt/user/snapshots/$HOSTNAME/
}

setup_nfs_shares
setup_hardlinks
setup_btrfs_optimizations
setup_btrfs_snapshots
push_snapshots_to_unraid

echo "NFS shares (systemd), hardlinks, BTRFS optimizations, and snapshots setup completed!"

