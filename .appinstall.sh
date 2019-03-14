#!/usr/bin/env bash


################################################################################
# Author :	BigRush
#
# License :	GPLv3
#
# Description :	Install applications that I want
#				Install VirtualBox
#
#
# Version :	2.0.0
################################################################################

## ToDo	####################################
# Add verbos option
############################################

## Applications I want to install with aurman
Aurman_Applications () {
		if [[ $Distro_Val == arch || $Distro_Val == manjaro ]] ;then
			aur_apps=(discord firefox ncdu guake teamviewer openssh vlc atom screenfetch etcher speedtest-cli)
			for i in ${aur_apps[*]}; do
				sudo echo
				output_text="$i installation"
				error_text="while installing $i"
				aurman -S $i --needed --noconfirm --noedit --pgp_fetch 2>> $errorpath >> $outputpath &
				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status
			done

			## Start screenfetch
			if [[ -n $(command -v screenfetch) ]]; then
				if [[ -z $(grep "screenfetch -E" $HOME/.bashrc) ]]; then
				printf "screenfetch -E\n" >> $HOME/.bashrc
				fi
			fi

			## special attention packages that stdout needs to be seen
			printf "$line\n"
			printf "Installing steam\n"
			printf "$line\n\n"
			output_text="steam installation"
			error_text="while installing steam"
			aurman -S steam --needed
			status=$?
			Exit_Status
		fi
}

## Applications I want to install with yay
Yay_Applications () {
		if [[ $Distro_Val == arch || $Distro_Val == manjaro ]] ;then
			yay_apps=(discord steam firefox ncdu guake plank teamviewer openssh vlc atom screenfetch etcher speedtest-cli)
			for i in ${yay_apps[*]}; do
				sudo echo
				output_text="$i installation"
				error_text="while installing $i"
				yay -S $i --needed --noconfirm --sudoloop 2>> $errorpath >> $outputpath &
				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status
			done

			## Start screenfetch
			if [[ -n $(command -v screenfetch) ]]; then
				if [[ -z $(grep "screenfetch -E" $HOME/.bashrc) ]]; then
				printf "screenfetch -E\n" >> $HOME/.bashrc
				fi
			fi
		fi
}

## Applications I want to install with apt for Debian and Ubuntu based distributions
Apt_Applications () {
	apt_apps=(vim ncdu guake plank vlc screenfetch speedtest-cli)
	for i in ${apt_apps[*]}; do
		sudo echo
		output_text="$i installation"
		error_text="while installing $i"
		sudo apt-get install $i -y 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status
	done

	## Start screenfetch
	if [[ -n $(command -v screenfetch) ]]; then
		if [[ -z $(grep "screenfetch -E" $HOME/.bashrc) ]]; then
		printf "screenfetch -E\n" >> $HOME/.bashrc
		fi
	fi
}

