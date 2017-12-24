info() {
    echo "BEAGLESTRAP: $*"
}

error() {
    echo "BEAGLESTRAP: $*"
}

chroot_exec() {
    LANG=C LC_ALL=C DEBIAN_FRONTEND=noninteractive chroot ${ROOTFS} $*
}