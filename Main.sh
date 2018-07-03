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
		printf "Something went wrong $error_txt, please check log under:\n$errorpath\n"
		printf "$line\n\n"

        ## Propmet the user if he wants to continue with the script
        ## although the last command failed to execute successfully.
        read -p "Would you like to continue anyway?[y/N]: " answer
        printf "\n"
        if [[ -z $answer ]]; then
            exit 1
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
	if [[ -z $SUDO_USER ]]; then
		orig_user=$(whoami)
	else
		orig_user=$SUDO_USER
	fi
	user_path=/home/$orig_user
	errorpath=$user_path/Automated-Installer-Log/error.log
    outputpath=$user_path/Automated-Installer-Log/output.log
    lightconf=/etc/lightdm/lightdm.conf
	lightwebconf=/etc/lightdm/lightdm-webkit2-greeter.conf
	post_script="https://raw.githubusercontent.com/BigRush/Automated-Installer/master/.post-install.sh"
    aurhelper_script="https://raw.githubusercontent.com/BigRush/Automated-Installer/master/.aurhelper.sh"
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
	if ! [[ -d $user_path/Automated-Installer-Log ]]; then
		sudo runuser -l $orig_user -c "mkdir $user_path/Automated-Installer-Log"
	fi

	## Check if error log exits, if not, create it
	if ! [[ -e $errorpath ]]; then
		sudo runuser -l $orig_user -c "touch $errorpath"
	fi

	## Check if output log exits, if not, create it
	if ! [[ -e $outputpath ]]; then
		sudo runuser -l $orig_user -c "touch $outputpath"
	fi
}

