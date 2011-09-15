#!/bin/bash -ex
source functions.sh

mirror="http://mirror.rightscale.com"

function get_rubygems {
  wget -O /tmp/rubygems.tgz $2 
  tar -xzvf /tmp/rubygems.tgz  -C /tmp
  mv /tmp/rubygems-$1 /tmp/rubygems
}

ruby_ver=`ruby --version`
if [[ $ruby_ver == *1.8.5* ]] ; then
  get_rubygems 1.3.3 http://rubyforge.org/frs/download.php/56227/rubygems-1.3.3.tgz
else
  get_rubygems 1.3.7 http://rubyforge.org/frs/download.php/70696/rubygems-1.3.7.tgz
fi

cd /tmp/rubygems
ruby setup.rb 
if [ "$os" == "ubuntu" ]; then
  ln -sf /usr/bin/gem1.8 /usr/bin/gem
fi
gem source -a $mirror/rubygems/archive/latest/
gem source -r $mirror
gem install xml-simple net-ssh net-sftp
gem install rake
