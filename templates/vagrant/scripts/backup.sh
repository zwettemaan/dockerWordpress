export SCRIPTDIR=`dirname "$0"`
cd "${SCRIPTDIR}"
export SCRIPTDIR=`pwd`

. /root/setupenv.sh

if [ "${OWNCLOUD_BACKUP_SERVER}" != "" ]; then

	. /vagrant/scripts/credentials.ini

	/vagrant/scripts/dumpAllServers.sh

	cd /vagrant
	tar -zcvf ${BACKUP_ARCHIVE_PATH} ${BACKUP_FILE}

	curl -X PUT -u ${BU_USER}:${BU_PASS} --data-binary @"${BACKUP_ARCHIVE_PATH}" "https://${OWNCLOUD_BACKUP_SERVER}/remote.php/webdav/Docker/${BACKUP_ARCHIVE}"
	rm -f ${UPLOAD}
fi