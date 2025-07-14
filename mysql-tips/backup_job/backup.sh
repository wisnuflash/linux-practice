#!/bin/bash

# === Konfigurasi Umum ===
BACKUP_DIR_BASE="/mnt/disk-backup/BACKUP DAILY DB"
DATE=$(date +%F)
#LOG_FILE="$BACKUP_DIR_BASE/$JOB_NAME_log_$DATE.txt"

# === Daftar Job Backup ===
# Format: "NAMA_JOB|HOST|PORT|USER|PASSWORD|FOLDER"
JOBS=(
   "dbtest|localhost|3306|root|password|dbtest"
)

# === Fungsi Backup ===
backup_database() {
  JOB_NAME="$1"
  HOST="$2"
  PORT="$3"
  USER="$4"
  PASSWORD="$5"
  FOLDER="$6"

  LOG_FILE="$BACKUP_DIR_BASE/${JOB_NAME}_log_$DATE.txt"
  echo "dir backup: $LOG_FILE"
  BACKUP_DIR="$BACKUP_DIR_BASE/$FOLDER"
  mkdir -p "$BACKUP_DIR"

  echo "[$(date '+%F %T')] 🔄 Memulai backup untuk $JOB_NAME  ($HOST)" | tee -a "$LOG_FILE"

  # Ambil daftar database
  DBS=$(mysql -u "$USER" -p"$PASSWORD" -h"$HOST" -P"$PORT" -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|sys)")

  for DB in $DBS; do
    echo "Membackup database: $DB"
    DUMP_FILE="$BACKUP_DIR/${DB}.sql"
    ZIP_FILE="$BACKUP_DIR/${DB}_${DATE}.zip"

    mysqldump -u "$USER" -p"$PASSWORD" -h"$HOST" -P"$PORT" "$DB" > "$DUMP_FILE" | tee -a "$LOG_FILE"
    
    if [ $? -eq 0 ]; then
      zip -j "$ZIP_FILE" "$DUMP_FILE"
      rm "$DUMP_FILE"
      echo "[$(date '+%F %T')] ✅ Backup $DB (job: $JOB_NAME) sukses." | tee -a "$LOG_FILE"
    else
      echo "[$(date '+%F %T')] ❌ Backup $DB (job: $JOB_NAME) gagal." | tee -a "$LOG_FILE"
    fi
  done

  curl -X POST http://localhost/api/send-media-group \
   -H "Content-Type: multipart/form-data" \
   -F "groupId=120363421263725908@g.us" \
   -F "message=✅ [$(date '+%F %T')] ✔️ Selesai backup untuk job: $JOB_NAME" \
   -F "file=@$LOG_FILE" \
   >> "$LOG_FILE"
  echo "[$(date '+%F %T')] ✔️ Selesai backup untuk job: $JOB_NAME" | tee -a "$LOG_FILE"
  echo "[$(date '+%F %T')] 📬 Notifikasi backup terkirim." | tee -a "$LOG_FILE"
}

# === Loop semua job ===
for JOB in "${JOBS[@]}"; do
  IFS='|' read -r JOB_NAME HOST PORT USER PASSWORD FOLDER <<< "$JOB"
  backup_database "$JOB_NAME" "$HOST" "$PORT" "$USER" "$PASSWORD" "$FOLDER"
done

# === Kirim Notifikasi via Trustcore (jika diperlukan) ===


echo "[$(date '+%F %T')] ✅ Backuo Job Selesai"
