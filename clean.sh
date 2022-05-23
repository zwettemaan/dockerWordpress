export REPO_ROOT=`dirname "$0"`/
pushd "$REPO_ROOT" > /dev/null
export REPO_ROOT=`pwd`/

echo "Deleting all custom data and resetting to a clean state."
echo "The file config.txt will not be deleted - you need to do that manually."
echo "Are you really sure (Y/N)?"

read -r confirm

if [ "${confirm}" == "Y" ]; then
	rm "${REPO_ROOT}config.rb"
	rm "${REPO_ROOT}config.sh"
	rm "${REPO_ROOT}bootstrap.sh"
	rm "${REPO_ROOT}Vagrantfile"
fi