export SCRIPTDIR=`dirname "$0"`
cd "${SCRIPTDIR}"
export SCRIPTDIR=`pwd`

# Needs the following environment variables
#
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

if [ -d /root/${SERVER_DOMAIN}/wp-content ]; then

    cd /root/${SERVER_DOMAIN}
    rm -f "/vagrant/serverport/${SERVER_DOMAIN}/wp-content.tgz"
    tar -zcvf "/vagrant/serverport/${SERVER_DOMAIN}/wp-content.tgz" wp-content

fi

docker exec -i $DOCKERNAME_DB mysqldump -u root -p"${MYSQL_ROOT_PASSWORD}" --databases ${MYSQL_DATABASE} | gzip > /vagrant/serverport/${SERVER_DOMAIN}/serverdump.gz
