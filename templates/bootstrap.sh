#!/usr/bin/env bash

. config.sh

if [ "${SERVERTYPE}" == "dockerlocal" ]; then
  export SERVER_SHORT_NAME=dockerlocal
  export LOCALVM=1
else
  export SERVER_SHORT_NAME=docker
  export LOCALVM=0
fi

if [ "${VERBOSE}" == "1" ]; then
  export VERBOSE_OUTPUT=""
else
  export VERBOSE_OUTPUT="> /dev/null"
fi

apt-get -y update

if [ "$DEV_ADD_TOOLS" == "1" ]; then
  apt-get -y install linux-headers-$(uname -r) build-essential dkms
  if [ "${SERVERTYPE}" == "dockerlocal" ]; then
    cd /opt/VBoxGuestAdditions-*/init  
    ./vboxadd setup
  fi
fi

rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/NZ /etc/localtime

apt-get -y install docker.io
apt-get -y install docker-compose
apt-get -y install nginx
apt-get -y install certbot 
apt-get -y install ccrypt
apt-get -y install python3-pip
apt-get -y install fail2ban
apt-get -y install inotify-tools
apt-get -y install php7.4-cli php7.4-curl
apt-get -y install net-tools

export IPV4_ADDR=`hostname -I | cut -d' ' -f1`

cat > /root/setupenv.sh << EOF
export VERBOSE="${VERBOSE}"
export DEV_ADD_TOOLS="${DEV_ADD_TOOLS}"
export VERBOSE_OUTPUT="${VERBOSE_OUTPUT}"
export APACHEVERSION="${APACHEVERSION}"
export APACHEIMAGE="${APACHEIMAGE}"
export WORDPRESSVERSION="${WORDPRESSVERSION}"
export WORDPRESSIMAGE="${WORDPRESSIMAGE}"
export DOKUWIKIVERSION="${DOKUWIKIVERSION}"
export DOKUWIKIIMAGE="${DOKUWIKIIMAGE}"
export MYSQLIMAGE="${MYSQLIMAGE}"
export SERVERTYPE="${SERVERTYPE}"
export SERVER_SHORT_NAME="${SERVER_SHORT_NAME}"
export LOCALVM="${LOCALVM}"
export LETSENCRYPT_IWANTMYNAME_SHARED_DOMAIN="${LETSENCRYPT_IWANTMYNAME_SHARED_DOMAIN}"
export LETSENCRYPT_CLOUDFLARE_SHARED_DOMAIN="${LETSENCRYPT_CLOUDFLARE_SHARED_DOMAIN}"
export TRUSTED_IP="${TRUSTED_IP}"
export IPV4_ADDR="${IPV4_ADDR}"
export OWNCLOUD_BACKUP_SERVER="${OWNCLOUD_BACKUP_SERVER}"
EOF

pip install zope-interface
pip install certbot-dns-cloudflare

/vagrant/scripts/decryptSensitive.sh

groupadd dokuwiki -g 1001
useradd dokuwiki -u 1001 -g dokuwiki

if [ ! -d /vagrant/serverport/letsencrypt ]; then
  if [ -f /vagrant/serverport/letsencrypt.tgz ]; then
    pushd /vagrant/serverport
    tar -zxvf letsencrypt.tgz
    popd
  fi
fi

if [ ! -f /vagrant/serverport/letsencrypt.tgz ]; then
  /vagrant/scripts/offlinecerts.sh
  cd /vagrant/serverport
  tar -zcvf /vagrant/serverport/letsencrypt.tgz letsencrypt/
fi

cd /etc/ssl/certs
openssl dhparam -out dhparam.pem 2048

cd /etc
tar -zxvf /vagrant/serverport/letsencrypt.tgz

if [ ! -d /etc/docker ]; then
  mkdir /etc/docker
fi

cd /etc/nginx/sites-enabled
rm -f default

cat > /etc/fail2ban/filter.d/docuwiki-fish.conf << EOF
# Fail2Ban configuration file
#
#
# \$Revision: 1 \$
#
 
[Definition]
# Option: failregex
# Notes.: Regexp to catch known spambots and software alike. Please verify
# that it is your intent to block IPs which were driven by
# abovementioned bots.
# Values: TEXT
#
failregex = ^<HOST> -.*GET.*\/dokuwiki\/doku\.php\?.*do=login.*\$

# Option: ignoreregex
# Notes.: regex to ignore. If this regex matches, the line is ignored.
# Values: TEXT
#
ignoreregex =
EOF

