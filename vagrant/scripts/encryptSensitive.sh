export SCRIPTDIR=`dirname "$0"`
cd "${SCRIPTDIR}"
export SCRIPTDIR=`pwd`

if [ ! -f cryptkeyfile.txt ]; then
    echo "Please first create cryptkeyfile.txt"
    exit
fi

chmod 400 cryptkeyfile.txt

. sensitiveFileList.sh

CRYPT_LIST=""
for BASE_FILENAME in ${BASE_FILENAME_LIST[@]}; do
    if [ -f ${BASE_FILENAME} ]; then
	   CRYPT_LIST="$CRYPT_LIST ${BASE_FILENAME}.orig"
	   rm -f ${BASE_FILENAME}.orig.cpt
	   cp ${BASE_FILENAME} ${BASE_FILENAME}.orig
	fi
done

ccrypt -k cryptkeyfile.txt -e ${CRYPT_LIST}