## Applications that needs to be installed from .deb files
Deb_Packages () {

	##  Discord installation ##

	## Check if Downloads folder exists and if not, create it
	if ! [[ -d $HOME/Downloads ]]; then
		mkdir $HOME/Downloads
	fi

	## Download Discord's .deb package from their website
	printf "$line\n"
	printf "Downloading Discord's .deb package\n"
	printf "$line\n\n"

	output_text="Downloading Discord's .deb package"
	error_text="while downloading Discord's .deb package"

	wget --show-progress --progress=bar -a $outputpath -O "$HOME/Downloads/discord.deb" https://discordapp.com/api/download?platform=linux&format=deb
	wait
	status=$?
	Exit_Status

	## Installing Discord from .deb package
	sudo printf "\n"

	output_text="Installing Discord from .deb package"
	error_text="while installing Discord"


	sudo apt-get install $HOME/Downloads/discord.deb -y 2>> $errorpath >> $outputpath &
	BPID=$!
	Progress_Spinner
	wait $BPID
	status=$?
	Exit_Status
	## Steam installation ##

	## Download Steam's .deb package from their website
	printf "$line\n"
	printf "Downloading Steam's .deb package\n"
	printf "$line\n\n"

	output_text="Downloading Steam's .deb package"
	error_text="while downloading Steam's .deb package"

	wget --show-progress --progress=bar -a $outputpath -O "$HOME/Downloads/steam.deb" https://steamcdn-a.akamaihd.net/client/installer/steam.deb
	wait
	status=$?
	Exit_Status

	## Adding i386 architecture

	sudo printf "\n"

	output_text="Adding i386 architecture"
	error_text="while adding i386 architecture"

	sudo dpkg --add-architecture i386 2>> $errorpath >> $outputpath
	status=$?
	Exit_Status

	## Update the package lists

	output_text="Updating the package lists"
	error_text="while updating the package lists"

	sudo apt-get update 2>> $errorpath >> $outputpath &
	BPID=$!
	Progress_Spinner
	wait $BPID
	status=$?
	Exit_Status

	## Installing Steam from .deb package

	output_text="Installing Steam from .deb package"
	error_text="while installing Steam"

	sudo echo

	sudo apt-get install $HOME/Downloads/steam.deb -y 2>> $errorpath >> $outputpath &
	BPID=$!
	Progress_Spinner
	wait $BPID
	status=$?
	Exit_Status

	## Installing TeamViewer ##

	## Download TeamViewer's .deb package from their website
	printf "$line\n"
	printf "Downloading TeamViewer's .deb package\n"
	printf "$line\n\n"

	output_text="Downloading TeamViewer's .deb package"
	error_text="while downloading TeamViewer's .deb package"

	wget --show-progress --progress=bar -a $outputpath -O "$HOME/Downloads/teamviewer.deb" https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
	wait
	status=$?
	Exit_Status

	## Installing TeamViewer from .deb package
	sudo printf "\n"

	output_text="Installing TeamViewer from .deb package"
	error_text="while installing TeamViewer"

	sudo apt-get install $HOME/Downloads/teamviewer.deb -y 2>> $errorpath >> $outputpath &
	BPID=$!
	Progress_Spinner
	wait $BPID
	status=$?
	Exit_Status

	## Installing Atom ##

	## Download Atom's .deb package from their website
	printf "$line\n"
	printf "Downloading Atom's .deb package\n"
	printf "$line\n\n"

	output_text="Downloading Atom's .deb package"
	error_text="while downloading Atom's .deb package"

	wget --show-progress --progress=bar -a $outputpath -O "$HOME/Downloads/atom.deb" https://atom.io/download/deb
	wait
	status=$?
	Exit_Status


	## Installing Atom from .deb package
	sudo printf "\n"

	output_text="Installing Atom from .deb package"
	error_text="while installing Atom"

	sudo apt-get install $HOME/Downloads/atom.deb -y 2>> $errorpath >> $outputpath &
	BPID=$!
	Progress_Spinner
	wait $BPID
	status=$?
	Exit_Status

	## Installing Etcher ##

	## Add Etcher's debian repository

	output_text="Adding Etcher's debian repository"
	error_text="while adding Etcher's debian repository"

	echo "deb https://deb.etcher.io stable etcher" | sudo tee /etc/apt/sources.list.d/balena-etcher.list 2>> $errorpath >> $outputpath
	status=$?
	Exit_Status


	## Add Bintray.com's GPG key
	output_text="Adding Bintray.com's GPG key"
	error_text="while adding Bintray.com's GPG key"

	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61 >> $outputpath 2>> $errorpath &
	BPID=$!
	Progress_Spinner
	wait $BPID
	status=$?
	Exit_Status

	## Download dependency
	output_text="Downloading dependency: apt-transport-https"
	error_text="while downloading dependency"

	sudo apt-get install apt-transport-https 2>> $errorpath >> $outputpath &
	BPID=$!
	Progress_Spinner
	wait $BPID
	status=$?
	Exit_Status

	## Update the package lists

	output_text="Updating the package lists"
	error_text="while updating the package lists"

	sudo apt-get update 2>> $errorpath >> $outputpath &
	BPID=$!
	Progress_Spinner
	wait $BPID
	status=$?
	Exit_Status

	## Installing Etcher

	output_text="Installing Etcher"
	error_text="while installing Etcher"

	sudo echo

	sudo apt-get install balena-etcher-electron -y 2>> $errorpath >> $outputpath &
	BPID=$!
	Progress_Spinner
	wait $BPID
	status=$?
	Exit_Status
}

