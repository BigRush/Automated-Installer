#!/usr/bin/env bash


#######################################################################################
# Author	: BigRush
#
#License	: GPLv3
#
# Description	: Post installation script.
#
# Version	: 1.0.0
#######################################################################################

####  Functions  ###############################################################

Root_Check () {		## Checks if the script runs as root
	if ! [[ $EUID -eq 0 ]]; then
		printf "$line\n"
		printf "The script needs to run with root privileges\n"
		printf "$line\n"
		exit 1
	fi
}

Log_And_Variables () {

	####  Varibale	####
	line="\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-"
	logfolder="/var/log/post_install"
	errorpath=$logfolder/error.log
	outputpath=$logfolder/output.log
	orig_user=$SUDO_USER
	user_path=/home/$orig_user
	####  Varibale	####

	## Check if log folder exits, if not - create it
	if ! [[ -e $logfolder ]]; then
		mkdir -p $logfolder
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

Arch_Config () {		## Configure arch after a clean install with KDE desktop environment
	## Propmet the user with what the script will now do (with cosmetics :D)
	printf "$line\n"
	printf "Updating the system...\n"
	printf "$line\n\n"

	## Will be used in Exit_Status function to output text for the user
	output_text="Update"
	error_txt="while updating"

	## Update the system, send stdout and sterr to log files
	pacman -Syu --noconfirm 2>> $errorpath >> $outputpath
	Exit_Status

	printf "$line\n"
	printf "Installing Xorg...\n"
	printf "$line\n\n"

	output_text="Xorg installation"
	error_txt=" while installing Xorg"
	pacman -S xorg xorg-xinit wget --noconfirm --needed 2>> $errorpath >> $outputpath --noconfirm
	Exit_Status

	## Make sure there is an Intel video card and install its drivers
	## If no Intel video card detected then ask the user if he wants to continue with the script
	lspci |grep VGA |grep Intel
	if [[ $? -eq 0 ]]; then
		printf "$line\n"
		printf "Installing video drivers...\n"
		printf "$line\n\n"

		output_text="Video card drivers installationl"
		error_txt="while installing video card's drivers"

		pacman -S xf86-video-intel --noconfirm --needed 2>> $errorpath >> $outputpath
		Exit_Status
	else
		printf "$line\n"
		printf "Did not detect Intel video card,\nplease install video card drivers by yourself later.\nContinuing with the script...\n"
		printf "$line\n\n"
		sleep 2
	fi

	printf "$line\n"
	printf "Downloading background picture...\n"
	printf "$line\n\n"

	output_text="Background picture download"
	error_txt="Downloading background picture"

	## Download background picture
	if ! [[ -e $user_path/Pictures ]]; then
		mkdir $user_path/Pictures
		wget -O $user_path/Pictures/archbk.jpg http://getwallpapers.com/wallpaper/full/f/2/a/1056675-download-free-arch-linux-wallpaper-1920x1080.jpg 2>> $errorpath >> $outputpath
		Exit_Status
	fi

	## customize shell, check if the config exists, if not - add it to .bashrc
	if ! [[ -z $(grep "alias ll='ls -l'" $user_path/.bashrc) ]]; then
		printf "alias ll='ls -l'\n" >> $user_path/.bashrc
	fi

	if ! [[ -z $(grep "alias lh='ls -lh'" $user_path/.bashrc) ]]; then
		printf "alias lh='ls -lh'\n" >> $user_path/.bashrc
	fi

	if ! [[ -z $(grep "alias la='ls -la'" $user_path/.bashrc) ]]; then
		printf "alias la='ls -la'\n" >> $user_path/.bashrc
	fi

	if ! [[ -z $(grep "alias screenfetch -E" $user_path/.bashrc) ]]; then
		printf "screenfetch -E" >> $user_path/.bashrc
	fi

	if ! [[ -z $(grep "alias ll='ls -l'" /root/.bashrc) ]]; then
		printf "alias ll='ls -l'\n" >> /root/.bashrc
	fi

	if ! [[ -z $(grep "alias lh='ls -lh'" /root/.bashrc) ]]; then
		printf "alias lh='ls -lh'\n" >> /root/.bashrc
	fi

	if ! [[ -z $(grep "alias la ='ls -la'" /root/.bashrc) ]]; then
		printf "alias la='ls -la'\n" >> /root/.bashrc
	fi

	desk_env=(Plasma Deepin xfce4)
	local PS3="Please choose a desktop environment to install: "
	select opt in ${desk_env[@]} ; do
		case $opt in
			Plasma)
				KDE_Installation
				break
				;;
			Deepin)
				printf "Not avaliable at the moment, coming soon...\n"
				;;
			xfce4)
				printf "Not avaliable at the moment, coming soon...\n"
				;;
			*)
			printf "Invalid option\n"
			;;
		esac
	done


	## Call Pacaur_Install function to install pacaur
	echo $(pwd)
	runuser -l $orig_user -c "bash $(pwd)/pacaur-install.sh"
	## Call Arch_Font_Config function to configure the ugly stock font that arch KDE comes with
	Arch_Font_Config
}

