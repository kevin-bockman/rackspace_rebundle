#!/bin/bash -ex
#
# First create directories, expand tarballs, etc.
#
source functions.sh

rightlink_ver=$1

if [ -z "$rightlink_ver" ]; then
  echo "FATAL: RightLink version not specified"
  exit 1
fi

cd /root
mkdir -p /etc/rightscale.d
echo -n rackspace > /etc/rightscale.d/cloud
mkdir -p /root/.rightscale

cp /root/.bashrc /root/.profile /root/.rightscale
cp /root/files/rightscale.sources.list /etc/apt/sources.list.d
if [ -f /etc/apt/sources.list ] ; then
  mv /etc/apt/sources.list /etc/apt/sources.list.ORIG
fi

export DEBIAN_FRONTEND="noninteractive"
apt-get update

#
# Install packages
#
localedef -i en_US -c -f UTF-8 en_US.UTF-8

apt-get -y install apt-transport-https at autoconf automake autotools-dev bash-completion bind9-host binutils bison build-essential busybox-static byobu collectd collectd-core collectd-utils command-not-found command-not-found-data cpu-checker debconf-utils defoma dnsutils dosfstools dpkg-dev ed emacs emacs23 emacs23-bin-common emacs23-common emacsen-common fakeroot flex fontconfig fontconfig-config friendly-recovery ftp fuse-utils g++ g++-4.4 gcc gcc-4.4 geoip-database gettext-base git-core guile-1.8-libs hdparm hicolor-icon-theme info install-info iptraf iputils-arping iputils-tracepath irb irb1.8 irqbalance iso-codes java-common language-selector-common libanthy0 libapr1 libaprutil1 libasound2 libatk1.0-0 libatk1.0-data libavahi-client3 libavahi-common3 libavahi-common-data libbind9-60 libc6-dev libcairo2 libcap-ng0 libc-dev-bin libcollectdclient0 libcroco3 libcups2 libdatrie1 libdigest-sha1-perl libdirectfb-1.2-0 libdns64 libelf1 liberror-perl libevtlog0 libexpat1 libfont-afm-perl libfontconfig1 libfontenc1 libfreetype6 libfuse2 libgc1c2 libgd2-noxpm libgeoip1 libgif4 libgomp1 libgsasl7 libgsf-1-114 libgsf-1-common libgtk2.0-0 libgtk2.0-bin libgtk2.0-common libhtml-format-perl libhtml-parser-perl libhtml-tagset-perl libhtml-tree-perl libice6 libisc60 libisccc60 libisccfg60 libjasper1 libjpeg62 libltdl7 libltdl-dev liblwres60 liblzma1 libm17n-0 libmailtools-perl libmailutils2 libmysqlclient16 libncurses5-dev libneon27-gnutls libntfs-3g75 libntlm0 libopenssl-ruby1.8 libotf0 libpango1.0-0 libpango1.0-common libparted0debian1 libpcap0.8 libpci3 libpixman-1-0 libreadline5 libreadline5-dev libreadline-ruby1.8 librpc-xml-perl librrd4 librsvg2-2 libruby1.8 libshadow-ruby1.8 libsm6 libstdc++6-4.4-dev libsvn1 libsysfs2 libterm-readkey-perl libthai0 libthai-data libtiff4 libtool libts-0.0-0 liburi-perl libwww-perl libxcb-render0 libxcb-render-util0 libxcomposite1 libxcursor1 libxdamage1 libxfixes3 libxfont1 libxft2 libxi6 libxinerama1 libxml2-dev libxml-libxml-perl libxml-namespacesupport-perl libxml-parser-perl libxml-sax-expat-perl libxml-sax-perl libxpm4 libxrandr2 libxrender1 libxslt1.1 libxslt1-dev libxt6 libyaml-0-2 linux-firmware linux-libc-dev lshw lsof ltrace m17n-contrib m17n-db m4 mailutils manpages-dev memtest86+ mlocate mtr-tiny mysql-common nscd ntfs-3g odbcinst odbcinst1debian1 os-prober parted patch pciutils plymouth-theme-ubuntu-text popularity-contest postfix powermgmt-base ppp pppconfig pppoeconf psmisc python-apt python-boto python-cheetah python-configobj python-gdbm python-gnupginterface python-m2crypto python-newt python-software-properties python-support python-yaml rake rdoc1.8 rsync ruby ruby1.8 ruby1.8-dev screen sqlite3 ssh-import ssl-cert strace subversion syslog-ng sysstat tcpdump telnet time tsconf ttf-dejavu-core ubuntu-standard ufw unattended-upgrades unixodbc unzip update-manager-core update-motd update-notifier-common usbutils uuid-runtime w3m xfonts-encodings xfonts-utils x-ttcidfont-conf xz-utils zip zlib1g-dev linux-image-2.6.35-25-server linux-headers-2.6.35-25
apt-get -y upgrade
apt-get -y purge apparmor apparmor-utils libapparmor-perl libapparmor1 aspell aspell-en consolekit dbus dbus-x11 dictionaries-common ethtool fancontrol gawk gconf2 gconf2-common hunspell-en-us libaspell15 libck-connector0 libdbi0 libdbus-glib-1-2 libdevmapper-event1.02.1 libeggdbus-1-0 libenchant1c2a libesmtp5 libevent-1.4-2 libgconf2-4 libglade2-0 libgstreamer0.10-0 libhal1 libhunspell-1.2-0 libidl0 libmemcached2 libnotify1 libopenipmi0 liboping0 liborbit2 libpam-ck-connector libperl5.10 libpolkit-gobject-1-0 libpq5 libsensors4 libsexy2 libsnmp15 libsnmp-base libstartup-notification0 libupsclient1 libwnck22 libwnck-common libxcb-atom1 libxcb-aux0 libxcb-event1 libxres1 libyajl1 lm-sensors memcached notification-daemon rrdtool ttf-dejavu ttf-dejavu-extra watershed 
apt-get -y autoremove
apt-get clean

