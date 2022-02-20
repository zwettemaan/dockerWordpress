declare -a CLOUDFLARE_CERTLIST=( \
"MY_domain,*.MY_domain"  \
)

export CERTLIST=""
for CLOUDFLARE_CERT in ${CLOUDFLARE_CERTLIST[@]}; do
	export CERTLIST="$CERTLIST -d ${CLOUDFLARE_CERT}"
done
