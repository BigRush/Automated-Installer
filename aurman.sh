#!/usr/bin/env bash


################################################################################
# Author :	BigRush
#
# License :	GPLv3
#
# Description :	Update the system
#				Install aurman (AUR helper),
#				Enable multilib repository for pacman
#				Install applications that i want with aurman
#
# Version :	1.0.0
################################################################################

## ToDo	####################################
# Add verbos option
############################################

## Make sure the script doesn't run as root
Non_Root_Check () {
	if [[ $EUID -eq 0 ]]; then
		printf "$line\n"
		printf "The Aurman \n"
		printf "$line\n"
		exit 1
	fi
}
<<COM
Log_And_Variables () {	## declare variables and log path that will be used by other functions

	####  Varibale	####
	line="\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-"
	logfolder="/var/log/post_install"
	errorpath=$logfolder/error.log
	outputpath=$logfolder/output.log
	orig_user=$USER
	user_path=/home/$orig_user
	####  Varibale	####

	## Check if log folder exits, if not - create it
	if ! [[ -e $logfolder ]]; then
		sudo mkdir -p $logfolder
		sudo chown -R $orig_user $logfolder
	else
		sudo chown -R $orig_user $logfolder
	fi
}

Exit_Status () {		## Check exit status of the last command to see if it completed successfully
	if [[ $? -eq 0 ]]; then
		printf "$line\n"
		printf "$output_text complete...\n"
		printf "$line\n\n"
	else
		printf "$line\n"
		printf "Somethong went wrong $error_txt, please check log under:\n$errorpath\n"
		printf "$line\n\n"

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

Distro_Check () {		## Checking the environment the user is currenttly running on to determine which settings should be applied
	cat /etc/*-release |grep ID |cut  -d "=" -f "2" |egrep "^manjaro$" &> /dev/null

	if [[ $? -eq 0 ]]; then
	  	Distro_Val="manjaro"
	fi

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
}
COM

## Install aurman manually
Aurman_Install () {

	## Propmet the user with what the script will now do (with cosmetics :D)
	printf "$line\n"
	printf "Updating the system...\n"
	printf "$line\n\n"

	## Will be used in Exit_Status function to output text for the user
	output_text="Update"
	error_txt="while updating"

	## Update the system, send stdout and sterr to log files
	sudo $PACSTALL 2>> $errorpath >> $outputpath &
	status=$?
	Progress_Spinner
	Exit_Status

	## Create a tmp-working-dir if it does't exits and navigate into it
	if ! [[ -e $user_path/pacaur_install_tmp ]]; then
		mkdir -p $user_path/pacaur_install_tmp
	fi

	pushd . 2>> $errorpath >> $outputpath
	cd $user_path/pacaur_install_tmp
	# gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53 2>> $errorpath >> $outputpath
<<COM
	printf "$line\n"
	printf "Installing pacaur dependencies...\n"
	printf "$line\n\n"

	output_text="base-devel packages installation"
	error_txt="while installing base-devel packages"

	## If didn't install the "base-devel" group and git
	sudo pacman -S binutils make gcc fakeroot pkg-config git --noconfirm --needed 2>> $errorpath >> $outputpath
	Exit_Status

	output_text="base-devel pacaur dependencies installation"
	error_txt="while installing pacaur dependencies"

	## Install pacaur dependencies from arch repos
	sudo pacman -S expac yajl git --noconfirm --needed 2>> $errorpath >> $outputpath
	Exit_Status

COM

	## Install "aurman" from AUR
	if ! [[ -n "$(pacman -Qs aurman)" ]]; then
		output_text="getting aurman with curl from AUR"
		error_txt="while getting aurman with curl from AUR"

		## Get the build files for AUR
    	curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cower 2>> $errorpath >> $outputpath
		Exit_Status
		output_text="cower installation"
		error_txt="while installing cower"

		## Compile
		makepkg -si PKGBUILD--noconfirm --needed 2>> $errorpath >> $outputpath
		Exit_Status
	fi

	## Clean up on aisle four
	popd 2>> $errorpath >> $outputpath
	rm -rf $user_path/pacaur_install_tmp
}

## Enable multilib repo
Pacman_Multilib () {

	## validate the multilib section is in the place that we are going to replace
	pac_path=/etc/pacman.conf
	if ! [[ -z $(cat $pac_path |egrep "^\#\[multilib\]$") ]]; then
		for ((i; i<=100; i++)); do
			pac_line=$(sed -n "$i"p $pac_path)
			if [[ "#[multilib]" == "$pac_line" ]]; then
				if [[ $i -eq 93 ]]; then
					sudo sed -ie "93,94s/.//" $pac_path
					break
				else
					printf "$line\n"
					printf "the pacman.conf file has changed its format\nplease enable multilib for pacman so the script will run correctly\nnot applying any chnages\n"
					printf "$line\n\n"
					break
				fi
			fi
		done
	fi
}

## Install Webkit2_greeter for lightdm and change its theme
Webkit2_greeter () {

	$AURSTALL lightdm-webkit2-greeter lightdm-webkit-theme-litarvan 2>> $errorpath >> $outputpath &
}

## Applications i want to install with pacaur
Aurman_Applications () {
		if [[ $Distro_Val == manjaro || $Distro_Val == arch  ]] ;then
				app=(ncdu guake git steam teamviewer openssh vlc atom discord screenfetch)
				for i in ${app[*]}; do
					printf "$line\n"
					printf "Installing $i\n"
					printf "$line\n\n"
					output_text="$i installation"
					error_txt="while installing $i"
					$AURSTALL $i 2>> $errorpath >> $outputpath &
					status=$?
					Progress_Spinner
					Exit_Status
				done
		fi
}

## Virtualbox installation
Vbox_Installation () {

	read -p "Would you like to install virtualbox?[y/n]: " answer
	printf "\n"
	if [[ -z $answer ]]; then
		:
	elif [[ $answer =~ [y|Y] || $answer =~ [y|Y]es ]]; then
		:
	elif [[ $answer =~ [n|N] || $answer =~ [n|N]o ]]; then
		printf "$line\n"
		printf "Exiting..."
		printf "\n"
		printf "$line\n\n"
		exit 1
	else
		printf "$line\n"
		printf "Invalid answer - exiting\n"
		printf "$line\n\n"
	fi

	vb=(virtualbox linux97-virtualbox-host-modules virtualbox-guest-iso virtualbox-ext-vnc virtualbox-ext-oracle)
	for i in ${vb[*]}; do
		printf "$line\n"
		printf "Installing $i\n"
		printf "$line\n\n"
		output_text="$i installation"
		error_txt="while installing $i"
		$AURSTALL $i 2>> $errorpath >> $outputpath &
		status=$?
		Progress_Spinner
		Exit_Status
	done

	sudo modprobe vboxdrv 2>> $errorpath >> $outputpath
	Exit_Status
	sudo gpasswd -a tom vboxusers 2>> $errorpath >> $outputpath
	Exit_Status
}

<<COM
Aur_Main () {	## Call functions and source functions from post-install.sh
	Non_Root_Check
	Log_And_Variables
	Distro_Check
	if [[ $Distro_Val == arch ]]; then
		Pacman_Multilib
		sleep 1
		Pacaur_Install
		sleep 0.5
		Webkit2_greeter
		sleep 0.5
		Pacaur_applications
		sleep 0.5
		Vbox_Installation
	else
		printf "$line\n"
		printf "This script does not support your distribution\n"
		printf "$line\n\n"
	fi
}
COM
