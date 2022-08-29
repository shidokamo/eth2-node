NETWORK=
CHECKPOINT=https://goerli.checkpoint-sync.ethdevops.io
FEE_RECIPIENT=

-include env
export

UGNAME=beacon
DATADIR=/mnt/disks/ssd/beacon
JWT_DIR=/var/opt/eth2
GENESIS_DIR:=${DATADIR}

default:run logrotate

install:adduser
	# Create working directory and download shell script
	# TODO: Check if we should always use same versions between beacon/slasher/validator
	sudo mkdir -p /var/opt/beacon
	sudo chown -R ${UGNAME}:${UGNAME} /var/opt/beacon
	sudo curl https://raw.githubusercontent.com/prysmaticlabs/prysm/master/prysm.sh --output /var/opt/beacon/prysm.sh
	sudo chmod +x /var/opt/beacon/prysm.sh

adduser:
	-sudo adduser --disabled-password --gecos "" ${UGNAME}
	-sudo adduser ${USER} ${UGNAME}

help:
	/var/opt/beacon/prysm.sh beacon-chain help

genesis:
	sudo mkdir -p ${GENESIS_DIR}
	wget https://github.com/eth-clients/eth2-networks/raw/master/shared/prater/genesis.ssz
	sudo mv genesis.ssz ${GENESIS_DIR}

run:
	-sudo systemctl stop beacon.service
	cat ./beacon.service | envsubst > ./tmp.service
	sudo cp ./tmp.service /etc/systemd/system/beacon.service
	rm tmp.service
	sudo mkdir -p ${DATADIR}
	sudo chown -R ${UGNAME}:${UGNAME} ${DATADIR}
	sudo mkdir -p /var/log/beacon
	sudo chown -R ${UGNAME}:${UGNAME} /var/log/beacon
	sudo chmod 755 /var/log/beacon
	sudo systemctl daemon-reload
	sudo systemctl enable beacon.service
	sudo systemctl start beacon.service

run-checkpoint:
	-sudo systemctl stop beacon.service
	cat ./beacon.checkpoint.service | envsubst > ./tmp.service
	sudo cp ./tmp.service /etc/systemd/system/beacon.service
	rm tmp.service
	sudo mkdir -p ${DATADIR}
	sudo chown -R ${UGNAME}:${UGNAME} ${DATADIR}
	sudo mkdir -p /var/log/beacon
	sudo chown -R ${UGNAME}:${UGNAME} /var/log/beacon
	sudo chmod 755 /var/log/beacon
	sudo systemctl daemon-reload
	sudo systemctl enable beacon.service
	sudo systemctl start beacon.service

reload:
	sudo cp ./beacon.service /etc/systemd/system/beacon.service
	sudo systemctl daemon-reload
	sudo systemctl enable beacon.service
	sudo systemctl start beacon.service

logrotate:
	chmod 644 beacon.logrotate.conf
	sudo cp beacon.logrotate.conf /etc/logrotate.d/beacon

status:
	sudo systemctl status beacon.service

restart:
	sudo systemctl restart beacon.service

stop:
	sudo systemctl stop beacon.service

disable:
	sudo systemctl disable beacon.service

enable:
	sudo systemctl enable beacon.service

update:restart

# Very dangerous. Clean up all block data
clean:
	sudo rm -rf /mnt/disks/ssd/beacon
