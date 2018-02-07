#!/bin/bash
#paranoidtruth

echo "=================================================================="
echo "PARANOID TRUTH Artax MN Install"
echo "=================================================================="
echo "Installing, this will compile and take up to 30 min to run..."
read -p 'Enter your masternode genkey you created in windows, then hit [ENTER]: ' GENKEY

echo -n "Installing pwgen..."
sudo apt-get install pwgen 

echo -n "Installing dns utils..."
sudo apt-get install dnsutils

PASSWORD=$(pwgen -s 64 1)
WANIP=$(dig +short myip.opendns.com @resolver1.opendns.com)

echo -n "Installing with GENKEY: $GENKEY, RPC PASS: $PASSWORD, VPS IP: $WANIP..."

#begin optional swap section
echo "Setting up disk swap..."
free -h 
sudo fallocate -l 4G /swapfile 
ls -lh /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab sudo bash -c "
echo 'vm.swappiness = 10' >> /etc/sysctl.conf"
free -h
echo "SWAP setup complete..."
#end optional swap section

echo "Installing packages and updates..."
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install -y software-properties-common python-software-properties
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get install build-essential libssl-dev libdb++-dev libboost-all-dev libqrencode-dev -y
sudo apt-get install build-essential libssl-dev libcrypto++-dev libminiupnpc-dev libgmp-dev libgmp3-dev -y
sudo apt-get install autoconf autogen automake libtool -y
sudo apt-get install git -y

#this section may fix the target error
echo "BITCOIN CORE..."
cd ~/
git clone https://github.com/bitcoin-core/secp256k1.git
cd secp256k1
./autogen.sh
./configure
make
./tests
sudo make install

echo "MAKING ARTAX..."
cd ~/
git clone https://github.com/Artax-Project/Artax.git
cd ~/Artax/src 
make -f makefile.unix

echo "COPY TO LOCAL..."
sudo cp ~/Artax/src/artaxd /usr/local/bin

echo "INITIAL START: IGNORE ANY CONFIG ERROR MSGs..." 
artaxd

echo "Loading wallet, be patient, wait..." 
sleep 60
artaxd getmininginfo
artaxd stop

echo "creating config..." 

cat <<EOF > ~/.Artax/Artax.conf
rpcuser=rpcartax
rpcpassword=$PASSWORD
rpcallowip=127.0.0.1
rpcport=21526
listen=1
server=1
daemon=1
maxconnections=64
listenonion=0
port=21527
masternode=1
masternodeaddr=$WANIP:21527
masternodeprivkey=$GENKEY
addnode=artax.online 
addnode=seed1.artax.one 
addnode=seed2.artax.one 
addnode=seed3.artax.one 
addnode=104.207.156.30:34457
addnode=108.51.164.90:56635
addnode=108.51.88.251:60423
addnode=108.61.181.58:43427
addnode=108.61.215.152:21527
addnode=113.161.8.131:53080
addnode=115.75.5.106:63112
addnode=124.121.188.118:56878
EOF

echo "setting basic security..."
sudo apt-get install fail2ban -y
sudo apt-get install -y ufw
sudo apt-get update -y

#add a firewall & fail2ban
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow 21527/tcp
sudo ufw logging on
sudo ufw status
sudo ufw enable

#fail2ban:
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
echo "basic security completed..."

echo "restarting wallet, be patient, wait..."
artaxd
sleep 60

echo "artaxd getmininginfo:"
artaxd getmininginfo

echo "Note: installed with IP: $WANIP and genkey: $GENKEY.  If either are incorrect, you will need to edit the .Artax/Artax.conf file"
echo "Done!  It may take time to sync, you can start your final setup checks in the guide once the block count is sync'd"
