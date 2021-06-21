#!/usr/bin/env bash

set -euf -o pipefail

if [ "${BACKUP_ENDPOINT_URL}" != "" ]; then
  BACKUP_ENDPOINT_ARG=${BACKUP_ENDPOINT_URL:+--endpoint-url=$BACKUP_ENDPOINT_URL}
else
  BACKUP_ENDPOINT_ARG="";
fi

STAMP_DATE=`date +"%Y-%m-%d-%H-%M"`
echo "Starting encrypted backup of databases to S3 at `date`..."

# set the mysql pass pre command inline so not to appear in the proc list
echo -n "STARTING SQL DUMP OF SESSIONS DB - "
MYSQL_PWD="${WIFI_DB_PASS}" mysqldump -h "${WIFI_DB_HOSTNAME}" -u "${WIFI_DB_USER}" \
  --compress --quick --single-transaction "${WIFI_DB_NAME}" \
  | gzip -c | gpg --symmetric --batch --yes --passphrase ${ENCRYPTION_KEY} | aws ${BACKUP_ENDPOINT_ARG} s3 cp - s3://"${S3_BUCKET}/govwifi-backup-sessions-${STAMP_DATE}.sql.gz.gpg"
STATUS1=$?
[ $STATUS1 -eq 0 ] && echo COMPLETE || echo FAILED

echo -n "STARTING SQL DUMP OF USERS DB - "
MYSQL_PWD="${USERS_DB_PASS}" mysqldump -h "${USERS_DB_HOSTNAME}" -u "${USERS_DB_USER}" \
  --compress --quick --single-transaction "${USERS_DB_NAME}" \
  | gzip -c | gpg --symmetric --batch --yes --passphrase ${ENCRYPTION_KEY} | aws ${BACKUP_ENDPOINT_ARG} s3 cp - s3://"${S3_BUCKET}/govwifi-backup-user-details-${STAMP_DATE}.sql.gz.gpg"
STATUS2=$?
[ $STATUS2 -eq 0 ] && echo COMPLETE || echo FAILED

echo -n "STARTING SQL DUMP OF ADMIN DB - "
MYSQL_PWD="${ADMIN_DB_PASS}" mysqldump -h "${ADMIN_DB_HOSTNAME}" -u "${ADMIN_DB_USER}" \
  --compress --quick --single-transaction "${ADMIN_DB_NAME}" \
  | gzip -c | gpg --symmetric --batch --yes --passphrase ${ENCRYPTION_KEY} | aws ${BACKUP_ENDPOINT_ARG} s3 cp - s3://"${S3_BUCKET}/govwifi-backup-admin-${STAMP_DATE}.sql.gz.gpg"
STATUS3=$?
[ $STATUS3 -eq 0 ] && echo COMPLETE || echo FAILED

if [ $STATUS1 -ne 0 ] || [ $STATUS2 -ne 0 ] || [ $STATUS3 -ne 0 ]
then
        echo BACKUPS FAILED - `date`
        exit 1
fi

echo BACKUPS OK - `date`
