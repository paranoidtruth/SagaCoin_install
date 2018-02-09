echo "=================================================================="
echo "PARANOID TRUTH DINERO MN Install"
echo "=================================================================="
echo "Installing, and will take up to 3 min to run..."
#read -p 'Enter your masternode genkey you created in windows, then hit [ENTER]: ' GENKEY

echo -n "Installing pwgen..."
sudo apt-get install pwgen 

echo -n "Installing dns utils..."
sudo apt-get install dnsutils

#PASSWORD=$(pwgen -s 64 1)
PASSWORD="dinercocoin"
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
sudo apt-get install build-essential libtool automake autoconf -y
sudo apt-get install autotools-dev autoconf pkg-config libssl-dev -y 
sudo apt-get install libgmp3-dev libevent-dev bsdmainutils libboost-all-dev -y
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y
sudo apt-get install libzmq3-dev -y
sudo apt-get install libminiupnpc-dev -y
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get install git -y
sudo apt-get install nano -y
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y

wget https://github.com/paranoidtruth/SagaCoin_install/raw/master/dinero.tar.gz
tar -zxvf dinero.tar.gz
sudo cp dinero_files/dinerod /usr/local/bin/
sudo cp dinero_files/dinero-cli /usr/local/bin/

echo "Loading wallet, 30 seconds wait..." 
dinerod -daemon
sleep 30

echo "making genkey..."
GENKEY=$(dinero-cli masternode genkey)

echo "mining info..."
dinero-cli getmininginfo
dinero-cli stop

echo "creating config..." 

cat <<EOF > ~/.dinerocore/dinero.conf
rpcuser=dinercocoin
rpcpassword=$PASSWORD
rpcallowip=127.0.0.1
rpcport=26284
listen=1
server=1
daemon=1
maxconnections=24
masternode=1
masternodeaddr=$WANIP:26285
externalip=$WANIP:26285
masternodeprivkey=$GENKEY
addnode=seed1.dinerocoin.org
addnode=seed2.dinerocoin.org
addnode=seed3.dinerocoin.org
addnode=seed4.dinerocoin.org
EOF

echo "setting basic security..."
sudo apt-get install fail2ban -y
sudo apt-get install -y ufw
sudo apt-get update -y

#fail2ban:
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
echo "basic security completed..."

echo "restarting wallet with new configs, 30 seconds..."
dinerod -daemon
sleep 30

echo "dinero-cli getmininginfo:"
dinero-cli getmininginfo

echo "masternode status:"
dinero-cli masternode status

echo "INSTALLED WITH VPS IP: $WANIP"
sleep 1
echo "INSTALLED WITH GENKEY: $GENKEY"
