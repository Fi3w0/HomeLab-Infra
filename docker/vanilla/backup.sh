#!/usr/bin/env bash
set -euo pipefail

# ------------ CONFIG ------------
CONTAINER="vanilla"
WORLD="AitorLand"
BACKUP_DIR="/srv/mc/vanilla/backup"
MAX_BACKUPS=8
SLEEP_TIME=20
TIMESTAMP=$(date +"%d_%m_%Y-%H_%M")
LOGFILE="${BACKUP_DIR}/backup.log"
# --------------------------------

mkdir -p "$BACKUP_DIR"

log() {
  echo "$(date --iso-8601=seconds)  $1" | tee -a "$LOGFILE"
}

log "Starting backup for world '${WORLD}'"

# 1) Force save
docker exec "$CONTAINER" rcon-cli save-all >/dev/null 2>&1
log "save-all issued, waiting ${SLEEP_TIME}s..."
sleep "$SLEEP_TIME"

ARCHIVE="${BACKUP_DIR}/${WORLD}_${TIMESTAMP}.tar.gz"

# 2) Get original world size (best effort)
ORIG_BYTES=$(docker exec "$CONTAINER" sh -c "du -sb /data/${WORLD} 2>/dev/null | cut -f1" || echo 0)
if [[ "$ORIG_BYTES" -gt 0 ]]; then
  log "Original world size: $ORIG_BYTES bytes"
else
  log "Could not determine original world size"
fi

# 3) Create compressed backup (streamed)
log "Creating archive ${ARCHIVE}"
docker exec "$CONTAINER" tar -C /data -cf - "$WORLD" | gzip -c > "$ARCHIVE"

# 4) Log archive size
ARCH_BYTES=$(stat -c%s "$ARCHIVE")
ARCH_HUMAN=$(du -h "$ARCHIVE" | cut -f1)
log "Backup created: ${ARCH_HUMAN} (${ARCH_BYTES} bytes)"

# Compression ratio
if [[ "$ORIG_BYTES" -gt 0 ]]; then
  ratio=$(awk "BEGIN {printf \"%.2f\", ${ARCH_BYTES}/${ORIG_BYTES}}")
  saved=$(awk "BEGIN {printf \"%.2f\", (1 - (${ARCH_BYTES}/${ORIG_BYTES})) * 100}")
  log "Compression ratio: ${ratio} | Space saved: ${saved}%"
fi

# 5) Prune old backups (keep newest MAX_BACKUPS)
log "Pruning old backups (keeping ${MAX_BACKUPS})"
mapfile -t backups < <(ls -1t "${BACKUP_DIR}/${WORLD}_"*.tar.gz 2>/dev/null || true)

if (( ${#backups[@]} > MAX_BACKUPS )); then
  for (( i=MAX_BACKUPS; i<${#backups[@]}; i++ )); do
    rm -f "${backups[$i]}"
    log "Deleted old backup: ${backups[$i]}"
  done
else
  log "No old backups to remove (${#backups[@]} total)"
fi

log "Backup completed successfully"
