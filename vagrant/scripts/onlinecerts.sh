export SCRIPTDIR=`dirname "$0"`
cd "${SCRIPTDIR}"
export SCRIPTDIR=`pwd`

chmod 644 ./iwantmyname.sh

. certlist_iwantmyname.sh

chmod 600 ./iwantmyname.sh

certbot --expand ${CERTLIST} certonly

. certlist_cloudflare.sh

certbot --expand ${CERTLIST} certonly
