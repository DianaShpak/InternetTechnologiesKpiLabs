#!/bin/bash
echo "NFS"


sudo apt update

sudo apt install nfs-kernel-server

sudo adduser alpha
sudo adduser beta
sudo adduser gamma
sudo adduser delta
sudo adduser omega

sudo mkdir -p /nfs/private 
ls -la /nfs/private

#total 8
#drwxr-xr-x 2 root root 4096 Jun 19 19:24 .
#drwxr-xr-x 3 root root 4096 Jun 19 19:24 ..

sudo mkdir -p /nfs/incoming
ls -la /nfs/incoming

#total 8
#drwxr-xr-x 2 root root 4096 Jun 19 19:25 .
#drwxr-xr-x 4 root root 4096 Jun 19 19:25 ..

sudo mkdir -p /nfs/public
ls -la /nfs/public

sudo chown alpha:alpha /nfs/private
sudo chown nobody:nogroup /nfs/incoming
sudo chown nobody:nogroup /nfs/public

sudo sudo groupadd mygroup1
sudo usermod -a -G mygroup1 beta
sudo usermod -a -G mygroup1 gamma
sudo chmod 775 /nfs/private

sudo cat /etc/passwd

/nfs/public      *(ro,sync,no_subtree_check)
/nfs/private     172.20.1.100(rw,sync,root_squash, anonuid=1002,anongid=1002)
/nfs/incoming    172.20.1.0/24(rw,sync,no_root_squash,no_subtree_check,anonuid=1003,anongid=1003)