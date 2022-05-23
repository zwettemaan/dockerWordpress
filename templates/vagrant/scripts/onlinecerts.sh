export SCRIPTDIR=`dirname "$0"`
cd "${SCRIPTDIR}"
export SCRIPTDIR=`pwd`

. certlist_cloudflare.sh

certbot --expand ${CERTLIST} certonly
