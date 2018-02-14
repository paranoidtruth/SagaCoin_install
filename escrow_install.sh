echo "=================================================================="
echo "PARANOID TRUTH ESCROW MN Install"
echo "=================================================================="
echo "Installing, and will take up to 3 min to run..."
#read -p 'Enter your masternode genkey you created in windows, then hit [ENTER]: ' GENKEY

echo -n "Installing pwgen..."
sudo apt-get install pwgen 

echo -n "Installing dns utils..."
sudo apt-get install dnsutils

#PASSWORD=$(pwgen -s 64 1)
PASSWORD="escrowcoinpass"
WANIP=$(dig +short myip.opendns.com @resolver1.opendns.com)

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
sudo apt-get install git -y
sudo apt-get install nano -y
sudo apt-get install build-essential libtool automake autoconf -y
sudo apt-get install autotools-dev autoconf pkg-config libssl-dev -y
sudo apt-get install libgmp3-dev libevent-dev bsdmainutils libboost-all-dev -y
sudo apt-get install libzmq3-dev -y
sudo apt-get install libminiupnpc-dev -y
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y
sudo apt-get install libdb5.3-dev libdb5.3++-dev -y

echo "Packages complete..."

wget https://github.com/paranoidtruth/SagaCoin_install/raw/master/Escrow.tar.gz
#wget https://github.com/dinerocoin/dinero/releases/download/v1.0.0.5/dinerocore-1.0.0.5-linux64.tar.gz

tar -zxvf Escrow.tar.gz
#mv dinerocore-1.0.0 dinero
sudo cp Escrowd /usr/local/bin/
#sudo cp escrow/bin/Escrow-cli /usr/local/bin/

echo "Loading wallet, 30 seconds wait..." 
Escrowd
sleep 30

cat <<EOF > ~/.Escrow/Escrow.conf
rpcuser=escrowcoin
rpcpassword=$PASSWORD
rpcallowip=127.0.0.1
rpcport=8017
listen=1
server=1
daemon=1
maxconnections=24
EOF

echo "RELOADING WALLET..."
Escrowd
sleep 10

echo "making genkey..."
GENKEY=$(Escrowd masternode genkey)

echo "mining info..."
Escrowd getmininginfo
Escrowd stop

echo "creating final config..." 

cat <<EOF > ~/.Escrow/Escrow.conf
rpcuser=escrowcoin
rpcpassword=$PASSWORD
rpcallowip=127.0.0.1
rpcport=8017
listen=1
server=1
daemon=1
maxconnections=24
masternode=1
masternodeaddr=$WANIP:8018
masternodeprivkey=$GENKEY
EOF

echo "setting basic security..."
sudo apt-get install fail2ban -y
sudo apt-get install -y ufw
sudo apt-get update -y

#fail2ban:
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

#add a firewall
sudo ufw default allow outgoing 
sudo ufw default deny incoming 
sudo ufw allow ssh/tcp 
sudo ufw limit ssh/tcp 
sudo ufw allow 8018/tcp 
sudo ufw allow 8017/tcp
sudo ufw logging on 
sudo ufw status
sudo ufw enable
echo "basic security completed..."

echo "restarting wallet with new configs, 30 seconds..."
Escrowd
sleep 30

echo "escrow getmininginfo:"
Escrowd getmininginfo

echo "masternode status:"
Escrowd masternode status

echo "INSTALLED WITH VPS IP: $WANIP:8018"
sleep 1
echo "INSTALLED WITH GENKEY: $GENKEY"
