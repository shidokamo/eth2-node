NETWORK=

-include env
export

GO_VERSION=1.19

# Relay endpoints
RELAY_goerli  = https://0xafa4c6985aa049fb79dd37010438cfebeb0f2bd42b115b89dd678dab0670c1de38da0c4e9138c9290a398ecd9a0b3110@builder-relay-goerli.flashbots.net
RELAY_sepolia = https://0x845bd072b7cd566f02faeb0a4033ce9399e42839ced64e8b2adcfc859ed1e8e1a5a293336a49feac6d9a5edb779be53a@builder-relay-sepolia.flashbots.net
RELAY_siln    = https://0xb5246e299aeb782fbc7c91b41b3284245b1ed5206134b0028b81dfb974e5900616c67847c2354479934fc4bb75519ee1@builder-relay-kiln.flashbots.net
RELAY_ropsten = https://0xb124d80a00b80815397b4e7f1f05377ccc83aeeceb6be87963ba3649f1e6efa32ca870a88845917ec3f26a8e2aa25c77@builder-relay-ropsten.flashbots.net
RELAY = ${RELAY_${NETWORK}}

default:run

install:adduser install-go install-mev-boost

adduser:
	# Special user without login shell and home dir
	-sudo useradd --no-create-home --shell /bin/false mevboost

# This is very dangerouns if other service is using it. So be very careful.
install-go:
	sudo rm -rf /usr/local/go | echo "There is no Go installed."
	wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
	sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
	rm go${GO_VERSION}.linux-amd64.tar.gz

install-mev-boost:
	CGO_CFLAGS="-O -DBLST_PORTABLE" go install github.com/flashbots/mev-boost@latest
	sudo cp ~/go/bin/mev-boost /usr/local/bin
	sudo chown mevboost:mevboost /usr/local/bin/mev-boost

run:logrotate
	-sudo systemctl stop mev-boost.service
	cat ./mev-boost.service | envsubst > tmp.service
	sudo cp ./tmp.service /etc/systemd/system/mev-boost.service
	rm tmp.service
	sudo mkdir -p /var/log/mev-boost
	sudo chown -R mevboost:mevboost /var/log/mev-boost
	sudo chmod 755 /var/log/mev-boost
	sudo systemctl daemon-reload
	sudo systemctl enable mev-boost.service
	sudo systemctl restart mev-boost.service

logrotate:
	chmod 644 logrotate.conf
	sudo cp logrotate.conf /etc/logrotate.d/mev-boost

status:
	sudo systemctl status mev-boost.service

restart:
	sudo systemctl restart mev-boost.service

stop:
	sudo systemctl stop mev-boost.service

update:stop install-mev-boost restart
