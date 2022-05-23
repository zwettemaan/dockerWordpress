export SCRIPTDIR=`dirname "$0"`
cd "${SCRIPTDIR}"
export SCRIPTDIR=`pwd`

# Needs the following environment variables
#
# SERVER_DOMAIN
# DOCKERNAME
# 

export NGINX_ACTIVE=`systemctl is-active nginx.service`
if [ ${NGINX_ACTIVE} == "active" ]; then
    service nginx stop
fi

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

export DOCKERID_DB=`docker ps -aqf name=${DOCKERNAME_DB}`
export DOCKERID_WP=`docker ps -aqf name=${DOCKERNAME_WP}`

docker stop ${DOCKERID_WP} 2>&1 ${VERBOSE_OUTPUT}
docker rm ${DOCKERID_WP} 2>&1 ${VERBOSE_OUTPUT}

docker stop ${DOCKERID_DB} 2>&1 ${VERBOSE_OUTPUT}
docker rm ${DOCKERID_DB} 2>&1 ${VERBOSE_OUTPUT}

rm /usr/local/bin/db_$DOCKERNAME
rm /usr/local/bin/wp_${DOCKERNAME} 

rm -rf /root/${SERVER_DOMAIN}
rm -f /etc/nginx/sites-enabled/${SERVER_DOMAIN}
rm -f /etc/nginx/sites-available/${SERVER_DOMAIN}

if [ ${NGINX_ACTIVE} == "active" ]; then
    service nginx start
fi
