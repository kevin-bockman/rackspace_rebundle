#!/bin/bash
#
#
# Create a /dev/xvda2 partition for LVM
#
# NB: The size of the partition will depend on the instance size,
# and as such must be dynamically generated.
#
TMPFILE=`mktemp`
parted --script /dev/xvda unit b print > $TMPFILE
PART_END=`tail -2 $TMPFILE | head -1 | sed -e 's/[ ]\+/ /g' -e 's/B//g' | cut -d' ' -f4`
PART_SIZE=`head -3 $TMPFILE | tail -1 | cut -d' ' -f3`
NEW_PART_START=$(($PART_END+1))B

parted --script /dev/xvda mkpart primary $NEW_PART_START $PART_SIZE
pvcreate /dev/xvda2
vgcreate vg-data /dev/xvda2
lvcreate vg-data -n lvol0 -l 100%VG

#
# Create filesystem, fstab entries, and mount
#
mkfs.xfs /dev/vg-data/lvol0
echo "/dev/vg-data/lvol0 /mnt xfs defaults,noatime 0 0" >> /etc/fstab
mount /dev/vg-data/lvol0

