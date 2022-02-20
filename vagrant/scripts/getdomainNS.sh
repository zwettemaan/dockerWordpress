export DOMAIN_NS="$(dig +short SOA $1 | cut -d' ' -f1)"
echo $DOMAIN_NS