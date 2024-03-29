export SCRIPTDIR=`dirname "$0"`
cd "${SCRIPTDIR}"
export SCRIPTDIR=`pwd`

export DIR_LOG="/tmp/certbotlog"
export DIR_WORK="/tmp/certbotwork"
export DIR_CONFIG="${SCRIPTDIR}/../serverport/letsencrypt"

if [ ! -d "${DIR_LOG}" ]; then
	mkdir "${DIR_LOG}"
fi

if [ ! -d "${DIR_WORK}" ]; then
	mkdir "${DIR_WORK}"
fi

if [ ! -d "${DIR_CONFIG}" ]; then
	mkdir "${DIR_CONFIG}"
fi

# dns_cloudflare_api_token = ${CLOUDFLARE_API_TOKEN} # fail2ban needs to support tokens and then we can switch
cat > /tmp/credentials.ini << EOF
dns_cloudflare_email = ${CLOUDFLARE_USER}
dns_cloudflare_api_key = ${CLOUDFLARE_GLOBAL_API_KEY}
EOF

chmod 400 /tmp/credentials.ini

. certlist_cloudflare.sh

certbot -n \
  --expand \
  --agree-tos \
  --email !!EMAIL \
  --work-dir "${DIR_WORK}" \
  --logs-dir "${DIR_LOG}" \
  --config-dir "${DIR_CONFIG}" \
  --preferred-challenges dns \
  --dns-cloudflare \
  --dns-cloudflare-propagation-seconds 60 \
  --dns-cloudflare-credentials /tmp/credentials.ini \
  ${CERTLIST} certonly

chmod 600 /tmp/credentials.ini
rm -f /tmp/credentials.ini