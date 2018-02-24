#!/bin/bash
#paranoidtruth

echo "=================================================================="
echo "PARANOID TRUTH BOXY BLOCKS"
echo "=================================================================="

echo "installing unzip"
cd ~/
echo "STOP BOXY"
boxycoin-cli stop
sleep 5

echo "install unzip"
sudo apt-get install unzip -y
echo "pulling blockchain zip file"
wget http://www.boxycoin.org/dl/blockchain.zip
echo "unzipping"
unzip blockchain.zip

cd ~/.boxycoin 
echo "clear out old dir"
rm -rf blocks .lock backups db.log chainstate database peers.dat debug.log
cd ~/
echo "move blocks into boxycoin"
mv blocks ~/.boxycoin/

echo "RESTART WALLET WITH BLOCKS BOOTSTRAP wait..." 
boxycoind -daemon
echo "Loading wallet, be patient, wait 60 seconds ..." 
sleep 60
boxycoin-cli getmininginfo

echo "THIS MAY TAKE UP TO 10 MINUTES.  RUN: boxycoin-cli getmininginfo UNTIL get valid data and syncd up!"
