#!/bin/bash
sudo apt-get update -y
sudo apt-get upgrade -y

# checing EBS type
NVME_DISKS=$(lsblk | grep -e nvme1 | wc -l)
if  [ $NVME_DISKS > 0 ]; then
        echo "NVMe type of disk" 
        EBS="/dev/nvme1n1"
else
        echo "Standart EBS disk" 
         EBS="/dev/xvdf"
fi

# formating volume
sudo mkfs -t xfs $EBS

# creating mounting dir (default polkadot folder)
mkdir -p /home/$USER/.local/share/polkadot/chains/
sudo mount $EBS /home/$USER/.local/share/polkadot/chains/
sudo chmod -Rv a+w /home/$USER/.local/share/polkadot/chains

# adding to fstab
sudo cp /etc/fstab /etc/fstab.orig
echo "$EBS /home/$USER/.local/share/polkadot/chains/ xfs  defaults,nofail  0  2" | sudo tee -a /etc/fstab > /dev/null

# checking mounted disks
df -h

