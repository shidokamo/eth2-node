#!/bin/sh

## System
apt-get update
apt-get -y upgrade

## Basic command line tools
apt-get install -y zsh
apt-get install -y tmux
apt-get install -y mosh
apt-get install -y jq
apt-get install -y ack
apt-get install -y tree

echo '----- Install stackdriver monitoring agent for GCP ----'
curl -sSO https://dl.google.com/cloudagents/install-monitoring-agent.sh
sudo bash install-monitoring-agent.sh

# echo '----- Install stackdriver logging agent ----'

## Network tools
apg-get install -y traceroute
apg-get install -y dnsutils

## GCC, Make, etc.
apt-get install -y build-essential
apt-get install -y automake
apt-get install -y libtool

# Required to build ruby (2.5, 2.6)
# 2.3 open ssl compilation will fail with the latest libssl-dev...
# apt-get install -y libssl-dev libreadline-dev zlib1g-dev

## Redis
wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable
make
make install
cd ..

## Ruby
apt-get install -y ruby ruby-dev
gem install bunder
gem install fluentd

## Python (system Python is required for any virtual env)
apt-get install -y python3 python3-pip python3-dev

## NTP (You don't need this anymore. Now chrony will set NTP by default)
# cat <<EOF > /etc/systemd/timesyncd.conf
# [Time]
# NTP=
# FallbackNTP=time.google.com
# EOF
# systemctl daemon-reload
# systemctl enable systemd-timesyncd
# systemctl start systemd-timesyncd

## SSD
apt-get install -y mdadm --no-install-recommends

## SSD benchmark
sudo apt install -y fio

