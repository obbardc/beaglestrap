# Beaglestrap

another magical invention

if you know what this is, hello.



install instructions:

```
sudo apt-get install git debootstrap qemu-user-static kpartx dosfstools whois
```

execution instructions:
```
cd ~
git clone https://github.com/obbardc/beaglestrap.git
cd beaglestrap
(put your debs into beaglestrap/incoming)
sudo ./beaglestrap
```


todo:
```
> remove depends on whois for mkpasswd
```