#!/bin/bash
echo "FTP1"
sudo apt-get update
sudo apt upgrade
sudo apt-get -y install vsftpd
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.orig
echo "y" | sudo ufw status
echo "y" | sudo ufw allow ssh
echo "y" | sudo ufw default  deny incoming
echo "y" | sudo ufw default allow outgoing
echo "y" | sudo ufw enable
echo "y" | sudo ufw status verbose
echo "y" | sudo ufw allow 20,21,990/tcp
echo "y" | sudo ufw allow 40000:50000/tcp
echo "y" | sudo ufw status verbose
sudo apt-get install -y openssh-server
sudo systemctl status ssh
sudo systemctl enable ssh
sudo systemctl restart ssh

sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
cd /etc/ssh/
cat <<EOT >> /etc/ssh/sshd_config
Match group ftpaccess
ChrootDirectory %h
X11Forwarding no
AllowTcpForwarding no
ForceCommand internal-sftp

EOT

sudo service ssh restart


# sudo adduser alpha
# sudo adduser beta
# sudo adduser gamma
# sudo adduser delta
# sudo adduser omega

# sudo addgroup ftpaccess

# sudo usermod -a -G ftpaccess alpha
# sudo usermod -a -G ftpaccess beta
# sudo usermod -a -G ftpaccess gamma
# sudo usermod -a -G ftpaccess delta
# sudo usermod -a -G ftpaccess omega

# sudo chown root: /home/alpha
# sudo chown root: /home/beta
# sudo chown root: /home/gamma
# sudo chown root: /home/delta
# sudo chown root: /home/omega


# sudo chmod 755 /home/alpha
# sudo chmod 755 /home/beta
# sudo chmod 755 /home/gamma
# sudo chmod 755 /home/delta
# sudo chmod 755 /home/omega

# sudo mkdir /home/alpha/www
# sudo mkdir /home/beta/www
# sudo mkdir /home/gamma/www
# sudo mkdir /home/delta/www
# sudo mkdir /home/omega/www
# sudo mkdir /srv/ftp/pub
# sudo mkdir /srv/ftp/incoming

# sudo chmod 755 /home/alpha/www
# sudo chmod 755 /home/beta/www
# sudo chmod 755 /home/gamma/www
# sudo chmod 755 /home/delta/www
# sudo chmod 755 /home/omega/www
# sudo chmod 555 /srv/ftp/pub
# sudo chmod 777 /srv/ftp/incoming

# sudo chown alpha:ftpaccess /home/alpha/www
# sudo chown beta:ftpaccess /home/beta/www
# sudo chown gamma:ftpaccess /home/gamma/www
# sudo chown delta:ftpaccess /home/delta/www
# sudo chown omega:ftpaccess /home/omega/www



# cd /home/alpha && sudo mkdir .ssh
# sudo chmod 755 .ssh/
# sudo touch .ssh/authorized_keys
# sudo chmod 777 .ssh/authorized_keys
# sudo chown alpha:alpha .ssh/authorized_keys
# sudo chown alpha:alpha .ssh/
# echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCiFy09Fps+n0IPqOJAtrqEUIDUUgAt65i/UNas3uiYVc/+Fl7JCClP5U0GmYNTvwVY/icQ/2TBTbd1e4X7FY+9WPntYGuCUIMUF1mfLv/joxo2TwXXAcmVNX6k+sXv859khHkkPHzrTWIK111D9qzgoxgRZgOM6u/dxviL7BpfeHjWo0SWi9+ntFWi3AWYUbBr136DaewkUKn5EWPQS3UA14xTBg9BQnKftwf9JiYrFZ7Cx1Jub6Dynj+Qo5XxXdQgm+z2nBKPgjWDI2eFSPIiNNbaUcLrzvKdAwzxgCs0PTCfh4hxCZm50hM4/pD6WIZWWqKh8FhMj6kWWYSpzQ3tCQckQ1K0mcJVbrX7oEhx3tsWqzdcbumP7VSv9DhiZBR0jo6cVsOsEZWOr3X/ckx/MTWMGescFMZMfAyf9rvIHMACCYf6FDkZLOuAMsn/Yr/3cVXYJIQboJw0+bFtOn47jjnYn1fyq9W+A7lAAe2IS+ksNak0MgyoTreGOcsemZM= chygyk@chygyk-pc"  >> .ssh/authorized_keys
# sudo chmod 600 .ssh/authorized_keys

# cd /home/beta && sudo mkdir .ssh
# sudo chmod 755 .ssh/
# sudo touch .ssh/authorized_keys
# sudo chmod 777 .ssh/authorized_keys
# sudo chown beta:beta .ssh/authorized_keys
# sudo chown beta:beta .ssh/
# echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCiFy09Fps+n0IPqOJAtrqEUIDUUgAt65i/UNas3uiYVc/+Fl7JCClP5U0GmYNTvwVY/icQ/2TBTbd1e4X7FY+9WPntYGuCUIMUF1mfLv/joxo2TwXXAcmVNX6k+sXv859khHkkPHzrTWIK111D9qzgoxgRZgOM6u/dxviL7BpfeHjWo0SWi9+ntFWi3AWYUbBr136DaewkUKn5EWPQS3UA14xTBg9BQnKftwf9JiYrFZ7Cx1Jub6Dynj+Qo5XxXdQgm+z2nBKPgjWDI2eFSPIiNNbaUcLrzvKdAwzxgCs0PTCfh4hxCZm50hM4/pD6WIZWWqKh8FhMj6kWWYSpzQ3tCQckQ1K0mcJVbrX7oEhx3tsWqzdcbumP7VSv9DhiZBR0jo6cVsOsEZWOr3X/ckx/MTWMGescFMZMfAyf9rvIHMACCYf6FDkZLOuAMsn/Yr/3cVXYJIQboJw0+bFtOn47jjnYn1fyq9W+A7lAAe2IS+ksNak0MgyoTreGOcsemZM= chygyk@chygyk-pc"  >> .ssh/authorized_keys
# sudo chmod 600 .ssh/authorized_keys

