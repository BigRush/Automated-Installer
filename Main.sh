#!/usr/bin/env bash


################################################################################
# Author :	BigRush
#
# License :  GPLv3
#
# Description :  Main script that calls the appropriate functions
#                from the other scripts
#
# Version :  1.0.0
################################################################################

## Declare variables and log path that will be used by other functions
Log_And_Variables () {
	####  Varibale	####
	line="\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-"
	logfolder="/var/log/post_install"
	errorpath=$logfolder/error.log
	outputpath=$logfolder/output.log
	orig_user=$SUDO_USER
	user_path=/home/$orig_user
	lightconf=/etc/lightdm/lightdm.conf
	PACSTALL="pacman -S --needed --noconfirm"
	AURSTALL="aurman -S --needed --noconfirm --noedit"
	####  Varibale	####

	## Check if log folder exits, if not - create it
	if ! [[ -e $logfolder ]]; then
		mkdir -p $logfolder
	fi
}

## Source the functions from the other scripts
source ./post_install
source ./aurman.sh

scripts=("Post install **Run as Root**" "Aurman **Run as Non-Root**")
local PS3="Please choose what would you like to do: "
select opt in ${scripts[@]} ; do
    case $opt in
        "Post install **Run as Root**")
            Log_And_Variables
            Root_Check
            Distro_Check
        	if [[ $Distro_Val == arch ]]; then
                Arch_Config
            break
            ;;

        "Aurman **Run as Non-Root**")
            Deepin_Installation
            break
            ;;

        Exit)
            printf "$line\n"
            printf "Exiting, have a nice day!"
            printf "$line\n"
            exit 0
        *)
            printf "Invalid option\n"
        ;;
    esac
done
