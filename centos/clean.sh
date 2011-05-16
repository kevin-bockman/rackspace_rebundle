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
rm -rf /root/.ssh
rm -rf /root/.gem

#
# /etc
#
rm -f /etc/hosts.backup.*

#
# Yum
#
yum -y clean all

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

find /etc -name \*~ -exec rm -- {} \;
find /etc -name \*.backup* -exec rm -- {} \;

rm -rf /root/files
rm /root/*.sh

#
# dot files
#
rm -f /root/*.tar /root/.*
