#!/bin/bash

# Define all cron jobs in an array
CRON_JOBS=(
    "*/15 * * * * $HOME/.scripts/tools/run_dotfiles_sync.sh"
    "0 4 * * 0 journalctl --vacuum-time=7d && rm -rf ~/.cache/*"
    "0 5 * * 0 fstrim -av"
    "0 2 * * * rsync -av --exclude=Vault --exclude=Games/foundryvtt --exclude=Shared --exclude=Unraid --exclude=Videos/unRAID --exclude=Pictures/unRAID --exclude=Games/unRAID --one-file-system ~ /mnt/unraid/andrew/backup/home/"
    "0 1 * * * rsync -av ~/dotfiles /mnt/unraid/andrew/backup/dotfiles/"
    "*/5 * * * * if [ -x "$(command -v moonlight)" ]; then pgrep moonlight || moonlight stream -app Steam; fi"
    "*/5 * * * * ping -c 1 8.8.8.8 > /dev/null || (if [ -x "$(command -v notify-send)" ]; then notify-send "🌐 Internet Connection Lost!"; fi)"
    "*/10 * * * * uptime | awk '{if ($10 > 2.0) print strftime("%Y-%m-%d %H:%M:%S"), "⚠️ High CPU Load:", $10}' >> /mnt/unraid/andrew/backup/cpu_load.log && if [ -x "$(command -v notify-send)" ]; then notify-send "⚠️ High CPU Load detected!"; fi"
    "*/30 * * * * df -h | awk '$5 > 90 {print "🚨 Low Disk Space on "$6": "$5}' | mail -s "Disk Space Warning!" covadax.ag@gmail.com"
    "*/10 * * * * if [ -x "$(command -v mountpoint)" ]; then mountpoint -q /mnt/unraid || (systemctl restart mnt-unraid-data.mount && notify-send "🔄 Remounted Unraid Share"); fi"
    "0 1 * * * find ~/Downloads -type f -size +2G -mtime +30 -exec mv {} /mnt/unraid/andrew/backup/old_downloads/ \;"
    "0 4 * * * find /var/log -type f -mtime +7 -exec rm -f {} \;"
    "0 5 * * * rsync -av ~/.ssh /mnt/unraid/andrew/backup/ssh_keys/"
    "0 9 * * * if [ -x "$(command -v curl)" ] && [ -x "$(command -v jq)" ]; then curl -s https://api.quotable.io/random | jq -r '.content + " - " + .author' | notify-send "🌟 Daily Motivation"; fi"
    "*/5 * * * * (ping -c 1 192.168.50.3 > /dev/null || (sleep 30 && ping -c 1 192.168.50.3 > /dev/null) || ( 
    TIMESTAMP=$(date +\"%Y-%m-%d %H:%M:%S\") 
    MESSAGE=\"🚨 [Unraid Down] - $TIMESTAMP: Unraid (192.168.50.3) is unreachable.\"
    
    # Log the downtime
    echo \"$MESSAGE\" >> /mnt/unraid/andrew/backup/unraid_status.log 

    # Send desktop notification (Linux/macOS)
    if [ -x \"$(command -v notify-send)\" ]; then 
        notify-send \"$MESSAGE\" 
    elif [ \"$(uname)\" = \"Darwin\" ]; then 
        osascript -e \"display notification \\\"$MESSAGE\\\" with title \\\"Unraid Alert\\\"\"
    fi

    # Send email to covadax.ag@gmail.com
    if [ -x \"$(command -v mail)\" ]; then 
        echo \"$MESSAGE\" | mail -s \"🚨 Unraid Down Alert\" covadax.ag@gmail.com
    elif [ -x \"$(command -v sendmail)\" ]; then
        echo -e \"Subject: 🚨 Unraid Down Alert\n\n$MESSAGE\" | sendmail covadax.ag@gmail.com
    fi
))"
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

