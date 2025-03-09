# Automated System Maintenance and Monitoring

This repository contains a collection of automated cron jobs for system maintenance, monitoring, and backup operations. The jobs are managed through a bootstrap script that ensures consistent setup across different systems.

## 🚀 Quick Start

```bash
# Make the bootstrap script executable
chmod +x .scripts/bootstrap/bootstrap_cron.sh

# Run the bootstrap script
./.scripts/bootstrap/bootstrap_cron.sh
```

## 🔧 System Requirements

- Linux or macOS system
- Required tools:
  - `rsync` for backups
  - `notify-send` for desktop notifications
  - `sensors` for temperature monitoring
  - `curl` and `jq` for daily motivational quotes
  - `mail` or `sendmail` for email notifications
  - `moonlight` (optional, for game streaming)
  - `docker` (optional, for container management)

## 📋 Features

### System Maintenance
- Weekly system cleanup (cache, logs)
- SSD optimization with TRIM
- Automatic removal of large old files
- Docker system cleanup
- Log rotation and compression

### Backup Operations
- Home directory backup (excluding specified directories)
- Dotfiles backup
- SSH keys backup
- Firefox bookmarks backup
- Large downloads archival

### System Monitoring
- CPU load monitoring
- Disk space monitoring
- CPU temperature monitoring
- Zombie process cleanup
- Failed systemd services detection

### Network Monitoring
- Internet connectivity checks
- Unraid server monitoring
- Network latency monitoring
- DNS resolution monitoring
- SSH login attempt monitoring

### Quality of Life
- Daily motivational quotes
- USB device detection
- Automatic game streaming setup
- Network share remounting

## ⚙️ Configuration

The cron jobs are defined in `.scripts/bootstrap/bootstrap_cron.sh`. Key configurations:

- Backup paths are set to `/mnt/unraid/andrew/backup/`
- Email notifications are sent to `covadax.ag@gmail.com`
- Monitoring thresholds:
  - CPU load > 2.0
  - Disk usage > 90%
  - CPU temperature > 80°C
  - Network latency > 100ms

## 📦 Backup Locations

- Home directory: `/mnt/unraid/andrew/backup/home/`
- Dotfiles: `/mnt/unraid/andrew/backup/dotfiles/`
- SSH keys: `/mnt/unraid/andrew/backup/ssh_keys/`
- Firefox bookmarks: `/mnt/unraid/andrew/backup/firefox_bookmarks/`
- Large old downloads: `/mnt/unraid/andrew/backup/old_downloads/`

## 🔔 Notifications

The system uses multiple notification methods:
- Desktop notifications via `notify-send`
- Email notifications for critical events
- Log files for historical tracking

## 📊 Monitoring Logs

- CPU load: `/mnt/unraid/andrew/backup/cpu_load.log`
- Unraid status: `/mnt/unraid/andrew/backup/unraid_status.log`
- Package list: `/mnt/unraid/andrew/backup/pkg-list-YYYYMMDD.txt`

## 🕒 Schedule Overview

- Every 5 minutes:
  - Internet connectivity check
  - Unraid server monitoring
  - USB device detection
  - Game streaming check

- Every 10 minutes:
  - CPU load monitoring
  - Network share monitoring
  - Network latency check

- Every 15 minutes:
  - Dotfiles sync
  - CPU temperature check
  - DNS resolution check

- Every 30 minutes:
  - Disk space monitoring
  - Zombie process cleanup

- Daily:
  - Various backup operations
  - Large file cleanup
  - Motivational quotes

- Weekly:
  - System cleanup
  - Docker cleanup
  - Log compression

## 🛠️ Customization

To modify the cron jobs:
1. Edit `.scripts/bootstrap/bootstrap_cron.sh`
2. Modify the `CRON_JOBS` array
3. Run the bootstrap script again

## 🔒 Security Notes

- SSH key backups are encrypted during transfer
- Failed SSH login attempts are monitored
- System logs are automatically rotated
- Sensitive directories are excluded from backups

## 🤝 Contributing

Feel free to submit issues and enhancement requests! 