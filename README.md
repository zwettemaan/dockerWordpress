# dockerWordpress

Build a Docker host for Wordpress either on VirtualBox (local) or DigitalOcean (cloud) and shuttle complete WordPress sites between hosts

## Preamble

The scripts in this repository are configured for specific versions of various software components. 

As these dependencies all change over time, some stuff will no doubt break.

I've attempted to make all code readable so any necessary updates or fixes would hopefully be easy to figure out.

## What it does

This repository contains a set of scripts which automate managing Docker-based host for one or more WordPress sites. 

It offers:

- Backups
- Easily move WordPress sites wholesale 
- Easily restore WordPress sites to a previous backup
- Easily add additional WordPress sites on the same host
- Handle Let's Encrypt certificate renewals, if necessary in coordination with CloudFlare

# How to use

## Vagrant

Install Vagrant on your computer

https://www.vagrantup.com/downloads

At the time of this writing, the version is Vagrant 2.2.19

## VirtualBox

Install VirtualBox on your computer

At the time of this writing, the version of VirtualBox is 6.1.32



