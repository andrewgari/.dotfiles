#!/bin/bash

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_DIR="$SCRIPT_DIR/../.scripts/bootstrap"

# Check if running on a DNF-based system
if ! command -v dnf &>/dev/null; then
    echo "❌ Error: DNF package manager not found. This script is for DNF-based systems only."
    exit 1
fi

# Execute the DNF bootstrap script
bash "$BOOTSTRAP_DIR/dnf_bootstrap.sh" 