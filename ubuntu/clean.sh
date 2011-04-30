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
rm -rf /etc/rightscale.d
mkdir /etc/rightscale.d
echo -n "rackspace" > /etc/rightscale.d/cloud

#
# /root
#
rm -rf /root/.ssh

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

rm -rf /var/cache/*
rm -rf /var/mail/*
rm -rf /root/.cache

find /etc -name \*~ -exec rm -- {} \;
find /etc -name \*.backup* -exec rm -- {} \;

rm -rf /root/files
rm /root/*.sh /root/*.deb
