#!/bin/bash -e
# On each server: rpm --queryformat "%{NAME}\n" -a -q|sort --ignore-case  --dictionary-order|uniq > list
# diff -u LIST-NEW-IMAGE LIST-OLD-IMAGE > diff

for i in `grep "^+[^+]" diff|cut -d"+" -f2-`; do
  pkgs_to_add="$pkgs_to_add $i"
done

if [ -n "$pkgs_to_add" ] ; then
#  yum -y install $pkgs_to_add
  echo "PACKAGES TO ADD: $pkgs_to_add"
fi

for i in `grep "^-[^-]" diff|cut -d"-" -f2-`; do
  pkgs_to_del="$pkgs_to_del $i"
done

if [ -n "$pkgs_to_del" ] ; then
#  rpm --erase --nodeps $pkgs_to_del
  echo "PACKAGES TO DELETE: $pkgs_to_del"
fi

#yum -y update

