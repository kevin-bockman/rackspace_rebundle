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
