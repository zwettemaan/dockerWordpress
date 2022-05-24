# A single server can carry multiple domains, but one of those domains needs to be
# chosen as the 'main' domain. This is also the domain to use for reverse name 
# lookup

export LETSENCRYPT_CLOUDFLARE_SHARED_DOMAIN="!!MAIN_DOMAIN"

export CLOUDFLARE_USER="!!CLOUDFLARE_USER"
export CLOUDFLARE_GLOBAL_API_KEY="!!CLOUDFLARE_GLOBAL_API_KEY"
# fail2ban does not yet support CLOUDFLARE_API_TOKEN
# export CLOUDFLARE_API_TOKEN="!!CLOUDFLARE_API_TOKEN"

# Base name for the server's off-server backup file

export BACKUP_FILE="serverport"

# Where to put the backup file before carting it off-server

export BACKUP_DIR="/tmp/"

export PRIVATE_KEY_FILE="!!PRIVATE_KEY_FILE"

# Leave OWNCLOUD_BACKUP_SERVER empty if you don't have one
# Otherwise put in the web address that can be used to send
# the backup files to

export OWNCLOUD_BACKUP_SERVER=""

# 
# Verbose or not. 1 or 0
#

export VERBOSE="1"

# 
# Add developer tools or not. 1 or 0
#

export DEV_ADD_TOOLS="1"

# 
# Name of the docker image for the database
#

export MYSQLIMAGE="mariadb"

export APACHEVERSION="2.4"
export WORDPRESSVERSION="php7.4"
export BACKUP_ARCHIVE="${BACKUP_FILE}.tgz"
export BACKUP_ARCHIVE_PATH="${BACKUP_DIR}${BACKUP_ARCHIVE}"
export APACHEIMAGE="httpd:${APACHEVERSION}"
export WORDPRESSIMAGE="wordpress:${WORDPRESSVERSION}"

# Which IP addresses to trust from fail2ban

export CLOUDFLARE_IPV4="!!CLOUDFLARE_IPV4"
export CLOUDFLARE_IPV6="!!CLOUDFLARE_IPV6"
export DOCKER_IP="172.0.0.0/8 10.0.0.0/8"
export TRUSTED_IP="127.0.0.1 192.168.0.0/16 ${CLOUDFLARE_IPV4} ${CLOUDFLARE_IPV6} ${DOCKER_IP}"
