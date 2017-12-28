. ./functions.sh

# install alsa-utils
chroot_exec apt-get install alsa-utils --yes

# copy in soundcard settings
cp /home/chris/projects/oldenburg/bbb_audio_extension.alsactl.state $ROOTFS/root/bbb_audio_extension.alsactl.state