cat > /etc/fail2ban/filter.d/docuwiki-noregister.conf << EOF
# Fail2Ban configuration file
#
#
# \$Revision: 1 \$
#
 
[Definition]
# Option: failregex
# Notes.: Regexp to catch known spambots and software alike. Please verify
# that it is your intent to block IPs which were driven by
# abovementioned bots.
# Values: TEXT
#
failregex = ^<HOST> -.*GET.*\/dokuwiki\/doku\.php\?.*do=register.*\$

# Option: ignoreregex
# Notes.: regex to ignore. If this regex matches, the line is ignored.
# Values: TEXT
#
ignoreregex =
EOF

cat > /etc/fail2ban/filter.d/pythonattack.conf << EOF
# Fail2Ban configuration file
#
#
# \$Revision: 1 \$
#
 
[Definition]
# Option: failregex
# Notes.: Regexp to catch known spambots and software alike. Please verify
# that it is your intent to block IPs which were driven by
# abovementioned bots.
# Values: TEXT
#

failregex = ^<HOST> -.* \/jmx-console.*\$
            ^<HOST> -.* \/cgi-bin.*\$
            ^<HOST> -.* \/vicidial.*\$
            ^<HOST> -.* \/manager.*\$
            ^<HOST> -.* \/\/administrator.*\$
            ^<HOST> -.* \/administrator.*\$
            ^<HOST> -.*\/[Dd]rupal.*\$
            ^<HOST> -.*\/joomla.*\$
            ^<HOST> -.*\/Joomla.*\$
            ^<HOST> -.*\/cms.*\$
            ^<HOST> -.*\/phpmyadmin.*\$
            ^<HOST> -.*\/phpMyAdmin.*\$
            ^<HOST> -.*\/mysql.*\$
            ^<HOST> -.*\/sql.*\$
            ^<HOST> -.*\/myadmin.*\$
            ^<HOST> -.*\/sqlite.*\$
            ^<HOST> -.*\/SQLite.*\$
            ^<HOST> -.*\/webdav.*\$
            ^<HOST> -.*\/webdav.*\$
            ^<HOST> -.*\/web-console.*\$

# Option: ignoreregex
# Notes.: regex to ignore. If this regex matches, the line is ignored.
# Values: TEXT
#
ignoreregex =
EOF

cat > /etc/fail2ban/filter.d/wordpress-badlogin.conf << EOF
# Fail2Ban configuration file
#
#
# \$Revision: 1 \$
#
 
[Definition]
# Option: failregex
# Notes.: Regexp to catch known spambots and software alike. Please verify
# that it is your intent to block IPs which were driven by
# abovementioned bots.
# Values: TEXT
#
failregex = ^<HOST>\s*-.*POST.*\/wp-login.php.*


# Option: ignoreregex
# Notes.: regex to ignore. If this regex matches, the line is ignored.
# Values: TEXT
#
ignoreregex =
EOF

cat > /etc/fail2ban/filter.d/wordpress-fish.conf << EOF
# Fail2Ban configuration file
#
#
# \$Revision: 1 \$
#
 
[Definition]
# Option: failregex
# Notes.: Regexp to catch known spambots and software alike. Please verify
# that it is your intent to block IPs which were driven by
# abovementioned bots.
# Values: TEXT
#
failregex = ^<HOST> -.*wp-login.*\$

# Option: ignoreregex
# Notes.: regex to ignore. If this regex matches, the line is ignored.
# Values: TEXT
#
ignoreregex =
EOF

cat > /etc/fail2ban/filter.d/wordpress-rpc.conf << EOF
# Fail2Ban configuration file
#
#
# \$Revision: 1 \$
#
 
[Definition]
# Option: failregex
# Notes.: Regexp to catch known spambots and software alike. Please verify
# that it is your intent to block IPs which were driven by
# abovementioned bots.
# Values: TEXT
#
failregex = ^<HOST> -.*xmlrpc.*\$

# Option: ignoreregex
# Notes.: regex to ignore. If this regex matches, the line is ignored.
# Values: TEXT
#
ignoreregex =
EOF

cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
ignoreip = ${TRUSTED_IP}
EOF

cat /etc/fail2ban/jail.conf >> /etc/fail2ban/jail.local

cat >> /etc/fail2ban/jail.local << EOF
[wordpress]
enabled = true
port = http,https
filter = wordpress-fish
action = cloudflare-blacklist
         iptables-allports
logpath = /var/log/nginx/access.log
          /var/log/nginx/access.log.1
maxretry = 5
findtime = 86400
bantime = 864000

