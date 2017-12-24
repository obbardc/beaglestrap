. ./functions.sh

LINUX_DIR="/home/chris/projects/oldenburg/linux"
UBOOT_DIR="/home/chris/projects/oldenburg/u-boot"

if [ ! -d "$LINUX_DIR" ]; then
    info "cannot find built kernel, please use tallykernel"
    exit 1
fi


# copy kernel & dtb
cp $LINUX_DIR/arch/arm/boot/zImage $ROOTFS/boot/
cp $LINUX_DIR/arch/arm/boot/dts/am335x-boneblack.dtb $ROOTFS/boot/

# copy kernel modues
cp $LINUX_DIR/compiled_modules/* ${ROOTFS}/ -R

# copy boot script

cat <<'EOF' >> $ROOTFS/boot/boot.cmd
echo "booting..."

loadaddr=0x82000000
fdtaddr=0x88000000
rdaddr=0x88080000

load mmc 0:1 ${loadaddr} zImage
load mmc 0:1 ${fdtaddr} am335x-boneblack.dtb

# cmdline=coherent_pool=1M quiet cape_universal=disable capemgr.disable_partno=BB-BONELT-HDMI
# console=ttyO0,115200n8 bone_capemgr.uboot_capemgr_enabled=1 root=/dev/mmcblk0p1 ro rootfstype=ext4 rootwait coherent_pool=1M net.ifnames=0 quiet

setenv bootargs console=ttyO0,115200n8 noinitrd root=/dev/mmcblk0p2 rootfstype=ext4 rw rootwait fixrtc
bootz ${loadaddr} - ${fdtaddr}
EOF

# build it anyway even though we are not using
${UBOOT_DIR}/tools/mkimage -C none -A arm -T script -d $ROOTFS/boot/boot.cmd $ROOTFS/boot/boot.scr

cp $ROOTFS/boot/boot.cmd $ROOTFS/boot/uEnv.txt
