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
# Yum
#
yum -y clean all

#
# State information
#
rm -f /var/spool/cloud/*
rm -f /tmp/inject*
rm -f /tmp/agent-smith*

#
# Log files
#
clean /var/log/agent-smith.log
clean /log/audit.log
clean /var/log/boot.log
clean /var/log/btmp
clean /var/log/cron
clean /var/log/cups/error_log
clean /var/log/decommission
clean /var/log/dmesg
clean /var/log/faillog
clean /var/log/install
clean /var/log/install
clean /var/log/lastlog
clean /var/log/maillog
clean /var/log/messages
clean /var/log/prelink/prelink.log
clean /var/log/secure
clean /var/log/spooler
clean /var/log/tallylog
clean /var/log/wtmp
clean /var/log/yum.log

rm -f /var/log/rs-instance*
rm -f /var/log/anaconda.*
rm -rf /var/log/exim
rm -rf /var/log/news
rm -rf /var/cache/*
rm -rf /var/mail/*

find /etc -name \*~ -exec rm -- {} \;
find /etc -name \*.backup* -exec rm -- {} \;

rm -rf /root/files/
rm /root/*.sh
