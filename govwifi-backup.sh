#!/usr/bin/env bash

set -euf -o pipefail

echo "Starting backup of databases to S3..."

ENDPOINT_ARG=${ENDPOINT_URL:+--endpoint-url=$ENDPOINT_URL}

MYSQL_PWD="${WIFI_DB_PASS}" mysqldump \
  -h "${WIFI_DB_HOST}" -u "${WIFI_DB_USER}" \
  --compress --quick --single-transaction \
  --no-create-info --complete-insert "${WIFI_DB_NAME}" \
  | gzip -c | aws ${ENDPOINT_ARG} s3 cp - s3://"${S3_BUCKET}/wifi-backup-$(date -I)".sql.gz

STATUS1=$?
if [ $STATUS1 -eq 0 ] ; then echo "OK - Wifi Database" ; else echo "FAILED - Wifi Database"; fi

MYSQL_PWD="${USERS_DB_PASS}" mysqldump \
  -h "${USERS_DB_HOST}" -u "${USERS_DB_USER}" \
  --compress --quick --single-transaction \
  --no-create-info --complete-insert "${USERS_DB_NAME}" \
  | gzip -c | aws ${ENDPOINT_ARG} s3 cp - s3://"${S3_BUCKET}/wifi-backup-user-details-$(date -I)".sql.gz

STATUS2=$?
if [ $STATUS2 -eq 0 ] ; then echo "OK - Users Databse"; else echo "FAILED - Users Database" ; fi

MYSQL_PWD="${ADMIN_DB_PASS}" mysqldump \
  -h "${ADMIN_DB_HOST}" -u "${ADMIN_DB_USER}" \
  --compress --quick --single-transaction \
  --no-create-info --complete-insert "${ADMIN_DB_NAME}" \
  | gzip -c | aws ${ENDPOINT_ARG} s3 cp - s3://"${S3_BUCKET}/wifi-backup-admin-$(date -I)".sql.gz

STATUS3=$?
if [ $STATUS3 -eq 0 ] ; then echo "OK - Admin Database"; else echo "FAILED - Admin Database"; fi

if [ $STATUS1 -ne 0 ] || [ $STATUS2 -ne 0 ] || [ $STATUS3 -ne 0 ]
then
        echo BACKUPS FAILED
else
        echo BACKUPS OK
fi
