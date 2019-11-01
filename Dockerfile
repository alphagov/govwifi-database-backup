FROM python:3-alpine

RUN wget "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" \
 && unzip awscli-bundle.zip \
 && rm awscli-bundle.zip \
 && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
 && rm -r ./awscli-bundle
RUN apk --no-cache add mariadb-client

COPY govwifi-backup.sh ./
RUN chmod +x /govwifi-backup.sh

ENTRYPOINT ["/govwifi-backup.sh"]
