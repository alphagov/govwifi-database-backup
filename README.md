# GovWifi Database Backup

This repository contains scripts used to perform automated data exports of all GovWifi MySQL databases for backup purposes.

## Overview

GovWifi databases are exported using `mysqldump`. The contents of the SQL dump are compressed and stored in Amazon S3.

Backups are scheduled to run nightly and target replica instances. This is in addition to automated RDS snapshots of master servers.

The backup script runs as a scheduled container task using Amazon ECS.

## Getting started

To build configure and run the application via docker-compose:

`make build`

To run tests:

`make test`

## Environment Variables

The following environment variables are required:

| Variable         | Description             |
| ---------------- | ----------------------- |
| `WIFI_DB_HOST`   | Wifi database hostname  |
| `WIFI_DB_USER`   | Wifi database username  |
| `WIFI_DB_PASS`   | Wifi database password  |
| `WIFI_DB_NAME`   | Wifi database name      |
| `USERS_DB_HOST`  | Users database hostname |
| `USERS_DB_USER`  | Users database username |
| `USERS_DB_PASS`  | Users database password |
| `USERS_DB_NAME`  | Users database name     |
| `ADMIN_DB_HOST`  | Admin database hostname |
| `ADMIN_DB_USER`  | Admin database username |
| `ADMIN_DB_PASS`  | Admin database password |
| `ADMIN_DB_NAME`  | Admin database name     |
| `S3_BUCKET`      | AWS S3 bucket name      |

## Logging & Metrics

The successful completion of the backup is logged using Cloudwatch Logs and used to create a metric filter with relevant alerting.

## Scheduling

The task is scheduled in the relevant AWS Account, ECS, Clusters (staging-api-cluster), Scheduled Tasks.