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

## Checks if the script runs as root
Root_Check () {

	if ! [[ $EUID -eq 0 ]]; then
		printf "$line\n"
		printf "The script needs to run with root privileges\n"
		printf "$line\n"
		exit 1
	fi
}

## Check exit status of the last command to see if it completed successfully
Exit_Status () {

	if [[ $status -eq 0 ]]; then
		printf "$line\n"
		printf "$output_text complete...\n"
		printf "$line\n\n"
	else
		printf "$line\n"
		printf "Somethong went wrong $error_txt, please check log under:\n$errorpath\n"
		printf "$line\n\n"

        ## Propmet the user if he wants to continue with the script
        ## although the last command failed to execute successfully.
        read -p "Would you like to continue anyway?[y/n]: " answer
        printf "\n"
        if [[ -z $answer ]]; then
            :
        elif [[ $answer =~ [y|Y] || $answer =~ [y|Y]es ]]; then
            :
        elif [[ $answer =~ [n|N] || $answer =~ [n|N]o ]]; then
            printf "$line\n"
            printf "Exiting...\n"
            printf "$line\n\n"
            exit 1
        else
            printf "$line\n"
            printf "Invalid answer - exiting\n"
            printf "$line\n\n"
            exit 1
        fi
	fi
}

## progress bar that runs while the installation process is running
Progress_Spinner () {

	## Loop until the PID of the last background process is not found
	until [[ -z $(ps aux |awk '{print $2}' |egrep -Eo "$!") ]];do
		## Print text with a spinner
		printf "\r$output_text in progress...  [|]"
		sleep 0.75
		printf "\r$output_text in progress...  [/]"
		sleep 0.75
		printf "\r$output_text in progress...  [-]"
		sleep 0.75
		printf "\r$output_text in progress...  [\\]"
		sleep 0.70
	done

	## Print a new line outside the loop so it will not interrupt with the it
	## and will not interrupt with the upcoming text of the script
	printf "\n"
}

## Source functions from other scripts
## If they doesn't exists, pull them from GitHub
Source_And_Validation () {

    ## Source the functions from the other scripts.
    ## Check if it was successfull by inserting exit status to a variable
    ## and examen it later
    source ./post_install
    status=$?
    source ./aurman.sh
    status=$?

    if [[ $status -eq 0 ]]; then
        if

}

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

## Checking the environment the user is currenttly running on to determine which settings should be applied
Distro_Check () {

    Distro_Array=(manjaro arch debian \"centos\" \"fedora\")
    status=1
    DistroChk="cat /etc/*-release |grep ID |cut  -d '=' -f '2' |egrep \"^$tmp_dist$\""
    for i in ${Distro_Array[@]}; do
        tmp_dist=$i
    	if ! [[ -z $DistroChk ]]; then
    	  	Distro_Val="$i"
            status=0
    	fi
    done

    if [[ $status -eq 1 ]]; then
        printf "$line\n"
        printf "Sorry, but the script did not find your distribution,
        \b\b\b\bExiting...\n"
        printf "$line\n\n"
        exit 1
    fi

<<COM
	cat /etc/*-release |grep ID |cut  -d "=" -f "2" |egrep "^arch$" &> /dev/null

	if [[ $? -eq 0 ]]; then
		Distro_Val="arch"
	fi

	cat /etc/*-release |grep ID |cut  -d "=" -f "2" |egrep "^debian$|^\"Ubuntu\"$" &> /dev/null

	if [[ $? -eq 0 ]]; then
		Distro_Val="debian"
	fi

	cat /etc/*-release |grep ID |cut  -d "=" -f "2" |egrep "^\"centos\"$|^\"fedora\"$" &> /dev/null

	if [[ $? -eq 0 ]]; then
	   	Distro_Val="centos"
	fi
COM
}

## Make sure the script doesn't run as root
Non_Root_Check () {
	if [[ $EUID -eq 0 ]]; then
		printf "$line\n"
		printf "The Aurman \n"
		printf "$line\n"
		exit 1
	fi
}

## Call Log_And_Variables function
Log_And_Variables

## Call Distro_Check function
Distro_Check

scripts=("Post install **Run as Root**" "Aurman **Run as Non-Root**")
local PS3="Please choose what would you like to do: "
select opt in ${scripts[@]} ; do
    case $opt in
        "Post install **Run as Root**")
            Root_Check
        	if [[ $Distro_Val == arch ]]; then
                Arch_Config
                sleep 1
                Alias_and_Wallpaper
                sleep 1
                DE_Menu
                sleep 1
                Boot_Manager_Config
            fi
            break
            ;;

        "Aurman **Run as Non-Root**")
            Non_Root_Check
            if [[ $Distro_Val == arch ]]; then
                Aurman_Install
                sleep 1
                Aurman_Applications
                sleep 1
                Vbox_Installation
            fi
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
