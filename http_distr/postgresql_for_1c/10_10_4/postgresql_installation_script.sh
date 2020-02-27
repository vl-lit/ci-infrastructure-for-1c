#!/bin/bash

postgres_password=$1

pwd
sudo locale-gen ru_RU.utf8
sudo locale-gen en_US.utf8

export LANG=en_US.UTF-8
export LC_CTYPE=ru_RU.UTF8 
export LC_COLLATE=ru_RU.UTF8

tar -xjf postgresql_10.10_4.1C_amd64_addon_deb.tar.bz2 -C ./
tar -xjf postgresql_10.10_4.1C_amd64_deb.tar.bz2 -C ./

sudo wget -O - http://repo.postgrespro.ru/pgpro-10/keys/GPG-KEY-POSTGRESPRO | sudo apt-key add -
sudo -E sh -c 'echo "deb http://repo.postgrespro.ru/pgpro-10/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/postgrespro.list'
sudo apt-get update -y

sudo apt-get install -y postgresql-client-common
sudo apt-get install -y postgresql-common

# Installing obsolete packages
sudo dpkg -i libicu55_55.1-7ubuntu0.4_amd64.deb

wget http://cz.archive.ubuntu.com/ubuntu/pool/main/g/glibc/multiarch-support_2.29-0ubuntu2_amd64.deb
sudo dpkg -i multiarch-support_2.29-0ubuntu2_amd64.deb
sudo dpkg -i libssl1.0.0_1.0.1t-1+deb8u11_amd64.deb

sudo dpkg -i postgresql-10.10-4.1C_amd64_deb/libpq5_10.10-4.1C_amd64.deb
sudo DEBIAN_FRONTEND=noninteractive dpkg -i postgresql-10.10-4.1C_amd64_deb/postgresql-client-10_10.10-4.1C_amd64.deb 
sudo DEBIAN_FRONTEND=noninteractive dpkg -i postgresql-10.10-4.1C_amd64_deb/postgresql-10_10.10-4.1C_amd64.deb 
sudo DEBIAN_FRONTEND=noninteractive dpkg -i postgresql-10.10-4.1C_amd64_addon_deb/*.deb

# Locking updates for some packages
sudo apt-mark hold postgresql-10
sudo apt-mark hold postgresql-client-10
sudo apt-mark hold postgresql-client-common
sudo apt-mark hold postgresql-common
sudo apt-mark hold postgresql-doc-10
sudo apt-mark hold postgresql-server-dev-10
sudo apt-mark hold libpq5
sudo apt-mark hold libicu55
sudo apt-mark hold libssl1.0.0

sudo DEBIAN_FRONTEND=noninteractive apt-get --fix-broken -y install

# Allow admin user 'postgres' to connect without password from localhost
sudo sed -i "s/.*local.*all.*postgres.*/local   all             postgres                                trust/" /etc/postgresql/10/main/pg_hba.conf
sudo systemctl restart postgresql.service
# Setting password for user 'postgres'
psql -U postgres -c "ALTER USER postgres PASSWORD '$postgres_password'"
# Switching off passwordless access for user 'postgres' from localhost
sudo sed -i "s/.*local.*all.*postgres.*/local   all             postgres                                md5/" /etc/postgresql/10/main/pg_hba.conf

# Substituting default conf file by prepaired for 1C:Enterprise
sudo cp -rf /etc/postgresql/10/main/postgresql.conf /etc/postgresql/10/main/postgresql.conf.bak
sudo cp -rf ./postgresql.conf /etc/postgresql/10/main/postgresql.conf

sudo systemctl restart postgresql.service

# Installing pgAdmin 4
sudo wget -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg_for_pg_admin_4.list'
sudo apt-get update -y
sudo apt-get install -y pgadmin4
sudo rm /etc/apt/sources.list.d/pgdg_for_pg_admin_4.list
sudo apt-get update -y
