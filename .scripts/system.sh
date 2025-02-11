#!/bin/bash

set -e  # Exit on error

echo "Starting system maintenance..."

# Update system packages
update_system() {
    echo "Updating system packages..."
    if command -v dnf &> /dev/null; then
        sudo dnf upgrade -y
    elif command -v apt &> /dev/null; then
        sudo apt update && sudo apt upgrade -y
    elif command -v pacman &> /dev/null; then
        sudo pacman -Syu --noconfirm
    else
        echo "Unsupported package manager. Skipping updates."
    fi
}

# Clean up orphaned and unused packages
cleanup_system() {
    echo "Cleaning up orphaned and unused packages..."
    if command -v dnf &> /dev/null; then
        sudo dnf autoremove -y
        sudo dnf clean all
    elif command -v apt &> /dev/null; then
        sudo apt autoremove -y
        sudo apt autoclean -y
    elif command -v pacman &> /dev/null; then
        sudo pacman -Rns $(pacman -Qdtq) --noconfirm || true
        sudo pacman -Sc --noconfirm
    else
        echo "Unsupported package manager. Skipping cleanup."
    fi
}

# Check disk usage
check_disk_usage() {
    echo "Checking disk usage..."
    df -h
}

# Check for failed systemd services
check_failed_services() {
    echo "Checking failed systemd services..."
    systemctl --failed
}

# Run Btrfs balance and scrub on local Btrfs system
optimize_local_btrfs() {
    if command -v btrfs &> /dev/null; then
        echo "Running Btrfs maintenance on local system..."
        sudo btrfs balance start -dusage=75 /  # Balance only if >75% data usage
        sudo btrfs scrub start /
    else
        echo "Btrfs not found. Skipping local Btrfs maintenance."
    fi
}

# Suggest running Btrfs maintenance on Unraid manually
suggest_unraid_btrfs_maintenance() {
    echo "Unraid shares are also Btrfs, but balance and scrub should be run locally from the Unraid terminal."
    echo "Suggested commands to run on Unraid manually:"
    echo "  btrfs balance start /mnt/poolname"
    echo "  btrfs scrub start /mnt/poolname"
}

update_system
cleanup_system
check_disk_usage
check_failed_services
optimize_local_btrfs
suggest_unraid_btrfs_maintenance

echo "System maintenance completed!"

