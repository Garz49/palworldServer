#! /bin/bash
#
#                                                                     
#                         -  PALWORLD SERVER INSTALLATION SCRIPT  -                        
#                                                                     
#
# This script automates the installation process of a Palworld game server. Please note the following:
#
# - This script requires sudo privileges to perform certain system-level operations. It is recommended to review the script contents before execution.
# - Ensure that you trust the source from which you obtained this script. 
#   While efforts have been made to create a reliable installation process, always exercise caution when running scripts obtained from the internet.
# - By executing this script, you acknowledge that you are responsible for any changes made to your system and any consequences thereof.
#
# Usage:
#   sudo ./install_palworld_server.sh
#
# Please report any issues or provide feedback at Garz.

set -e

### VARIABLES
DEFAULT_USER=$(whoami)
DISTRIBUTION=$(lsb_release -is)


### FUNCTIONS

function update()
{
    echo "| Updating your environment...\n"
    sudo apt update
    sudo apt upgrade -y
}

function install_necessary_package()
{
    echo "| Installing software-properties-common...\n"
    sudo apt install software-properties-common -y
}

function install_steamcmd()
{
    echo "| Installing software-properties-common...\n"
    if [[ "${DISTRIBUTION}" == "Ubuntu" ]]; then
        echo "| | Installation for Ubuntu distribution...\n"
        sudo apt-add-repository main universe restricted multiverse && sudo dpkg --add-architecture i386 && apt update && apt install steamcmd -y
    elif [[ "${DISTRIBUTION}" == "Debian" ]]; then
        echo "| | Installation for Debian distribution...\n"
        sudo apt-add-repository non-free && sudo dpkg --add-architecture i386 && apt update && apt install steamcmd -y
    else
        echo "| | Your distribution is not compatible with this script, please use a Debian or a Ubuntu distribution instead."
        exit 1
    fi


}

function create_steam_user()
{
    echo "| Create steam user... \n"
    sudo useradd -m steam
    
    echo "| Update PATH... \n"
    echo 'export PATH="/usr/games/:$PATH"' >> ~/.bashrc
    
    echo "| Switch steam user... \n"
    sudo -u steam -s
    cd ~
}

function install_palworld_server()
{
    echo "| Downloading the Steamworks SDK redistributable... \n"
    steamcmd +force_install_dir '/home/steam/Steam/steamapps/common/steamworks' +login anonymous +app_update 1007 +quit
    
    echo "| Create SDK library directory... \n"
    mkdir -p /home/steam/.steam/sdk64

    echo "| Creating symlink to avoid log server errors... \n"
    cd /home/steam/.steam && ln -s /home/steam/.local/share/Steam/steamcmd/linux32 sdk32 && ln -s /home/steam/.local/share/Steam/steamcmd/linux64 sdk64
    
    echo "| Copy steamclient.so into it... \n"
    cp '/home/steam/Steam/steamapps/common/steamworks/linux64/steamclient.so' /home/steam/.steam/sdk64/
    
    echo "| Downloading Palworld dedicated Server... \n"
    steamcmd +force_install_dir '/home/steam/Steam/steamapps/common/PalServer' +login anonymous +app_update 2394010 validate +quit

}

function create_palworld_service()
{
    echo "| Changing user... \n"
    sudo -u ${DEFAULT_USER} -s

    echo "| Setting up palworld service... \n"
    sudo mv palworld.service /etc/systemd/system/
    sudo systemctl start palworld.service
    sudo systemctl stop palworld.service
    sudo systemctl enable palworld.service
}

function installation_process()
{
    echo "\n######################################\n"
    echo "### PREPARATION OF THE ENVIRONMENT ###\n"
    echo "######################################\n"

    update
    install_necessary_package


    echo "\n\n#############################\n"
    echo "### STEAMCMD INSTALLATION ###\n"
    echo "#############################\n"

    install_steamcmd


    echo "\n\n#########################\n"
    echo "### CREATE USER STEAM ###\n"
    echo "#########################\n"

    create_steam_user


    echo "\n\n###############################\n"
    echo "### INSTALL PALWORLD SERVER ###\n"
    echo "###############################\n"

    install_palworld_server


    echo "\n\n###############################\n"
    echo "### CREATE PALWORLD SERVICE ###\n"
    echo "###############################\n"

    create_palworld_service


    echo "\n\n################################\n"
    echo "### SUCCESSFULL INSTALLATION ###\n"
    echo "################################\n"
}

