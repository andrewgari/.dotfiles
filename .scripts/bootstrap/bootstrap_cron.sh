#!/bin/bash

# Define all cron jobs in an array
CRON_JOBS=(
    "*/15 * * * * $HOME/.scripts/tools/run_dotfiles_sync.sh"
    # "# Example: Add new cron jobs here"
    # "0 3 * * * $HOME/.scripts/tools/backup_script.sh"
)

CRON_JOB_FILE="/tmp/current_cron"

echo -e "\n🔍 Checking and updating cron jobs..."

# Get current crontab (if exists)
crontab -l > "$CRON_JOB_FILE" 2>/dev/null || touch "$CRON_JOB_FILE"

# Add missing cron jobs
UPDATED=false
for job in "${CRON_JOBS[@]}"; do
    # Skip empty/commented lines
    [[ "$job" =~ ^#.*$ || -z "$job" ]] && continue

    if grep -Fxq "$job" "$CRON_JOB_FILE"; then
        echo "✅ Cron job already exists: $job"
    else
        echo "🆕 Adding cron job: $job"
        echo "$job" >> "$CRON_JOB_FILE"
        UPDATED=true
    fi
done

# Apply new crontab only if changes were made
if [ "$UPDATED" = true ]; then
    crontab "$CRON_JOB_FILE"
    echo "✅ Cron jobs updated."
else
    echo "✅ No changes needed. All cron jobs are up to date."
fi

# Ensure cron service is running (Linux-specific)
if command -v systemctl &> /dev/null; then
    echo "🔄 Restarting cron service..."
    sudo systemctl restart cron
    echo "✅ Cron service restarted."
fi

# Clean up temp file
rm -f "$CRON_JOB_FILE"

echo -e "\n🎉 Cron job bootstrap complete!"

