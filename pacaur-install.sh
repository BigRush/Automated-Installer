#!/usr/bin/env bash

Non_Root_Check () {		## Make sure the script doesn't run as root
	if [[ $EUID -eq 0 ]]; then
		printf "$line\n"
		printf "The script can't run as root\n"
		printf "$line\n"
		exit 1
	fi
}

Log_And_Variables () {	## declare variables and log path that will be used by other functions

	####  Varibale	####
	line="\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-"
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
		exit 1
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

Pacaur_Install () {

	## Propmet the user with what the script will now do (with cosmetics :D)
	printf "$line\n"
	printf "Updating the system...\n"
	printf "$line\n\n"

	## Will be used in Exit_Status function to output text for the user
	output_text="Update"
	error_txt="while updating"

	## Update the system, send stdout and sterr to log files
	sudo pacman -Syu --noconfirm 2>> $errorpath >> $outputpath
	Exit_Status

	## Create a tmp-working-dir if it does't exits and navigate into it
	if ! [[ -e $user_path/pacaur_install_tmp ]]; then
		mkdir -p $user_path/pacaur_install_tmp
	fi

	pushd . 2>> $errorpath >> $outputpath
	cd $user_path/pacaur_install_tmp
	gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53 2>> $errorpath >> $outputpath

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

	## Install "cower" from AUR
	if ! [[ -n "$(pacman -Qs cower)" ]]; then
		output_text="cowers installation"
		error_txt="while installing cower"
    	curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cower 2>> $errorpath >> $outputpath
		Exit_Status
		makepkg PKGBUILD --install --noconfirm --needed 2>> $errorpath >> $outputpath
		Exit_Status
	fi

	## Install "pacaur" from AUR
	if ! [[ -n "$(pacman -Qs pacaur)" ]]; then
		output_text="pacaur installation"
		error_txt="while installing pacaur"
    	curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=pacaur # 2>> $errorpath >> $outputpath
		Exit_Status
		makepkg PKGBUILD --install --noconfirm --needed 2>> $errorpath >> $outputpath
		Exit_Status
	fi

	## Clean up on aisle four
	popd 2>> $errorpath >> $outputpath
	rm -rf $user_path/pacaur_install_tmp
}

Pacman_Multilib () {	## Enablr multilib repo

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
					printf "the pacman.conf file has changed its format\n please enable multilib for pacman so the script will run correctly\nnot applying any chnages\n"
					printf "$line\n\n"
					break
				fi
			fi
		done
	fi
}

Pacaur_applications () {		## Applications i want to install with pacaur
		if [[ $Distro_Val == manjaro || $Distro_Val == arch  ]] ;then
				app=(ncdu git steam teamviewer openssh vlc atom discord screenfetch)
				for i in ${app[*]}; do
					printf "$line\n"
					printf "Installing $i\n"
					printf "$line\n\n"
					output_text="$i installation"
					error_txt="while installing $i"
					pacaur -S $i --noconfirm --needed --noedit 2>> $errorpath >> $outputpath
					Exit_Status
				done
		fi
}

Vbox_Installation () {		## Virtualbox installation
	vb=(virtualbox linux97-virtualbox-host-modules virtualbox-guest-iso virtualbox-ext-vnc virtualbox-ext-oracle)
	for i in ${vb[*]}; do
		printf "$line\n"
		printf "Installing $i\n"
		printf "$line\n\n"
		output_text="$i installation"
		error_txt="while installing $i"
		pacaur -S $i --noconfirm --needed --noedit
	done
	sudo modprobe vboxdrv
	sudo gpasswd -a tom vboxusers
}

Pac_Main () {	## Call functions and source functions from post-install.sh
	Non_Root_Check
	Log_And_Variables
	Exit_Status
	Distro_Check
	if [[ $Distro_Val == arch ]]; then
		Pacaur_Install
		Pacman_Multilib
		Pacaur_applications
		Vbox_Installation
	else
		printf "$line\n"
		printf "This script does not support your distribution\n"
		printf "$line\n\n"
	fi
}
Pac_Main
