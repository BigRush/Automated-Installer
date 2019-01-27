#!/usr/bin/env bash


################################################################################
# Author :	BigRush
#
# License :	GPLv3
#
# Description :	Update the system
#				Add aliases and download a nice wallpaper
#				Install desktop environment
#				Download themes and icons
#				Install display manager
#				Configure the grub background and fast boot time
#
# Version :	1.0.0
################################################################################

## ToDo	####################################
# Add xfce4 DE
# Add verbos option
############################################

####  Functions  ###############################################################


## Add aliases and download a nice wallpaper
Alias_and_Wallpaper () {

	printf "$line\n"
	printf "Downloading background picture...\n"
	printf "$line\n\n"

	output_text="Background picture download"
	error_txt="while downloading background picture"

	## If the directory doesn't exits, create it
	if ! [[ -d $user_path/Pictures ]]; then
		sudo runuser -l $orig_user -c "mkdir $user_path/Pictures"
	fi

	## If the background picture doesn't already exists, download it
	if ! [[ -e $user_path/Pictures/archbk.jpg ]]; then
		sudo runuser -l $orig_user -c "wget -O $user_path/Pictures/archbk.jpg http://getwallpapers.com/wallpaper/full/f/2/a/1056675-download-free-arch-linux-wallpaper-1920x1080.jpg" 2>> $errorpath >> $outputpath
		status=$?
		Exit_Status
	fi

	## customize shell, check if the config exists, if not, add it to .bashrc
	if [[ -z $(grep "alias ll='ls -l'" $HOME/.bashrc) ]]; then
        printf "alias ll='ls -l'\n" >> $HOME/.bashrc
	fi

	if [[ -z $(grep "alias lh='ls -lh'" $HOME/.bashrc) ]]; then
	        printf "alias lh='ls -lh'\n" >> $HOME/.bashrc
	fi

	if [[ -z $(grep "alias la='ls -la'" $HOME/.bashrc) ]]; then
	        printf "alias la='ls -la'\n" >> $HOME/.bashrc
	fi

	if [[ -z $(grep "alias syst='systemctl status'" $HOME/.bashrc) ]]; then
	        printf "alias syst='systemctl status'\n" >> $HOME/.bashrc
	fi

	if [[ -z $(grep "alias sysr='systemctl restart'" $HOME/.bashrc) ]]; then
	        printf "alias sysr='sudo systemctl restart'\n" >> $HOME/.bashrc
	fi

	if [[ -z $(grep "alias syse='systemctl enable'" $HOME/.bashrc) ]]; then
	        printf "alias syse='sudo systemctl enable'\n" >> $HOME/.bashrc
	fi

	if [[ -z $(grep "alias sysd='systemclt disable'" $HOME/.bashrc) ]]; then
	        printf "alias sysd='sudo systemctl disable'\n" >> $HOME/.bashrc
	fi

	if ! [[ -z $(command -v git) ]]; then
	        if [[ -z $(grep "alias gita='git add'" $HOME/.bashrc) ]]; then
	                printf "alias gita='git add'\n" >> $HOME/.bashrc
	        fi

	        if [[ -z $(grep "alias gitc='git commit -m'" $HOME/.bashrc) ]]; then
	                printf "alias gitc='git commit -m'\n" >> $HOME/.bashrc
	        fi

	        if [[ -z $(grep "alias gitp='git push'" $HOME/.bashrc) ]]; then
	                printf "alias gitp='git push'\n" >> $HOME/.bashrc
	        fi
	fi

	if [[ -z $(grep "alias pls='sudo \$(history -p !!)'" $HOME/.bashrc) ]]; then
	        printf "alias pls='sudo \$(history -p !!)'\n" >> $HOME/.bashrc
	fi

	if [[ -z $(grep "alias fuck='pkill \$1'" $HOME/.bashrc) ]]; then
	        printf "alias fuck='pkill \$1'\n" >> $HOME/.bashrc
	fi

	if ! [[ -z $(command -v screenfetch) ]]; then
	        if [[ -z $(grep "screenfetch -E" $HOME/.bashrc) ]]; then
	        printf "screenfetch -E\n" >> $HOME/.bashrc
	        fi
	fi

	if ! [[ -e /root/.bashrc ]]; then
	        sudo touch /root/.bashrc
	fi

	if [[ -z $(sudo grep "alias ll='ls -l'" /root/.bashrc) ]]; then
	        sudo runuser -l "root" -c "printf \"alias ll='ls -l'\n\" >> /root/.bashrc"
	fi

	if [[ -z $(sudo grep "alias lh='ls -lh'" /root/.bashrc) ]]; then
	        sudo runuser -l "root" -c "printf \"alias lh='ls -lh'\n\" >> /root/.bashrc"
	fi

	if [[ -z $(sudo grep "alias la='ls -la'" /root/.bashrc) ]]; then
	        sudo runuser -l "root" -c "printf \"alias la='ls -la'\n\" >> /root/.bashrc"
	fi

	if [[ -z $(sudo grep "alias syst='systemctl status'" /root/.bashrc) ]]; then
	        sudo runuser -l "root" -c "printf \"alias syst='systemctl status'\n\" >> /root/.bashrc"
	fi

	if [[ -z $(sudo grep "alias sysr='systemctl restart'" /root/.bashrc) ]]; then
	        sudo runuser -l "root" -c "printf \"alias sysr='systemctl restart'\n\" >> /root/.bashrc"
	fi

	if [[ -z $(sudo grep "alias syse='systemctl enable'" /root/.bashrc) ]]; then
	        sudo runuser -l "root" -c "printf \"alias syse='systemctl enable'\n\" >> /root/.bashrc"
	fi

	if [[ -z $(sudo grep "alias sysd='systemclt disable'" /root/.bashrc) ]]; then
	        sudo runuser -l "root" -c "printf \"alias sysd='systemctl disable'\n\" >> /root/.bashrc"
	fi

	if [[ -z $(sudo grep "alias fuck='pkill \$1'" /root/.bashrc) ]]; then
	        sudo runuser -l "root" -c "printf 'alias fuck=\"pkill \$1\"\n' >> /root/.bashrc"
	fi


	printf "$line\n"
	printf "Aliases added...\n"
	printf "$line\n\n"
}

