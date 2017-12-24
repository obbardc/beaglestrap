. ./functions.sh

# remove qemu binary
rm $ROOTFS/usr/bin/qemu-arm-static

# show used disk space
df -h | grep $ROOTFS

info "Completed system setup!"