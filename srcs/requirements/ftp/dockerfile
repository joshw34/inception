FROM alpine:3.22.2

RUN apk update && \
    apk add --no-cache vsftpd openssl

COPY ./files/vsftpd.conf /etc/vsftpd/vsftpd.conf

COPY ./files/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 20 21 50000-50010

LABEL description="ftp"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
