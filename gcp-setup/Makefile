-include env
PROJECT=$(shell gcloud config get-value project)
ZONE=asia-northeast1-c
MACHINE=n2-standard-8
SWAP_SIZE_MB=32000
NAME=eth

# <Note for SSD>
# If you wanto change # of SSD, add/remove '--local-ssd' options.
# By default, it will use 8 SSDs in parallel (375GB x 8)
#
COMMON_OPTION:=\
  --zone=${ZONE} \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-type=pd-balanced \
  --boot-disk-size=200GB \
  --local-ssd interface=nvme \
  --local-ssd interface=nvme \
  --local-ssd interface=nvme \
  --local-ssd interface=nvme \
  --local-ssd interface=nvme \
  --local-ssd interface=nvme \
  --local-ssd interface=nvme \
  --local-ssd interface=nvme \
  --metadata-from-file startup-script=./startup_script.sh \
  --service-account=${SERVICE_ACCOUNT}@${PROJECT}.iam.gserviceaccount.com \
  --scopes=cloud-platform \
  --tags=jupyter,geth,prysm,eth \
  --network-tier=PREMIUM \

vm:
	gcloud compute instances create ${NAME} ${COMMON_OPTION} --machine-type=${MACHINE}

network-test:
	curl -Lo speedtest-cli https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py
	chmod +x speedtest-cli
	python3 ./speedtest-cli

ssd:merge-ssd format mount fstab

# <Note for SSD>
# If you wanto change # of SSD, change --raid-devices option and add/remove /dev/* arguments
merge-ssd:
	sudo mdadm --create /dev/md0 --level=0 --raid-devices=8 \
		/dev/nvme0n1 \
		/dev/nvme0n2 \
		/dev/nvme0n3 \
		/dev/nvme0n4 \
		/dev/nvme0n5 \
		/dev/nvme0n6 \
		/dev/nvme0n7 \
		/dev/nvme0n8 \

format:
	sudo mkfs.ext4 -F /dev/md0

mount:
	sudo mkdir -p /mnt/disks/ssd
	sudo mount -o discard,defaults,nobarrier /dev/md0 /mnt/disks/ssd
	sudo chmod a+w /mnt/disks/ssd

# Automatically mount SSD when VM restarts
# Don't run this command twice
fstab:
	echo UUID=`sudo blkid -s UUID -o value /dev/md0` /mnt/disks/ssd ext4 discard,defaults,nobarrier,nofail 0 2 | sudo tee -a /etc/fstab
	echo "--------- fstab config ----------"
	cat /etc/fstab

unmount:
	sudo umount /mnt/disks/ssd

test-ssd-iops:
	sudo fio -readwrite=randwrite -blocksize=4k -numjobs=64 \
	-ioengine=libaio -direct=1 -runtime=15 -time_based \
	-filename=/dev/disk/by-id/google-local-nvme-ssd-0 -name=testbench -group_reporting

test-ssd-through-put:
	sudo fio -readwrite=randwrite -blocksize=32m -numjobs=64 \
	-ioengine=libaio -direct=1 -runtime=15 -time_based \
	-filename=/dev/disk/by-id/google-local-nvme-ssd-0 -name=testbench -group_reporting

SWAP=/mnt/disks/ssd/swap
swap:
	sudo dd if=/dev/zero of=${SWAP} bs=1M count=${SWAP_SIZE_MB}
	sudo chmod 600 ${SWAP}
	sudo mkswap ${SWAP}
	sudo swapon ${SWAP}
	echo '${SWAP} none swap sw 0 0' | sudo tee -a /etc/fstab
	echo "--------- fstab config ----------"
	cat /etc/fstab

check-swap:
	sudo swapon --show
	free -h