## Virtualbox installation
Vbox_Installation () {
	if ! [[ $vbox_inst == "yes" ]]; then
		read -p "Would you like to install Virtualbox?[Y/n]: " answer
		printf "\n"
		if [[ -z $answer ]]; then
			:
		elif [[ $answer =~ [y|Y] || $answer =~ [y|Y]es ]]; then
			:
		elif [[ $answer =~ [n|N] || $answer =~ [n|N]o ]]; then
			printf "$line\n"
			printf "Exiting Virtualbox installation...\n"
			printf "\n"
			printf "$line\n\n"
			return 0
		else
			printf "$line\n"
			printf "Invalid answer - exiting Virtualbox installation\n"
			printf "$line\n\n"
			return 1
		fi
	fi


	if [[ $Distro_Val == arch || $Distro_Val == manjaro ]]; then
		vbox_pkg=(virtualbox virtualbox-host-modules-arch linux-headers virtualbox-ext-oracle)

		## Check which AUR helper is installed
		if [[ $aur_helper == "aurman" ]]; then
			for i in ${vbox_pkg[*]}; do
				sudo echo
				output_text="$i installation"
				error_text="while installing $i"
				aurman -S $i --needed --noconfirm --noedit 2>> $errorpath >> $outputpath &
				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status
			done

		elif [[ $aur_helper == "yay" ]]; then
			for i in ${vbox_pkg[*]}; do
				sudo echo
				output_text="$i installation"
				error_text="while installing $i"
				yay -S $i --needed --noconfirm 2>> $errorpath >> $outputpath &
				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status
			done

		else
			printf "$line\n"
			printf "No AUR helper detected, can't install  virtualbox extension pack,\n"
			printf "Please install it manually later... Continueing with the Vbox installation...\n"

			vbox_pkg_pac=(virtualbox virtualbox-host-modules-arch linux-headers)
			for i in ${vbox_pkg_pac[*]}; do
				sudo echo
				output_text="$i installation"
				error_text="while installing $i"
				pacman -S $i --needed --noconfirm 2>> $errorpath >> $outputpath &
				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status
			done
		fi

		sudo modprobe vboxdrv 2>> $errorpath >> $outputpath
		Exit_Status
		sudo gpasswd -a $orig_user vboxusers 2>> $errorpath >> $outputpath
		Exit_Status

	elif [[ $Distro_Val == debian || $Distro_Val == \"Ubuntu\" ]]; then

		## Add the repository key
		output_text="Adding the repository key"
		error_text="while adding the repository key"

		wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add - 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

		output_text="Adding the second repository key"
		error_text="while adding the second repository key"

		wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add - 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

		## Add the VirtualBox repository

		output_text="Adding the VirtualBox repository"
		error_text="while adding the VirtualBox repository"

		echo "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list 2>> $errorpath >> $outputpath
		status=$?
		Exit_Status

		## Update the package lists

		output_text="Updating the package lists"
		error_text="while ufpdating the package lists"

		sudo apt-get update 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

		## Installing headers

		output_text="Installing linux-headers"
		error_text="while installing linux-headers"

		sudo apt-get install linux-headers-$(uname -r) dkms -y 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

		## Installing VirtualBox

		output_text="Installing VirtualBox"
		error_text="while installing VirtualBox"

		sudo apt-get install virtualBox-6.0 -y 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status
	fi
}

## Docker installation
Docker_Installation () {
	if ! [[ $docker_inst == "yes" ]]; then
		read -p "Would you like to install Docker?[Y/n]: " answer
		printf "\n"
		if [[ -z $answer ]]; then
			:
		elif [[ $answer =~ [y|Y] || $answer =~ [y|Y]es ]]; then
			:
		elif [[ $answer =~ [n|N] || $answer =~ [n|N]o ]]; then
			printf "$line\n"
			printf "Exiting Docker installation...\n"
			printf "\n"
			printf "$line\n\n"
			return 0
		else
			printf "$line\n"
			printf "Invalid answer - exiting Docker installation\n"
			printf "$line\n\n"
			return 1
		fi
	fi

	if [[ $Distro_Val == debian || $Distro_Val == \"Ubuntu\" ]]; then
		## Install packages to allow apt to use a repository over HTTPS
		docker_dep=(apt-transport-https ca-certificates gnupg2 software-properties-common)
		for i in ${docker_dep[*]}; do
			sudo echo
			output_text="$i installation"
			error_text="while installing $i"
			sudo apt-get install $i -y 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status
		done

		if [[ $Distro_Val == debian ]]; then

			## Add Docker’s official GPG key
			output_text="Adding Docker’s official GPG key"
			error_text="while adding Docker’s official GPG key"

			wget -q https://download.docker.com/linux/debian/gpg -O- | sudo apt-key add - 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

			## Set up the stable repository for Docker if it doesn't exists
			if [[ -z $(grep -o "https://download.docker.com/linux/debian" /etc/apt/sources.list) ]]; then
				printf "$line\n"
				printf "Set up the stable repository for Docker\n"
				printf "$line\n\n"

				sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $debian_cname stable" 2>> $errorpath >> $outputpath
				status=$?
				Exit_Status
			fi

		elif [[ $Distro_Val == \"Ubuntu\" ]]; then
			## Add Docker’s official GPG key
			output_text="Adding Docker’s official GPG key"
			error_text="while adding Docker’s official GPG key"

			wget -q https://download.docker.com/linux/ubuntu/gpg -O- | sudo apt-key add - 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

			## Set up the stable repository for Docker if it doesn't exists
			if [[ -z $(grep -o "https://download.docker.com/linux/ubuntu" /etc/apt/sources.list) ]]; then
				printf "$line\n"
				printf "Set up the stable repository for Docker\n"
				printf "$line\n\n"

				sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $ubuntu_cname stable" 2>> $errorpath >> $outputpath
				status=$?
				Exit_Status
			fi
		fi

		## Update the package lists

		output_text="Updating the package lists"
		error_text="while ufpdating the package lists"

		sudo apt-get update 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

		## Install Docker
		docker_pkg=(docker-ce docker-ce-cli containerd.io)
		for i in ${docker_pkg[*]}; do
			sudo echo
			output_text="$i installation"
			error_text="while installing $i"
			sudo apt-get install $i -y 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status
		done

	elif [[ $Distro_Val == arch || $Distro_Val == manjaro ]] ;then
		output_text="Installing Docker"
		error_text="while installing Docker"

		sudo pacman -S docker --needed --noconfirm 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status
	fi

}

# Vagrant installation
Vagrant_Installation () {

	if ! [[ $vagrant_inst == "yes" ]]; then
		read -p "Would you like to install Vagrant?[Y/n]: " answer
		printf "\n"
		if [[ -z $answer ]]; then
			:
		elif [[ $answer =~ [y|Y] || $answer =~ [y|Y]es ]]; then
			:
		elif [[ $answer =~ [n|N] || $answer =~ [n|N]o ]]; then
			printf "$line\n"
			printf "Exiting Vagrant installation...\n"
			printf "\n"
			printf "$line\n\n"
			return 0
		else
			printf "$line\n"
			printf "Invalid answer - exiting Vagrant installation\n"
			printf "$line\n\n"
			return 1
		fi
	fi

	if [[ $Distro_Val == arch || $Distro_Val == manjaro ]] ;then
		output_text="Installing Vagrant"
		error_text="while installing Vagrant"

		sudo pacman -S vagrant  --needed --noconfirm 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

	elif [[ $Distro_Val == debian || $Distro_Val == \"Ubuntu\" ]]; then

		## Check if Downloads folder exists and if not, create it
		if ! [[ -d $HOME/Downloads ]]; then
			mkdir $HOME/Downloads
		fi

		## Download Vagrant's .deb package from their website
		printf "$line\n"
		printf "Downloading Vagrant's .deb package\n"
		printf "$line\n\n"

		output_text="Downloading Vagrant's .deb package"
		error_text="while downloading Vagrant's .deb package"

		wget --show-progress --progress=bar -a $outputpath -O "$HOME/Downloads/vagrant.deb" https://releases.hashicorp.com/vagrant/2.2.3/vagrant_2.2.3_x86_64.deb
		wait
		status=$?
		Exit_Status

		## Installing Vagrant from .deb package
		sudo printf "\n"

		output_text="Installing Vagrant from .deb package"
		error_text="while installing Vagrant"


		sudo apt-get install $HOME/Downloads/vagrant.deb -y 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status
	fi
}