# cd /home/gamma && sudo mkdir .ssh
# sudo chmod 755 .ssh/
# sudo touch .ssh/authorized_keys
# sudo chmod 777 .ssh/authorized_keys
# sudo chown gamma:gamma .ssh/authorized_keys
# sudo chown gamma:gamma .ssh/
# echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCiFy09Fps+n0IPqOJAtrqEUIDUUgAt65i/UNas3uiYVc/+Fl7JCClP5U0GmYNTvwVY/icQ/2TBTbd1e4X7FY+9WPntYGuCUIMUF1mfLv/joxo2TwXXAcmVNX6k+sXv859khHkkPHzrTWIK111D9qzgoxgRZgOM6u/dxviL7BpfeHjWo0SWi9+ntFWi3AWYUbBr136DaewkUKn5EWPQS3UA14xTBg9BQnKftwf9JiYrFZ7Cx1Jub6Dynj+Qo5XxXdQgm+z2nBKPgjWDI2eFSPIiNNbaUcLrzvKdAwzxgCs0PTCfh4hxCZm50hM4/pD6WIZWWqKh8FhMj6kWWYSpzQ3tCQckQ1K0mcJVbrX7oEhx3tsWqzdcbumP7VSv9DhiZBR0jo6cVsOsEZWOr3X/ckx/MTWMGescFMZMfAyf9rvIHMACCYf6FDkZLOuAMsn/Yr/3cVXYJIQboJw0+bFtOn47jjnYn1fyq9W+A7lAAe2IS+ksNak0MgyoTreGOcsemZM= chygyk@chygyk-pc"  >> .ssh/authorized_keys
# sudo chmod 600 .ssh/authorized_keys

# cd /home/delta && sudo mkdir .ssh
# sudo chmod 755 .ssh/
# sudo touch .ssh/authorized_keys
# sudo chmod 777 .ssh/authorized_keys
# sudo chown delta:delta .ssh/authorized_keys
# sudo chown delta:delta .ssh/
# echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCiFy09Fps+n0IPqOJAtrqEUIDUUgAt65i/UNas3uiYVc/+Fl7JCClP5U0GmYNTvwVY/icQ/2TBTbd1e4X7FY+9WPntYGuCUIMUF1mfLv/joxo2TwXXAcmVNX6k+sXv859khHkkPHzrTWIK111D9qzgoxgRZgOM6u/dxviL7BpfeHjWo0SWi9+ntFWi3AWYUbBr136DaewkUKn5EWPQS3UA14xTBg9BQnKftwf9JiYrFZ7Cx1Jub6Dynj+Qo5XxXdQgm+z2nBKPgjWDI2eFSPIiNNbaUcLrzvKdAwzxgCs0PTCfh4hxCZm50hM4/pD6WIZWWqKh8FhMj6kWWYSpzQ3tCQckQ1K0mcJVbrX7oEhx3tsWqzdcbumP7VSv9DhiZBR0jo6cVsOsEZWOr3X/ckx/MTWMGescFMZMfAyf9rvIHMACCYf6FDkZLOuAMsn/Yr/3cVXYJIQboJw0+bFtOn47jjnYn1fyq9W+A7lAAe2IS+ksNak0MgyoTreGOcsemZM= chygyk@chygyk-pc"  >> .ssh/authorized_keys
# sudo chmod 600 .ssh/authorized_keys

# cd /home/omega && mkdir .ssh
# sudo chmod 755 .ssh/
# sudo touch .ssh/authorized_keys
# sudo chmod 777 .ssh/authorized_keys
# sudo chown omega:omega authorized_keys
# sudo chown omega:omega .ssh/
# echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCiFy09Fps+n0IPqOJAtrqEUIDUUgAt65i/UNas3uiYVc/+Fl7JCClP5U0GmYNTvwVY/icQ/2TBTbd1e4X7FY+9WPntYGuCUIMUF1mfLv/joxo2TwXXAcmVNX6k+sXv859khHkkPHzrTWIK111D9qzgoxgRZgOM6u/dxviL7BpfeHjWo0SWi9+ntFWi3AWYUbBr136DaewkUKn5EWPQS3UA14xTBg9BQnKftwf9JiYrFZ7Cx1Jub6Dynj+Qo5XxXdQgm+z2nBKPgjWDI2eFSPIiNNbaUcLrzvKdAwzxgCs0PTCfh4hxCZm50hM4/pD6WIZWWqKh8FhMj6kWWYSpzQ3tCQckQ1K0mcJVbrX7oEhx3tsWqzdcbumP7VSv9DhiZBR0jo6cVsOsEZWOr3X/ckx/MTWMGescFMZMfAyf9rvIHMACCYf6FDkZLOuAMsn/Yr/3cVXYJIQboJw0+bFtOn47jjnYn1fyq9W+A7lAAe2IS+ksNak0MgyoTreGOcsemZM= chygyk@chygyk-pc"  >> .ssh/authorized_keys
# sudo chmod 600 .ssh/authorized_keys