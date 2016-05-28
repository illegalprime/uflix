# µflix
a specialized docker container to run plex media service with ssh and luks encryption 

# Setup

Note: `sudo` is assumed to be installed, if it is not simply run the commands
prepended with `sudo` as root.

## Ubuntu Precise, Trusty, Wily, Xenial

### Install `docker`:
Install `docker` by following the instructions on their [website](https://docs.docker.com/engine/installation/linux/ubuntulinux/)
repeated here:

Add the docker debian repo to your system:
```BASH
source /etc/lsb-release
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo deb https://apt.dockerproject.org/repo ubuntu-$DISTRIB_CODENAME main | sudo tee /etc/apt/sources.list.d/docker.list
```

Install it:
```BASH
sudo apt-get update
sudo apt-get install docker-engine
sudo service docker start
```

### Install `cryptsetup`:
```BASH
sudo apt-get install cryptsetup
```

## Arch Linux
Install `docker` and `cryptsetup`:
```BASH
sudo pacman -S docker cryptsetup
sudo systemctl start docker
```

# Running
```BASH
git clone https://github.com/illegalprime/uflix.git
cd uflix
sudo ./build
sudo ./start --help
```

# Road Map

1. ~~Basic Plex Server~~
2. ~~Avahi integration~~
3. ~~SSH Access~~
4. ~~Support ext4 fs~~
5. ~~Support luks fs~~
6. ~~Gracefully exit on error~~
7. ~~Identify device file by UUID, etc.~~
8. ~~Mounting normal directories~~
9. ~~Add command line configuration options~~
10. ~~Be able to configure mount point names~~
11. ~~Better logging~~
12. Support Multiple Disk Mounting
13. Support ZFS
14. Move password entry out of Dockerfile
15. Support FAT32
15. Support NTFS
16. Explicity name mount points
17. Configuration file
