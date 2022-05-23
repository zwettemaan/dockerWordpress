# A single server can carry multiple domains, but one of those domains needs to be
# chosen as the 'main' domain. This is also the domain to use for reverse name 
# lookup

export LETSENCRYPT_CLOUDFLARE_SHARED_DOMAIN=!!MAIN_DOMAIN

# Base name for the server's off-server backup file

export BACKUP_FILE=serverport

# Where to put the backup file before carting it off-server

export BACKUP_DIR=/tmp/

# Leave OWNCLOUD_BACKUP_SERVER empty if you don't have one
# Otherwise put in the web address that can be used to send
# the backup files to

export OWNCLOUD_BACKUP_SERVER=""

# 
# Verbose or not. 1 or 0
#

export VERBOSE=1

# 
# Add developer tools or not. 1 or 0
#

export DEV_ADD_TOOLS=1

# 
# Name of the docker image for the database
#

export MYSQLIMAGE=mariadb

export APACHEVERSION=2.4
export WORDPRESSVERSION=php7.4
export BACKUP_ARCHIVE=${BACKUP_FILE}.tgz
export BACKUP_ARCHIVE_PATH=${BACKUP_DIR}${BACKUP_ARCHIVE}
export APACHEIMAGE=httpd:${APACHEVERSION}
export WORDPRESSIMAGE=wordpress:${WORDPRESSVERSION}

# Which IP addresses to trust from fail2ban

# CloudFlare IPv4 and IPv6 addresses (https://www.cloudflare.com/ips-v4 https://www.cloudflare.com/ips-v6)

export CLOUDFLARE_IPV4="173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 188.114.96.0/20 197.234.240.0/22 198.41.128.0/17 162.158.0.0/15 104.16.0.0/13 104.24.0.0/14 172.64.0.0/13 131.0.72.0/22"
export CLOUDFLARE_IPV6="2400:cb00::/32 2606:4700::/32 2803:f800::/32 2405:b500::/32 2405:8100::/32 2a06:98c0::/29 2c0f:f248::/32"
export DOCKER_IP="172.0.0.0/8 10.0.0.0/8"
export TRUSTED_IP="127.0.0.1 192.168.0.0/16 ${CLOUDFLARE_IPV4} ${CLOUDFLARE_IPV6} ${DOCKER_IP}"
