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
	error_text="while downloading background picture"

	## If the directory doesn't exits, create it
	if ! [[ -d $HOME/Pictures ]]; then
		sudo runuser -l $orig_user -c "mkdir $HOME/Pictures"
	fi

	## If the background picture doesn't already exists, download it
	if ! [[ -e $HOME/Pictures/archbk.jpg ]]; then
		sudo runuser -l $orig_user -c "wget --show-progress --progress=bar -a $outputpath -O $HOME/Pictures/archbk.jpg http://getwallpapers.com/wallpaper/full/f/2/a/1056675-download-free-arch-linux-wallpaper-1920x1080.jpg"
		wait
		status=$?
		Exit_Status
		sudo printf "\n"
	fi

	## customize shell, check if the config exists, if not, add it to .bashrc
	if [[ -z $(grep "^alias ll='ls -l'$" $HOME/.bashrc) ]]; then
		printf "alias ll='ls -l'\n" >> $HOME/.bashrc
	fi

	if [[ -z $(grep "^alias lh='ls -lh'$" $HOME/.bashrc) ]]; then
		printf "alias lh='ls -lh'\n" >> $HOME/.bashrc
	fi

	if [[ -z $(grep "^alias la='ls -la'$" $HOME/.bashrc) ]]; then
		printf "alias la='ls -la'\n" >> $HOME/.bashrc
	fi

	if [[ -z $(grep "^alias syst='systemctl status'$" $HOME/.bashrc) ]]; then
		printf "alias syst='systemctl status'\n" >> $HOME/.bashrc
	fi

	if [[ -z $(grep "^alias sysr='sudo systemctl restart'$" $HOME/.bashrc) ]]; then
		printf "alias sysr='sudo systemctl restart'\n" >> $HOME/.bashrc
	fi

	if [[ -z $(grep "^alias syse='sudo systemctl enable'$" $HOME/.bashrc) ]]; then
		printf "alias syse='sudo systemctl enable'\n" >> $HOME/.bashrc
	fi

	if [[ -z $(grep "^alias sysd='sudo systemctl disable'$" $HOME/.bashrc) ]]; then
		printf "alias sysd='sudo systemctl disable'\n" >> $HOME/.bashrc
	fi

	if ! [[ -z $(command -v git) ]]; then
		if [[ -z $(grep "^alias gita='git add'$" $HOME/.bashrc) ]]; then
			printf "alias gita='git add'\n" >> $HOME/.bashrc
		fi

		if [[ -z $(grep "^alias gitc='git commit -m'$" $HOME/.bashrc) ]]; then
			printf "alias gitc='git commit -m'\n" >> $HOME/.bashrc
		fi

		if [[ -z $(grep "^alias gitp='git push'$" $HOME/.bashrc) ]]; then
			printf "alias gitp='git push'\n" >> $HOME/.bashrc
		fi
	fi

	if [[ -z $(grep "^alias pls='sudo \$(history -p !!)'$" $HOME/.bashrc) ]]; then
		printf "alias pls='sudo \$(history -p !!)'\n" >> $HOME/.bashrc
	fi

	if [[ -z $(grep "^alias fuck='pkill \$1'$" $HOME/.bashrc) ]]; then
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

	if [[ -z $(sudo grep "^alias ll='ls -l'$" /root/.bashrc) ]]; then
		sudo runuser -l "root" -c "printf \"alias ll='ls -l'\n\" >> /root/.bashrc"
	fi

	if [[ -z $(sudo grep "^alias lh='ls -lh'$" /root/.bashrc) ]]; then
		sudo runuser -l "root" -c "printf \"alias lh='ls -lh'\n\" >> /root/.bashrc"
	fi

	if [[ -z $(sudo grep "^alias la='ls -la'$" /root/.bashrc) ]]; then
		sudo runuser -l "root" -c "printf \"alias la='ls -la'\n\" >> /root/.bashrc"
	fi

	if [[ -z $(sudo grep "^alias syst='systemctl status'$" /root/.bashrc) ]]; then
		sudo runuser -l "root" -c "printf \"alias syst='systemctl status'\n\" >> /root/.bashrc"
	fi

	if [[ -z $(sudo grep "^alias sysr='systemctl restart'$" /root/.bashrc) ]]; then
		sudo runuser -l "root" -c "printf \"alias sysr='systemctl restart'\n\" >> /root/.bashrc"
	fi

	if [[ -z $(sudo grep "^alias syse='systemctl enable'$" /root/.bashrc) ]]; then
		sudo runuser -l "root" -c "printf \"alias syse='systemctl enable'\n\" >> /root/.bashrc"
	fi

	if [[ -z $(sudo grep "^alias sysd='systemclt disable'$" /root/.bashrc) ]]; then
		sudo runuser -l "root" -c "printf \"alias sysd='systemctl disable'\n\" >> /root/.bashrc"
	fi

	if [[ -z $(sudo grep "^alias fuck='pkill \$1'$" /root/.bashrc) ]]; then
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
	sudo runuser -l "root" -c "printf \"exec startkde\n\" > $HOME/.xinitrc"

	output_text="Plasma desktop installation"
	error_text="while installing plasma desktop"

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

