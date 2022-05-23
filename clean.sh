export REPO_ROOT=`dirname "$0"`/
pushd "$REPO_ROOT" > /dev/null
export REPO_ROOT=`pwd`/

echo "Deleting all custom data and resetting to a clean state."
echo "The files are not fully deleted."
echo "They are instead moved to a directory 'toBeDeleted', which you them manually delete"
echo "Are you really sure (Y/N)?"

read -r confirm

if [ "${confirm}" == "Y" ]; then
	if [ -d "${REPO_ROOT}toBeDeleted" ]; then
		echo "Directory 'toBeDeleted' aready exists. Aborting."
		exit
	fi
	mkdir "${REPO_ROOT}toBeDeleted"
	mv "${REPO_ROOT}config.txt" "${REPO_ROOT}toBeDeleted"
	mv "${REPO_ROOT}config.rb" "${REPO_ROOT}toBeDeleted"
	mv "${REPO_ROOT}config.sh" "${REPO_ROOT}toBeDeleted"
	mv "${REPO_ROOT}bootstrap.sh" "${REPO_ROOT}toBeDeleted"
	mv "${REPO_ROOT}Vagrantfile" "${REPO_ROOT}toBeDeleted"
	mv "${REPO_ROOT}ssh" "${REPO_ROOT}toBeDeleted/ssh"
	mv "${REPO_ROOT}vagrant" "${REPO_ROOT}toBeDeleted/vagrant"
fi