function display_palworld_settings() {
    echo -e "
    [00] - Difficulty 	                        Game difficulty level.\n
    [01] - DayTimeSpeedRate 	                Day time progression speed. \n
    [02] - NightTimeSpeedRate              	    Night time progression speed.\n
    [03] - ExpRate 	                            Experience points rate.\n
    [04] - PalCaptureRate 	                    Pal capture rate.\n
    [05] - PalSpawnNumRate 	                    Pal appearance rate.\n
    [06] - PalDamageRateAttack 	                Damage from Pals multiplier.\n
    [07] - PalDamageRateDefense 	            Damage to Pals multiplier.\n
    [08] - PlayerDamageRateAttack 	            Damage from player multiplier.\n
    [09] - PlayerDamageRateDefense 	            Damage to player multiplier.\n
    [10] - PlayerStomachDecreaceRate 	        Player hunger depletion rate.\n
    [11] - PlayerStaminaDecreaceRate 	        Player stamina reduction rate.\n
    [12] - PlayerAutoHPRegeneRate 	            Player HP regeneration rate.\n
    [13] - PlayerAutoHpRegeneRateInSleep 	    Player HP regeneration during sleep.\n
    [14] - PalStomachDecreaceRate          	    Pal hunger depletion rate.\n
    [15] - PalStaminaDecreaceRate 	            Pal stamina reduction rate.\n
    [16] - PalAutoHPRegeneRate 	                Pal HP regeneration rate.\n
    [17] - PalAutoHpRegeneRateInSleep 	        Pal health regeneration in Palbox (sleep).\n
    [18] - BuildObjectDamageRate 	            Structure damage multiplier.\n
    [19] - BuildObjectDeteriorationDamageRate 	Structure deterioration rate.\n
    [20] - CollectionDropRate 	                Gatherable items drop rate.\n
    [21] - CollectionObjectHpRate 	            Gatherable objects HP rate.\n
    [22] - CollectionObjectRespawnSpeedRate 	Gatherable objects respawn rate.\n
    [23] - EnemyDropItemRate 	                Enemy item drop rate.\n
    [24] - DeathPenalty 	                    Settings for death penalty.\n
    [25] - GuildPlayerMaxNum 	                Guild player capacity.\n
    [26] - PalEggDefaultHatchingTime 	        Time to hatch a massive egg.\n
    [27] - ServerPlayerMaxNum              	    Server player capacity.\n
    [28] - ServerName 	                        Server's name.\n
    [29] - ServerDescription 	                Server description.\n
    [30] - AdminPassword 	                    Administrator password.\n
    [31] - ServerPassword 	                    Server access password.\n
    [32] - PublicPort 	                        Public port number.\n
    [33] - PublicIP 	                        Server's public IP\n"
}


function schedule_management()
{
    # echo "# Palworld dedicated server is memory intensive, please follow this instruction:\n"
    # echo "# [0] - If you have less than 8GB of RAM, it is recommanded to restart the service every hours, select '0' if you accept to do it.\n"
    # echo "# [1] - If you have between 8GB and 16GB of RAM, it is recommanded to restart the service every day, select '1' if you accept to do it.\n"
    # echo "# [2] - If you have more than 16GB of RAM, it is not necessary to reboot the server, " \
    # "# please select '2' if you don't want schedule a reboot of the server.\n"
    # echo "# [3] - Exit\n"
    # read -p "# Please select your case: [0-3]: " schedule_decision

    # case "${schedule_decision}" in
    # 0)

    #     ;;
    # 1)
    #     ;;
    # 2|3)
    #     echo "Bye bye"
    #     exit 1
    #     ;;
    # *)
    #     echo "\n# Please enter a number between [0-3]\n"
    #     ;;
    # esac
    echo "This option is not supported for now\n"
}

function configuration_server()
{
    display_palworld_settings
    read -p "Witch setting do you want modify [0-33]: " settingToModify

    case "${settingToModify}" in

}


############
### MAIN ###
############

echo "# Welcome to the installation script\n"
echo "# Please run this script with 'sudo'\n"
echo "# \n"
echo "\n"
echo "# [0] - Fully Installation (recommanded if you never run this script before)\n"
echo "# [1] - Only installation\n"
echo "# [2] - Only schedule reboot management (all will be explain futher)\n"
echo "# [3] - Only configuration server (the server need to be installed)\n"
echo "# [4] - Exit\n"

read -p "# Please select one of these instructions, enter a number between [0-4]: " user_decision

case "${user_decision}" in
    0)
        installation_process
        schedule_management
        configuration_server
        ;;
    1)
        installation_process
        ;;
    2)
        schedule_management
        ;;
    3)
        configuration_server
        ;;
    4)
        echo "Bye bye"
        exit 1
        ;;
    *)
        echo "\n# Please enter a number between [0-4]\n"
        ;;
esac



