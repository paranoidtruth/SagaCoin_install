#!/bin/bash
#paranoidtruth

#PATH TO CURRENT SAGA:  YOU MUST ALSO CHANGE TAR & MV COMMANDS
FILE_NAME="https://github.com/sagacrypto/SagaCoin/releases/download/1.0.0.5/sagacoin_1.0.0.5_ubuntu16.04.tar.gz"

echo "=================================================================="
echo "SagaCoin MN Install"
echo "=================================================================="
echo "Installing, this will take appx 2 min to run..."
read -p 'Enter your masternode genkey you created in windows, then [ENTER]: ' GENKEY
echo -n "Installing pwgen..."

sudo apt-get install pwgen
PASSWORD=$(pwgen -s 64 1)
WANIP=$(dig +short myip.opendns.com @resolver1.opendns.com)

echo -n "Installing with GENKEY: $GENKEY, RPC PASS: $PASSWORD, VPS IP: $WANIP..."

#begin optional swap section
echo "Setting up disk swap..."
free -h 
sudo fallocate -l 4G /swapfile ls -lh /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab sudo bash -c "echo 'vm.swappiness = 10' >> /etc/sysctl.conf"
free -h
echo "SWAP setup complete..."
#end optional swap section

echo "Installing packages and updates..."
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install build-essential libssl-dev libdb++-dev libboost-all-dev libqrencode-dev -y

echo "Downloading saga wallet..."
wget $FILE_NAME
tar -zxvf sagacoin_1.0.0.5_ubuntu16.04.tar.gz
mv sagacoin_1.0.0.5_ubuntu16.04 SagaCoin
chmod +x SagaCoin/sagacoind
sudo cp SagaCoin/sagacoind /usr/local/bin

echo "INITIAL START: IGNORE ANY CONFIG ERROR MSGs..." 
sagacoind

echo "Loading wallet, be patient, wait..." 
sleep 30
sagacoind getmininginfo
sagacoind stop

echo "creating config..." 

cat <<EOF > ~/.SagaCoin/sagacoin.conf
rpcuser=sagaadminrpc
rpcpassword=$PASSWORD
rpcallowip=127.0.0.1
rpcport=48844
listen=1
server=1
daemon=1
maxconnections=64
listenonion=0
port=48744
masternode=1
masternodeaddr=$WANIP:48744
masternodeprivkey=$GENKEY
addnode=node1.sagacoin.net
addnode=node2.sagacoin.net
addnode=node3.sagacoin.net
addnode=155.94.230.24
addnode=155.94.230.163
addnode=80.209.228.1
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
sudo ufw allow 48744/tcp
sudo ufw logging on
sudo ufw status
sudo ufw enable

#fail2ban:
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
echo "basic security completed..."

echo "restarting wallet, be patient, wait..."
sagacoind
sleep 30


echo "Done!  It may take time to sync, you can start your setup checks in the guide once the block count is sync'd"
echo "sagacoind getmininginfo:"
sagacoind getmininginfo