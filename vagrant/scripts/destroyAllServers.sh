export SCRIPTDIR=`dirname "$0"`
cd "${SCRIPTDIR}"
export SCRIPTDIR=`pwd`

. serverList.sh

export GLOBAL_NGINX_ACTIVE=`systemctl is-active nginx.service`
if [ ${GLOBAL_NGINX_ACTIVE} == "active" ]; then
    service nginx stop
fi

for SERVER_INFO in ${SERVERLIST[@]}; do
	export SERVERTYPE=`echo ${SERVER_INFO} | sed -E -e "s/^([^,]*),([^,]*),([^,]*)/\\1/g"`
	export SERVER_DOMAIN=`echo ${SERVER_INFO} | sed -E -e "s/^([^,]*),([^,]*),([^,]*)/\\2/g"`
	export DOCKERNAME=`echo ${SERVER_INFO} | sed -E -e "s/^([^,]*),([^,]*),([^,]*)/\\3/g"`
	echo "Destroying ${SERVER_DOMAIN}"
	/vagrant/scripts/destroy${SERVERTYPE}Server.sh ${SERVER_DOMAIN} ${DOCKERNAME} 2>&1 ${VERBOSE_OUTPUT}
done

if [ ${GLOBAL_NGINX_ACTIVE} == "active" ]; then
    service nginx start
fi
