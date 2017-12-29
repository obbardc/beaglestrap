. ./functions.sh

# install custom packages needed
chroot_exec apt-get install alsa-utils --yes
chroot_exec apt-get install mplayer --yes
chroot_exec apt-get install sudo --yes

# create jack user (p/w jack)
USERNAME="jack"
ENCRYPTED_PASSWORD=`mkpasswd -m sha-512 "jack"`

chroot_exec adduser --gecos $USERNAME --add_extra_groups --disabled-password $USERNAME

chroot_exec usermod -aG audio $USERNAME
chroot_exec usermod -aG sudo $USERNAME
chroot_exec usermod -p "${ENCRYPTED_PASSWORD}" $USERNAME

# copy in soundcard settings
cp /home/chris/projects/oldenburg/bbb_audio_extension.alsactl.state $ROOTFS/home/jack/bbb_audio_extension.alsactl.state
cp /home/chris/projects/oldenburg/bbb_audio_extension.alsactl.state $ROOTFS/root/bbb_audio_extension.alsactl.state

# copy in compiled jack
mkdir $ROOTFS/tmp/
cp /home/chris/projects/oldenburg/jackd2/*.deb $ROOTFS/tmp/

# install jackd2
#  (this can be improved)
echo "jackd2	jackd/tweak_rt_limits	boolean	true" > $ROOTFS/tmp/debconf_selections.conf
chroot_exec debconf-set-selections /tmp/debconf_selections.conf
rm $ROOTFS/tmp/debconf_selections.conf
chroot_exec dpkg -i /tmp/libjack-jackd2-0_*_armhf.deb
chroot_exec apt-get install -f
chroot_exec dpkg -i /tmp/libjack-jackd2-dev_*_armhf.deb
chroot_exec apt-get install -f
chroot_exec dpkg -i /tmp/jackd2_*_armhf.deb
rm $ROOTFS/tmp/*.deb
chroot_exec apt-get install -f
chroot_exec apt-get clean