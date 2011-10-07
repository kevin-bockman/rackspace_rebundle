#!/bin/bash -x
source functions.sh

grep ". /etc/bashrc" /root/.bashrc
if [ "$?" == "1" ]; then
  cat <<-BASHRC >> /root/.bashrc
# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi
BASHRC
fi

# Install rubygems (if not already installed)
which gem
[ "$?" == "1" ] && ./rubygems.sh

#
# Download RightLink
#
download $rightlink_ver
[ "$?" == "1" ] && build $rightlink_ver

#
# Disable unnecessary services
#

#
# Boot fast
#
touch /fastboot

#
# setup hostname
#
echo "localhost" > /etc/hostname
echo "127.0.0.1   localhost   localhost.localdomain" > /etc/hosts

# NTP (w-3981)
echo "jiffies" > /sys/devices/system/clocksource/clocksource0/current_clocksource

ntp_conf="/etc/ntp.conf"
grep "tinker panic 0" $ntp_conf
[ "$?" == "1" ] && sed -i "1i tinker panic 0 dispersion 1.000" $ntp_conf

sed -i "/^server.*127.127/d" $ntp_conf
sed -i "/^fudge.*127.127/d" $ntp_conf
