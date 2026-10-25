#!/bin/bash
set -euo pipefail
umask 077
exec 9>/run/vaultwarden-backup.lock
flock -n 9 || exit 0
mountpoint -q /srv/vaultwarden
cd /opt/vaultwarden
archive="/srv/vaultwarden/backups/vaultwarden-$(date -u +%Y%m%dT%H%M%SZ).tar.gz"
# Stop writes while copying SQLite, its WAL, attachments and configuration.
trap 'docker compose start vaultwarden' EXIT
docker compose stop vaultwarden
tar -czf "$archive.partial" -C /srv/vaultwarden data secrets
mv "$archive.partial" "$archive"
docker compose start vaultwarden
trap - EXIT
# Optional encrypted off-site copy. Configure and initialize the repository first.
if [ -f /srv/vaultwarden/secrets/restic.env ]; then
    set -a
    source /srv/vaultwarden/secrets/restic.env
    set +a
    restic backup --tag vaultwarden "$archive"
    restic forget --tag vaultwarden --group-by host,tags --keep-daily 14 --keep-weekly 8 --keep-monthly 12 --prune
fi
find /srv/vaultwarden/backups -maxdepth 1 -type f -name 'vaultwarden-*.tar.gz' -mtime +14 -delete