## Menu, to choose which desktop environment to install
DE_Menu () {

	desk_env=(Plasma Deepin xfce4 Continue Exit)
	local PS3="Please choose a desktop environment to install: "
	select opt in ${desk_env[@]} ; do
		case $opt in
			Plasma)
				KDE_Installation
				sleep 0.5
				KDE_Font_Config
				sleep 0.5
				Theme_Config
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
			Continue)
				printf "$line\n"
				printf "Continuing...\n"
				printf "$line\n"
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

}

## Installs KDE desktop environment
KDE_Installation () {

	sudo echo

	## Add the option to start the deepin desktop environment with xinit
	sudo runuser -l "root" -c "printf \"exec startkde\n\" > $user_path/.xinitrc"

	printf "$line\n"
	printf "Installing Plasma desktop environment...\n"
	printf "$line\n\n"

	output_text="Plasma desktop installation"
	error_txt="while installing plasma desktop"

	##	Install plasma desktop environment
	sudo pacman -S plasma --needed --noconfirm 2>> $errorpath >> $outputpath &
	BPID=$!
	Progress_Spinner
	wait $BPID
	status=$?
	Exit_Status

	## Declare a variable for DM_Menu function to use
	de_env="kde"
}

## Download themes and icons
Theme_Config () {

	## Check Desktop environment
	if [[ -z $de_env ]]; then
		if [[ $DESKTOP_SESSION == "plasma" ]]; then
			de_env=kde
		else
			de_env=gtk
		fi
	fi

	## Check if megatools is available, if not download it
	if [[ -z $(command -v megadl) ]]; then
		if [[ $Distro_Val == arch ]]; then
			if [[ $aur_helper == "aurman" ]]; then
				sudo echo

				## Check if "aurman" exists, if not, call the function that installs it
				if [[ -z $(command -v aurman) ]]; then
					Aurman_Install
				fi

				printf "$line\n"
				printf "Installing Megatools...\n"
				printf "$line\n\n"

				output_text="Megatools installation"
				error_txt="while installing Megatools"

				## Install megatools to get theme files from mega cloud
				sudo echo
				aurman -S megatools --needed --noconfirm 2>> $errorpath >> $outputpath &
				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status

			elif [[ $aur_helper == "yay" ]]; then

				## Check if "yay" exists, if not, call the function that installs it
				if [[ -z $(command -v yay) ]]; then
					Yay_Install
				fi

				printf "$line\n"
				printf "Installing Megatools...\n"
				printf "$line\n\n"

				output_text="Megatools installation"
				error_txt="while installing Megatools"

				## Install megatools to get theme files from mega cloud
				sudo echo
				yay -S megatools --needed --noconfirm 2>> $errorpath >> $outputpath &
				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status
			fi

		elif [[ $Distro_Val == "debian" || $Distro_Val == \"Ubuntu\" ]]; then

			## Install megatools to get theme files from mega cloud
			sudo echo
			sudo apt-get install megatools -y 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

		elif [[ $Distro_Val == \"centos\" || $Distro_Val == \"fedora\" ]]; then

			## Install megatools to get theme files from mega cloud
			sudo echo
			sudo yum install megatools -y 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status
		fi
	fi


	if ! [[ -d $user_path/Documents/Themes ]]; then
		mkdir -p $user_path/Documents/Themes
		if [[ $de_env == "kde" ]]; then
			printf "$line\n"
			printf "Installing themes form Mega cloud...\n"
			printf "$line\n\n"

			output_text="Getting themes form Mega cloud"
			error_txt="while getting themes form Mega cloud"

			megadl --no-progress --path=$user_path/Documents/Themes 'https://mega.nz/#F!TgBkwIjY!YZ1RpgF19Z2vO7X5gg0KLg' 2>> $errorpath >> $outputpath &

			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

		elif [[ $de_env == "gtk" ]]; then
			printf "$line\n"
			printf "Installing themes form Mega cloud...\n"
			printf "$line\n\n"

			output_text="Getting themes form Mega cloud"
			error_txt="while getting themes form Mega cloud"

			megadl --no-progress --path=$user_path/Documents/Themes 'https://mega.nz/#F!38QiXCrS!aa5xSCuP_HLrpLJK9Mx6rg' 2>> $errorpath >> $outputpath &

			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status
		fi
	fi


	## Chili theme
	if [[ $de_env == "kde" ]]; then
		if ! [[ -e $user_path/Documents/Themes/kde-plasma-chili.tar.gz ]]; then
			printf "$line\n"
			printf "Chili theme doesn't exists...\n"
			printf "$line\n\n"

			output_text="Getting Chili theme with megatools"
			error_txt="while getting Chili with megatools"

			status=1
			Exit_Status
		fi
	fi

	## Shadow icons
	if [[ $de_env == "kde" ]]; then
		if [[ -e $user_path/Documents/Themes/shadow-kde-04-2018.tar.xz  ]]; then
			if ! [[ -e $user_path/.icons ]]; then
				mkdir $user_path/.icons
			fi

			printf "$line\n"
			printf "Extracting Shadow icons...\n"
			printf "$line\n\n"

			output_text="Extraction"
			error_txt="while extracting Shadow icons"

			sudo tar -xvf $user_path/Documents/Themes/shadow-kde-04-2018.tar.xz  -C $user_path/.icons 2>> $errorpath >> $outputpath

			status=$?
			Exit_Status

		else
			printf "$line\n"
			printf "Shadow icons doesn't exists...\n"
			printf "$line\n\n"

			output_text="Getting shadow icons with megatools"
			error_txt="while getting shadow icons megatools"

			status=1
			Exit_Status

		fi

	elif [[ $de_env == "gtk" ]]; then
		if [[ $Distro_Val == arch ]]; then
			if [[ $aur_helper == "aurman" ]]; then
				sudo echo

				## Check if "aurman" exists, if not, call the function that installs it
				if [[ -z $(command -v aurman) ]]; then
					Aurman_Install
				fi

				printf "$line\n"
				printf "Installing Shadow icons...\n"
				printf "$line\n\n"

				output_text="Shadow icons installation"
				error_txt="while installing Shadow icons"

				## Install megatools to get theme files from mega cloud
				sudo echo
				aurman -S shadow-icon-theme --needed --noconfirm 2>> $errorpath >> $outputpath &
				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status

			elif [[ $aur_helper == "yay" ]]; then

				## Check if "yay" exists, if not, call the function that installs it
				if [[ -z $(command -v yay) ]]; then
					Yay_Install
				fi

				printf "$line\n"
				printf "Installing Shadow icons...\n"
				printf "$line\n\n"

				output_text="Shadow icons installation"
				error_txt="while installing Shadow icons"

				## Install megatools to get theme files from mega cloud
				sudo echo
				yay -S shadow-icon-theme --needed --noconfirm 2>> $errorpath >> $outputpath &
				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status
			fi

		elif [[ $Distro_Val == '\"Ubuntu\"' ]]; then
			## Add PPA
			printf "$line\n"
			printf "Adding repository for Shadow icons...\n"
			printf "$line\n\n"

			output_text="Adding the repository"
			error_txt="while adding the repository"
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

			sudo add-apt-repository ppa:noobslab/icons -y 2>> $errorpath >> $outputpath &
			sudo apt-get update 2>> $errorpath >> $outputpath &
			sudo apt-get install shadow-icon-theme -y 2>> $errorpath >> $outputpath &

		else
			if [[ -e $user_path/Documents/Themes/shadow-4.8.3.tar.xz ]]; then
				if ! [[ -e $user_path/.icons ]]; then
					mkdir $user_path/.icons
				fi

				printf "$line\n"
				printf "Extracting Shadow icons...\n"
				printf "$line\n\n"

				output_text="Extraction"
				error_txt="while extracting Shadow icons"

				sudo tar -xvf $user_path/Documents/Themes/shadow-4.8.3.tar.xz -C $user_path/.icons 2>> $errorpath >> $outputpath

				status=$?
				Exit_Status

			else
				printf "$line\n"
				printf "Shadow icons doesn't exists...\n"
				printf "$line\n\n"

				output_text="Getting shadow icons with megatools"
				error_txt="while getting shadow icons megatools"

				status=1
				Exit_Status

			fi
		fi
	fi

	## Papirus icons
	sudo echo

	if [[ $Distro_Val == arch ]]; then
		printf "$line\n"
		printf "Installing Papirus icons...\n"
		printf "$line\n\n"

		output_text="Installing Papirus icons"
		error_txt="while installing Papirus icons"

		sudo pacman -S papirus-icon-theme --needed --noconfirm 2>> $errorpath >> $outputpath &

		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

	elif [[ $Distro_Val == debian ]]; then

		## Add PPA
		printf "$line\n"
		printf "Adding repository for Papirus icons...\n"
		printf "$line\n\n"

		output_text="Adding the repository"
		error_txt="while adding the repository"

		sudo sh -c "echo 'deb http://ppa.launchpad.net/papirus/papirus/ubuntu bionic main' > /etc/apt/sources.list.d/papirus-ppa.list"
		status=$?
		Exit_Status

		## Install dirmngr to manage and download OpenPGP and X.509 certificates
		printf "$line\n"
		printf "Installing dirmngr for certificate management...\n"
		printf "$line\n\n"

		output_text="Installing dirmngr"
		error_txt="while installing dirmngr"

		sudo apt-get install dirmngr -y 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

		## Add certificate
		printf "$line\n"
		printf "Adding the certificate...\n"
		printf "$line\n\n"

		output_text="Installing dirmngr"
		error_txt="while installing dirmngr"
		sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com E58A9D36647CAE7F 2>> $errorpath >> $outputpath
		status=$?
		Exit_Status

		## Update the package list after adding the new repository
		printf "$line\n"
		printf "Updating the package lists...\n"
		printf "$line\n\n"

		output_text="Updating the package lists"
		error_txt="while updating the package lists"

		sudo apt-get update -y 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

		## Install Papirus icons
		printf "$line\n"
		printf "Installing Papirus icons...\n"
		printf "$line\n\n"

		output_text="Installing Papirus icons"
		error_txt="while installing Papirus icons"

		sudo apt-get install papirus-icon-theme -y 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

	elif [[ $Distro_Val == \"Ubuntu\" ]]; then

		## Add PPA
		printf "$line\n"
		printf "Adding repository for Papirus icons...\n"
		printf "$line\n\n"

		output_text="Adding the repository"
		error_txt="while adding the repository"

		sudo add-apt-repository ppa:papirus/papirus
		status=$?
		Exit_Status

		## Update the package list after adding the new repository
		printf "$line\n"
		printf "Updating the package lists...\n"
		printf "$line\n\n"

		output_text="Updating the package lists"
		error_txt="while updating the package lists"

		sudo apt-get update -y 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

		## Install Papirus icons
		printf "$line\n"
		printf "Installing Papirus icons...\n"
		printf "$line\n\n"

		output_text="Installing Papirus icons"
		error_txt="while installing Papirus icons"

		sudo apt-get install papirus-icon-theme -y 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status
	fi

	## Arc theme
	if [[ $de_env == "kde" ]]; then
		if [[ $Distro_Val == arch ]]; then
			printf "$line\n"
			printf "Installing Arc theme...\n"
			printf "$line\n\n"

			output_text="Installing Arc theme"
			error_txt="while installing Arc theme"

			sudo pacman -S arc-kde --needed --noconfirm 2>> $errorpath >> $outputpath &

			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

		elif [[ $Distro_Val == "debian" ]]; then
			printf "$line\n"
			printf "Installing Arc theme\n"
			printf "$line\n\n"

			output_text="Installing Arc theme"
			error_txt="while installing Arc theme"
			wget -qO- https://raw.githubusercontent.com/PapirusDevelopmentTeam/arc-kde/master/install.sh | sh 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

		elif [[ $Distro_Val == \"Ubuntu\" ]]; then

			## Install Arc-KDE theme
			printf "$line\n"
			printf "Installing Arc-KDE theme...\n"
			printf "$line\n\n"

			output_text="Installing Arc-KDE theme"
			error_txt="while installing Arc-KDE theme"

			sudo apt-get install --install-recommends arc-kde -y 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status
		fi

	elif [[ $de_env == "gtk" ]]; then
		if [[ $Distro_Val == arch ]]; then
			printf "$line\n"
			printf "Installing Arc theme...\n"
			printf "$line\n\n"

			output_text="Installing Arc theme"
			error_txt="while installing Arc theme"

			sudo pacman -S arc-gtk-theme --needed --noconfirm 2>> $errorpath >> $outputpath &

			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

		elif [[ $Distro_Val == debian || $Distro_Val == \"Ubuntu\" ]]; then
			printf "$line\n"
			printf "Cloning Arc theme from GitHub...\n"
			printf "$line\n\n"

			output_text="Cloning Arc theme"
			error_txt="while Cloning Arc theme"

			git clone https://github.com/horst3180/arc-theme.git 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

			pushd . 2>> $errorpath >> $outputpath

			cd arc-theme

			arc_pkg=("autoconf" "automake" "pkg-config" "libgtk-3-dev" "gnome-themes-standard" "gtk2-engines-murrine")
			for i in ${arc_pkg[*]}; do
				printf "$line\n"
				printf "Installing Arc theme dependency: $i...\n"
				printf "$line\n\n"

				output_text="Installing Arc theme dependency: $i"
				error_txt="while installing Arc theme dependency: $i"

				sudo apt-get install -y $i 2>> $errorpath >> $outputpath &
				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status
			done

			printf "$line\n"
			printf "Building Arc theme...\n"
			printf "$line\n\n"

			output_text="Building Arc theme"
			error_txt="while building Arc theme"

			./autogen.sh --prefix=/usr 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

			printf "$line\n"
			printf "Installing Arc theme...\n"
			printf "$line\n\n"

			output_text="Installing Arc theme"
			error_txt="while installing Arc theme"

			sudo make install 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

			popd 2>> $errorpath >> $outputpath
			rm -rf arc-theme
		fi
	fi

	## Install Adapta theme
	if [[ $de_env == "kde" ]]; then
		if [[ $Distro_Val == arch ]]; then
			sudo echo

			printf "$line\n"
			printf "Installing Adapta theme...\n"
			printf "$line\n\n"

			output_text="Installing Adapta theme"
			error_txt="while installing Adapta theme"

			sudo pacman -S adapta-kde --needed --noconfirm 2>> $errorpath >> $outputpath &

			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

		elif [[ $Distro_Val == debian ]]; then
			printf "$line\n"
			printf "Installing Adapta theme\n"
			printf "$line\n\n"

			output_text="Installing Adapta theme"
			error_txt="while installing Adapta theme"

			wget -qO- https://raw.githubusercontent.com/PapirusDevelopmentTeam/adapta-kde/master/install.sh | sh 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

		elif [[ $Distro_Val == \"Ubuntu\" ]]; then
			## Install Arc-KDE theme
			printf "$line\n"
			printf "Installing Arc-KDE theme...\n"
			printf "$line\n\n"

			output_text="Installing Arc-KDE theme"
			error_txt="while installing Arc-KDE theme"

			sudo apt-get install --install-recommends adapta-kde -y 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status
		fi

	elif [[ $de_env == "gtk" ]]; then
		printf "$line\n"
		printf "Cloning Arc theme from GitHub...\n"
		printf "$line\n\n"

		output_text="Cloning Arc theme"
		error_txt="while Cloning Arc theme"

		git clone https://github.com/adapta-project/adapta-gtk-theme.git 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

		pushd .

		cd adapta-gtk-theme

		adapta_pkg=("autoconf" "automake" "inkscape" "libgdk-pixbuf2.0-dev" "libglib2.0-dev" "libxml2-utils" "pkg-config" "sassc")
		if [[ $Distro_Val == debian || $Distro_Val == \"Ubuntu\" ]]; then
			for i in ${adapta_pkg[*]}; do
				printf "$line\n"
				printf "Installing Adapta theme dependency: $i...\n"
				printf "$line\n\n"

				output_text="Installing Adapta theme dependency: $i"
				error_txt="while installing Adapta theme dependency: $i"
				sudo apt-get install -y $i 2>> $errorpath >> $outputpath &
				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status
			done

		elif [[ $Distro_Val == arch ]]; then
			for i in ${adapta_pkg[*]}; do
				printf "$line\n"
				printf "Installing Adapta theme dependency: $i...\n"
				printf "$line\n\n"

				output_text="Installing Adapta theme dependency: $i"
				error_txt="while installing Adapta theme dependency: $i"
				sudo pacman -S --needed --noconfirm $i 2>> $errorpath >> $outputpath &
				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status
			done
		fi

		printf "$line\n"
		printf "Building Adapta theme...\n"
		printf "$line\n\n"

		output_text="Building Adapta theme"
		error_txt="while building Adapta theme"

		./autogen.sh --prefix=/usr --enable-plank 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

		printf "$line\n"
		printf "Making Adapta theme...\n"
		printf "$line\n\n"

		output_text="Making Adapta theme"
		error_txt="while making Adapta theme"

		make 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

		printf "$line\n"
		printf "Installing Adapta theme...\n"
		printf "$line\n\n"

		output_text="Installing Adapta theme"
		error_txt="while installing Adapta theme"

		sudo make install 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

		popd

		rm -rf adapta-gtk-theme
	fi

	## Install Foggy theme for plank
	if ! [[ -d /usr/share/plank/themes/Foggy ]]; then
		sudo mkdir -p /usr/share/plank/themes/Foggy
	fi

	if ! [[ -e /usr/share/plank/themes/Foggy/dock.theme ]]; then
		if [[ -e $user_path/Documents/Themes/dock.theme ]]; then
			sudo cp $user_path/Documents/Themes/dock.theme /usr/share/plank/themes/Foggy

		else
			printf "$line\n"
			printf "Foggy theme doesn't exists...\n"
			printf "$line\n\n"

			output_text="Getting Foggy theme with megatools"
			error_txt="while getting Foggy theme megatools"

			status=1
			Exit_Status
		fi
	fi

	## Install Transparent theme for plank
	if ! [[ -e /usr/share/plank/themes/Transparent ]]; then
		if [[ -e $user_path/Documents/Themes/Transparent.tar.gz ]]; then
			printf "$line\n"
			printf "Extracting Transparent theme...\n"
			printf "$line\n\n"

			output_text="Extraction"
			error_txt="while extracting Transparent.tar.gz theme"

			sudo tar -xvf $user_path/Documents/Themes/Transparent.tar.gz -C /usr/share/plank/themes 2>> $errorpath >> $outputpath

			status=$?
			Exit_Status

		else
			printf "$line\n"
			printf "Transparent theme doesn't exists...\n"
			printf "$line\n\n"

			output_text="Getting Transparent theme with megatools"
			error_txt="while getting Transparent theme megatools"

			status=1
			Exit_Status
		fi
	fi

	## Install Zero theme for plank
	if ! [[ -e /usr/share/plank/themes/zero ]]; then
		if [[ -e $user_path/Documents/Themes/zero.tar.gz ]]; then
			printf "$line\n"
			printf "Extracting theme...\n"
			printf "$line\n\n"

			output_text="Extraction"
			error_txt="while extracting zero.tar.gz theme"

			sudo tar -xvf /$user_path/Documents/Themes/zero.tar.gz -C /usr/share/plank/themes 2>> $errorpath >> $outputpath

			status=$?
			Exit_Status

		else
			printf "$line\n"
			printf "Zero theme doesn't exists...\n"
			printf "$line\n\n"

			output_text="Getting Zero theme with megatools"
			error_txt="while getting Zero theme megatools"

			status=1
			Exit_Status
		fi
	fi
}

## Installs Deepin desktop environment
Deepin_Installation () {

	sudo echo

	## Add the option to start the deepin desktop environment with xinit
	sudo runuser -l "root" -c "printf \"exec startdde\n\" > $user_path/.xinitrc"

	printf "$line\n"
	printf "Installing Deepin desktop environment...\n"
	printf "$line\n\n"

	output_text="Deepin desktop installation"
	error_txt="while installing Deepin desktop"

	##	Install deepin desktop environment
	sudo pacman -S deepin --needed --noconfirm 2>> $errorpath >>$outputpath &
	BPID=$!
	Progress_Spinner
	wait $BPID
	status=$?
	Exit_Status

	## Declare a variable for DM_Menu function to use
	de_env="deepin"

	## Disable deepin's login and log out sound
	if [[ -e $deepin_sound_path/desktop-login.ogg ]]; then
		sudo mv $deepin_sound_path/desktop-login.ogg $deepin_sound_path/disable.login
	fi
	if [[ -e $deepin_sound_path/desktop-logout.ogg ]]; then
		sudo mv $deepin_sound_path/desktop-logout.ogg $deepin_sound_path/disable.logout
	fi

	## Copy the wallpaper to deepin's wallpaper folder
	if ! [[ -e /usr/share/wallpapers/deepin/archbk.jpg ]]; then
		sudo cp $user_path/Pictures/archbk.jpg /usr/share/wallpapers/deepin/
	fi
}

## Choose which display manager to install
DM_Menu () {

	## Check which desktop environment was chosen,
	## If KDE was chosen then prompt a menu to the user which display manager
	## to install, if Deeping was chosen then automatically install LightDM
	if [[ $de_env == "kde" ]]; then
		displaymgr=(LightDM SDDM Continue Exit)
		local PS3="Please choose the desired display manager: "
		select opt in ${displaymgr[*]} ; do
		    case $opt in
				LightDm)
					LightDM_Installation
					sleep 0.5
					LightDM_Configuration
					break
					;;
				SDDM)
					SDDM_Installation
					break
					;;
				Continue)
					printf "$line\n"
					printf "Continuing...\n"
					printf "$line\n"
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

	elif [[ $de_env == "deepin" ]]; then
		LightDM_Installation
		sleep 0.5
		LightDM_Configuration

	else
		printf "$line\n"
		printf "Somehow something went wrong somewhere\n"
		printf "$line\n\n"
	fi
}

## Install SDDM display manager
SDDM_Installation () {

	sudo echo

	printf "$line\n"
	printf "Installing sddm...\n"
	printf "$line\n\n"

	output_text="sddm installation"
	error_txt="while installing sddm"

	## Install sddm
	sudo pacman -S sddm --needed --noconfirm 2>> $errorpath >> $outputpath &
	BPID=$!
	Progress_Spinner
	wait $BPID
	status=$?
	Exit_Status

	## Check if LightDM service is enabled, if it is, disable it
	if ! [[ -z $(systemctl status lightdm |awk "{print $4}" |grep -w "enabled;") ]] &> /dev/null; then
		sudo systemctl disable lightdm
	fi

	## Enable and start the sddm service
	printf "$line\n"
	printf "Enabling sddm service...\n"
	printf "$line\n\n"

	output_text="Enable sddm service"
	error_txt="while enabling sddm service"

	systemctl enable sddm 2>> $errorpath >> $outputpath
	status=$?
	Exit_Status
}

## Installs LightDM display manager and configures it
LightDM_Installation () {

	sudo echo

	printf "$line\n"
	printf "Installing Lightdm...\n"
	printf "$line\n\n"

	output_text="Lightdm installation"
	error_txt="while installing Lightdm"

	## Install lightdm and configure it to work with webkit2-greeter
	sudo pacman -S lightdm --needed --noconfirm 2>> $errorpath >> $outputpath &
	BPID=$!
	Progress_Spinner
	wait $BPID
	status=$?
	Exit_Status

	## Check if sddm service is enabled, if it is, disable it
	if ! [[ -z $(systemctl status sddm |awk "{print $4}" |grep -w "enabled;") ]] &> /dev/null; then
		sudo systemctl disable sddm
	fi

	## Enable and start the LightDm service
	printf "$line\n"
	printf "Enabling Lightdm service...\n"
	printf "$line\n\n"

	output_text="Enable Lightdm service"
	error_txt="while enabling Lightdm service"

	sudo systemctl enable lightdm 2>> $errorpath >> $outputpath
	status=$?
	Exit_Status
}

## Download dependencies and configure lightDM
LightDM_Configuration () {

	sudo echo

	if [[ $aur_helper == "aurman" ]]; then

		## Check if "aurman" exists, if not, call the function that installs it
		if [[ -z $(command -v aurman) ]]; then
			Aurman_Install
		fi

		printf "$line\n"
		printf "Installing Lightdm-webkit2-greeter...\n"
		printf "$line\n\n"

		output_text="Lightdm-webkit2-greeter installation"
		error_txt="while installing Lightdm-webkit2-greeter"

		## Install webkit greeter for a nice theme
		aurman -S lightdm-webkit2-greeter lightdm-webkit-theme-litarvan --needed --noconfirm 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

	elif [[ $aur_helper == "yay" ]]; then

		## Check if "yay" exists, if not, call the function that installs it
		if [[ -z $(command -v yay) ]]; then
			Yay_Install
		fi

		printf "$line\n"
		printf "Installing Lightdm-webkit2-greeter...\n"
		printf "$line\n\n"

		output_text="Lightdm-webkit2-greeter installation"
		error_txt="while installing Lightdm-webkit2-greeter"

		## Install webkit greeter for a nice theme
		yay -S lightdm-webkit2-greeter lightdm-webkit-theme-litarvan --needed --noconfirm 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status
	fi

	## Change LightDm's greeter and theme
	sudo sed -ie "s/\#greeter-session=.*/greeter-session=lightdm-webkit2-greeter/" $lightconf
	sudo sed -ie "s/webkit_theme.*/webkit_theme        = litarvan/" $lightwebconf
}

## Full system update for manjaro
Manjaro_Sys_Update () {
	sudo echo

	printf "$line\n"
	printf "Updating the system...\n"
	printf "$line\n\n"

	output_text="Update"
	error_txt="while updating"

	sudo pacman -Syu --noconfirm 2>> $errorpath >> $outputpath &
	BPID=$
	Progress_Spinner
	wait $BPID
	status=$?
	Exit_Status
}

## Set desktop theme
xfce_theme () {
	#	wget -O /home/tom/Pictures/archbk.jpg http://getwallpapers.com/wallpaper/full/f/2/a/1056675-download-free-arch-linux-wallpaper-1920x1080.jpg 2>> $errorpath >> $outputpath
	xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s "/home/tom/Pictures/archbk.jpg" 2>> $errorpath >> $outputpath
	xfconf-query --channel "xfce4-panel" --property '/panels/panel-1/size' --type int --set 49
	xfconf-query --channel "xfce4-panel" --property '/panels/panel-1/background-alpha' --type int --set 0
	xfconf-query --channel 'xfce4-keyboard-shortcuts' --property '/commands/custom/<Super>t' --type string --set xfce4-terminal --create
	xfconf-query --channel 'xfce4-keyboard-shortcuts' --property '/commands/custom/grave' --type string --set "xfce4-terminal --drop-down" --create
}

## Config the grub background and fast boot time
Boot_Manager_Config () {

	sudo echo

	## Check if grub's configuration file exits
	if [[ -e /etc/default/grub ]]; then
		sudo cp /etc/default/grub /etc/default/grub.bck

		if [[ -z $(egrep "^GRUB_TIMEOUT=.*" /etc/default/grub) ]]; then
			sudo sed -ie 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
		fi

		if [[ -z $(egrep "^GRUB_HIDDEN_TIMEOUT=.*" /etc/default/grub) ]]; then
			sudo sed -ie 's/GRUB_HIDDEN_TIMEOUT=.*/GRUB_HIDDEN_TIMEOUT=0/' /etc/default/grub

		else
			sudo runuser -l "root" -c "printf \"GRUB_HIDDEN_TIMEOUT=1\" >> /etc/default/grub"
		fi


		if [[ -z $(egrep "^GRUB_HIDDEN_TIMEOUT_QUIET=.*" /etc/default/grub) ]]; then
			sudo sed -ie 's/GRUB_HIDDEN_TIMEOUT_QUIET=.*/GRUB_HIDDEN_TIMEOUT_QUIET=true/' /etc/default/grub

		else
			sudo runuser -l "root" -c "printf \"GRUB_HIDDEN_TIMEOUT_QUIET=true\" >> /etc/default/grub"
		fi

		if ! [[ -d /boot/grub/themes ]]; then
			sudo mkdir -p /boot/grub/themes
		fi

		if ! [[ -e /boot/grub/themes/Vimix ]]; then
			if [[ -e $user_path/Documents/Themes/grub-theme-vimix.tar.xz ]]; then

				printf "$line\n"
				printf "Extracting theme...\n"
				printf "$line\n\n"

				output_text="Extraction"
				error_txt="while extracting Vimix theme"

				sudo tar -xvf $user_path/Documents/Themes/grub-theme-vimix.tar.xz -C /boot/grub/themes 2>> $errorpath >> $outputpath

				status=$?
				Exit_Status
			else
				printf "$line\n"
				printf "Vimix GRUB theme doesn't exists...\n"
				printf "$line\n\n"

				output_text="Getting Vimix GRUB theme with megatools"
				error_txt="while getting Vimix GRUB theme megatools"

				status=1
				Exit_Status
			fi
		fi

		if [[ -z $(sudo egrep "^GRUB_THEME=.*" /etc/default/grub) ]]; then
			sudo runuser -l "root" -c 'printf "GRUB_THEME=\"boot/grub/themes/grub-theme-vimix/Vimix/theme.txt\"" >> /etc/default/grub'
		else
			sudo sed -ie "s/GRUB_THEME=.*/GRUB_THEME=\"boot\/grub\/themes\/grub-theme-vimix\/Vimix\/theme.txt\"/" /etc/default/grub
		fi

		## Apply changes to grub
		printf "$line\n"
		printf "Applying changes to GRUB...\n"
		printf "$line\n\n"

		sudo grub-mkconfig -o /boot/grub/grub.cfg 2>> $errorpath >> $outputpath

		## If GRUB changes failed, rollback to backup file
		if [[ $? -ne 0 ]]; then
			sudo mv /etc/default/grub.bck /etc/default/grub

			printf "$line\n"
			printf "Applying changes to GRUB failed, roolling back to backup GRUB file...\n"
			printf "$line\n\n"

			output_text="Roolling back to backup GRUB file"
			error_txt="while rolling back to backup GRUB file"

			sudo grub-mkconfig -o /boot/grub/grub.cfg 2>> $errorpath >> $outputpath
			status=$?
			Exit_Status

		else
			output_text="GRUB changes"
			error_txt="while applying changes to GRUB"
			status=0
			Exit_Status
		fi

	else
		error_txt=", could not find GRUB's configuraion file"
		status=1
		Exit_Status
	fi

	## Ask the user if he wants to install refined boot manager
	read -p "Would you like to install refined boot manager?[y/N]: " answer
	printf "\n"
	if [[ -z $answer ]]; then
		printf "$line\n"
		printf "Post-Install completed successfully\n"
		printf "$line\n\n"
		exit 0
	elif [[ $answer =~ [y|Y] || $answer =~ [y|Y]es ]]; then
		:
	elif [[ $answer =~ [n|N] || $answer =~ [n|N]o ]]; then
		printf "$line\n"
		printf "Post-Install completed successfully\n"
		printf "$line\n\n"
		exit 0
	else
		printf "$line\n"
		printf "Invalid answer - exiting\n"
		printf "$line\n\n"
		exit 1
	fi

	## install refinds boot manager and configure it
	printf "$line\n"
	printf "Downloading refind boot manager...\n"
	printf "$line\n\n"

	output_text="Refind boot manager download"
	error_txt="while downloading refind boot manager"

	sudo pacman -S refind-efi --needed --noconfirm 2>> $errorpath >> $outputpath &
	BPID=$!
	Progress_Spinner
	wait $BPID
	status=$?
	Exit_Status

	printf "$line\n"
	printf "Configuring refind with 'refind-install'...\n"
	printf "$line\n\n"

	output_text="'refind-install'"
	error_txt="while configuring refind with 'refind-install'"

	sudo refind-install 2>> $errorpath >> $outputpath
	status=$?
	Exit_Status

	printf "$line\n"
	printf "Configuring refind to be the default boot manager...\n"
	printf "$line\n\n"

	output_text="Setting refind to be the default boot manager"
	error_txt="while setting refind to be the default boot manager"

	sudo refind-mkdefault 2>> $errorpath >> $outputpath
	status=$?
	Exit_Status

	## Check if "themes" directory exits in refind, if not, create one
	if ! [[ -d $refind_path/themes ]]; then
		sudo mkdir $refind_path/themes
	fi

	## Check if the theme exits, if not, clone from git and add it to refind.conf
	if ! [[ -d $refind_path/themes/rEFInd-minimal ]]; then
		sudo mkdir $refind_path/themes/rEFInd-minimal
		printf "$line\n"
		printf "Cloning refind's theme from git...\n"
		printf "$line\n\n"

		output_text="Cloning theme from git"
		error_txt="while cloning from git"

		## Get the build files for AUR
		sudo git clone https://github.com/EvanPurkhiser/rEFInd-minimal.git $refind_path/themes/rEFInd-minimal 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

		sudo runuser -l "root" -c "printf \"include themes/rEFInd-minimal/theme.conf\" >> $refind_path/refind.conf"
	fi
}
