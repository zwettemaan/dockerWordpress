export SCRIPTDIR=`dirname "$0"`
cd "${SCRIPTDIR}"
export SCRIPTDIR=`pwd`

export NGINX_ACTIVE=`systemctl is-active nginx.service`
if [ ${NGINX_ACTIVE} == "active" ]; then
    service nginx stop
fi

# Needs the following environment variables set:
#
# LETSENCRYPT_CLOUDFLARE_SHARED_DOMAIN (shared cert folder name is based on first domain in list of CloudFlare domains)
# SERVER_DOMAIN
# DOCKERNAME
# 

if [ "${1}" != "" ]; then
    export SERVER_DOMAIN="${1}"
fi

if [ "${2}" != "" ]; then
    export DOCKERNAME="${2}"
fi

. /root/setupenv.sh
. /vagrant/serverport/${SERVER_DOMAIN}/${DOCKERNAME}.sh
export DOCKERNAME_DB=${DOCKERNAME}_mysql_1
export DOCKERNAME_WP=${DOCKERNAME}_wordpress_1

export BASE_DOMAIN=`echo ${SERVER_DOMAIN} | sed -E -e "s/^(www\.)?([^,]*)\$/\\2/g"`
export DOMAIN_NS=`${SCRIPTDIR}/getdomainNS.sh ${BASE_DOMAIN}`

export BASE_DOMAIN_NS=`echo ${DOMAIN_NS} | sed -E -e "s/^(.*\.)?ns[1-9]?\.(.*)\$/\\2/g"`

export LETSENCRYPT_SHARED_DOMAIN=${LETSENCRYPT_CLOUDFLARE_SHARED_DOMAIN}

cd /root
if [ ! -d ${SERVER_DOMAIN} ]; then
    mkdir ${SERVER_DOMAIN}
fi

if [ ! -d /root/${SERVER_DOMAIN}/wp-content ]; then
    mkdir /root/${SERVER_DOMAIN}/wp-content
fi

if [ ! -d /root/${SERVER_DOMAIN}/mysql ]; then
    mkdir /root/${SERVER_DOMAIN}/mysql
fi

export EXTRA_REDIRECT=""

cd /etc/nginx/sites-available
cat > ${SERVER_DOMAIN} << EOF

server { 
    
    listen 443 ssl;
    listen [::]:443;

    server_name ${SERVER_DOMAIN} ${ADDITIONAL_DOMAINS};
    root /usr/share/nginx/html;
    client_max_body_size 100m;
    client_body_timeout 120s;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_dhparam /etc/ssl/certs/dhparam.pem;
    ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_certificate /etc/letsencrypt/live/${LETSENCRYPT_SHARED_DOMAIN}/fullchain.pem; 
    ssl_certificate_key /etc/letsencrypt/live/${LETSENCRYPT_SHARED_DOMAIN}/privkey.pem;

    ${EXTRA_REDIRECT}

    location / {
        proxy_redirect off;
        proxy_pass         http://127.0.0.1:${DOCKER_WP_PORT};
        proxy_set_header   X-Real-IP \$remote_addr;
        proxy_set_header   Host      \$http_host;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto https;
    }

    # From https://www.cloudflare.com/ips-v4
    !!NGINX_CLOUDFLARE_IPV4

    # From https://www.cloudflare.com/ips-v6
    !!NGINX_CLOUDFLARE_IPV6

    real_ip_header X-Forwarded-For;
}

server {

    listen 80;
    listen [::]:80;

    server_name ${SERVER_DOMAIN} ${ADDITIONAL_DOMAINS};

    return 301 https://${SERVER_DOMAIN}\$request_uri;
}

EOF

cd /etc/nginx/sites-enabled

if [ ! -f ${SERVER_DOMAIN} ]; then
    ln -s ../sites-available/${SERVER_DOMAIN} ${SERVER_DOMAIN}
fi

cd /root/${SERVER_DOMAIN}

cat > docker-compose.yml << EOF
version: '2'

