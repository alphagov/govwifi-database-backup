FROM python:3-alpine

RUN apk add aws-cli
RUN apk --no-cache add mariadb-connector-c mariadb-client bash gnupg

COPY govwifi-backup.sh ./
RUN chmod +x /govwifi-backup.sh

ENTRYPOINT ["/govwifi-backup.sh"]
