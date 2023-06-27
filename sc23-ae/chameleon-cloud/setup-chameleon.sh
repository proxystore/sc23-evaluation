#!/bin/bash

set -e

sudo apt-get update -y
sudo apt-get install -y --no-install-recommends \
  make gcc g++ cmake git build-essential ca-certificates autoconf automake libtool \
  libjson-c-dev libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev pkg-config \
  libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python3-openssl libjson-c4 \
  libjson-c-dev uuid numactl libnuma-dev \
  libudev-dev libnl-3-dev libnl-route-3-dev ninja-build valgrind python3-dev cython3 \
  python3-docutils pandoc

sudo apt-get clean autoclean
sudo rm -rf /var/lib/apt/lists/*

# Get analysis and benchmark repo
#git clone -b dim-instructions https://github.com/proxystore/sc23-proxystore-analysis.git

if [ ! -d "/home/cc/benchmarks" ]
then
	echo 'cloning benchmarks'
	git clone -b dspaces https://github.com/proxystore/benchmarks.git ~/benchmarks
fi

mkdir -p ~/downloads
cd ~/downloads

# install mellanox ib drivers

if [ ! -f "/home/cc/downloads/MLNX_OFED_LINUX-4.9-6.0.6.0-ubuntu20.04-x86_64.tgz" ]
then
	wget http://www.mellanox.com/downloads/ofed/MLNX_OFED-4.9-6.0.6.0/MLNX_OFED_LINUX-4.9-6.0.6.0-ubuntu20.04-x86_64.tgz
fi

if [ ! -d "/home/cc/downloads/MLNX_OFED_LINUX-4.9-6.0.6.0-ubuntu20.04-x86_64" ]
then
	tar -xvf MLNX_OFED_LINUX-4.9-6.0.6.0-ubuntu20.04-x86_64.tgz
fi

cd ~/downloads/MLNX_OFED_LINUX-4.9-6.0.6.0-ubuntu20.04-x86_64
yes | sudo ./mlnxofedinstall
sudo /etc/init.d/openibd restart

#### Configure static IP for infiniband  ####
# Step 1: Check that interface is up and get interface name by using `ibv_devices` and `ip addr`
# Step 2: create file /etc/netplan/01-netcfg.yaml
# Step 3: Edit file with correct interface name and IP address that's within the same shared VLAN subnet (check on Chameleon what is the subnet and change Gateway4 if different) , e.g.,
# network:
#  version: 2
#  renderer: networkd
#  ethernets:
#    ibp3s0:
#      dhcp4: no
#      addresses:
#        - 10.52.3.144/24
#      gateway4:  10.52.0.0
#      nameservers:
#          addresses: [8.8.8.8, 1.1.1.1]
# Step 4: Update the network interfaces by running command `sudo netplan apply`
# Step 5: Verify that interface has been updated by running `ip addr show <interface>`

x=$(hostname -I |  awk -F '.' '{print $--NF}')
y=$(hostname -I | awk -F '.' '{print $NF}' | xargs)
sudo bash -c "cat > /etc/netplan/01-netcfg.yaml" << EOL
network:
 version: 2
 renderer: networkd
 ethernets:
   ibp3s0:
     dhcp4: no
     addresses:
       - 172.16.${x}.${y}/24
     gateway4:  10.52.0.0
     nameservers:
         addresses: [8.8.8.8, 1.1.1.1]
EOL

sudo netplan apply

# Install Spack
if [ ! -d "/home/cc/downloads/spack" ]
then
	git clone -c feature.manyFiles=true https://github.com/spack/spack.git ~/downloads/spack
fi
source ~/downloads/spack/share/spack/setup-env.sh

setup_str='source /home/cc/downloads/spack/share/spack/setup-env.sh'
activate_str='spack env activate proxystore -p'

if grep -Fxq "$setup_str" ~/.bashrc
then
	echo "$setup_str" >> ~/.bashrc
fi

if grep -Fxq "$activate_str" ~/.bashrc
then
	echo "$activate_str" >> ~/.bashrc
fi

# Install Mochi packages

if [ ! -d  "/home/cc/downloads/mochi-spack-packages" ]
then
	git clone https://github.com/mochi-hpc/mochi-spack-packages.git /home/cc/downloads/mochi-spack-packages
fi

# Install DataSpaces packages
if [ ! -d "/home/cc/downloads/dspaces-spack" ]
then
	git clone https://github.com/rdi2dspaces/dspaces-spack.git /home/cc/downloads/dspaces-spack
fi

spack env create proxystore ~/sc23-proxystore-analysis/dim-instructions/spack-chameleon.yml || true
spack env activate proxystore -p
spack install

pip install --upgrade pip

## install UCX
export C_INCLUDE_PATH=${C_INCLUDE_PATH}:$(find /home/cc/downloads/spack -regex '.*ucx.*/include')
pip install git+https://github.com/rapidsai/ucx-py.git@v0.30.00

## setup redis
cd ~/benchmarks
redis-server ~/sc23-proxystore-analysis/dim-instructions/redis.conf

## setup benchmarks and execute
cd ~/benchmarks
pip install -e .
pip install globus_compute_sdk
