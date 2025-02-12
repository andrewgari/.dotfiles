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
What=192.168.50.3:/mnt/user/$share
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

    # Ensure /mnt/unraid exists
    sudo mkdir -p /mnt/unraid

    # Define paths as associative arrays (Bash 4+)
    declare -A paths=(
        ["~/Games/unraid"]="/mnt/nfs_shares/data/media/games"
        ["~/Videos/unraid"]="/mnt/nfs_shares/data/media/videos"
        ["~/Pictures/unraid"]="/mnt/nfs_shares/data/media/photos"
        ["~/foundryvtt"]="/mnt/nfs_shares/foundryvtt"
        ["~/Vault"]="/mnt/nfs_shares/vault"
    )

    for target in "${!paths[@]}"; do
        src="${paths[$target]}"
        expanded_target=$(eval echo "$target")  # Expand ~ to absolute path

        # Ensure the target directory exists
        mkdir -p "$(dirname "$expanded_target")"

        # Check if the symlink already exists and points correctly
        if [ -L "$expanded_target" ] && [ "$(readlink -f "$expanded_target")" == "$src" ]; then
            echo "Symlink $expanded_target already exists and is correct. Skipping..."
        elif [ -e "$expanded_target" ]; then
            echo "Warning: $expanded_target exists but is not a symlink. Skipping to prevent overwriting."
        else
            echo "Creating symlink: $expanded_target → $src"
            ln -s "$src" "$expanded_target"
        fi
    done

    echo "Hardlink setup complete!"
}


setup_btrfs_optimizations() {
    echo "Setting up BTRFS optimizations..."

    # List all Btrfs mounts except /mnt
    MOUNTS=$(findmnt -t btrfs -n -o TARGET | grep -v "^/mnt$")

    for mount in $MOUNTS; do
        echo "Running maintenance on $mount..."

        echo "Defragmenting $mount..."
        sudo btrfs filesystem defragment -r "$mount"

        echo "Starting balance on $mount..."
        sudo btrfs balance start "$mount"

        echo "Starting scrub on $mount..."
        sudo btrfs scrub start "$mount"

        echo "Completed maintenance on $mount."
    done
}


setup_btrfs_snapshots() {
    echo "Setting up BTRFS snapshots..."
    HOSTNAME=$(hostname)
    SNAPSHOT_DIR="~/backups/snapshots/$HOSTNAME"
    sudo mkdir -p "$SNAPSHOT_DIR"
    sudo btrfs subvolume snapshot / "$SNAPSHOT_DIR/snapshot-$(date +%Y%m%d-%H%M%S)"
}

push_snapshots_to_unraid() {
    echo "Pushing snapshots to Unraid..."
    HOSTNAME=$(hostname)
    REMOTE_PATH="/mnt/user/vault/backup/snapshots/$HOSTNAME"
    LOCAL_PATH="~/backups/snapshots/$HOSTNAME/"
    UNRAID_SERVER="192.168.50.3"

    # Ensure the remote directory exists before syncing
    ssh $UNRAID_SERVER "mkdir -p '$REMOTE_PATH'"

    # Run rsync to transfer snapshots
    rsync -a --delete "$LOCAL_PATH" "$UNRAID_SERVER:$REMOTE_PATH/"

    echo "Snapshot push complete!"
}


setup_nfs_shares
setup_hardlinks
# setup_btrfs_optimizations
setup_btrfs_snapshots
push_snapshots_to_unraid

echo "NFS shares (systemd), hardlinks, BTRFS optimizations, and snapshots setup completed!"

