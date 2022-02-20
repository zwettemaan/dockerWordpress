# dockerWordpress

Build a Docker host for Wordpress either on VirtualBox (local) or DigitalOcean (cloud) and shuttle complete WordPress sites between hosts.

Initially I'll be documenting how to use these on a Mac - Windows-specific changes are to be done later.

## Preamble

The scripts in this repository are configured for specific versions of various software components. 

As these dependencies all change over time, some stuff will no doubt break.

I've attempted to make all code readable so any necessary updates or fixes would hopefully be easy to figure out.

## What it does

This repository contains a set of scripts which automate managing Docker-based host for one or more WordPress sites. 

It offers:

- Easily spin up new or existing WordPress sites. Initially, the scripts handle DigitalOcean, but other providers can easily be added.
- Backups
- Easily move WordPress sites wholesale 
- Easily restore WordPress sites to a previous backup
- Easily add additional WordPress sites on the same host
- Handle Let's Encrypt certificate renewals, if necessary in coordination with CloudFlare
- Easily mirror your production site on a cloud provider to a local copy running in VirtualBox for debugging, development or post-mortems.
- Use local command-line scripts to trigger actions on the production site in the cloud

# How to use

You will need to configure the scripts to match your particular requirements. Many of the files contain constants that need to 
be customized for your particular setup.

Search all text files for the prefix 'MY_' - e.g. you'll find things like
```
...
VIRTUALBOX_LOCAL_IP_ADDRESS = "MY_localIPAddress"
...
```

which indicates you need to replace that string with something else - in this case, the IP address you want to use for your local VM in VirtualBox.

## Check out this repo

Put it somewhere convenient on your computer.

## Vagrant

Install Vagrant on your computer

https://www.vagrantup.com/downloads

At the time of this writing, the version is Vagrant 2.2.19

During setup we use a single folder `/vagrant` which is shared between your local copy of the repository and the Ubuntu host on the virtual machine.

## DNS provider

You need to use CloudFlare to handle your DNS entries; if you are currently running your DNS servers with another provider, you need to convert these over to use the CloudFlare DNS servers.

https://www.cloudflare.com/plans/#add-ons

## VirtualBox

Install VirtualBox on your computer

At the time of this writing, the version of VirtualBox is 6.1.32

## Vagrant plugins

```
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-digitalocean
```

## Ubuntu

The scripts are set up to use Ubuntu as the host operating system for Docker.

We're using Ubuntu 20.04 LTS which should be supported until 2024

## Pick a target

The root directory of this repo contains at least two Vagrantfiles: `Vagrantfile.DigitalOcean` and `Vagrantfile.VirtualBox`

Neither of these file is 'active' - the Vagrant software expects a file called just `Vagrantfile` (without file name extension).

`Vagrantfile` (without file name extension) is part of the `.gitignore` list, so you can edit the copied `Vagrantfile` to your heart's content - any changes you make are not reported back to the repository.

If things go to custard, you can always start over by making a fresh copy of `Vagrantfile.DigitalOcean` or `Vagrantfile.VirtualBox`.

Both `Vagrantfile.xxx` will pass an environment variable `SERVERTYPE` to the `bootstrap.sh` script which is run by Vagrant when launching the virtual computer.

This mechanism allows the `bootstrap.sh` script to alter its behavior depending on whether we're building a local VM in VirtualBox, or a remote VM with DigitalOcean.

## VirtualBox

To spin up your WordPress site on a local VirtualBox, duplicate the `Vagrantfile.VirtualBox` to `Vagrantfile`.

Make a copy of the files `templates\config.rb` and `templates\config.sh` and put them in the root of the repository.

Edit the copies of `config.rb` and `config.sh` to match your needs.

If you have a free local IP address on your network that you can use for a local web server, you can set `VIRTUALBOX_LOCAL_IP_ADDRESS` to that IP address. The server can be visible and accessible to other computers on your local network.

If you don't have that information, you can instead create a host-only network (a network that only exists in your computer) in VirtualBox and then use an address on that network. In that case, the server will only be visible and accessible from your own computer.



See 'File - Host Network Manager...' in VirtualBox. 

For VirtualBox you can ignore any settings that start with `DIGOCE_...`.

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
