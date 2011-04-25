#!/bin/bash
#
# First create directories, expand tarballs, etc.
#

mkdir -p /tmp/updates

cd /
mkdir -p /etc/rightscale.d
echo -n rackspace > /etc/rightscale.d/cloud
mkdir -p /root/.rightscale
mv /root/EPEL.pubkey /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL
mv /etc/yum.repos.d /etc/yum.repos.d.old
tar xvf /root/rs_yum.repos.d.tar

#
# Install packages
#
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL
yum -y clean all
yum -y makecache
yum -y groupinstall Base
yum -y install git bind-utils redhat-lsb.x86_64 parted xfsprogs ruby rubygems syslog-ng
yum -y install wget mlocate nano logrotate ruby ruby-devel ruby-docs ruby-irb ruby-libs ruby-mode ruby-rdoc ruby-ri ruby-tcltk postfix openssl openssh openssh-askpass openssh-clients openssh-server curl gcc* zip unzip bison flex compat-libstdc++-296 cvs subversion autoconf automake libtool compat-gcc-34-g77 mutt sysstat rpm-build fping vim-common vim-enhanced rrdtool-1.2.27 rrdtool-devel-1.2.27 rrdtool-doc-1.2.27 rrdtool-perl-1.2.27 rrdtool-python-1.2.27 rrdtool-ruby-1.2.27 rrdtool-tcl-1.2.27 pkgconfig lynx screen yum-utils bwm-ng createrepo redhat-rpm-config redhat-lsb git nscd xfsprogs swig
yum -y remove bluez* gnome-bluetooth*
yum -y clean all

#
# Configuration steps
#
chkconfig --level 2345 nscd on
authconfig --enableshadow --useshadow --enablemd5 --updateall

#
# Java configuration steps
# (Should really be factored out-- use real chef imagebuilder scripts instead?)
# 

if [ `uname -m` = "x86_64" ]; then
  java_arch="amd64"
else
  java_arch="i586"
fi

curl -o /tmp/updates/jdk-6u14-linux-$java_arch.rpm https://s3.amazonaws.com/rightscale_software/java/jdk-6u14-linux-$java_arch.rpm
curl -o /tmp/updates/sun-javadb-common-10.4.2-1.1.i386.rpm https://s3.amazonaws.com/rightscale_software/java/sun-javadb-common-10.4.2-1.1.i386.rpm
curl -o /tmp/updates/sun-javadb-client-10.4.2-1.1.i386.rpm https://s3.amazonaws.com/rightscale_software/java/sun-javadb-client-10.4.2-1.1.i386.rpm
curl -o /tmp/updates/sun-javadb-core-10.4.2-1.1.i386.rpm https://s3.amazonaws.com/rightscale_software/java/sun-javadb-core-10.4.2-1.1.i386.rpm
curl -o /tmp/updates/sun-javadb-demo-10.4.2-1.1.i386.rpm https://s3.amazonaws.com/rightscale_software/java/sun-javadb-demo-10.4.2-1.1.i386.rpm
curl -o /tmp/updates/sun-javadb-docs-10.4.2-1.1.i386.rpm https://s3.amazonaws.com/rightscale_software/java/sun-javadb-docs-10.4.2-1.1.i386.rpm
curl -o /tmp/updates/sun-javadb-javadoc-10.4.2-1.1.i386.rpm https://s3.amazonaws.com/rightscale_software/java/sun-javadb-javadoc-10.4.2-1.1.i386.rpm

#Install RPM's
rpm -Uvh /tmp/updates/jdk-6u14-linux-$java_arch.rpm

rpm -Uvh /tmp/updates/sun-javadb-common-10.4.2-1.1.i386.rpm
rpm -Uvh /tmp/updates/sun-javadb-client-10.4.2-1.1.i386.rpm
rpm -Uvh /tmp/updates/sun-javadb-core-10.4.2-1.1.i386.rpm
rpm -Uvh /tmp/updates/sun-javadb-demo-10.4.2-1.1.i386.rpm
rpm -Uvh /tmp/updates/sun-javadb-docs-10.4.2-1.1.i386.rpm
rpm -Uvh /tmp/updates/sun-javadb-javadoc-10.4.2-1.1.i386.rpm

echo "export JAVA_HOME=/usr/java/default" >> /etc/profile.d/java.sh
chmod +x /etc/profile.d/java.sh

#
# Download RightLink
#
wget http://ec2-us-east-mirror.rightscale.com/rightlink/5.6.28/centos/rightscale_5.6.28-centos_5.4-x86_64.rpm

#
# Install any RPMs
#
rpm -iv /root/*.rpm

#
# Disable unnecessary services
#
chkconfig --level 2345 smartd off
chkconfig --level 2345 portmap off
chkconfig --level 2345 nfslock off
chkconfig --level 2345 mdmonitor off
chkconfig --level 2345 rpcidmapd off
chkconfig --level 2345 rpcgssd off
chkconfig --level 2345 bluetooth off
chkconfig --level 2345 cups off
chkconfig --level 2345 gpm off
chkconfig --level 2345 hidd off
chkconfig --level 2345 messagebus off

service smartd stop
service portmap stop
service nfslock stop
service mdmonitor stop
service rpcidmapd stop
service rpcgssd stop
service bluetooth stop
service cups stop
service gpm stop
service messagebus stop

#
# Boot fast
#
touch /fastboot

#
# Cleanup
#
rm -rf /tmp/updates
mv /root/*.rpm /root/.rightscale/
rm /root/*.tar
rm /root/install.log /root/install.log.syslog
echo "You will need to manually delete any files left in /root."
