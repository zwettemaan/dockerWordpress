export REPO_ROOT=`dirname "$0"`/
pushd "$REPO_ROOT" > /dev/null
export REPO_ROOT=`pwd`/

echo ""
echo "Extracting all custom data and resetting to a clean state."
echo "The files are not deleted."
echo "They are instead moved to a directory 'extractedContents', which you can then manually file away"
echo ""
echo "Are you really sure (Y/N)?"

read -r confirm

if [ "${confirm}" == "Y" ]; then
	if [ -d "${REPO_ROOT}extractedContents" ]; then
		echo "Directory 'extractedContents' aready exists. Aborting."
		exit
	fi
	mkdir "${REPO_ROOT}extractedContents"
	mv "${REPO_ROOT}bootstrap.sh" "${REPO_ROOT}extractedContents"
	mv "${REPO_ROOT}config.rb" "${REPO_ROOT}extractedContents"
	mv "${REPO_ROOT}config.sh" "${REPO_ROOT}extractedContents"
	mv "${REPO_ROOT}config.txt" "${REPO_ROOT}extractedContents"
	mv "${REPO_ROOT}Vagrantfile" "${REPO_ROOT}extractedContents"
	mv "${REPO_ROOT}.vagrant" "${REPO_ROOT}extractedContents/.vagrant"
	mv "${REPO_ROOT}ssh" "${REPO_ROOT}extractedContents/ssh"
	mv "${REPO_ROOT}vagrant" "${REPO_ROOT}extractedContents/vagrant"
fi