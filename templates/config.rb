PRIVATE_KEY_FILE="!!PRIVATE_KEY_FILE"

# If you make multiple copies of the repo to set up multiple VirtualBox instances, 
# each should use a different address here
VIRTUALBOX_LOCAL_IP_ADDRESS="!!VIRTUALBOX_LOCAL_IP_ADDRESS"

# You would normally choose the same name as the LETSENCRYPT_CLOUDFLARE_SHARED_DOMAIN 
# you have configred in config.sh

DIGOCE_DROPLET_NAME="!!MAIN_DOMAIN"
DIGOCE_PROVIDER_TOKEN="!!DIGOCE_PROVIDER_TOKEN"

SHARED_FOLDER_NAME="vagrant"
SHARED_FOLDER_ID="vagrant-root"

# We're using Ubuntu 22.04 LTS which should be supported until 2027.
VIRTUALBOX_UBUNTU_VERSION="ubuntu/jammy64"
DIGOCE_UBUNTU_VERSION="ubuntu-22-04-x64"

DIGOCE_VM_BOX="digital_ocean"
DIGOCE_VM_BOX_URL="https://github.com/devopsgroup-io/vagrant-digitalocean/raw/master/box/digital_ocean.box"
DIGOCE_PROVIDER_REGION="nyc1"
DIGOCE_PROVIDER_SIZE="s-1vcpu-2gb"

