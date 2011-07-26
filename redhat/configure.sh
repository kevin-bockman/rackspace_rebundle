#!/bin/bash -ex
#
# First create directories, expand tarballs, etc.
#

mkdir -p /tmp/updates

cd /root
# Dot files get removed somewhere in here...
find /root -maxdepth 1 -name ".????*" -type f | xargs -i cp {} /root/files

mkdir -p /etc/rightscale.d
echo -n ec2 > /etc/rightscale.d/cloud
mkdir -p /root/.rightscale
cp /root/files/EPEL.pubkey /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL
tar -C / -xvf /root/files/rs_yum.repos.d.tar etc/yum.repos.d/Epel.repo etc/yum.repos.d/RightScale-epel.repo

#
# Install packages
#
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL
yum -y clean all
yum -y makecache
yum -y groupinstall Base
yum -y install git bind-utils redhat-lsb parted ruby syslog-ng wget mlocate nano logrotate ruby ruby-devel ruby-docs ruby-irb ruby-libs ruby-mode ruby-rdoc ruby-ri ruby-tcltk postfix openssl openssh openssh-askpass openssh-clients openssh-server curl gcc* zip unzip bison flex compat-libstdc++-296 cvs subversion autoconf automake libtool compat-gcc-34-g77 mutt sysstat rpm-build fping vim-common vim-enhanced rrdtool-1.2.27 rrdtool-devel-1.2.27 rrdtool-doc-1.2.27 rrdtool-perl-1.2.27 rrdtool-python-1.2.27 rrdtool-ruby-1.2.27 rrdtool-tcl-1.2.27 pkgconfig lynx screen yum-utils bwm-ng createrepo redhat-rpm-config nscd swig rubygems
yum -y remove bluez* gnome-bluetooth* cpuspeed irqbalance kudzu acpid NetworkManager wpa_supplicant exim

#array=( audit-libs-python checkpolicy dhcpv6-client libselinux-python libselinux-utils libsemanage policycoreutils prelink redhat-logos rootfiles selinux-policy selinux-policy-targeted setools setserial sysfsutils sysklogd udftools avahi avahi-compat-libdns_sd cups mysql-connector-odbc mysql );

array=( dhcpv6-client prelink redhat-logos rootfiles setserial sysfsutils sysklogd udftools avahi avahi-compat-libdns_sd cups mysql-connector-odbc mysql );

set +e
for i in "${array[@]}"; do 
  rpm --erase --nodeps --allmatches "${i}"; 
done
set -e

yum -y clean all
yum -y --exclude=redhat-release update # installs 2.6.18-238.12.1, comes with 2.6.18-238.9.

#
# Configuration steps
#
chkconfig --level 2345 nscd on
chkconfig --level 2345 syslog-ng on
authconfig --enableshadow --useshadow --enablemd5 --updateall

cp -f /root/files/sshd_config /etc/ssh

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
set +e
rpm -Uvh /tmp/updates/jdk-6u14-linux-$java_arch.rpm

rpm -Uvh /tmp/updates/sun-javadb-common-10.4.2-1.1.i386.rpm
rpm -Uvh /tmp/updates/sun-javadb-client-10.4.2-1.1.i386.rpm
rpm -Uvh /tmp/updates/sun-javadb-core-10.4.2-1.1.i386.rpm
rpm -Uvh /tmp/updates/sun-javadb-demo-10.4.2-1.1.i386.rpm
rpm -Uvh /tmp/updates/sun-javadb-docs-10.4.2-1.1.i386.rpm
rpm -Uvh /tmp/updates/sun-javadb-javadoc-10.4.2-1.1.i386.rpm
set -e

echo "export JAVA_HOME=/usr/java/default" >> /etc/profile.d/java.sh
chmod +x /etc/profile.d/java.sh

#
# Download RightLink (unless skipped)
#
RIGHT_LINK_VERSION="5.6.35"
RIGHT_LINK_BUCKET="rightscale_rightlink"
ARCH=`uname -i`
FILE="rightscale_$RIGHT_LINK_VERSION-redhatenterpriseserver_`lsb_release -r -s`-$ARCH.rpm"
curl -o /root/.rightscale/$FILE https://s3.amazonaws.com/$RIGHT_LINK_BUCKET/$RIGHT_LINK_VERSION/redhatenterpriseserver/$FILE
echo $RIGHT_LINK_VERSION > /etc/rightscale.d/rightscale-release
chmod 0770 /root/.rightscale
chmod 0440 /root/.rightscale/*
# Install RightLink seed script
install /root/files/rightimage /etc/init.d/rightimage --mode=0755
chkconfig --add rightimage

#install /root/files/getsshkey /etc/init.d/getsshkey --mode=0544
#chkconfig --add getsshkey
#chkconfig --level 4 getsshkey on

rm -rf /home/ec2 || true
mkdir -p /home/ec2
curl -o /tmp/ec2-api-tools.zip http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip
curl -o /tmp/ec2-ami-tools.zip http://s3.amazonaws.com/ec2-downloads/ec2-ami-tools.zip
unzip /tmp/ec2-api-tools.zip -d /tmp/
unzip /tmp/ec2-ami-tools.zip -d /tmp/
cp -r /tmp/ec2-api-tools-*/* /home/ec2/.
rsync -av /tmp/ec2-ami-tools-*/ /home/ec2
rm -r /tmp/ec2-a*
echo 'export PATH=/home/ec2/bin:${PATH}' >> /etc/profile.d/ec2.sh
echo 'export EC2_HOME=/home/ec2' >> /etc/profile.d/ec2.sh
gem install s3sync --no-ri --no-rdoc

#
# Disable unnecessary services
#
set +e
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

# From rightimage github project.
./chkconfig
set -e

#
# Boot fast
#
touch /fastboot

#
#
# Cleanup
#
rm -rf /tmp/updates
set +e
rm /root/install.log /root/install.log.syslog
set -e
echo "You will need to manually delete any files left in /root."