## Checking the environment the user is currenttly running on to determine which settings should be applied
Distro_Check () {

	## Put all the distros i want to check in an array
	Distro_Array=(manjaro arch debian \"Ubuntu\" \"centos\" \"fedora\")
	## set the initial success variable to 1 (0=success 1=failed)
	status=1
	## Go other each element of the array and check if that element (in this
	## case the element will be a distro) exists in the distro check file
	## (/etc/*-release), if it does set the Distro_Val to the current element
	## ($i) and set the status to 0 (success), if it doesn't find any element
	## of the array that matches the file, then status will remain 1 (failed)
	## and propmet the user that the script did not find his distribution
	for i in ${Distro_Array[@]}; do
		DistroChk=$(cat /etc/*-release |grep ID |cut  -d '=' -f '2' |egrep "^$i$")
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


## Installs dependencies
Dependencies_Installation () {

	## Check if wget is installed,
	## if not then download it
	if [[ -z $(command -v wget) ]]; then
		printf "$line\n"
		printf "Downloading wget...\n"
		printf "$line\n\n"

		output_text="wget download"
		error_txt="while downloading wget"

		## Download wget
		if [[ $Distro_Val == arch || $Distro_Val == manjaro ]]; then
			sudo pacman -S wget --needed --noconfirm 2>> $errorpath >> $outputpath &
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

	## Check if curl is installed,
	## if not then download it
	if [[ -z $(command -v curl) ]]; then
		printf "$line\n"
		printf "Downloading curl...\n"
		printf "$line\n\n"

		output_text="curl download"
		error_txt="while downloading curl"

		## Download wget
		if [[ $Distro_Val == arch || $Distro_Val == manjaro ]]; then
			sudo pacman -S curl --needed --noconfirm 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

		elif [[ $Distro_Val == \"debian\" || $Distro_Val == \"Ubuntu\" ]]; then
			apt-get install curl -y 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

		elif [[ $Distro_Val == \"centos\" || $Distro_Val == \"fedora\" ]]; then
			yum install curl -y 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status
		fi
	fi

	## Check if git is installed,
	## if not then download it
	if [[ -z $(command -v git) ]]; then
		printf "$line\n"
		printf "Downloading git...\n"
		printf "$line\n\n"

		output_text="git download"
		error_txt="while downloading git"

		## Download wget
		if [[ $Distro_Val == arch || $Distro_Val == manjaro ]]; then
			sudo pacman -S git --needed --noconfirm 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

		elif [[ $Distro_Val == \"debian\" || $Distro_Val == \"Ubuntu\" ]]; then
			apt-get install git -y 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

		elif [[ $Distro_Val == \"centos\" || $Distro_Val == \"fedora\" ]]; then
			yum install git -y 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status
		fi
	fi
}

## Source functions from other scripts
## If they doesn't exists, pull them from GitHub
Source_And_Validation () {

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
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

		output_text=".post-install.sh source"
		error_txt="while sourcing .post-install.sh"

		source ./.post-install.sh 2>> $errorpath >> $outputpath
		status=$?
		Exit_Status
    fi

    source ./.aurhelper.sh 2>> $errorpath >> $outputpath
    if ! [[ $? -eq 0 ]]; then
		printf "$line\n"
		printf "Downloading .aurhelper.sh...\n"
		printf "$line\n\n"

		output_text=".aurhelper.sh download"
		error_txt="while downloading .aurhelper.sh"

		wget $aurhelper_script 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

		output_text=".aurhelper.sh source"
		error_txt="while sourcing .aurhelper.sh"

		source ./.aurhelper.sh 2>> $errorpath >> $outputpath
		status=$?
		Exit_Status
    fi
}

## Call Log_And_Variables function
Log_And_Variables

## Call Distro_Check function
Distro_Check

## Call Dependencies_Installation function
Dependencies_Installation

## Call Source_And_Validation function
Source_And_Validation

## Propmet the user with a menu to start the script
Main_Menu () {
	IFS=","
	scripts=("Post install","Aurhelper **Run as Non-Root**","Clean Logs","Exit")
	PS3="Please choose what would you like to do: "
	select opt in ${scripts[*]} ; do
	    case $opt in
	        "Post install")
				if [[ $Distro_Val == arch ]]; then
					Arch_Config
					sleep 1
					Alias_and_Wallpaper
					sleep 1
					Pacman_Multilib
					sleep 1
					DE_Menu
					sleep 1
					DM_Menu
					sleep 1
					Boot_Manager_Config
				fi
				printf "$line\n"
				printf "Aurhelper completed successfully\n"
				printf "$line\n\n"
				exit 0
				;;

	        "Aurhelper **Run as Non-Root**")
				Non_Root_Check
				if [[ $Distro_Val == arch ]]; then
					if [[ $aur_helper == "yay" || -z $aur_helper ]]; then
						Yay_Install
						sleep 1
						Yay_Applications
						sleep 1
						Vbox_Installation

					elif [[ $aur_helper == "aurman" ]]; then
						aur_helper="aurman"
						Main_Menu
						Aurman_Install
						sleep 1
						Aurman_Applications
						sleep 1
						Vbox_Installation
					fi
				fi

				printf "$line\n"
				printf "Aurhelper completed successfully\n"
				printf "$line\n\n"
				exit 0
				;;

			Exit)
				printf "$line\n"
				printf "Exiting, have a nice day!\n"
				printf "$line\n"
				exit 0
				;;

			"Clean Logs")
				output_text="Cleaning log files"
				error_txt="while cleaning log files"

				sudo rm -rf $user_path/Automated-Installer-Log
				status=$?
				Exit_Status
				;;

			*)
				printf "Invalid option\n"
				;;
		esac
	done
}

## Use getopts so I'll have the option to
## choose between aurman and yay
while getopts :a:h flag; do
	case $flag in
		a)
			if [[ "aurman" == "$OPTARG" ]]; then
				aur_helper="aurman"
				Main_Menu
			elif [[ "yay" == "$OPTARG" ]]; then
				aur_helper="yay"
				Main_Menu
			else
				printf "$line\n"
				printf "Invalid argument, use '-h' for help\n"
				printf "$line\n\n"
			fi
			;;

		h)
			printf "$line\n"
			printf " Usage:\n -a <argument>\n"
			printf "\t\tchoose which AUR helper you would\n"
			printf "\t\tlike to use [ 'aurman' or 'yay' ]\n"
			printf "\t\t('yay' is the default option if '-a' is not triggered)\n"
			printf "$line\n\n"
			exit 0
			;;

		:)
			printf "$line\n"
			printf " Usage:\n -a <argument>\n"
			printf "\t\tchoose which AUR helper you would\n"
			printf "\t\tlike to use [ 'aurman' or 'yay' ]\n"
			printf "\t\t('yay' is the default option if '-a' is not triggered)\n"
			printf "$line\n\n"
			exit 0
			;;

		\?)
			printf "$line\n"
			printf "Invalid option -$OPTARG\ntry -h for help\n"
			printf "$line\n\n"
			exit 1
			;;
	esac
done

## declare a variable for funtions to use later
aur_helper="yay"

## Call Main_Menu function if getopts did not detected any arguments
Main_Menu
