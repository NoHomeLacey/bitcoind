#!/bin/sh

#########
# Bitcoind and c-lightning on Ubuntu 16.04.4 Server Script
# Author: Paul Guest <paul.guest@acadsol.co.uk>
# Version: v0.1, 2018-03-17
# Source: https://github.com/berferd67/bitcoind
#########

########
# Check script is being run as root
########

#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

########
# Set Hostname
########

#Assign existing hostname to $HOSTNAME
HOSTNAME=$(cat /etc/hostname)

#Display existing hostname
echo "Existing hostname is $HOSTNAME"

#Ask for new domainname $DOMAIN
echo "Enter new domain name: "
read DOMAIN

#Ask for new hostname $NEWHOST
echo "Enter new hostname: "
read NEWHOST

#change hostname in /etc/hosts & /etc/hostname
sed -i "s/$HOSTNAME/$NEWHOST/g" /etc/hosts
sed -i "s/$HOSTNAME/$NEWHOST/g" /etc/hostname

#display new hostname
echo "Your new hostname is $NEWHOST"

########
# Update repos and install updates
########

apt-get update && apt-get -y dist-upgrade && apt-get clean

#Install dev tools

apt-get install -y autoconf automake build-essential git libtool libgmp-dev libsqlite3-dev python python3 net-tools libsodium-dev

#Install additional dependencies for development and testing

apt-get install -y asciidoc valgrind python3-pip
pip3 install python-bitcoinlib

########
#Configure Uncomplicated Firewall to allow access to ssh, bitcoind and lightningd
########

ufw enable
ufw allow 22
ufw allow 8333
ufw allow 9735

########
# Harden ssh server
########

#Install fail2ban which blocks repaeated login attempts (banned for 10 mins after 5 failed logins)
apt-get -y install fail2ban

#Configure keys based authentication
cd ~/
ssh-keygen -t rsa
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

#Disable root logins
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.ORIG
sed -i "s/#PermitRootLogin/PermitRootLogin/g" /etc/ssh/sshd_config
sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config

#Disbale Protocol 1
sed -i "s/# Protocol 2,1/Protocol 2/g" /etc/ssh/sshd_config

#Disable password authentication forcing use of keys
sed -i "s/PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config

#PasswordAuthentication no

#Restart Networking to enforce changes
#Don't worry - it *shouldn't* terminate your current session.
/etc/init.d/networking restart

########
#Install Bitcoin and Lightning
########

#Install Bitcoind

apt-get install -y software-properties-common
add-apt-repository ppa:bitcoin/bitcoin
apt-get update
apt-get install -y bitcoind


#Install Lightning

git clone https://github.com/ElementsProject/lightning.git
cd lightning
make

#Run bitcoind and lightningd

# bitcoind &
# ./lightningd/lightningd &
# ./cli/lightning-cli help
