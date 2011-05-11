#!/bin/bash -ex

RIGHT_LINK_PACKAGE_TAG="rightlink_package_5.6.30"
ARCH="x86_64"
RIGHT_LINK_VERSION="5.6.30"
PACKAGE_BUCKET="rightscale_rightlink_dev"

yum -y install rubygems 
gem install --remote rake

if [ -d /opt/rightscale/sandbox ]; then mv /opt/rightscale/sandbox /opt/rightscale/sandbox.OLD; fi
cd /tmp
if [ -d sandbox_builds ]; then rm -rf sandbox_builds; fi
git clone git@github.com:rightscale/sandbox_builds.git 
cd sandbox_builds 
git reset $RIGHT_LINK_PACKAGE_TAG --hard
git submodule init 
git submodule update
cd repos/right_net
git submodule init 
git submodule update
cd ../..
export ARCH=$ARCH
export RS_VERSION=$RIGHT_LINK_VERSION
rake submodules:sandbox:create
rake right_link:rpm:build

rm -rf /root/.rightscale
mkdir /root/.rightscale
cp dist/*.rpm /root/.rightscale
echo $RIGHT_LINK_VERSION > /etc/rightscale.d/rightscale-release
chmod 0770 /root/.rightscale
chmod 0440 /root/.rightscale/*

# UPLOAD
# $AWS_SECRET_ACCESS_KEY
# $AWS_ACCESS_KEY_ID
# gem install s3sync
# gem_bin=$(gem env |grep "EXECUTABLE DIRECTORY"|cut -d: -f2)
# cd /root
# filename=$(ls -1 *.rpm)
# $gem_bin/s3cmd put $PACKAGE_BUCKET:"$filename" "$filename" x-amz-acl:public-read
