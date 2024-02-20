#!/bin/bash

# Wait for the EBS volume to show up
while [ ! -e /dev/nvme1n1 ]; do echo "Waiting for EBS volume to attach"; sleep 5; done

DEVICE_FS=`sudo blkid -o value -s TYPE /dev/nvme1n1`

sudo touch /test.txt
sudo echo $DEVICE_FS > /test.txt

# Make file system on mounted ebs device if no file system exists
if [ "`echo -n $DEVICE_FS`" == "" ]; then
        sudo mkfs.ext4 /dev/nvme1n1
fi
sudo bash -c "echo '/dev/nvme1n1 /opt/nomad ext4 defaults 0 0' >> /etc/fstab"
sudo mount /opt/nomad

sudo chown -R nomad:nomad /opt/nomad

sudo systemctl restart nomad
