#!/usr/bin/env bash


################################################################################
#
# License :  GPLv3
#
# Description :  Main script that calls the appropriate functions
#                from the other scripts
#
# Version :  1.0.0
################################################################################

##
source ./post_install
source ./aurman.sh

scripts=("Post install")
local PS3="Please choose what would you like to do: "
select opt in ${scripts[@]} ; do
    case $opt in
        Plasma)
            KDE_Installation
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
