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
# /etc
#
rm -f /etc/hosts.backup.*
rm -rf /etc/ssh/ssh_host_*

#
# Yum
#
yum -y clean all

#
# State information
#
rm -f /var/spool/cloud/*
service postfix stop
find /var/spool -type f -exec ~/truncate.sh {} \;
rm -rf /tmp/* /tmp/.*
mkdir /tmp/agent-smith

#
# Log files
#
find /var/log -type f -exec ~/truncate.sh {} \;

rm -rf /var/cache/*
rm -rf /var/mail/*

find /etc -name \*~ -exec rm -- {} \;
find /etc -name \*.backup* -exec rm -- {} \;

#
# /root
#
rm -rf /root/.ssh
rm -rf /root/.gem
rm -f /root/*.tar
rm -rf /root/files
rm -f /root/*
rm -f /root/.bash_history /root/.vim* /root/.lesshst
