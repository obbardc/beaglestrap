. ./functions.sh

HOSTNAME=mahalia

# hostname
echo ${HOSTNAME} > $ROOTFS/etc/hostname

# hosts file
echo "127.0.0.1	localhost.localdomain	localhost
127.0.1.1	${HOSTNAME}.localdomain	${HOSTNAME}" > $ROOTFS/etc/hosts


# set root password
PASSWORD="toor"
ENCRYPTED_PASSWORD=`mkpasswd -m sha-512 "${PASSWORD}"`
chroot_exec usermod -p "${ENCRYPTED_PASSWORD}" root

# mount root filesystem
echo "/dev/mmcblk0p1	/boot	vfat	defaults	0	0
/dev/mmcblk0p2	/	ext4	defaults,noatime	0	1" > $ROOTFS/etc/fstab

# setup wired network (dhcp)
echo "
# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet dhcp" >> $ROOTFS/etc/network/interfaces

# setup apt
echo "deb http://ftp.uk.debian.org/debian stretch main contrib non-free
deb-src http://ftp.uk.debian.org/debian stretch main contrib non-free" > $ROOTFS/etc/apt/sources.list

# do not install recommended packages
echo "APT::Install-Recommends \"0\";
APT::Install-Suggests \"0\";" > $ROOTFS/etc/apt/apt.conf.d/99no-install-recommends-suggests

# update repo
chroot_exec apt-get update

# generate locales
chroot_exec apt-get install locales --yes
echo 'en_GB.UTF-8 UTF-8' > $ROOTFS/etc/locale.gen
chroot_exec locale-gen
# todo: save space: remove locale package after generating

# install ssh server
chroot_exec apt-get install openssh-server --yes

# allow root logins (this is temporary, do not worry)
sed -i -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' $ROOTFS/etc/ssh/sshd_config


# startup script to generate new ssh host keys
rm -f $ROOTFS/etc/ssh/ssh_host_*
cat << EOF > $ROOTFS/etc/init.d/ssh_gen_host_keys
#!/bin/sh
### BEGIN INIT INFO
# Provides:          Generates new ssh host keys on first boot
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Generates new ssh host keys on first boot
# Description:       Generates new ssh host keys on first boot
### END INIT INFO
systemctl stop ssh
ssh-keygen -f /etc/ssh/ssh_host_rsa_key -t rsa -N ""
ssh-keygen -f /etc/ssh/ssh_host_dsa_key -t dsa -N ""
update-rc.d ssh_gen_host_keys disable
update-rc.d ssh_gen_host_keys remove
update-rc.d ssh defaults
systemctl start ssh

# remove the script
rm -f \$0
EOF
chmod a+x $ROOTFS/etc/init.d/ssh_gen_host_keys
#insserv $ROOTFS/etc/init.d/ssh_gen_host_keys
chroot_exec update-rc.d ssh_gen_host_keys defaults