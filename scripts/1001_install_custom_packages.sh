. ./functions.sh

# install custom packages needed
chroot_exec apt-get install sudo alsa-utils rt-tests psmisc --yes

# install packages for wireless
#chroot_exec apt-get install bluez --yes
chroot_exec apt-get install firmware-ti-connectivity hostapd dnsmasq --yes

# create user
USERNAME="mha"
ENCRYPTED_PASSWORD=`mkpasswd -m sha-512 "mha"`
chroot_exec adduser --gecos $USERNAME --add_extra_groups --disabled-password $USERNAME
chroot_exec usermod -aG audio $USERNAME
chroot_exec usermod -aG sudo $USERNAME
chroot_exec usermod -p "${ENCRYPTED_PASSWORD}" $USERNAME

# copy in debs
cp $INCOMING/*.deb $ROOTFS/tmp/

# install jackd2
#  (this can be improved)
echo "jackd2	jackd/tweak_rt_limits	boolean	true" > $ROOTFS/tmp/debconf_selections.conf
chroot_exec debconf-set-selections /tmp/debconf_selections.conf
rm $ROOTFS/tmp/debconf_selections.conf
chroot_exec apt-get install --yes libsndfile1 libopus0
chroot_exec dpkg -i /tmp/libjack-jackd2-0.deb
#chroot_exec apt-get install -f --yes
#chroot_exec dpkg -i /tmp/libjack-jackd2-dev.deb
chroot_exec apt-get install -f --yes
chroot_exec dpkg -i /tmp/jackd2.deb
chroot_exec apt-get install -f --yes

# install mahalia-utils
chroot_exec dpkg -i /tmp/mahalia-utils.deb

# install openMHA
chroot_exec dpkg -i /tmp/libopenmha.deb
#chroot_exec dpkg -i /tmp/libopenmha-dev.deb
chroot_exec dpkg -i /tmp/openmha.deb
chroot_exec dpkg -i /tmp/openmha-examples.deb
chroot_exec apt-get install -f --yes

# hold jackd2 (so it doesn't get over-written by apt)
# dpkg: error: --set-selections takes no arguments ?!?!?!?
echo "jackd2 hold" | chroot_exec dpkg --set-selections
echo "libjack-jackd2-0 hold" | chroot_exec dpkg --set-selections
#echo "libjack-jackd2-dev hold" | chroot_exec dpkg --set-selections

# cleanup apt
rm $ROOTFS/tmp/*.deb
chroot_exec apt-get install -f --yes
chroot_exec apt-get clean


# setup wifi hotspot
echo "
auto wlan0
iface wlan0 inet static
  address 10.0.0.1
  netmask 255.255.255.0" >> $ROOTFS/etc/network/interfaces
