#!/bin/bash
read -p 'makemkv version : ' version #ie 1.x.x
echo updating to : makemkv_v$version

wget http://www.makemkv.com/download/makemkv_v$version\_beta_bin.tar.gz -P /home/<user>/Download
wget http://www.makemkv.com/download/makemkv_v$version\_beta_oss.tar.gz -P /home/<user>/Download
tar -xvzf /home/<user>/Download/makemkv_v$version\_beta_bin.tar.gz -C /home/<user>/source/makemkv
tar -xvzf /home/<user>/Download/makemkv_v$version\_beta_oss.tar.gz -C /home/<user>/source/makemkv

cd /home/<user>/source/makemkv/makemkv_v$version\_beta_bin/
make -f makefile.linux
sudo make -f makefile.linux install

cd /home/<user>/source/makemkv/makemkv_v$version\_beta_oss/
make -f makefile.linux
sudo make -f makefile.linux install