[docuwiki-noreg]
enabled = true
port = http,https
filter = docuwiki-noregister
action = cloudflare-blacklist
         iptables-allports
logpath = /var/log/nginx/access.log
          /var/log/nginx/access.log.1
maxretry = 0
findtime = 86400
bantime = 864000

[docuwiki-fish]
enabled = true
port = http,https
filter = docuwiki-fish
action = cloudflare-blacklist
         iptables-allports
logpath = /var/log/nginx/access.log
          /var/log/nginx/access.log.1
maxretry = 1
findtime = 86400
bantime = 864000

[peters-fish]
enabled = true
port = http,https
filter = petersfish
action = cloudflare-blacklist
         iptables-allports
logpath = /var/log/nginx/access.log
          /var/log/nginx/access.log.1
maxretry = 0
findtime = 86400
bantime = 864000

[wordprpc]
enabled = true
port = http,https
filter = wordpress-rpc
action = cloudflare-blacklist
         iptables-allports
logpath = /var/log/nginx/access.log
          /var/log/nginx/access.log.1
maxretry = 0
findtime = 86400
bantime = 864000

[wordprgin]
enabled = true
port = http,https
filter = wordpress-badlogin
action = cloudflare-blacklist
         iptables-allports
logpath = /var/log/nginx/access.log
          /var/log/nginx/access.log.1
maxretry = 5
findtime = 8640

[pythonattack]
enabled = true
port = http,https
filter = pythonattack
action = cloudflare-blacklist
         iptables
logpath = /var/log/nginx/access.log
          /var/log/nginx/access.log.1
maxretry = 0
findtime = 86400
bantime = 864000
EOF

. /vagrant/scripts/credentials.ini

cat > /etc/fail2ban/action.d/cloudflare-blacklist.conf << EOF
#
# Author: Mike Rushton
# Source: https://github.com/fail2ban/fail2ban/blob/master/config/action.d/cloudflare.conf
# Referenced from: http://www.normyee.net/blog/2012/02/02/adding-cloudflare-support-to-fail2ban by NORM YEE
#
# To get your Cloudflare API key: https://www.cloudflare.com/my-account
#

[Definition]

# Option:  actionstart
# Notes.:  command executed once at the start of Fail2Ban.
# Values:  CMD
#
actionstart =

# Option:  actionstop
# Notes.:  command executed once at the end of Fail2Ban
# Values:  CMD
#
actionstop =

# Option:  actioncheck
# Notes.:  command executed once before each actionban command
# Values:  CMD
#
actioncheck =

# Option:  actionban
# Notes.:  command executed when banning an IP. Take care that the
#          command is executed with Fail2Ban user rights.
# Tags:    <ip>  IP address
#          <failures>  number of failures
#          <time>  unix timestamp of the ban time
# Values:  CMD
#
#actionban = curl https://www.cloudflare.com/api_json.html -d 'a=ban' -d 'tkn=<cftoken>' -d 'email=<cfuser>' -d 'key=<ip>'

actionban = curl -s -X POST "https://api.cloudflare.com/client/v4/user/firewall/access_rules/rules" -H "X-Auth-Email: <cfuser>" -H "X-Auth-Key: <cftoken>" -H "Content-Type: application/json" --data '{"mode":"block","configuration":{"target":"ip","value":"<ip>"},"notes":"Fail2ban"}' 

# Option:  actionunban
# Notes.:  command executed when unbanning an IP. Take care that the
#          command is executed with Fail2Ban user rights.
# Tags:    <ip>  IP address
#          <failures>  number of failures
#          <time>  unix timestamp of the ban time
# Values:  CMD
#
# actionunban = curl https://www.cloudflare.com/api_json.html -d 'a=nul' -d 'tkn=<cftoken>' -d 'email=<cfuser>' -d 'key=<ip>'

actionunban = curl -X DELETE "https://api.cloudflare.com/client/v4/user/firewall/access_rules/rules/\$( curl -s -X GET "https://api.cloudflare.com/client/v4/user/firewall/access_rules/rules?mode=block&configuration_target=ip&configuration_value=<ip>&page=1&per_page=1&match=all" -H "X-Auth-Email: <cfuser>" -H "X-Auth-Key: <cftoken>" -H "Content-Type: application/json" | awk -F"[,:}]" '{for(i=1;i<=NF;i++){if(\$i~/'id'\042/){print \$(i+1)}}}' | tr -d '"' | head -n 1)" -H "X-Auth-Email: <cfuser>" -H "X-Auth-Key: <cftoken>" -H "Content-Type: application/json"