services:

  mysql:
    container_name: ${DOCKERNAME_DB}
    image: ${MYSQLIMAGE}
    restart: always
    ports:
      - ${DOCKER_DB_PORT}:3306
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - /root/${SERVER_DOMAIN}/mysql:/var/lib/mysql:delegated

  wordpress:
    container_name: ${DOCKERNAME_WP}
    image: ${WORDPRESSIMAGE}
    restart: always
    depends_on:
      - mysql
    ports:
      - ${DOCKER_WP_PORT}:80
    environment:
      WORDPRESS_DB_NAME: ${MYSQL_DATABASE}
      WORDPRESS_DB_USER: ${MYSQL_USER}
      WORDPRESS_DB_PASSWORD: ${MYSQL_PASSWORD}
      WORDPRESS_TABLE_PREFIX: ${WP_TABLE_PREFIX}
    working_dir: /var/www/html
    volumes:
      - /root/${SERVER_DOMAIN}/wp-content/:/var/www/html/wp-content:delegated
      - /vagrant/scripts/uploads.ini:/usr/local/etc/php/conf.d/uploads.ini:cached

EOF

cd /root/${SERVER_DOMAIN}
if [ -f "/vagrant/serverport/${SERVER_DOMAIN}/wp-content.tgz" ]; then
    tar -zxvf "/vagrant/serverport/${SERVER_DOMAIN}/wp-content.tgz"
fi

docker-compose up 2>&1 ${VERBOSE_OUTPUT} &

cat > /usr/local/bin/db_$DOCKERNAME << EOF
docker exec -it ${DOCKERNAME_DB} bash
EOF
chmod +x /usr/local/bin/db_${DOCKERNAME}

cat > /usr/local/bin/wp_$DOCKERNAME << EOF
docker exec -it ${DOCKERNAME_WP} bash
EOF
chmod +x /usr/local/bin/wp_${DOCKERNAME} 

sleep 10

export DB_STARTED=0
while [ "${DB_STARTED}" == "0" ]; do
    export DOCKERID_DB=`docker ps -aqf name=${DOCKERNAME_DB}`
    export PING_REPLY=`docker exec ${DOCKERID_DB} mysqladmin -u ${MYSQL_USER} -p${MYSQL_PASSWORD} ping 2> /dev/null`
    if [ "$PING_REPLY" == "mysqld is alive" ]; then
        echo "${DOCKERNAME_DB} started"
        export DB_STARTED=1
    else
        echo "waiting for ${DOCKERNAME_DB}"
        sleep 5
    fi
done

echo "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};" > /tmp/${SERVER_DOMAIN}_serverdump.sql
echo "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';" >> /tmp/${SERVER_DOMAIN}_serverdump.sql
if [ -f /vagrant/serverport/${SERVER_DOMAIN}/serverdump.gz ]; then
    echo "USE ${MYSQL_DATABASE};" >> /tmp/${SERVER_DOMAIN}_serverdump.sql
    gzip -d < /vagrant/serverport/${SERVER_DOMAIN}/serverdump.gz >> /tmp/${SERVER_DOMAIN}_serverdump.sql 
fi
cat /tmp/${SERVER_DOMAIN}_serverdump.sql | docker exec -i ${DOCKERNAME_DB} mysql -u root -p${MYSQL_ROOT_PASSWORD} 

if [ -d /vagrant/serverport/${SERVER_DOMAIN}/additional ]; then
    cd /vagrant/serverport/${SERVER_DOMAIN}/additional
    for filename in *; do
        docker cp ${filename} ${DOCKERNAME_WP}:/var/www/html/${filename}
    done
    if [ -d well-known ]; then
        docker cp well-known ${DOCKERNAME_WP}:/var/www/html/.well-known
    fi
    docker exec ${DOCKERNAME_WP} chown -R www-data:www-data /var/www/html
fi

if [ ${NGINX_ACTIVE} == "active" ]; then
    service nginx start
fi
