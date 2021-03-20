#!/bin/bash
clear
####################################
#   Setup
####################################
sudo echo "initialising root"

RED='\033[0;31m'
GREEN='\033[1;32m' 
NC='\033[0m' # No Color

# default values
NAME="fractal"
PORT="30333"
WS_PORT="9944"
RPC_PORT="9933"
PROMETHEUS_PORT="13001"
TELEMETRY1=" --telemetry-url 'wss://telemetry.polkadot.io/submit/ 1' "
TELEMETRY2=""
OUT_PEERS="25"
IN_PEERS="25"
SERVICE_NAME="polkadot"
BASE_PATH="/home/$USER/.local/share/polkadot/chains/"
CHAIN=""
# READ THE VARIABLES

PS3='Choose the substrate chain: '
chains=("kusama" "polkadot" "Quit")
select fav in "${chains[@]}" 
do
    case $fav in
        "kusama")
            echo -e "\n\n${GREEN} Installing KUSAMA CHAIN${NC}"
	          CHAIN=" --chain kusama "
            break
            ;;
        "polkadot")
            echo -e "\n\n${GREEN} Installing POLKADOT CHAIN${NC}"
	          # it's a default chain - so no need to specify one
            CHAIN=""
            break
            ;;
      	"Quit")
	         echo "User requested exit"
	         exit
	         ;;
        *) echo "invalid option $REPLY";;
    esac
done

read -p "What will be the SYSTEMD service name [default=$SERVICE_NAME]"   answer
: ${answer:=$SERVICE_NAME}
SERVICE_NAME=$answer

read -p "What will be the PUBLIC node name (visible on telemetry) [default=$NAME] " answer
: ${answer:=$NAME}
NAME=$answer

read -p "Which port(public) [default=$PORT] " answer
: ${answer:=$PORT}
PORT=$answer

read -p "Which WS PORT [default=$WS_PORT] " answer
: ${answer:=$WS_PORT}
WS_PORT=$answer

read -p "Which RPC PORT [default=$RPC_PORT] " answer
: ${answer:=$RPC_PORT}
RPC_PORT=$answer

read -p "PROMETHEUS metrics port [default=$PROMETHEUS_PORT] " answer
: ${answer:=$PROMETHEUS_PORT}
PROMETHEUS_PORT=$answer

read -p "Set MAX INCOMING peers [default=$IN_PEERS] " answer
: ${answer:=$IN_PEERS}
IN_PEERS=$answer

read -p "Set MAX OUTGOING peers [default=$OUT_PEERS] " answer
: ${answer:=$OUT_PEERS}
OUT_PEERS=$answer

read -p "Chain DB Base path [default=$BASE_PATH] " answer
: ${answer:=$BASE_PATH}
BASE_PATH=$answer


# Print out settings
echo -e  "\n\n${GREEN}Installing service with following settings:
${GREEN}SYSTEMD SERVICE=${RED}$SERVICE_NAME
${GREEN}PUBLIC NODE NAME=${RED}$NAME
${GREEN}PORT=${RED}$PORT
${GREEN}WS_PORT=${RED}$WS_PORT
${GREEN}RPC_PORT=${RED}$RPC_PORT
${GREEN}PROMETHEUS_PORT=${RED}$PROMETHEUS_PORT
${GREEN}OUT_PEERS=${RED}$OUT_PEERS
${GREEN}IN_PEERS=${RED}$IN_PEERS${NC}
${GREEN}BASE PATH=${RED}$BASE_PATH${NC}
"
printf "${GREEN}Press [Enter] to continue or ctrl+c to exit.${NC}"
read -p " "   


####################################
#   Install Software Packages
####################################


# Update base server & apt-get
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Base packages
printf "\n\n\n\n${GREEN}Install Base packages${NC} \n"
sudo apt-get install make clang pkg-config libssl-dev build-essential git 

# Install Rust
printf "\n\n\n${GREEN}Install RUST ${NC}\n"
curl https://sh.rustup.rs -sSf | sh

# update Rust
rustup update
source $HOME/.cargo/env

####################################
#   Install Polkadot binary
####################################


# Install polkadot binary
cd && mkdir -p source
cd source
git clone https://github.com/paritytech/polkadot.git
cd polkadot

# checking latest version
export LATEST_VERSION=$(git tag -l | sort -V | grep -v -- '-rc' | tail -n1)

printf "\n\n\n\n${GREEN}Installing polkadot version: ${RED}$LATEST_VERSION ${NC}\n"
printf "${GREEN}Press [Enter] to start installation process or ctrl+c to exit.${NC}"
read -p " "   

git checkout $LATEST_VERSION

./scripts/init.sh
cargo build --release

# copy the binary to .local/bin
mkdir -p ~/.local/bin
cp target/release/polkadot ~/.local/bin/

# adding to the PATH
echo "export PATH=~/.local/bin:$PATH" >> ~/.bashrc 
source ~/.bashrc 


printf "\n\n\n\n${GREEN}Checking installed version${NC}\n"
# checking the version
~/.local/bin/polkadot --version


####################################
#  installing systemd service
####################################

printf "\n\n\n\n${GREEN}createing $SERVICE_NAME config file in ~/config/${NC}\n"
printf "${GREEN}Press [Enter] to continue to install SYSTEMD Service or ctrl+c to exit.${NC}"
read -p " "   


# variable file
mkdir -p ~/config
tee /home/$USER/config/systemd-$SERVICE_NAME.environment  > /dev/null <<EOT
NAME="$NAME"
BASE_PATH="$BASE_PATH"
PORT="$PORT"
WS_PORT="$WS_PORT"
RPC_PORT="$RPC_PORT"
PROMETHEUS_PORT="$PROMETHEUS_PORT"
TELEMETRY1=" --telemetry-url 'wss://telemetry.polkadot.io/submit/ 1' "
TELEMETRY2="" 
OUT_PEERS="$OUT_PEERS"
IN_PEERS="$IN_PEERS"
WASM=""
CHAIN="$CHAIN"
EOT

# systemd file
printf "\n\n\n\n${GREEN}Installing $SERVICE_NAME as systemd service:${NC}\n"
sudo tee /etc/systemd/system/$SERVICE_NAME.service  > /dev/null <<EOT
[Unit]
Description=$SERVICE_NAME Validator

[Service]
Type=simple
EnvironmentFile=/home/$USER/config/systemd-$SERVICE_NAME.environment
ExecStart=/home/$USER/.local/bin/polkadot \$CHAIN --validator --prometheus-external --name \$NAME --port \$PORT  --ws-port \$WS_PORT  --rpc-port \$RPC_PORT --prometheus-port \$PROMETHEUS_PORT --out-peers \$OUT_PEERS  --in-peers \$IN_PEERS --base-path \$BASE_PATH \$TELEMETRY1 \$TELEMETRY2 \$WASM 


Restart=on-failure
RestartSec=120
KillSignal=SIGINT
RestartKillSignal=SIGINT
SyslogIdentifier=polkadot
StandardOutput=syslog
StandardError=syslog
LimitNOFILE=32768
User=$USER
Group=$USER


[Install]
WantedBy=multi-user.target
EOT
printf "\n${GREEN}Done${NC}\n"

####################################
#  Initialising systemd service
####################################
printf "\n\n\n\n${GREEN}Enabling $SERVICE_NAME as systemd service:${NC}\n"
sudo systemctl enable $SERVICE_NAME
printf "${GREEN}Done${NC}\n"
echo "To start $SERVICE_NAME type: sudo systemctl start $SERVICE_NAME"