## Prompt the user which themes he would like to install
Theme_Prompt () {

		## Chili prompt
		if [[ $de_env == "kde" ]]; then
			if [[ $chili_theme == "yes" ]]; then
				read -p "Would you like to install Chili theme?[Y/n]: " answer
				printf "\n"
				if [[ -z $answer ]]; then
					chili_theme="yes"
				elif [[ $answer =~ [y|Y] || $answer =~ [y|Y]es ]]; then
					chili_theme="yes"
				elif [[ $answer =~ [n|N] || $answer =~ [n|N]o ]]; then
					chili_theme="no"
				else
					printf "$line\n"
					printf "Invalid answer - Chili theme will NOT be installed\n"
					printf "$line\n\n"
					chili_theme="no"
			fi
		fi

		## Bibata prompt
		if ! [[ $bibata_cursor == "yes" ]]; then
			read -p "Would you like to install Bibata cursor pack?[Y/n]: " answer
			printf "\n"
			if [[ -z $answer ]]; then
				bibata_cursor="yes"
			elif [[ $answer =~ [y|Y] || $answer =~ [y|Y]es ]]; then
				bibata_cursor="yes"
			elif [[ $answer =~ [n|N] || $answer =~ [n|N]o ]]; then
				bibata_cursor="no"
			else
				printf "$line\n"
				printf "Invalid answer - Bibata cursor pack will NOT be installed\n"
				printf "$line\n\n"
				bibata_cursor="no"
			fi
		fi

		## La-Capitaine prompt
		if ! [[ $capitaine_icons == "yes" ]]; then
			read -p "Would you like to install La-Capitaine icons?[Y/n]: " answer
			printf "\n"
			if [[ -z $answer ]]; then
				capitaine_icons="yes"
			elif [[ $answer =~ [y|Y] || $answer =~ [y|Y]es ]]; then
				capitaine_icons="yes"
			elif [[ $answer =~ [n|N] || $answer =~ [n|N]o ]]; then
				capitaine_icons="no"
			else
				printf "$line\n"
				printf "Invalid answer - La-Capitaine icons will NOT be installed\n"
				printf "$line\n\n"
				capitaine_icons="no"
			fi
		fi

		## Shoadw prompt
		if ! [[ $shadow_icons == "yes" ]]; then
			read -p "Would you like to install Shadow icons?[Y/n]: " answer
			printf "\n"
			if [[ -z $answer ]]; then
				shadow_icons="yes"
			elif [[ $answer =~ [y|Y] || $answer =~ [y|Y]es ]]; then
				shadow_icons="yes"
			elif [[ $answer =~ [n|N] || $answer =~ [n|N]o ]]; then
				shadow_icons="no"
			else
				printf "$line\n"
				printf "Invalid answer - Shadow icons will NOT be installed\n"
				printf "$line\n\n"
				shadow_icons="no"
			fi
		fi

		## Papirus prompt
		if ! [[ $papirus_icons == "yes" ]]; then
			read -p "Would you like to install Papirus icons?[Y/n]: " answer
			printf "\n"
			if [[ -z $answer ]]; then
				papirus_icons="yes"
			elif [[ $answer =~ [y|Y] || $answer =~ [y|Y]es ]]; then
				papirus_icons="yes"
			elif [[ $answer =~ [n|N] || $answer =~ [n|N]o ]]; then
				papirus_icons="no"
			else
				printf "$line\n"
				printf "Invalid answer - Papirus icons will NOT be installed\n"
				printf "$line\n\n"
				papirus_icons="yes"
			fi
		fi

		## Adapta prompt
		if ! [[ $adapta_theme == "yes" ]]; then
			read -p "Would you like to install Adapta theme?[Y/n]: " answer
			printf "\n"
			if [[ -z $answer ]]; then
				adapta_theme="yes"
			elif [[ $answer =~ [y|Y] || $answer =~ [y|Y]es ]]; then
				adapta_theme="yes"
			elif [[ $answer =~ [n|N] || $answer =~ [n|N]o ]]; then
				adapta_theme="no"
			else
				printf "$line\n"
				printf "Invalid answer - Adapta theme will NOT be installed\n"
				printf "$line\n\n"
				adapta_theme="no"
			fi
		fi

		## Arc prompt
		if ! [[ $arc_theme == "yes" ]]; then
			read -p "Would you like to install Arc theme?[Y/n]: " answer
			printf "\n"
			if [[ -z $answer ]]; then
				arc_theme="yes"
			elif [[ $answer =~ [y|Y] || $answer =~ [y|Y]es ]]; then
				arc_theme="yes"
			elif [[ $answer =~ [n|N] || $answer =~ [n|N]o ]]; then
				arc_theme="no"
			else
				printf "$line\n"
				printf "Invalid answer - Arc theme will NOT be installed\n"
				printf "$line\n\n"
				arc_theme="no"
			fi
		fi




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
		output_text="Megatools installation"
		error_text="while installing Megatools"

		if [[ $Distro_Val == arch ]]; then
			if [[ $aur_helper == "aurman" ]]; then
				sudo echo

				## Check if "aurman" exists, if not, call the function that installs it
				if [[ -z $(command -v aurman) ]]; then
					Aurman_Install
				fi

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


	if ! [[ -d $HOME/Documents/Themes ]]; then
		mkdir -p $HOME/Documents/Themes
	fi

	printf "$line\n"
	printf "Installing themes form Mega cloud...\n"
	printf "$line\n\n"

	output_text="Getting themes form Mega cloud"
	error_text="while getting themes form Mega cloud"

	if [[ $de_env == "kde" ]]; then
		megadl --no-progress --path=$HOME/Documents/Themes 'https://mega.nz/#F!TgBkwIjY!YZ1RpgF19Z2vO7X5gg0KLg' 2>> $errorpath >> $outputpath &

		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

	elif [[ $de_env == "gtk" ]]; then
		megadl --no-progress --path=$HOME/Documents/Themes 'https://mega.nz/#F!38QiXCrS!aa5xSCuP_HLrpLJK9Mx6rg' 2>> $errorpath >> $outputpath &

		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status
	fi

	## Chili theme
	if [[ $chili_theme == "yes" ]]; then
		if [[ $de_env == "kde" ]]; then
			if ! [[ -e $HOME/Documents/Themes/kde-plasma-chili.tar.gz ]]; then
				printf "$line\n"
				printf "Chili theme doesn't exists...\n"
				printf "$line\n\n"

				output_text="Getting Chili theme with megatools"
				error_text="while getting Chili with megatools"

				status=1
				Exit_Status
			fi
		fi
	fi

	## Bibata cursor pack
	Bibata_Cursor_Pack.tar.gz
	if [[ $bibata_cursor == "yes" ]]; then
		if [[ -e $HOME/Documents/Themes/Bibata_Cursor_Pack.tar.gz ]]; then
			if ! [[ -e /usr/share/icons/Bibata_Amber && -e /usr/share/icons/Bibata_Ice && -e /usr/share/icons/Bibata_Oil ]]; then
				printf "$line\n"
				printf "Extracting Bibata cursor pack...\n"
				printf "$line\n\n"

				output_text="Extraction"
				error_text="while extracting Bibata cursor pack"

				sudo tar -xvf $HOME/Documents/Themes/ibata_Cursor_Pack.tar.gz -C /usr/share/icons 2>> $errorpath >> $outputpath

				status=$?
				Exit_Status

			else
				printf "$line\n"
				printf "Bibata cursor pack doesn't exists...\n"
				printf "$line\n\n"

				output_text="Getting Bibata cursor pack with megatools"
				error_text="while getting Bibata cursor pack megatools"

				status=1
				Exit_Status
			fi
		fi
	fi

	## La-Capitaine icons
	if [[ $capitaine_icons == "yes" ]]; then
		if [[ -e $HOME/Documents/Themes/la-capitaine-icon-theme-0.6.1-20190217.tar.gz ]]; then
			if ! [[ -e /usr/share/icons/la-capitaine-icon-theme ]]; then
				printf "$line\n"
				printf "Extracting La-Capitaine icons...\n"
				printf "$line\n\n"

				output_text="Extraction"
				error_text="while extracting La-Capitaine icons"

				sudo tar -xvf $HOME/Documents/Themes/la-capitaine-icon-theme-0.6.1-20190217.tar.gz -C /usr/share/icons 2>> $errorpath >> $outputpath

				status=$?
				Exit_Status

			else
				printf "$line\n"
				printf "La-Capitaine icons doesn't exists...\n"
				printf "$line\n\n"

				output_text="Getting La-Capitaine icons with megatools"
				error_text="while getting La-Capitaine icons megatools"

				status=1
				Exit_Status
			fi
		fi
	fi

	## Shadow icons
	if [[ $shadow_icons == "yes" ]]; then
		if [[ $de_env == "kde" ]]; then
			if [[ -e $HOME/Documents/Themes/shadow-kde-04-2018.tar.xz  ]]; then
				if ! [[ -e $HOME/.icons ]]; then
					mkdir $HOME/.icons
				fi

				printf "$line\n"
				printf "Extracting Shadow icons...\n"
				printf "$line\n\n"

				output_text="Extraction"
				error_text="while extracting Shadow icons"

				sudo tar -xvf $HOME/Documents/Themes/shadow-kde-04-2018.tar.xz -C $HOME/.icons 2>> $errorpath >> $outputpath

				status=$?
				Exit_Status

			else
				printf "$line\n"
				printf "Shadow icons doesn't exists...\n"
				printf "$line\n\n"

				output_text="Getting Shadow icons with megatools"
				error_text="while getting Shadow icons megatools"

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

					output_text="Shadow icons installation"
					error_text="while installing Shadow icons"

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

					output_text="Shadow icons installation"
					error_text="while installing Shadow icons"

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
				output_text="Adding the repository"
				error_text="while adding the repository"

				sudo add-apt-repository ppa:noobslab/icons -y 2>> $errorpath >> $outputpath &
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

				output_text="Installing Shadow icons"
				error_text="while installing shadow icons"

				sudo apt-get install shadow-icon-theme -y 2>> $errorpath >> $outputpath &
				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status

			else
				if [[ -e $HOME/Documents/Themes/shadow-4.8.3.tar.xz ]]; then
					if ! [[ -e $HOME/.icons ]]; then
						mkdir $HOME/.icons
					fi

					printf "$line\n"
					printf "Extracting Shadow icons...\n"
					printf "$line\n\n"

					output_text="Extraction"
					error_text="while extracting Shadow icons"

					sudo tar -xvf $HOME/Documents/Themes/shadow-4.8.3.tar.xz -C $HOME/.icons 2>> $errorpath >> $outputpath

					status=$?
					Exit_Status

				else
					printf "$line\n"
					printf "Shadow icons doesn't exists...\n"
					printf "$line\n\n"

					output_text="Getting shadow icons with megatools"
					error_text="while getting shadow icons megatools"

					status=1
					Exit_Status

				fi
			fi
		fi
	fi

	## Papirus icons
	sudo echo
	if [[ $papirus_icons == "yes" ]]; then
		if [[ $Distro_Val == arch ]]; then
			output_text="Installing Papirus icons"
			error_text="while installing Papirus icons"

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
			error_text="while adding the repository"

			sudo sh -c "echo 'deb http://ppa.launchpad.net/papirus/papirus/ubuntu bionic main' > /etc/apt/sources.list.d/papirus-ppa.list"
			status=$?
			Exit_Status

			## Install dirmngr to manage and download OpenPGP and X.509 certificates
			output_text="Installing dirmngr"
			error_text="while installing dirmngr"

			sudo apt-get install dirmngr -y 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

			## Add certificate
			output_text="Adding the certificate"
			error_text="while adding the certificate"
			sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com E58A9D36647CAE7F >> $outputpath 2>> $errorpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

			## Update the package list after adding the new repository
			output_text="Updating the package lists"
			error_text="while updating the package lists"

			sudo apt-get update -y 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

			## Install Papirus icons
			output_text="Installing Papirus icons"
			error_text="while installing Papirus icons"

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
			error_text="while adding the repository"

			sudo add-apt-repository ppa:papirus/papirus
			status=$?
			Exit_Status

			## Update the package list after adding the new repository
			output_text="Updating the package lists"
			error_text="while updating the package lists"

			sudo apt-get update -y 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

			## Install Papirus icons
			output_text="Installing Papirus icons"
			error_text="while installing Papirus icons"

			sudo apt-get install papirus-icon-theme -y 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status
		fi
	fi

	## Arc theme
	if [[ $arc_theme == "yes" ]]; then
		if [[ $de_env == "kde" ]]; then
			if [[ $Distro_Val == arch ]]; then
				output_text="Installing Arc theme"
				error_text="while installing Arc theme"

				sudo pacman -S arc-kde --needed --noconfirm 2>> $errorpath >> $outputpath &

				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status

			elif [[ $Distro_Val == "debian" ]]; then
				output_text="Installing Arc theme"
				error_text="while installing Arc theme"
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
				error_text="while installing Arc-KDE theme"

				sudo apt-get install --install-recommends arc-kde -y 2>> $errorpath >> $outputpath &
				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status
			fi

		elif [[ $de_env == "gtk" ]]; then
			if [[ $Distro_Val == arch ]]; then
				output_text="Installing Arc theme"
				error_text="while installing Arc theme"

				sudo pacman -S arc-gtk-theme --needed --noconfirm 2>> $errorpath >> $outputpath &

				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status

			elif [[ $Distro_Val == debian || $Distro_Val == \"Ubuntu\" ]]; then
				output_text="Cloning Arc theme"
				error_text="while Cloning Arc theme"

				pushd . 2>> $errorpath >> $outputpath

				git clone https://github.com/horst3180/arc-theme.git $tmpdir/arc-theme 2>> $errorpath >> $outputpath &
				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status

				cd $tmpdir/arc-theme

				arc_pkg=("autoconf" "automake" "pkg-config" "libgtk-3-dev" "gnome-themes-standard" "gtk2-engines-murrine")
				for i in ${arc_pkg[*]}; do
					output_text="Installing Arc theme dependency: $i"
					error_text="while installing Arc theme dependency: $i"

					sudo apt-get install -y $i 2>> $errorpath >> $outputpath &
					BPID=$!
					Progress_Spinner
					wait $BPID
					status=$?
					Exit_Status
				done

				output_text="Building Arc theme"
				error_text="while building Arc theme"

				./autogen.sh --prefix=/usr 2>> $errorpath >> $outputpath &
				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status

				output_text="Installing Arc theme"
				error_text="while installing Arc theme"

				sudo make install 2>> $errorpath >> $outputpath &
				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status

				popd 2>> $errorpath >> $outputpath
			fi
		fi
	fi

	## Install Adapta theme
	if [[ $adapta_theme == "yes" ]]; then
		if [[ $de_env == "kde" ]]; then
			if [[ $Distro_Val == arch ]]; then
				sudo echo

				output_text="Installing Adapta theme"
				error_text="while installing Adapta theme"

				sudo pacman -S adapta-kde --needed --noconfirm 2>> $errorpath >> $outputpath &

				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status

			elif [[ $Distro_Val == debian ]]; then

				output_text="Installing Adapta theme"
				error_text="while installing Adapta theme"

				wget -qO- https://raw.githubusercontent.com/PapirusDevelopmentTeam/adapta-kde/master/install.sh | sh 2>> $errorpath >> $outputpath &
				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status

			elif [[ $Distro_Val == \"Ubuntu\" ]]; then
				## Install Arc-KDE theme

				output_text="Installing Arc-KDE theme"
				error_text="while installing Arc-KDE theme"

				sudo apt-get install --install-recommends adapta-kde -y 2>> $errorpath >> $outputpath &
				BPID=$!
				Progress_Spinner
				wait $BPID
				status=$?
				Exit_Status
			fi

		elif [[ $de_env == "gtk" ]]; then
			output_text="Cloning Arc theme"
			error_text="while Cloning Arc theme"
			pushd . 2>> $errorpath >> $outputpath

			git clone https://github.com/adapta-project/adapta-gtk-theme.git $tmpdir/adapta-gtk-theme 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

			cd $tmpdir/adapta-gtk-theme

			adapta_pkg=("autoconf" "automake" "inkscape" "libgdk-pixbuf2.0-dev" "libglib2.0-dev" "libxml2-utils" "pkg-config" "sassc")
			if [[ $Distro_Val == debian || $Distro_Val == \"Ubuntu\" ]]; then
				for i in ${adapta_pkg[*]}; do
					output_text="Installing Adapta theme dependency: $i"
					error_text="while installing Adapta theme dependency: $i"
					sudo apt-get install -y $i 2>> $errorpath >> $outputpath &
					BPID=$!
					Progress_Spinner
					wait $BPID
					status=$?
					Exit_Status
				done

			elif [[ $Distro_Val == arch ]]; then
				for i in ${adapta_pkg[*]}; do
					output_text="Installing Adapta theme dependency: $i"
					error_text="while installing Adapta theme dependency: $i"
					sudo pacman -S --needed --noconfirm $i 2>> $errorpath >> $outputpath &
					BPID=$!
					Progress_Spinner
					wait $BPID
					status=$?
					Exit_Status
				done
			fi

			output_text="Building Adapta theme"
			error_text="while building Adapta theme"

			./autogen.sh --prefix=/usr --enable-plank 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status


			output_text="Making Adapta theme, this may take a while, now"
			error_text="while making Adapta theme"

			make 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

			output_text="Installing Adapta theme"
			error_text="while installing Adapta theme"

			sudo make install 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

			popd 2>> $errorpath >> $outputpath

		fi
	fi

	## Install Foggy theme for plank
	if ! [[ -d /usr/share/plank/themes/Foggy ]]; then
		sudo mkdir -p /usr/share/plank/themes/Foggy
	fi

	if ! [[ -e /usr/share/plank/themes/Foggy/dock.theme ]]; then
		if [[ -e $HOME/Documents/Themes/dock.theme ]]; then
			sudo cp $HOME/Documents/Themes/dock.theme /usr/share/plank/themes/Foggy

		else
			printf "$line\n"
			printf "Foggy theme doesn't exists...\n"
			printf "$line\n\n"

			output_text="Getting Foggy theme with megatools"
			error_text="while getting Foggy theme megatools"

			status=1
			Exit_Status
		fi
	fi

	## Install Transparent theme for plank
	if ! [[ -e /usr/share/plank/themes/Transparent ]]; then
		if [[ -e $HOME/Documents/Themes/Transparent.tar.gz ]]; then
			printf "$line\n"
			printf "Extracting Transparent theme...\n"
			printf "$line\n\n"

			output_text="Extraction"
			error_text="while extracting Transparent.tar.gz theme"

			sudo tar -xvf $HOME/Documents/Themes/Transparent.tar.gz -C /usr/share/plank/themes 2>> $errorpath >> $outputpath

			status=$?
			Exit_Status

		else
			printf "$line\n"
			printf "Transparent theme doesn't exists...\n"
			printf "$line\n\n"

			output_text="Getting Transparent theme with megatools"
			error_text="while getting Transparent theme megatools"

			status=1
			Exit_Status
		fi
	fi

	## Install Zero theme for plank
	if ! [[ -e /usr/share/plank/themes/zero ]]; then
		if [[ -e $HOME/Documents/Themes/zero.tar.gz ]]; then
			printf "$line\n"
			printf "Extracting theme...\n"
			printf "$line\n\n"

			output_text="Extraction"
			error_text="while extracting zero.tar.gz theme"

			sudo tar -xvf /$HOME/Documents/Themes/zero.tar.gz -C /usr/share/plank/themes 2>> $errorpath >> $outputpath

			status=$?
			Exit_Status

		else
			printf "$line\n"
			printf "Zero theme doesn't exists...\n"
			printf "$line\n\n"

			output_text="Getting Zero theme with megatools"
			error_text="while getting Zero theme megatools"

			status=1
			Exit_Status
		fi
	fi
}

## Installs Deepin desktop environment
Deepin_Installation () {

	sudo echo

	## Add the option to start the deepin desktop environment with xinit
	sudo runuser -l "root" -c "printf \"exec startdde\n\" > $HOME/.xinitrc"

	output_text="Deepin desktop installation"
	error_text="while installing Deepin desktop"

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
		sudo cp $HOME/Pictures/archbk.jpg /usr/share/wallpapers/deepin/
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

	output_text="sddm installation"
	error_text="while installing sddm"

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
	error_text="while enabling sddm service"

	systemctl enable sddm 2>> $errorpath >> $outputpath
	status=$?
	Exit_Status
}

## Installs LightDM display manager and configures it
LightDM_Installation () {

	sudo echo

	output_text="Lightdm installation"
	error_text="while installing Lightdm"

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
	error_text="while enabling Lightdm service"

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

		output_text="Lightdm-webkit2-greeter installation"
		error_text="while installing Lightdm-webkit2-greeter"

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

		output_text="Lightdm-webkit2-greeter installation"
		error_text="while installing Lightdm-webkit2-greeter"

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
	error_text="while updating"

	sudo pacman -Syu --noconfirm 2>> $errorpath >> $outputpath &
	BPID=$
	Progress_Spinner
	wait $BPID
	status=$?
	Exit_Status
}

## Set desktop theme
xfce_theme () {
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

		if [[ -n $(egrep "^GRUB_TIMEOUT=.*" /etc/default/grub) ]]; then
			sudo sed -ie 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
		else
			sudo runuser -l "root" -c "printf \"GRUB_TIMEOUT=0\n\" >> /etc/default/grub"
		fi

		if [[ -n $(egrep "^GRUB_HIDDEN_TIMEOUT=s.*" /etc/default/grub) ]]; then
			sudo sed -ie 's/GRUB_HIDDEN_TIMEOUT=.*/GRUB_HIDDEN_TIMEOUT=1/' /etc/default/grub

		else
			sudo runuser -l "root" -c "printf \"GRUB_HIDDEN_TIMEOUT=1\n\" >> /etc/default/grub"
		fi


		if [[ -n $(egrep "^GRUB_HIDDEN_TIMEOUT_QUIET=.*" /etc/default/grub) ]]; then
			sudo sed -ie 's/GRUB_HIDDEN_TIMEOUT_QUIET=.*/GRUB_HIDDEN_TIMEOUT_QUIET=true/' /etc/default/grub

		else
			sudo runuser -l "root" -c "printf \"GRUB_HIDDEN_TIMEOUT_QUIET=true\n\" >> /etc/default/grub"
		fi

		if ! [[ -d /boot/grub/themes ]]; then
			sudo mkdir -p /boot/grub/themes
		fi

		if ! [[ -e /boot/grub/themes/Vimix ]]; then
			if [[ -e $HOME/Documents/Themes/grub-theme-vimix.tar.xz ]]; then

				printf "$line\n"
				printf "Extracting theme...\n"
				printf "$line\n\n"

				output_text="Extraction"
				error_text="while extracting Vimix theme"

				sudo tar -xvf $HOME/Documents/Themes/grub-theme-vimix.tar.xz --no-same-owner -C /boot/grub/themes 2>> $errorpath >> $outputpath

				status=$?
				Exit_Status
			else
				printf "$line\n"
				printf "Vimix GRUB theme doesn't exists...\n"
				printf "$line\n\n"

				output_text="Getting Vimix GRUB theme with megatools"
				error_text="while getting Vimix GRUB theme megatools"

				status=1
				Exit_Status
			fi
		fi

		if [[ -z $(sudo egrep "^GRUB_THEME=.*" /etc/default/grub) ]]; then
			sudo runuser -l "root" -c 'printf "GRUB_THEME=\"/boot/grub/themes/grub-theme-vimix/Vimix/theme.txt\"" >> /etc/default/grub'
		else
			sudo sed -ie "s/GRUB_THEME=.*/GRUB_THEME=\"\/boot\/grub\/themes\/grub-theme-vimix\/Vimix\/theme.txt\"/" /etc/default/grub
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
			error_text="while rolling back to backup GRUB file"

			sudo grub-mkconfig -o /boot/grub/grub.cfg 2>> $errorpath >> $outputpath
			status=$?
			Exit_Status

		else
			output_text="GRUB changes"
			error_text="while applying changes to GRUB"
			status=0
			Exit_Status
		fi

	else
		error_text=", could not find GRUB's configuraion file"
		status=1
		Exit_Status
	fi

	## Ask the user if he wants to install refined boot manager
	if [[ $Distro_Val == arch || $Distro_Val == manjaro ]]; then
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

		## Install refind boot manager and configure it
		printf "$line\n"
		printf "Downloading refind boot manager...\n"
		printf "$line\n\n"

		output_text="Refind boot manager download"
		error_text="while downloading refind boot manager"

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
		error_text="while configuring refind with 'refind-install'"

		sudo refind-install 2>> $errorpath >> $outputpath
		status=$?
		Exit_Status

		printf "$line\n"
		printf "Configuring refind to be the default boot manager...\n"
		printf "$line\n\n"

		output_text="Setting refind to be the default boot manager"
		error_text="while setting refind to be the default boot manager"

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
			error_text="while cloning from git"

			## Get the build files for AUR
			sudo git clone https://github.com/EvanPurkhiser/rEFInd-minimal.git $refind_path/themes/rEFInd-minimal 2>> $errorpath >> $outputpath &
			BPID=$!
			Progress_Spinner
			wait $BPID
			status=$?
			Exit_Status

			sudo runuser -l "root" -c "printf \"include themes/rEFInd-minimal/theme.conf\" >> $refind_path/refind.conf"
		fi
	fi
}
