NETWORK=
CACHE=8092

-include env

OPENSSL=/usr/bin/openssl
JWT_DIR=/var/opt/eth2

export

default:run logrotate

install:
	sudo add-apt-repository -y ppa:ethereum/ethereum
	sudo apt-get update
	sudo apt-get install -y ethereum

jwt:
	${OPENSSL} rand -hex 32 | tr -d "\n" > jwt.hex

adduser:
	-sudo adduser --disabled-password --gecos "" geth
	-sudo adduser ${USER} geth

run:adduser logrotate
	-sudo systemctl stop geth.service
	cat ./geth.service | envsubst > tmp.service
	sudo cp ./tmp.service /etc/systemd/system/geth.service
	rm tmp.service
	sudo mkdir -p ${JWT_DIR}
	sudo cp ./jwt.hex ${JWT_DIR}
	sudo mkdir -p /var/log/geth
	sudo chown -R geth:geth /var/log/geth
	sudo chmod 755 /var/log/geth
	sudo systemctl daemon-reload
	sudo systemctl enable geth.service
	sudo systemctl restart geth

logrotate:
	chmod 644 logrotate.conf
	sudo cp logrotate.conf /etc/logrotate.d/geth

status:
	sudo systemctl status geth.service

restart:
	sudo systemctl restart geth.service

stop:
	sudo systemctl stop geth.service

attach:
	geth attach http://localhost:8545

update:
	sudo add-apt-repository -y ppa:ethereum/ethereum
	sudo apt-get update
	sudo apt-get upgrade
	sudo systemctl restart geth

# Very dangerous. Clean up all block data
clean:
	sudo rm -rf /mnt/disks/ssd/geth
