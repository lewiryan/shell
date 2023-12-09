#!/bin/sh

# On Azure attach data disk
azure_disk_tune () {
ls -l /dev/disk/by-id/ | grep -q sdc && (
echo o # Create a new empty DOS partition table
echo n # Add a new partition
echo p # Primary partition
echo 1 # Partition number
echo   # First sector (Accept default: 1)
echo   # Last sector (Accept default: varies)
echo w # Write changes
) | sudo fdisk /dev/sdc && (
mke2fs -F /dev/sdc1 
echo "/dev/sdc1	/opt	ext4	defaults,discard	0 0 " >> /etc/fstab
mount /opt
)
}

uname -a | grep -q -- "-azure " && azure_disk_tune 

#Modify /etc/ssh/sshd_config with: PermitRootLogin yes
sed -i -e "s/.*PermitRootLogin .*/PermitRootLogin yes/" /etc/ssh/sshd_config
wget -O - http://www.eve-ng.net/focal/eczema@ecze.com.gpg.key | sudo apt-key add -
apt-get update
apt-get -y install software-properties-common
#sudo add-apt-repository "deb [arch=amd64]  http://www.eve-ng.net/repo-testing xenial main"
echo "deb [arch=amd64] http://www.eve-ng.net/focal focal main" > /etc/apt/sources.list.d/eve-ng.list
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y docker-ce
DEBIAN_FRONTEND=noninteractive apt-get -y install eve-ng-pro
/etc/init.d/mysql restart
DEBIAN_FRONTEND=noninteractive apt-get -y install eve-ng-pro
rm -fr /var/lib/docker/aufs
DEBIAN_FRONTEND=noninteractive apt-get -y install eve-ng-pro

# Detect cloud


gcp_tune () {
cd /sys/class/net/; for i in ens* ; do echo 'SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="'$(cat $i/address)'", ATTR{type}=="1", KERNEL=="ens*", NAME="'$i'"' ; done  > /etc/udev/rules.d/70-persistent-net.rules
sed -i -e 's/NAME="ens.*/NAME="eth0"/' /etc/udev/rules.d/70-persistent-net.rules
sed -i -e 's/ens4/eth0/' /etc/netplan/50-cloud-init.yaml
sed -i -e 's/PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
apt-mark hold linux-image-gcp
mv /boot/vmlinuz-*gcp /root
update-grub2
}

azure_kernel_tune () {
apt update
#apt install linux-image-4.20.17-eve-ng-azure+
echo "options kvm_intel nested=1 vmentry_l1d_flush=never" > /etc/modprobe.d/qemu-system-x86.conf
sed -i -e 's/PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo -i
}


# GCP 
dmidecode  -t bios | grep -q Google  && gcp_tune

# Azure

uname -a | grep -q -- "-azure " && azure_kernel_tune