#
# Configuration steps
#
cp /root/files/menu.lst /boot/grub

#cp /root/files/sshd_config /etc/ssh
cp /usr/share/zoneinfo/UTC /etc/timezone

shadowconfig on
#sed -i s/root::/root:*:/ /etc/shadow

if [ ! -f /bin/env ] ; then
  ln -s /usr/bin/env /bin/env
fi

rm -f /etc/rc?.d/*hwclock*
if [ ! -e /usr/bin/ruby ]; then 
  ln -s /usr/bin/ruby1.8 /usr/bin/ruby
fi

# Configure IPtables
cp /root/files/iptables /etc/iptables.rules

cat <<-EOF>/etc/network/if-pre-up.d/iptables
#!/bin/sh
iptables-restore < /etc/iptables.rules
exit 0
EOF

chmod 700 /etc/network/if-pre-up.d/iptables

#
# Java configuration steps
# (Should really be factored out-- use real chef imagebuilder scripts instead?)
# 
echo "Setting APT::Install-Recommends to false"
echo "APT::Install-Recommends \"0\";" > /etc/apt/apt.conf

if [ -f /etc/apt/sources.list ] ; then
  cp /etc/apt/sources.list /etc/apt/sources.java.sav
fi

echo "deb http://archive.canonical.com/ lucid partner" >> /etc/apt/sources.list
apt-get update

apt-get -y install debconf-utils
echo 'sun-java6-bin   shared/accepted-sun-dlj-v1-1    boolean true
sun-java6-jdk   shared/accepted-sun-dlj-v1-1    boolean true
sun-java6-jre   shared/accepted-sun-dlj-v1-1    boolean true
sun-java6-jre   sun-java6-jre/stopthread        boolean true
sun-java6-jre   sun-java6-jre/jcepolicy note
sun-java6-bin   shared/present-sun-dlj-v1-1     note
sun-java6-jdk   shared/present-sun-dlj-v1-1     note
sun-java6-jre   shared/present-sun-dlj-v1-1     note
'|debconf-set-selections
apt-get -y install sun-java6-jdk

if [ -f /etc/apt/sources.java.sav ] ; then
  echo "Restore origional repo list"
  cp /etc/apt/sources.java.sav /etc/apt/sources.list
fi

apt-get update

echo "export JAVA_HOME=/usr/lib/jvm/java-6-sun" >> /etc/profile.d/java.sh
chmod +x /etc/profile.d/java.sh

#
# Download RightLink
#
download $rightlink_ver
[[ "$?" == "1" ]] && build $rightlink_ver

#
# Install any DEBs
#
#dpkg --install /root/*.deb

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

#
# Cleanup
#
#mv /root/*.deb /root/.rightscale/
#mv /root/.rightscale/.bashrc /root/.rightscale/.profile /root
#rm /root/install.log /root/install.log.syslog
echo "You will need to manually delete any files left in /root."
