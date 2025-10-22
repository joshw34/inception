#!/bin/sh
FTP_USER_PASSWORD=$(cat /run/secrets/ftp_user_password)

adduser -u 1000 -s /sbin/nologin -D -h /mnt/ftpdata $FTP_USER

# Set password of the user
echo "$FTP_USER:$FTP_USER_PASSWORD" | chpasswd

#cat > /etc/vsftpd/vsftpd.conf <<EOF
#seccomp_sandbox=NO
#local_enable=YES
#write_enable=YES
#chroot_local_user=YES
#passwd_chroot_enable=YES
#allow_writeable_chroot=YES
#ftpd_banner=Welcome to vsftpd
#max_clients=10
#max_per_ip=5
#local_umask=022
#pasv_enable=YES
#pasv_max_port=50010
#pasv_min_port=50000
#pasv_address=127.0.0.1
#anonymous_enable=NO
#no_anon_password=NO
#anon_root=/var/ftp
#EOF

exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
