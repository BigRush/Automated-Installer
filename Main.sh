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


## Check if the script doesn't run as root
Non_Root_Check () {
	if [[ $EUID -eq 0 ]]; then
		printf "$line\n"
		printf "This option must run as non-root\n"
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

        ## Prompt the user if he want to continue with the script
        ## although the last command failed to execute successfully.
        read -p "Would you like to continue anyway?[y/N]: " answer
        printf "\n"
        if [[ -z $answer ]]; then

			## Prompt the user if he want to read the log files
			read -p "Would you like to read log files?[Y/n]: " answer
	        printf "\n"
	        if [[ -z $answer ]]; then
	            less $errorpath
				exit 1
	        elif [[ $answer =~ [y|Y] || $answer =~ [y|Y]es ]]; then
	            less $errorpath
				exit 1
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

        elif [[ $answer =~ [y|Y] || $answer =~ [y|Y]es ]]; then
			:

        elif [[ $answer =~ [n|N] || $answer =~ [n|N]o ]]; then
			read -p "Would you like to read log files?[Y/n]: " answer
	        printf "\n"
	        if [[ -z $answer ]]; then
	            less $errorpath
	        elif [[ $answer =~ [y|Y] || $answer =~ [y|Y]es ]]; then
	            less $errorpath
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

	## Check the original user that executed the script
	if [[ -z $SUDO_USER ]]; then
		orig_user=$(whoami)
	else
		orig_user=$SUDO_USER
	fi

	## Check if the user has a home folder in '/home'
	if [[ -n $(ls /home |egrep ^$orig_user$) ]]; then
		user_path=/home/$orig_user
	elif [[ $orig_user == 'root' ]]; then
		user_path=/root
	fi

	errorpath=$user_path/Automated-Installer-Log/error.log
	outputpath=$user_path/Automated-Installer-Log/output.log
	lightconf=/etc/lightdm/lightdm.conf
	lightwebconf=/etc/lightdm/lightdm-webkit2-greeter.conf
	post_script="https://raw.githubusercontent.com/BigRush/Automated-Installer/master/.post-install.sh"
	appinstall_script="https://raw.githubusercontent.com/BigRush/Automated-Installer/master/.aurhelper.sh"
	archfuncs_script="https://raw.githubusercontent.com/BigRush/Automated-Installer/master/.appinstall.sh"
	deepin_sound_path=/usr/share/sounds/deepin/stereo/
	kernel_ver=$(uname -r |cut -d "." -f 1,2 |tr -d ".s")
	refind_path=$(sudo find /boot -path *refind)
	####  Varibale	####

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
	## and prompt the user that the script did not find his distribution
	for i in ${Distro_Array[@]}; do
		DistroChk=$(cat /etc/*-release |grep ID |cut  -d '=' -f '2' |egrep "^$i$")
		if ! [[ -z $DistroChk ]]; then
		  	Distro_Val="$i"
		    status=0
		fi
	done

    if [[ $status -eq 1 ]]; then
        printf "$line\n"
		## Save the exxit status of last command to a Varibale
        printf "Sorry, but the script did not find your distribution,\n"
        printf "Exiting...\n"
        printf "$line\n\n"
        exit 1
    fi

	if [[ $Distro_Val == \"centos\" || $Distro_Val == \"fedora\" ]]; then
		printf "$line\n"
		printf "This script doesn't support $Distro_Val at the moment\n"
		printf "$line\n"

		exit 1
	fi
}

## Update the system
System_Update () {

	output_text="Updating the package lists"
	error_txt="Updating the package lists"

	if [[ $Distro_Val == debian || $Distro_Val == \"Ubuntu\" ]]; then

		apt-get update 2>> $errorpath >> $outputpath &
		status=$?
		Progress_Spinner
		Exit_Status

	elif [[ $Distro_Val == arch || $Distro_Val == manjaro ]]; then
		## Prompet sudo
		sudo echo
		## Propmet the user with what the script will now do (with cosmetics :D)
		printf "$line\n"
		printf "Updating the system...\n"
		printf "$line\n\n"

		## Will be used in Exit_Status function to output text for the user
		output_text="Update"
		error_txt="while updating"

		## Update the system, send stdout, sterr to log files
		## and move the process to the background for the Progress_Spinner function.
		sudo pacman -Sy --noconfirm 2>> $errorpath >> $outputpath &

		## Save the background PID to a variable for later use with wait command
		BPID=$!

		## Call Progress_Spinner function
		Progress_Spinner

		## Wait until the process is done to get its exit status.
		wait $BPID

		## Save the exxit status of last command to a Varibale
		status=$?

		## Call Exit_Status function
		Exit_Status
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
			sudo echo
			sudo pacman -S wget --needed --noconfirm 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

		elif [[ $Distro_Val == "debian" || $Distro_Val == \"Ubuntu\" ]]; then
			sudo echo
			sudo apt-get install wget -y 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

		elif [[ $Distro_Val == \"centos\" || $Distro_Val == \"fedora\" ]]; then
			sudo echo
			sudo yum install wget -y 2>> $errorpath >> $outputpath &
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
			sudo echo
			sudo pacman -S curl --needed --noconfirm 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

		elif [[ $Distro_Val == debian || $Distro_Val == \"Ubuntu\" ]]; then
			sudo echo
			sudo apt-get install curl -y 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

		elif [[ $Distro_Val == \"centos\" || $Distro_Val == \"fedora\" ]]; then
			sudo echo
			sudo yum install curl -y 2>> $errorpath >> $outputpath &
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
			sudo echo
			sudo pacman -S git --needed --noconfirm 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

		elif [[ $Distro_Val == "debian" || $Distro_Val == \"Ubuntu\" ]]; then
			sudo echo
			sudo apt-get install git -y 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

		elif [[ $Distro_Val == \"centos\" || $Distro_Val == \"fedora\" ]]; then
			sudo echo
			sudo yum install git -y 2>> $errorpath >> $outputpath &
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

    source ./.appinstall.sh 2>> $errorpath >> $outputpath
    if ! [[ $? -eq 0 ]]; then
		printf "$line\n"
		printf "Downloading .appinstall.sh...\n"
		printf "$line\n\n"

		output_text=".appinstall.sh download"
		error_txt="while downloading .appinstall.sh"

		wget $appinstall_script 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

		output_text=".appinstall.sh source"
		error_txt="while sourcing .appinstall.sh"

		source ./.appinstall.sh 2>> $errorpath >> $outputpath
		status=$?
		Exit_Status
    fi

	source ./.archfuncs.sh 2>> $errorpath >> $outputpath
    if ! [[ $? -eq 0 ]]; then
		printf "$line\n"
		printf "Downloading .archfuncs.sh...\n"
		printf "$line\n\n"

		output_text=".archfuncs.sh download"
		error_txt="while downloading .archfuncs.sh"

		wget $archfuncs_script 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

		output_text=".archfuncs.sh source"
		error_txt="while sourcing .archfuncs.sh"

		source ./.archfuncs.sh 2>> $errorpath >> $outputpath
		status=$?
		Exit_Status
    fi
}

## Call Log_And_Variables function
Log_And_Variables

## Call Distro_Check function
Distro_Check

## Call System_Update function
System_Update

## Call Dependencies_Installation function
Dependencies_Installation

## Call Source_And_Validation function
Source_And_Validation

## prompt the user with a menu to start the script
Main_Menu () {
	IFS=","
	scripts=("Post install","AppInstall **Run as Non-Root**","Clean Logs","Exit")
	PS3="Please choose what would you like to do: "
	select opt in ${scripts[*]} ; do
	    case $opt in
	        "Post install")
				if [[ $Distro_Val == arch ]]; then
					Arch_Config
					sleep 2.5
					Alias_and_Wallpaper
					sleep 2.5
					Pacman_Multilib
					sleep 2.5
					if [[ "$desktop_env" == "plasma" ]]; then
						KDE_Installation
						sleep 0.5
						KDE_Font_Config
						sleep 0.5
						Theme_Config
					elif [[ "$desktop_env" == "deepin" ]]; then
						Deepin_Installation
					else
						DE_Menu
					fi
					sleep 2.5
					if [[ "$display_mgr" == "sddm" ]]; then
						SDDM_Installation
					elif [[ "$display_mgr" == "lightdm" ]]; then
						LightDM_Installation
						sleep 0.5
						LightDM_Configuration
					else
						DM_Menu
					fi
					sleep 2.5
					Boot_Manager_Config

				elif [[ $Distro_Val == "manjaro" ]]; then
					Alias_and_Wallpaper
					sleep 2.5
					Pacman_Multilib
					sleep 2.5
					if ! [[ -z $(echo $DESKTOP_SESSION | grep plasma) ]]; then
						Theme_Config
					fi
					DM_Menu
					sleep 2.5
					Boot_Manager_Config

				elif [[ $Distro_Val == "debian" || $Distro_Val == \"Ubuntu\" ]]; then
					Alias_and_Wallpaper
					sleep 2.5
					Theme_Config
					sleep 2.5
					Boot_Manager_Config
				fi


				printf "$line\n"
				printf "Post-Install completed successfully\n"
				printf "$line\n\n"
				exit 0
				;;

	        "AppInstall **Run as Non-Root**")
				Non_Root_Check
				if [[ $Distro_Val == arch || $Distro_Val == manjaro ]]; then
					if [[ $aur_helper == "yay" || -z $aur_helper ]]; then
						Yay_Install
						sleep 2.5
						Yay_Applications
						sleep 2.5
						Vbox_Installation

					elif [[ $aur_helper == "aurman" ]]; then
						aur_helper="aurman"
						Aurman_Install
						sleep 1
						Aurman_Applications
						sleep 1
						Vbox_Installation
					fi

				elif [[ $Distro_Val == debian || $Distro_Val == \"Ubuntu\" ]]; then
					Apt_Applications
					sleep 1
					Deb_Packages
					sleep 1
					Vbox_Installation
				fi

				printf "$line\n"
				printf "AppInstall completed successfully\n"
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
				Log_And_Variables
				;;

			*)
				printf "Invalid option\n"
				;;
		esac
	done
}

## Use getopts so I'll have the option to
## choose between aurman and yay
while getopts :a:e:d:h flag; do
	case $flag in
		a)
			if [[ "aurman" == "$OPTARG" ]]; then
				aur_helper="aurman"
			elif [[ "yay" == "$OPTARG" ]]; then
				aur_helper="yay"
			else
				printf "$line\n"
				printf "Invalid argument, use '-h' for help\n"
				printf "$line\n\n"
				exit 1
			fi
			;;

		e)
			if [[ "plasma" == "$OPTARG" ]]; then
				desktop_env="plasma"
			elif [[ "deepin" == "$OPTARG" ]]; then
				desktop_env="deepin"
			else
				printf "$line\n"
				printf "Invalid argument, use '-h' for help\n"
				printf "$line\n\n"
				exit 1
			fi
			;;

		d)
			if [[ "sddm" == "$OPTARG" ]]; then
				display_mgr="sddm"
			elif [[ "lightdm" == "$OPTARG" ]]; then
				display_mgr="lightdm"
			else
				printf "$line\n"
				printf "Invalid argument, use '-h' for help\n"
				printf "$line\n\n"
				exit 1
			fi
			;;

		h)
			printf "$line\n"
			printf " Usage: -a <argument> -e <argument> -d <argument>\n"
			printf " -a <argument>"
			printf "\t\tchoose which AUR helper you would\n"
			printf "      \t\t\tlike to use [ 'aurman' or 'yay' ]\n"
			printf "      \t\t\t('yay' is the default option if '-a' is not triggered)\n\n"
			printf " -e <argument>"
			printf "\t\tchoose which desktop environment\n"
			printf "      \t\t\tyou would tlike to use [ 'plasma' or 'deepin' ]\n\n"
			printf " -d <argument>"
			printf "\t\tchoose which display manager\n"
			printf "      \t\t\tyou would tlike to use [ 'sddm' or 'lightdm' ]\n"
			printf "$line\n\n"
			exit 0
			;;

		:)
			printf "$line\n"
			printf " Usage: -a <argument> -d <argument>\n"
			printf " -a <argument>"
			printf "\t\tchoose which AUR helper you would\n"
			printf "      \t\t\tlike to use [ 'aurman' or 'yay' ]\n"
			printf "      \t\t\t('yay' is the default option if '-a' is not triggered)\n\n"
			printf " -e <argument>"
			printf "\t\tchoose which desktop environment\n"
			printf "      \t\t\tyou would tlike to use [ 'plasma' or 'deepin' ]\n\n"
			printf " -d <argument>"
			printf "\t\tchoose which display manager\n"
			printf "      \t\t\tyou would tlike to use [ 'sddm' or 'lightdm' ]\n"
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


## Call Main_Menu function
Main_Menu
