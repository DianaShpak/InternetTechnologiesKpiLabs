#!/bin/bash
echo "NFS"


sudo apt update
sudo apt install nfs-common

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

sudo mount 172.20.1.90:/nfs/private /nfs/private
sudo mount 172.20.1.90:/nfs/incoming /nfs/incoming
sudo mount 172.20.1.90:/nfs/public /nfs/public

df -h


du -sh /nfs/home

du -sh /nfs/private
4.0K    /nfs/private

du -sh /nfs/incoming
4.0K    /nfs/incoming

du -sh /nfs/public
4.0K    /nfs/public

nfsstat -c

apt-get install showmount