# Initial install

## Clone this repo `dockerWordpress`

Put it somewhere convenient on your computer.

## OpenSSL

You need openssl installed so we can generate key files

## Vagrant

Install Vagrant on your computer

https://www.vagrantup.com/downloads

At the time of this writing, the version is Vagrant 2.2.19

During setup we use a single folder `/vagrant` which is shared between your local copy of the repository and the Ubuntu host on the virtual machine.

## DNS provider

To use these scripts, you do not need to use CloudFlare as your registrar, but you do need to use CloudFlare to handle your DNS entries.

If you are currently running your DNS servers with another provider or with your registrar, you need to move these over to use the CloudFlare DNS servers.

Registering your domain and handling DNS for your domain are two separate things. These services are often handled by the registrar, but there is no obligation to do that - you can keep your current registrar and have the DNS services be handled by CloudFlare.

https://www.cloudflare.com/dns/

Remark: for the sake of argument, I'll be using the following settings for a demo-site. I am using a local address - 192.168.5.xxx is not an internet address, it can
only be used on a local LAN. The IP addresses you'll use will be different - you'll have to use information provided by CloudFlare and your virtual machine provider Digital Ocean, Azure, Linode...).

```
domain: demo.tmp.domains
IP address: 192.168.5.123
```

## Set up CloudFlare

First log in to CloudFlare and use the function 'Add a Site' to add your domain. 

You can start out with CloudFlare's free plan, and upgrade later to a paid plan when needed.

CloudFlare will automatically copy your existing DNS entries, if any.

If you have no entries just yet (you're starting from scratch with a brand new domain), you can continue the CloudFlare setup without DNS records. When you get to the 'Review your DNS records' page, simply click 'Continue'.

Change the name servers as directed. 

Afterwards, you might need to wait up to 24 hours for this change to become effective.

## VirtualBox

Install VirtualBox on your computer

At the time of this writing, the version of VirtualBox is 6.1.34

## Vagrant plugins

```
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-digitalocean
```

## Choose between VirtualBox or DigitalOcean

VirtualBox is used for testing stuff locally - i.e. the server is built as a virtual machine running on your own computer; you typically want to NOT expose this server to the internet and use it purely for internal testing.

I normally set up both - i.e. I copy the repo twice, and configure one copy for VirtualBox, and the other copy for DigitalOcean. Then I can use the
various helper scripts to transport WordPress sites between the 'real' DigitalOcean server and the 'test' VirtualBox server.

The templates directory of this repo contains at least two Vagrantfiles: `templates/Vagrantfile.DigitalOcean` and `templates/Vagrantfile.VirtualBox`

Neither of these file is 'active'. 

The Vagrant software expects a file called just `Vagrantfile` (without file name extension) in the root directory of the repository.

Make a copy of either `templates/Vagrantfile.DigitalOcean` or `templates/Vagrantfile.VirtualBox`, and put it into the root directory of your repository, and rename it to `Vagrantfile`.

Note: such `Vagrantfile` (without file name extension) is listed as an entry in the `.gitignore` list. 

The copied `Vagrantfile` is not tracked by the git repository, and you can edit `Vagrantfile` to your heart's content, without fear that any changes you would disrupt the content of the parent git repository.

If things go to custard, you can always start over by making a fresh copy of `Vagrantfile.DigitalOcean` or `Vagrantfile.VirtualBox`.

Both `Vagrantfile.xxx` will pass an environment variable `SERVERTYPE` to the `bootstrap.sh` script which is run by Vagrant when launching the virtual computer.

This mechanism allows the `bootstrap.sh` script to alter its behavior depending on whether we're building a local virtual machine (aka VM) in VirtualBox, or a remote VM with DigitalOcean.

## Ubuntu

The scripts are set up to use Ubuntu as the host operating system for Docker.

We're using Ubuntu 22.04 LTS which should be supported until 2027

## Adjust to your environment

You will need to configure the scripts to match your particular requirements. The config files contain constants that need to 
be customized for your particular setup.

Search all text files for the prefix 'MY_' - e.g. you'll find things like
```
...
VIRTUALBOX_LOCAL_IP_ADDRESS = "MY_localIPAddress"
...
```

which indicates you need to replace that string with something else - in this case, the IP address you desire to use for your local VM in VirtualBox.


## VirtualBox

To spin up your WordPress site on a local VirtualBox, duplicate the `templates/Vagrantfile.VirtualBox` to `Vagrantfile`.

Make a copy of the files `templates/config.rb` and `templates/config.sh` and put them in the root of the repository.

Edit these copies of `config.rb` and `config.sh` to match your needs.

For a VirtualBox setup you can ignore any settings that start with `DIGOCE_...`.

If you have a local static IP address on your office network that you can use for running a local web server, you can set `VIRTUALBOX_LOCAL_IP_ADDRESS` in `config.rb` to that IP address. 

The server will then be visible and accessible to other computers on your office network.

If you don't have that information, you can instead create a host-only network (i.e. a network that only exists in your computer). 

This is a feature in VirtualBox.

Then use an address on that network. In that case, the server will only be visible and accessible from your own computer.

See 'File - Host Network Manager...' in VirtualBox. 

### Example

For the sake of argument, I've set up 192.168.5.xxx as a host-only network in VirtualBox.

In that case, any address between 192.168.5.2 and 192.168.5.254 will do. 

I randomly picked IP address 192.168.5.123 as the IP address I'll use for the VirtualBox server. 

192.168.5.1 is the address that will be used to represent my own physical computer on the host-only network.

We'll have at least two IP addresses on this network: 192.168.5.1 is my physical computer and 192.168.5.123 is the virtual machine.

Note: using CloudFlare is not a hard requirement for setting up a local VirtualBox server; it only becomes a requirement for using the scripts with DigitalOcean.

If you don't use CloudFlare, the process will be slightly different than what is documented below.

Using CloudFlare as my DNS provider, I set up demo.tmp.domains to map to address 192.168.5.123. 

Important: no proxying; the DNS entry needs to be set to 'DNS only'. 

As a result, each time I use the domain name 'demo.tmp.domains' it will be translated to 192.168.5.123.

Note: despite this mapping, address 192.168.5.123 is still not accessible 'from the outside'; it can only be reached from your own computer (for a host-only network) or from your own office network (if your office network were to be using 192.168.5.xxx for its internal addresses).

I.e. if someone tried to access 192.168.5.123 or demo.tmp.domains from anywhere on the internet, they would NOT be able to reach your virtual machine. The network packets cannot ever make it through.

Addresses that start with 192.168.xxx.xxx are 'unroutable' and cannot be accessed from anywhere else but the local network. See https://en.wikipedia.org/wiki/Reserved_IP_addresses

### Starting the machine

If you've gone through these motions previously, you might want to run
```
vagrant box update
```
to make sure you have the latest Vagrant box.

If you want to start over from scratch, first run
```
vagrant destroy
```
which will destroy any previously created virtual machine, so you can have a clean slate.

Start the virtual machine:
```
vagrant up
```
If the virtual machine does not exist yet, it will be built. Otherwise, the existing virtual machine will be started.

## DigitalOcean

To spin up your WordPress site on a droplet at DigitalOcean duplicate the `Vagrantfile.DigitalOcean` to `Vagrantfile`.

Edit the `config.rb` and `config.sh` to match your needs

For VirtualBox you can ignore any settings that start with `VIRTUALBOX_...`.
