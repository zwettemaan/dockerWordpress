# dockerWordpress

Build a Docker host for Wordpress either on VirtualBox (local) or DigitalOcean (cloud) and shuttle complete WordPress sites between hosts

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

## Check out this repo

Put it somewhere convenient on your computer.

## Vagrant

Install Vagrant on your computer

https://www.vagrantup.com/downloads

At the time of this writing, the version is Vagrant 2.2.19

During setup we use a single folder `/vagrant` which is shared between your local copy of the repository and the Ubuntu host on the virtual machine.

## VirtualBox

Install VirtualBox on your computer

At the time of this writing, the version of VirtualBox is 6.1.32

## Ubuntu

The scripts are set up to use Ubuntu as the host operating system for Docker.

We're using Ubuntu 20.04 LTS which should be supported until 2024

## Pick a target

The root directory of this repo contains at least two Vagrantfiles: `Vagrantfile.DigitalOcean` and `Vagrantfile.VirtualBox`

Neither of these file is 'active' - the Vagrant software expects a file called `Vagrantfile`. 

The `Vagrantfile` (without file name extension) is part of the `.gitignore` list, so you can edit `Vagrantfile` to your heart's content - any changes you make are reported back to the repository.

If things go to custard, you can always start over with a fresh copy of `Vagrantfile.DigitalOcean` or `Vagrantfile.VirtualBox`.

Both versions will pass an environment variable `SERVERTYPE` to the `bootstrap.sh` script which is run by Vagrant when launching the virtual computer.

This mechanism allows the `bootstrap.sh` script to alter its behavior depending on whether we're building a local VM in VirtualBox, or a remote VM with DigitalOcean.

## VirtualBox

To spin up your WordPress site on a local VirtualBox, duplicate the `Vagrantfile.VirtualBox` to `Vagrantfile`.

Edit the `Vagrantfile` to match your needs

