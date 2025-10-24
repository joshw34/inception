#!/bin/sh

set -e

REDIS_PASS=$(cat /run/secrets/redis_password)

cat > /var/lib/redis/redis.conf <<EOF
maxmemory 256mb
save 900 1
save 300 10
save 60 10000
appendonly yes
requirepass $REDIS_PASS
bind 0.0.0.0
port 6379
dir /var/lib/redis
EOF

exec redis-server /var/lib/redis/redis.conf
