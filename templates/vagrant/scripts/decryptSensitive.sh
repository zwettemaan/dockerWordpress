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
    if [ -f ${BASE_FILENAME}.orig.cpt ]; then
        CRYPT_LIST="$CRYPT_LIST ${BASE_FILENAME}.temp.cpt"
        cp ${BASE_FILENAME}.orig.cpt ${BASE_FILENAME}.temp.cpt   
    fi
done

ccrypt -k cryptkeyfile.txt -d ${CRYPT_LIST}

for BASE_FILENAME in ${BASE_FILENAME_LIST[@]}; do
    if [ ! -f ${BASE_FILENAME} ]; then
        mv ${BASE_FILENAME}.temp ${BASE_FILENAME}
        chmod 600 ${BASE_FILENAME}
    else 
        rm -f ${BASE_FILENAME}.temp
    fi  
done

