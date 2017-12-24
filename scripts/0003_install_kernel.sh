. ./functions.sh

LINUX_DIR="~/projects/oldenburg/linux"
UBOOT_DIR="~/projects/oldenburg/u-boot"

if [ ! -d "$KERNEL_TMP" ]; then
    info "cannot find built kernel, please use tallykernel"
    exit 1
fi


# copy kernel & dtb
cp $LINUX_DIR/arch/arm64/boot/Image $ROOTFS/boot/
cp $LINUX_DIR/arch/arm64/boot/dts/am335x-boneblack.dtb $ROOTFS/boot/

# copy kernel modues
cp $LINUX_DIR/compiled_modules/* ${ROOTFS}/ -R

# copy boot script

cat <<'EOF' >> $ROOTFS/boot/boot.cmd
echo "This is your bootloader speaking."
echo "---------------"
echo "Insert appropriate funny message here."
echo "---------------"
echo "booting..."

/boot/uEnv.txt

loadaddr=0x82000000
fdtaddr=0x88000000
rdaddr=0x88080000

loadzimage=load mmc 0:1 ${loadaddr} /boot/Image
loadfdt=load mmc 0:1 ${fdtaddr} /boot/am335x-boneblack.dtb
mmcargs=setenv bootargs console=ttyO0,115200n8 noinitrd root=/dev/mmcblk0p1 rootfstype=ext4 rw rootwait fixrtc
uenvcmd=run loadzimage; run loadfdt; run mmcargs; bootz ${loadaddr} - ${fdtaddr}

EOF

# build it anyway even though we are not using
${UBOOT_DIR}/tools/mkimage -C none -A arm -T script -d $ROOTFS/boot/boot.cmd $ROOTFS/boot/boot.scr

cp $ROOTFS/boot/boot.cmd $ROOTFS/boot/uEnv.txt