[Init]

cftoken = ${CF_PASS}
cfuser = ${CF_USER}

EOF

cat > /root/clearIPTables << EOF
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t mangle -X
iptables -t mangle -F
iptables -t nat -X
iptables -t nat -F
iptables -F
iptables -X
EOF

chmod +x /root/clearIPTables

cat > /root/clearCloudFlare.php << EOF
<?php
// Read in all existing CloudFlare IP blocks then delete 
// all which are older than some specified value

\$authemail = "${CF_USER}";
\$authkey   = "${CF_PASS}";
\$page      = 1;
\$ids       = array(); // id's to block
\$cutoff    = time()-(3600*24*28); // 28 days

\$loop = 1;
while(1)
{
  echo "Scan loop #\$loop\n";
  \$loop++;

    \$ch = curl_init("https://api.cloudflare.com/client/v4/user/firewall/access_rules/rules?mode=block&configuration_target=ip&page=\$page&per_page=10&order=created_on&direction=asc&match=all");
    curl_setopt(\$ch, CURLOPT_HTTPHEADER, array(
        'X-Auth-Email: '.\$authemail,
        'X-Auth-Key: '.\$authkey,
        'Content-Type: application/json'
        ));
    curl_setopt(\$ch, CURLOPT_RETURNTRANSFER, 1);
    \$response = curl_exec(\$ch);
    curl_close(\$ch);

    \$r = json_decode(\$response, true);

    \$result = \$r['result'];

    // Scan for results which were created BEFORE \$cutoff
    foreach (\$result as \$block)
    {
        // Only remove 'block' type rules
        // And not if 'donotexpire' is in the notes
        // for the rule
        if ((\$block['mode'] == 'block') and (!preg_match("/donotexpire/is",\$block['notes'])))
        {
            \$blocktime = strtotime(\$block['created_on']);
            if (\$blocktime <= \$cutoff)
            {
                \$ids[] = \$block['id'];
            }
        }
    }

    \$info   = \$r['result_info'];
    // Result info tells us how many pages in total there are
    \$page++;
    if (\$info['total_pages'] < \$page)
    {
        break;
    }
}

\$log = '';
\$loop = 1;
foreach (\$ids as \$id)
{
  echo "Delete loop #\$loop\n";
  \$loop++;
  
    // Delete this rule
    \$ch = curl_init("https://api.cloudflare.com/client/v4/user/firewall/access_rules/rules/\$id");
    curl_setopt(\$ch, CURLOPT_HTTPHEADER, array(
        'X-Auth-Email: '.\$authemail,
        'X-Auth-Key: '.\$authkey,
        'Content-Type: application/json'
        ));
    curl_setopt(\$ch, CURLOPT_CUSTOMREQUEST, 'DELETE');
    curl_setopt(\$ch, CURLOPT_RETURNTRANSFER, 1);
    \$response = curl_exec(\$ch);
    curl_close(\$ch);

    \$log .= \$response . "\n";
}

if (sizeof(\$ids)>0)
{
    mail(\$authemail, "CF UNBLOCK REPORT " . date('r'), \$log);
}
EOF

cd /root

/vagrant/scripts/setupAllServers.sh

export NGINX_ACTIVE=`systemctl is-active nginx.service`
if [ ${NGINX_ACTIVE} != "active" ]; then
  service nginx start
fi

ufw allow 22
ufw allow 80
ufw allow 443

ufw --force enable

sudo fallocate -l 4G /swap
sudo chmod 600 /swap
sudo mkswap /swap
sudo swapon /swap

cat >> /etc/fstab << EOF
/swap swap swap sw 0 0
EOF

cat >> /etc/hosts << EOF
!!HOSTLIST
EOF

systemctl enable fail2ban
service fail2ban start

crontab < /vagrant/scripts/crontab.txt

if [ "${SERVERTYPE}" == "dockerDO" ]; then
  rm -f /vagrant/scripts/*cpt
  rm -f /vagrant/scripts/decryptSensitive.sh
  rm -f /vagrant/scripts/encryptSensitive.sh
  rm -f /vagrant/scripts/sensitiveFileList.sh
  rm -f /vagrant/scripts/cryptkeyfile.txt
  rm -f /vagrant/scripts/iwantmyname.sh
  rm -f /vagrant/scripts/offlinecerts.sh
  rm -f /vagrant/scripts/certbot_iwantmyname_before.sh
  rm -f /vagrant/scripts/certbot_iwantmyname_delete.sh
fi
