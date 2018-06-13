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
		printf "The 'Post install' option must run with root privileges\n"
		printf "$line\n"
		exit 1
	fi
}

## Make sure the script doesn't run as root
Non_Root_Check () {
	if [[ $EUID -eq 0 ]]; then
		printf "$line\n"
		printf "The 'Aurman' option must run as non-root\n"
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
	until [[ -z $(ps aux |awk '{print $2}' |egrep -Eo "$BPID") ]];do
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
	printf "\n\n"
}

## Declare variables and log path that will be used by other functions
Log_And_Variables () {

	####  Varibale	####
    line="\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-"
    errorpath=log/error.log
    outputpath=log/output.log
    orig_user=$(who |awk {'print $1'})
    user_path=/home/$orig_user
    lightconf=/etc/lightdm/lightdm.conf
	CWD=$(pwd)
    # PACSTALL="$(pacman -S $PKGNAME --needed --noconfirm)"
    # AURSTALL="aurman -S --needed --noconfirm --noedit"
    post_script="https://raw.githubusercontent.com/BigRush/Automated-Installer/master/.post-install.sh"
    aurman_script="https://raw.githubusercontent.com/BigRush/Automated-Installer/master/.aurman.sh"
	####  Varibale	####

	## Validate that the original user that logged in isn't root
	if [[ $orig_user == "root" ]]; then
		printf "$line\n"
		printf "The script can't run when the user that originally logged in is root\n"
		printf "Please log in as non-root and try again..\n"
		printf "$line\n\n"
		exit 1
	fi

	## Check if log folder exits, if not, create it
	if ! [[ -d log ]]; then
		runuser -l $orig_user -c "mkdir $CWD/log"
	fi

	## Check if error log exits, if not, create it
	if ! [[ -e $errorpath ]]; then
		runuser -l $orig_user -c "touch $CWD/$errorpath"
	fi

	## Check if output log exits, if not, create it
	if ! [[ -e $outputpath ]]; then
		runuser -l $orig_user -c "touch $CWD/$outputpath"
	fi
}

## Checking the environment the user is currenttly running on to determine which settings should be applied
Distro_Check () {

    Distro_Array=(manjaro arch debian \"Ubuntu\" \"centos\" \"fedora\")
    status=1
    for i in ${Distro_Array[@]}; do
        tmp_dist=$i
        DistroChk=$(cat /etc/*-release |grep ID |cut  -d '=' -f '2' |egrep "^$tmp_dist$")
    	if ! [[ -z $DistroChk ]]; then
    	  	Distro_Val="$i"
            status=0
    	fi
    done

    if [[ $status -eq 1 ]]; then
        printf "$line\n"
        printf "Sorry, but the script did not find your distribution,\n"
        printf "Exiting...\n"
        printf "$line\n\n"
        exit 1
    fi
}

## Source functions from other scripts
## If they doesn't exists, pull them from GitHub
Source_And_Validation () {

    ## Check if wget is installed,
    ## if not then download it
    ## (It's a dependency for later anyways)
    if [[ -z $(command -v wget) ]]; then
        printf "$line\n"
        printf "Downloading wget...\n"
        printf "$line\n\n"

        output_text="wget download"
        error_txt="while downloading wget"

        ## Download wget
        if [[ $Distro_Val == arch || $Distro_Val == manjaro ]]; then
            pacman -S wget 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

        elif [[ $Distro_Val == \"debian\" || $Distro_Val == \"Ubuntu\" ]]; then
            apt-get install wget -y 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

        elif [[ $Distro_Val == \"centos\" || $Distro_Val == \"fedora\" ]]; then
            yum install wget -y 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status
        fi
    fi

    ## Source the functions from the other scripts.
    ## Check if it was successfull with exit status,
    ## if it wasn't, get the missing script from GitHub
    source ./.post-install.sh 2>> $errorpath >> $outputpath
    if ! [[ $? -eq 0 ]]; then
		printf "$line\n"
		printf "Downloading .post-install.sh...\n"
		printf "$line\n\n"

		output_text=".post-install.sh download"
		error_txt="while downloading .post-install.sh"

        wget $post_script 2>> $errorpath >> $outputpath &
        status=$?
        Progress_Spinner
        Exit_Status
    fi

    source ./.aurman.sh 2>> $errorpath >> $outputpath
    if ! [[ $? -eq 0 ]]; then
		printf "$line\n"
		printf "Downloading .aurman.sh...\n"
		printf "$line\n\n"

		output_text=".aurman.sh download"
		error_txt="while downloading .aurman.sh"

        wget $aurman_script 2>> $errorpath >> $outputpath &
        status=$?
        Progress_Spinner
        Exit_Status
    fi
}

## Call Log_And_Variables function
Log_And_Variables

## Call Distro_Check function
Distro_Check

## Call Source_And_Validation function
Source_And_Validation

## Propmet the user with a menu to start the script
IFS=","
scripts=("Post install **Run as Root**","Aurman **Run as Non-Root**","Exit")
PS3="Please choose what would you like to do: "
select opt in ${scripts[*]} ; do
    case $opt in
        "Post install **Run as Root**")
            Root_Check
        	if [[ $Distro_Val == arch ]]; then
                Arch_Config
				exit 0
                sleep 1
                Alias_and_Wallpaper
                sleep 1
				Pacman_Multilib
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
            printf "Exiting, have a nice day!\n"
            printf "$line\n"
            exit 0
            ;;

        *)
            printf "Invalid option\n"
            ;;
    esac
done
