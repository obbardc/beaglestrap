. ./functions.sh

# debootstrap a basic Debian system
info "Debootstrapping system (first-stage)"
debootstrap --arch=armhf --foreign stretch $ROOTFS

# copy in the ARM static binary (so we can chroot)
cp /usr/bin/qemu-arm-static $ROOTFS/usr/bin/

# actually install the packages
info "Debootstrapping system (second-stage)"
chroot_exec /debootstrap/debootstrap --second-stage