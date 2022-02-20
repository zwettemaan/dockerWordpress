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

rm -f /tmp/certbot_iwantmyname_before.log
touch /tmp/certbot_iwantmyname_before.log

. certlist_iwantmyname.sh

for CERTBOT_DOMAIN in ${IWANTMYNAME_CERTLIST[@]}; do
  ./certbot_iwantmyname_delete.sh "${CERTBOT_DOMAIN}"
done

. ${SCRIPTDIR}/credentials.ini

cat > /tmp/credentials.ini << EOF
dns_cloudflare_email = ${CF_USER}
dns_cloudflare_api_key = ${CF_PASS}
EOF

certbot -n \
  --expand \
  --agree-tos \
  --email kris@rorohiko.com \
  --work-dir "${DIR_WORK}" \
  --logs-dir "${DIR_LOG}" \
  --config-dir "${DIR_CONFIG}" \
  --manual \
  --preferred-challenges dns \
  --manual-auth-hook "${SCRIPTDIR}/certbot_iwantmyname_before.sh" \
  ${CERTLIST} certonly

. certlist_cloudflare.sh

certbot -n \
  --expand \
  --agree-tos \
  --email kris@rorohiko.com \
  --work-dir "${DIR_WORK}" \
  --logs-dir "${DIR_LOG}" \
  --config-dir "${DIR_CONFIG}" \
  --preferred-challenges dns \
  --dns-cloudflare \
  --dns-cloudflare-propagation-seconds 60 \
  --dns-cloudflare-credentials /tmp/credentials.ini \
  ${CERTLIST} certonly

  rm -f /tmp/credentials.ini