#!/bin/sh
FTP_USER_PASSWORD=$(cat /run/secrets/ftp_user_password)

if ! id -u "$FTP_USER" >/dev/null 2>&1; then
  adduser -u 1000 -s /sbin/nologin -D -h /mnt/ftpdata "$FTP_USER"
    echo "User $FTP_USER created"
  else
    echo "User $FTP_USER already exists"
fi

# Set password of the user
echo "$FTP_USER:$FTP_USER_PASSWORD" | chpasswd
echo "Password set for $FTP_USER"

if [ ! -f /etc/ssl/private/vsftpd.crt ]; then
  mkdir -p /etc/ssl/private
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/vsftpd.key \
    -out /etc/ssl/private/vsftpd.crt \
    -subj "/C=FR/ST=PACA/L=Nice/O=42/CN=$DOMAIN_NAME"
  echo "SSL certificate generated"
fi

exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
