#!/bin/sh
#
# Clean image before bundling
#

clean()
{
  echo "Cleaning logfile: $1"
  [ -f "$1" ] && cat /dev/null > $1
  rm -f $1.[12345]
}

#
# /etc/rightscale.d files
#
cp /etc/rightscale.d/rightscale-release /tmp/rightscale-release
rm -rf /etc/rightscale.d
mkdir /etc/rightscale.d
echo -n "rackspace" > /etc/rightscale.d/cloud
cp /tmp/rightscale-release /etc/rightscale.d/rightscale-release 

#
# /root
#
cp /root/.bashrc /root/.bash_logout /root/.profile /root/.rightscale

rm -rf /root/.ssh
rm -rf /root/.gem
rm -f /root/*.tar
rm -f /root/*.
rm -rf /root/files
rm -f /root/*
rm -f /root/.*

mv /root/.rightscale/.bashrc /root/.rightscale/.bash_logout /root/.rightscale/.profile /root

#
# /etc
#
rm -f /etc/hosts.backup.*

#
# Apt
#
apt-get clean

#
# State information
#
rm -f /var/spool/cloud/*
rm -rf /tmp/* /tmp/.*
mkdir /tmp/agent-smith

#
# Log files
#
find /var/log -type f -exec rm -f {} \;

find /var/cache -type f -exec rm -f {} \;

# Rebuild Apt cache
mkdir -p /var/cache/apt/archives/partial /var/cache/debconf
apt-cache gencaches

rm -rf /var/mail/*
rm -rf /root/.cache

find /etc -name \*~ -exec rm -- {} \;
find /etc -name \*.backup* -exec rm -- {} \;
