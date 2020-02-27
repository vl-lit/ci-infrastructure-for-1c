#!/bin/bash

version_of_1c_platform_with_underscores=$1
TAR_SUBNAME=$version_of_1c_platform_with_underscores
echo "TAR_SUBNAME is $TAR_SUBNAME"

FIRST_NUMBER_OF_1C_VERSION=`echo $version_of_1c_platform_with_underscores | cut -d "_" -f 1`
SECOND_NUMBER_OF_1C_VERSION=`echo $version_of_1c_platform_with_underscores | cut -d "_" -f 2`
THIRD_NUMBER_OF_1C_VERSION=`echo $version_of_1c_platform_with_underscores | cut -d "_" -f 3`
FORTH_NUMBER_OF_1C_VERSION=`echo $version_of_1c_platform_with_underscores | cut -d "_" -f 4`

PACKAGE_SUBNAME="$FIRST_NUMBER_OF_1C_VERSION.$SECOND_NUMBER_OF_1C_VERSION.$THIRD_NUMBER_OF_1C_VERSION"
PACKAGE_SUBNAME+="-"
PACKAGE_SUBNAME+=$FORTH_NUMBER_OF_1C_VERSION
PACKAGE_SUBNAME+="_amd64"
echo "PACKAGE_SUBNAME is $PACKAGE_SUBNAME"

pwd

# Installing Microsoft fonts
wget http://ftp.de.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.7_all.deb
sudo dpkg -i ttf-mscorefonts-installer_3.7_all.deb
sudo apt-get --fix-broken -y install

sudo apt-get install -y imagemagick
sudo apt-get install -y unixodbc

# Installing libwebkitgtk-3.0-0 - old package 
sudo sh -c 'echo "deb http://ru.archive.ubuntu.com/ubuntu/ bionic main universe" > /etc/apt/sources.list.d/old1c_libs.list'
sudo apt-get update
sudo apt-get install -y libwebkitgtk-3.0-0
sudo apt-get --fix-broken -y install

mkdir distrs1c
tar -C ./distrs1c/ -xzf deb64_$TAR_SUBNAME.tar.gz 
tar -C ./distrs1c/ -xzf client_$TAR_SUBNAME.deb64.tar.gz

cd distrs1c/
sudo dpkg -i 1c-enterprise83-common_$PACKAGE_SUBNAME.deb
sudo dpkg -i 1c-enterprise83-common-nls_$PACKAGE_SUBNAME.deb
sudo dpkg -i 1c-enterprise83-server_$PACKAGE_SUBNAME.deb
sudo dpkg -i 1c-enterprise83-server-nls_$PACKAGE_SUBNAME.deb
sudo dpkg -i 1c-enterprise83-ws_$PACKAGE_SUBNAME.deb
sudo dpkg -i 1c-enterprise83-ws-nls_$PACKAGE_SUBNAME.deb
sudo dpkg -i 1c-enterprise83-client_$PACKAGE_SUBNAME.deb
sudo dpkg -i 1c-enterprise83-client-nls_$PACKAGE_SUBNAME.deb

sudo mkdir -p /opt/1C/v8.3/x86_64/conf

# Draft for copying nethasp.ini if your server needs it
# cp ../nethasp.ini /opt/1C/v8.3/x86_64/conf/nethasp.ini

# Be careful!!!
# without the -a (--append) flag the command overwrites the whole file with the given string 
# instead of appending it to the end of the file
echo "DisableUnsafeActionProtection=.*" | sudo tee --append /opt/1C/v8.3/x86_64/conf/conf.cfg
# Enabling debug mode for server 1C
sudo sed -i "s/.*SRV1CV8_DEBUG=.*/SRV1CV8_DEBUG=1/" /etc/init.d/srv1cv83

# Starting RAS on 1C service startup
sudo sed -i "s/echo \${mypid} > \"\$SRV1CV8_PIDFILE\"/echo \${mypid} > \"\$SRV1CV8_PIDFILE\"\n\n    \$G_BINDIR\/ras --daemon cluster/" /etc/init.d/srv1cv83

# Changing ownership only after creating all necessary files
sudo chown -R usr1cv8:grp1cv8 /opt/1C

# Reloading deamons settings to avoid warring on first startup
sudo systemctl daemon-reload
# Starting srv1cv83 

sudo systemctl start srv1cv83.service
