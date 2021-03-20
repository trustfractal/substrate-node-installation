# substrate-install
installation script in 2 parts
1) formating and mounting EBS volume
2) installing substrate node with all its requirements + setting systemd service


## installation / running guide

installing prerequisites:

```
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt install file git vim -y
```

cloning the installation scripts:

```
cd && mkdir -p git && cd git
git clone https://github.com/trustfractal/substrate-node-installation
cd substrate-node-installation
chmod +x *.sh
```

### launching the format&mount script (run this only if you are 100% sure that it's ok to format that EBS volume)

```./format-mount-ebs.sh ```

check if volume is mounted: ```df -h```

```
> ubuntu@ip-172-31-63-104:~$ df -h  
> Filesystem      Size  Used Avail Use% Mounted on  
> /dev/root       7.7G  1.2G  6.6G  15% /  
> devtmpfs        484M     0  484M   0% /dev  
> tmpfs           490M     0  490M   0% /dev/shm  
> tmpfs            98M  776K   98M   1% /run  
> tmpfs           5.0M     0  5.0M   0% /run/lock  
> tmpfs           490M     0  490M   0% /sys/fs/cgroup  
> /dev/loop0       34M   34M     0 100% /snap/amazon-ssm-agent/3552  
> /dev/loop1       56M   56M     0 100% /snap/core18/1988  
> /dev/loop2       32M   32M     0 100% /snap/snapd/11036  
> **/dev/xvdf        10G  104M  9.9G   2% /home/ubuntu/.local/share/polkadot/chains**  
> tmpfs            98M     0   98M   0% /run/user/1000
```


## Installing substrate node

```./install-substrate.sh ```

To customise the node you can change the default settings:

```
> What will be the SYSTEMD service name [default=polkadot]  
> What will be the PUBLIC node name (visible on telemetry) [default=fractal]   
> Which port(public) [default=30333]   
> Which WS PORT [default=9944]   
> Which RPC PORT [default=9933]   
> PROMETHEUS metrics port [default=13001]   
> Set MAX INCOMING peers [default=25]   
> Set MAX OUTGOING peers [default=25]   
> Chain DB Base path [default=/home/ubuntu/.local/share/polkadot/chains/]   
```

Choose your setttings and follow the installaton process.
- you will be asked to choose rust version, if no preferences there, then choose default
- Script chooses the latest version of substrate which will be displayed, e.g.:

```
> Installing polkadot version: v0.8.29   
> Press [Enter] to start installation process or ctrl+c to exit.   
> 
```

if everything looks ok, press ENTER and go and grab a coffee - it will take 20-40min (depending on your hardware).

After node installation wou will be asked to confirm node installation as system service [systemd]

```
> Press [Enter] to continue to install SYSTEMD Service or ctrl+c to exit.  
> Installing xxxxx as systemd service:  
> Done.  
```

installation process is done!

you should see your node in the telemetry:

[1] Kusama: https://telemetry.polkadot.io/#list/Kusama

[2] Polkadot: https://telemetry.polkadot.io/#/Polkadot

# Where to download latest blockchain snapshots:
https://polkashots.io
