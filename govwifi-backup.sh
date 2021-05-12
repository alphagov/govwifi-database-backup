#!/bin/sh

set -eu

echo "Starting encrypted backup of databases to S3..."

#openssl enc -d -base64 -pass file:encrypt.key -in testdata.enc -out testdata.gz

ENDPOINT_ARG=${BACKUP_ENDPOINT_URL:+--endpoint-url=$BACKUP_ENDPOINT_URL}

# set the mysql pass pre command inline so not to appear in the proc list
echo -n "STARTING SQL DUMP OF SESSIONS DB - "
MYSQL_PWD="${WIFI_DB_PASS}" mysqldump -h "${WIFI_DB_HOSTNAME}" -u "${WIFI_DB_USER}" \
  --compress --quick --single-transaction --no-create-info --complete-insert "${WIFI_DB_NAME}" \
  | gzip -c | openssl enc -base64 -pass pass:${ENCRYPTION_KEY} | aws ${BACKUP_ENDPOINT_ARG} s3 cp - s3://"${S3_BUCKET}/wifi-backup-$(date -I)".sql.gz.enc

STATUS1=$?
[ $STATUS1 -eq 0 ] && echo COMPLETE || echo FAILED

echo -n "STARTING SQL DUMP OF USERS DB - "
MYSQL_PWD="${USERS_DB_PASS}" mysqldump -h "${USERS_DB_HOSTNAME}" -u "${USERS_DB_USER}" \
  --compress --quick --single-transaction --no-create-info --complete-insert "${USERS_DB_NAME}" \
  | gzip -c | openssl enc -base64 -pass pass:${ENCRYPTION_KEY} | aws ${BACKUP_ENDPOINT_ARG} s3 cp - s3://"${S3_BUCKET}/wifi-backup-user-details-$(date -I)".sql.gz
STATUS2=$?
[ $STATUS2 -eq 0 ] && echo COMPLETE || echo FAILED

echo -n "STARTING SQL DUMP OF ADMIN DB - "
MYSQL_PWD="${ADMIN_DB_PASS}" mysqldump -h "${ADMIN_DB_HOSTNAME}" -u "${ADMIN_DB_USER}" \
  --compress --quick --single-transaction --no-create-info --complete-insert "${ADMIN_DB_NAME}" \
  | gzip -c | openssl enc -base64 -pass pass:${ENCRYPTION_KEY} | aws ${BACKUP_ENDPOINT_ARG} s3 cp - s3://"${S3_BUCKET}/wifi-backup-admin-$(date -I)".sql.gz
STATUS3=$?
[ $STATUS3 -eq 0 ] && echo COMPLETE || echo FAILED

if [ $STATUS1 -ne 0 ] || [ $STATUS2 -ne 0 ] || [ $STATUS3 -ne 0 ]
then
        echo BACKUPS FAILED
else
        echo BACKUPS OK
fi
