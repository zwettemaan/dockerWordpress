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
export DOCKERNAME_AP=${DOCKERNAME}_httpd_1

if [ -d /root/${SERVER_DOMAIN}/html ]; then

    cd /root/${SERVER_DOMAIN}
    rm -f "/vagrant/serverport/${SERVER_DOMAIN}/html.tgz"
    tar -zcvf "/vagrant/serverport/${SERVER_DOMAIN}/html.tgz" html

fi
