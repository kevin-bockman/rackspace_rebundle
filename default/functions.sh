os=$(lsb_release -is|tr '[:upper:]' '[:lower:]'|tr -d '\n')
codename=$(lsb_release -cs)
rightlink_ver=$1
rightlink_os=$os
rightlink_os_ver=$(lsb_release -rs)

download() {
  case $rightlink_os in
  "centos")
    rightlink_pkg="rpm"
    rightlink_arch="x86_64"
    ;;
  "ubuntu")
    rightlink_pkg="deb"
    rightlink_arch="amd64"
    ;;
  *)
    echo "FATAL: Unknown OS"
    exit 1
    ;;
  esac
  
  rightlink_file="rightscale_${rightlink_ver}-${rightlink_os}_${rightlink_os_ver}-${rightlink_arch}.${rightlink_pkg}" 
  buckets=( rightscale_rightlink rightscale_rightlink_dev )
  locations=( /$rightlink_ver/$rightlink_os/ /$rightlink_ver/ / )

  [ -f /root/.rightscale/$rightlink_file ] && return 0
 
  set +e 
  for bucket in ${buckets[@]}
  do
    for location in ${locations[@]}
    do
      code=$(curl -o /root/.rightscale/${rightlink_file} --connect-timeout 10 --fail --silent --write-out %{http_code} http://s3.amazonaws.com/$bucket$location${rightlink_file})
      return=$?
      echo "BUCKET: $bucket LOCATION: $location RETURN: $return CODE: $code"
      [[ "$return" -eq "0" && "$code" -eq "200" ]] && break 2
    done
  done

  if [ "$?" == "0" ]; then
    set -e
    post
    set +e
    return 0
  fi

  return 1
}

build() {
  case $rightlink_os in
  "centos")
    pkg_mgr="yum" 
    pkg_type="rpm"
    rake="-v 0.8.7"
    ;;
  "ubuntu")
    pkg_mgr="apt-get"
    pkg_type="deb"
    rake=""
    ;;
  esac
   
  if [ -d /opt/rightscale/sandbox ]; then mv /opt/rightscale/sandbox /opt/rightscale/sandbox.OLD; fi
  cd /tmp/sandbox_builds
  export ARCH="x86_64"
  export RS_VERSION=$rightlink_ver
  rake submodules:sandbox:create
  rake right_link:$pkg_type:build
  
  rm -rf /root/.rightscale
  mkdir /root/.rightscale
  cp dist/*.$pkg_type /root/.rightscale
  post
}

post() {
  mkdir -p /etc/rightscale.d
  echo $rightlink_ver > /etc/rightscale.d/rightscale-release
  chmod 0770 /root/.rightscale
  chmod 0440 /root/.rightscale/*

  # Install RightLink seed script
  install /tmp/sandbox_builds/seed_scripts/rightimage /etc/init.d/rightimage --mode=0755

  case $rightlink_os in
  "centos")
    chkconfig --add rightimage
    ;;
  "ubuntu")
    update-rc.d rightimage start 96 2 3 4 5 . stop 1 0 1 6 .
    ;;
  esac

  sed -i "s/amazon$/nova-agent/g" /etc/init.d/rightimage
}