KDE_Installation () {		## install KDE desktop environment
	## Set kde to start on startup
	printf "exec startkde\n" > $user_path/.xinitrc

	printf "$line\n"
	printf "Installing plasma desktop environment...\n"
	printf "$line\n\n"

	output_text="Plasma desktop installation"
	error_txt="while installing plasma desktop"

	##	install plasma desktop environment
	pacman -S plasma --needed 2>> $errorpath
	Exit_Status

	printf "$line\n"
	printf "Installing sddm...\n"
	printf "$line\n\n"

	output_text="sddm installation"
	error_txt="while installing sddm"

	## install sddm
	pacman -S sddm --needed --noconfirm 2>> $errorpath >> $outputpath
	Exit_Status

	## enable and start the sddm service
	printf "$line\n"
	printf "Enabling sddm service...\n"
	printf "$line\n\n"

	output_text="Enable sddm service"
	error_txt="while enabling sddm service"

	systemctl enable sddm 2>> $errorpath >> $outputpath
	Exit_Status

}

#KDE_Config () {}

Arch_Font_Config () {		## Configure ugly arch kde fonts
	output_text="Font installation"
	error_txt="while installting fonts"

	## Install some nice fonts
	pacman -S ttf-dejavu ttf-liberation noto-fonts --noconfirm --needed 2>> $errorpath >> $outputpath
	Exit_Status

	## Enable font presets by creating symbolic links
	## It will disable embedded bitmap for all fonts
	## Enable sub-pixel RGB rendering
	## Enable the LCD filter which is designed to reduce colour fringing when subpixel rendering is used.
	ln -s /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
	ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
	ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d

	sed -ie "s/\#export.*/export FREETYPE_PROPERTIES=\"truetype:interpreter-version=40\"/" /etc/profile.d/freetype2.sh

	printf "
	<?xml version="1.0"?>
	<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
	<fontconfig>
	    <match>
	        <edit mode="prepend" name="family"><string>Noto Sans</string></edit>
	    </match>
	    <match target="pattern">
	        <test qual="any" name="family"><string>serif</string></test>
	        <edit name="family" mode="assign" binding="same"><string>Noto Serif</string></edit>
	    </match>
	    <match target="pattern">
	        <test qual="any" name="family"><string>sans-serif</string></test>
	        <edit name="family" mode="assign" binding="same"><string>Noto Sans</string></edit>
	    </match>
	    <match target="pattern">
	        <test qual="any" name="family"><string>monospace</string></test>
	        <edit name="family" mode="assign" binding="same"><string>Noto Mono</string></edit>
	    </match>
	</fontconfig>
	" > /etc/fonts/local.conf
}

Manjaro_Sys_Update () {
	## update the system, dump errors to /var/log/post_install_error.log and output to /var/log/post_install_output.log
	pacman -Syu 2>> $errorpath >> $outputpath
	printf "$line\n"
	printf "System update complete\n"
	printf "$line\n\n"
}

xfce_theme () {		## Set desktop theme
	wget -O /home/tom/Pictures/archbk.jpg http://getwallpapers.com/wallpaper/full/f/2/a/1056675-download-free-arch-linux-wallpaper-1920x1080.jpg 2>> $errorpath >> $outputpath
	xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s "/home/tom/Pictures/archbk.jpg" 2>> $errorpath >> $outputpath
	xfconf-query --channel "xfce4-panel" --property '/panels/panel-1/size' --type int --set 49
	xfconf-query --channel "xfce4-panel" --property '/panels/panel-1/background-alpha' --type int --set 0
	xfconf-query --channel 'xfce4-keyboard-shortcuts' --property '/commands/custom/<Super>t' --type string --set xfce4-terminal --create
	xfconf-query --channel 'xfce4-keyboard-shortcuts' --property '/commands/custom/grave' --type string --set "xfce4-terminal --drop-down" --create
}

Grub_Config () {		## Config the grub background and fast boot
	sed -ie 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
	sed -ie 's/#GRUB_HIDDEN_TIMEOUT=.*/GRUB_HIDDEN_TIMEOUT=1/' /etc/default/grub
	sed -ie 's/#GRUB_HIDDEN_TIMEOUT_QUIET=.*/GRUB_HIDDEN_TIMEOUT_QUIET=true/' /etc/default/grub

	## apply changes to grub
	grub-mkconfig -o /boot/grub/grub.cfg

}

App_Req () {		## Application's pre-install requirements
	gpg --recv-keys 0FC3042E345AD05D 2>> $errorpath >> $outputpath		## discord key
	return 0
}

Pacaur_applications () {		## Applications i want to install with pacaur
		if [[ $Distro_Val == manjaro || $Distro_Val == arch  ]] ;then
				app=(ncdu git steam-native-runtime openssh vlc atom discord screenfetch)
				for i in ${app[*]}; do
					printf "$line\n"
					printf "Installing $i"
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
		printf "Installing $i"
		printf "$line\n\n"
		output_text="$i installation"
		error_txt="while installing $i"
		pacaur -S $i --noconfirm --needed --noedit
	done
	modprobe vboxdrv
	gpasswd -a tom vboxusers
}

Post_Main () { ## Call Functions
	Log_And_Variables
	Root_Check
	Distro_Check
	if [[ $Distro_Val == arch ]]; then
		Arch_Config
	else
		printf "$line\n"
		printf "This script does not support your distribution\n"
		printf "$line\n\n"
	fi

}
Post_Main
