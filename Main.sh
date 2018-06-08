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
        Deepin)
            Deepin_Installation
            break
            ;;
        xfce4)
            printf "$line\n"
            printf "Not avaliable at the moment, coming soon...\n"
            printf "$line\n\n"
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
