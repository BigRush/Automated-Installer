#!/usr/bin/env bash


################################################################################
# Author :	BigRush
#
# License :	GPLv3
#
# Description :	Update the system
#				Install video card driver for intel
#				Install Desktop environment and a display manager
#				Add personal aliases and a nice wallpaper
# Version :	1.0.0
################################################################################

## ToDo	####################################
# Add xfce4 DE
# Add verbos option
############################################

####  Functions  ###############################################################

## Configure arch after a clean install with KDE desktop environment
Arch_Config () {

	## Propmet the user with what the script will now do (with cosmetics :D)
	printf "$line\n"
	printf "Updating the system...\n"
	printf "$line\n\n"

	## Will be used in Exit_Status function to output text for the user
	output_text="Update"
	error_txt="while updating"

	## Update the system, send stdout, sterr to log files
	## and move the process to the background for the Progress_Spinner function.
	pacman -Syu --noconfirm 2>> $errorpath >> $outputpath &

	## Save the background PID to a variable for later use with wait command
	BPID=$!

	## Wait until the process is done to get its exit status.
	wait $BPID

	## Save the exxit status of last command to a Varibale
	status=$?

	## Call Progress_Spinner function
	Progress_Spinner

	## Call Exit_Status function
	Exit_Status


	## Understanding the logic behind the code
	############################################################################
	## If I don't use this method of:
	## 1. Sending the process to the backgroud.
	## 2. Save its PID.
	## 3. Executing wait command.
	## 4. Save the process exit status.
	## 5. Make sure the exit status is 0.
	##
	## I will not be able to:
	## 1. Run the Progress_Spinner function because it
	##    depends on the backgroung PID of the last executed command.
	##
	## 2. Make sure the command executed successfully or not, because when you
	##    you compare the exit status of the process that has been sent to the
	##    the background, you will be getting the exit status of a different
	##    command, in this case I got the exit status of the declaration of
	##    "error_txt" variable (before implementing this method of wait command,
	##    it can be seen on early commits).
	##
	## So now by waiting until the process is done, I can safely check the exit
	## status, because the wait command will return an exit status according to
	## the success of the process its given.
	############################################################################

	## Wait for 0.5 seconds for preventing unwanted errors
	# sleep 0.5

	printf "$line\n"
	printf "Installing Xorg...\n"
	printf "$line\n\n"

	output_text="Xorg installation"
	error_txt=" while installing Xorg"
	pacman -S xorg xorg-xinit --needed --noconfirm 2>> $errorpath >> $outputpath &
	BPID=$!
	Progress_Spinner 
	wait $BPID
	status=$?
	Exit_Status

	# sleep 0.5

	## Make sure there is an Intel video card and install its drivers.
	## If no Intel video card detected,
	## tell the user and continue the script
	lspci |grep VGA |grep Intel
	if [[ $? -eq 0 ]]; then
		printf "$line\n"
		printf "Installing video drivers...\n"
		printf "$line\n\n"

		output_text="Video card drivers installationl"
		error_txt="while installing video card's drivers"

		pacman -S xf86-video-intel --needed --noconfirm 2>> $errorpath >> $outputpath &
		BPID=$!
		wait $BPID
		status=$?
		Progress_Spinner
		Exit_Status
		# sleep 0.5
	else
		printf "$line\n"
		printf "Did not detect Intel video card,\n"
		printf "please install video card drivers by yourself later.\n"
		printf "Continuing with the script...\n"
		printf "$line\n\n"
		# sleep 2
	fi

	## Call Pacman_Multilib function
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

## Add aliases and download a nice wallpaper
Alias_and_Wallpaper () {

	printf "$line\n"
	printf "Downloading background picture...\n"
	printf "$line\n\n"

	output_text="Background picture download"
	error_txt="while downloading background picture"

	## If the directory doesn't exits, create it
	if ! [[ -d $user_path/Pictures ]]; then
		runuser -l $orig_user -c "mkdir $user_path/Pictures"
	fi

	## If the background picture doesn't already exists, download it
	if ! [[ -e $user_path/Pictures/archbk.jpg ]]; then
		runuser -l $orig_user -c "wget -O $user_path/Pictures/archbk.jpg http://getwallpapers.com/wallpaper/full/f/2/a/1056675-download-free-arch-linux-wallpaper-1920x1080.jpg" 2>> $errorpath >> $outputpath
		Exit_Status
	fi

	## customize shell, check if the config exists, if not, add it to .bashrc
	if [[ -z $(grep "alias ll='ls -l'" $user_path/.bashrc) ]]; then
		printf "alias ll='ls -l'\n" >> $user_path/.bashrc
	fi

	if [[ -z $(grep "alias lh='ls -lh'" $user_path/.bashrc) ]]; then
		printf "alias lh='ls -lh'\n" >> $user_path/.bashrc
	fi

	if [[ -z $(grep "alias la='ls -la'" $user_path/.bashrc) ]]; then
		printf "alias la='ls -la'\n" >> $user_path/.bashrc
	fi

	if [[ -z $(grep "alias log=/var/log" $user_path/.bashrc) ]]; then
		printf "alias log=/var/log\n" >> $user_path/.bashrc
	fi

	if [[ -z $(grep "screenfetch -E" $user_path/.bashrc) ]]; then
		printf "screenfetch -E\n" >> $user_path/.bashrc
	fi

	if ! [[ -e /root/.bashrc ]]; then
		touch /root/.bashrc
	fi

	if [[ -z $(grep "alias ll='ls -l'" /root/.bashrc) ]]; then
		printf "alias ll='ls -l'\n" >> /root/.bashrc
	fi

	if [[ -z $(grep "alias lh='ls -lh'" /root/.bashrc) ]]; then
		printf "alias lh='ls -lh'\n" >> /root/.bashrc
	fi

	if [[ -z $(grep "alias la ='ls -la'" /root/.bashrc) ]]; then
		printf "alias la='ls -la'\n" >> /root/.bashrc
	fi

	if [[ -z $(grep "alias log=/var/log" $user_path/.bashrc) ]]; then
		printf "alias log=/var/log\n" >> /root/.bashrc
	fi
}

## Menu, to choose which desktop environment to install
DE_Menu () {

	desk_env=(Plasma Deepin xfce4 exit)
	local PS3="Please choose a desktop environment to install: "
	select opt in ${desk_env[@]} ; do
		case $opt in
			Plasma)
				KDE_Installation
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
			Exit)
				printf "$line\n"
				printf "Exiting, have a nice day!"
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

	## Add the option to start the deepin desktop environment with xinit
	printf "exec startkde\n" > $user_path/.xinitrc

	printf "$line\n"
	printf "Installing Plasma desktop environment...\n"
	printf "$line\n\n"

	output_text="Plasma desktop installation"
	error_txt="while installing plasma desktop"

	##	Install plasma desktop environment
	pacman -S plasma --needed --noconfirm 2>> $errorpath >> $outputpath &
	BPID=$!
	wait $BPID
	status=$?
	Exit_Status
	Progress_Spinner

	displaymgr=(LightDM SDDM Continue Exit)
	local PS3="Please choose the desired display manager: "
	select opt in ${scripts[@]} ; do
	    case $opt in
	        LightDm)
				LightDM_Installation
	            break
	            ;;
	        SDDM)
				SDDM_Installation
	            break
	            ;;
			Continue)
				printf "$line\n"
				printf "Continuing"
				printf "$line\n"
				break
				;;
	        Exit)
	            printf "$line\n"
	            printf "Exiting, have a nice day!"
	            printf "$line\n"
	            exit 0
				;;
	        *)
	        printf "Invalid option\n"
	        ;;
	    esac
	done

	## Call KDE_Font_Config function to fix the fonts
	KDE_Font_Config
}

## Configure ugly arch kde fonts
KDE_Font_Config () {
	output_text="Font installation"
	error_txt="while installting fonts"

	## Install some nice fonts
	pacman -S ttf-dejavu ttf-liberation noto-fonts --needed --noconfirm 2>> $errorpath >> $outputpath &
	BPID=$!
	wait $BPID
	status=$?
	Exit_Status
	Progress_Spinner

	## Enable font presets by creating symbolic links
	## It will disable embedded bitmap for all fonts
	## Enable sub-pixel RGB rendering
	## Enable the LCD filter which is designed to reduce colour fringing when subpixel rendering is used.
	ln -sf /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
	ln -sf /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
	ln -sf /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d

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

## Installs Deepin desktop environment
Deepin_Installation () {

	## Add the option to start the deepin desktop environment with xinit
	printf "exec startdde\n" > $user_path/.xinitrc

	printf "$line\n"
	printf "Installing Deepin desktop environment...\n"
	printf "$line\n\n"

	output_text="Deepin desktop installation"
	error_txt="while installing Deepin desktop"

	##	Install deepin desktop environment
	pacman -S deepin --needed --noconfirm 2>> $errorpath >>$outputpath &
	BPID=$!
	wait $BPID
	status=$?
	Exit_Status
	Progress_Spinner

	## Call the LightDM_Installation function
	LightDM_Installation
}

## Install SDDM display manager
SDDM_Installation () {

	printf "$line\n"
	printf "Installing sddm...\n"
	printf "$line\n\n"

	output_text="sddm installation"
	error_txt="while installing sddm"

	## Install sddm
	pacman -S sddm --needed --noconfirm 2>> $errorpath >> $outputpath &
	BPID=$!
	wait $BPID
	status=$?
	Exit_Status
	Progress_Spinner

	## Enable and start the sddm service
	printf "$line\n"
	printf "Enabling sddm service...\n"
	printf "$line\n\n"

	output_text="Enable sddm service"
	error_txt="while enabling sddm service"

	systemctl enable sddm 2>> $errorpath >> $outputpath
	Exit_Status
}

## Installs LightDM display manager and configures it
LightDM_Installation () {

	printf "$line\n"
	printf "Installing Lightdm...\n"
	printf "$line\n\n"

	output_text="Lightdm installation"
	error_txt="while installing Lightdm"

	## Install lightdm and webkit greeter for a nice theme
	pacman -S lightdm lightdm-webkit2-greeter lightdm-webkit-theme-litarvan --needed --noconfirm 2>> $errorpath >> $outputpath &
	BPID=$!
	wait $BPID
	status=$?
	Exit_Status
	Progress_Spinner

	## Enable and start the sddm service
	printf "$line\n"
	printf "Enabling Lightdm service...\n"
	printf "$line\n\n"

	output_text="Enable Lightdm service"
	error_txt="while enabling Lightdm service"

	systemctl enable lightdm 2>> $errorpath >> $outputpath
	Exit_Status

	sed -ie "s/\#greeter-session=.*/greeter-session=lightdm-webkit2-greeter/" $lightconf
}

## Full system update for manjaro
Manjaro_Sys_Update () {

	## Propmet the user with what the script will now do (with cosmetics :D)
	printf "$line\n"
	printf "Updating the system...\n"
	printf "$line\n\n"

	## Will be used in Exit_Status function to output text for the user
	output_text="Update"
	error_txt="while updating"

	## Update the system, send stdout, sterr to log files
	## and move the process to the background for the Progress_Spinner function.
	pacman -Syu --noconfirm 2>> $errorpath >> $outputpath &

	## Save the background PID to a variable for later use with wait command
	BPID=$!

	## Wait until the process is done to get its exit status.
	wait $BPID

	## Save the exxit status of last command to a Varibale
	status=$?

	## Call Exit_Status function
	Exit_Status

	## Call Progress_Spinner function
	Progress_Spinner
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

	if [[ -z $(egrep "^GRUB_TIMEOUT=0$" /etc/default/grub) ]] && \
	[[ -z $(egrep "^GRUB_HIDDEN_TIMEOUT=1$" /etc/default/grub) ]] && \
	[[ -z $(egrep "^GRUB_HIDDEN_TIMEOUT_QUIET=true$" /etc/default/grub) ]]; then

		sed -ie 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
		sed -ie 's/#GRUB_HIDDEN_TIMEOUT=.*/GRUB_HIDDEN_TIMEOUT=1/' /etc/default/grub
		sed -ie 's/#GRUB_HIDDEN_TIMEOUT_QUIET=.*/GRUB_HIDDEN_TIMEOUT_QUIET=true/' /etc/default/grub

		## apply changes to grub
		grub-mkconfig -o /boot/grub/grub.cfg

		## Ask the user if he wants to install refined boot manager
		read -p "Would you like to install refined boot manager?[y/n]: " answer
		printf "\n"
		if [[ -z $answer ]]; then
			:
		elif [[ $answer =~ [y|Y] || $answer =~ [y|Y]es ]]; then
			:
		elif [[ $answer =~ [n|N] || $answer =~ [n|N]o ]]; then
			printf "$line\n"
			printf "Exiting...\n"
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

		$PACSTALL refind-efi 2>> $errorpath >> $outputpath &
		status=$?
		Progress_Spinner
		Exit_Status

		printf "$line\n"
		printf "Configuring refind with 'refind-install'...\n"
		printf "$line\n\n"

		output_text="'refind-install'"
		error_txt="while configuring refind with 'refind-install'"

		refind-install 2>> $errorpath >> $outputpath
		Exit_Status

		printf "$line\n"
		printf "Configuring refind with 'mkrlconf'...\n"
		printf "$line\n\n"

		output_text="'mkrlconf'"
		error_txt="while configuring refind with 'mkrlconf'"

		mkrlconf 2>> $errorpath >> $outputpath
		Exit_Status
	fi
}

<<COM
## Call Functions
Post_Main () {
	Log_And_Variables
	Root_Check
	Distro_Check
	if [[ $Distro_Val == arch ]]; then
		Arch_Config
		sleep 0.5
		Arch_Font_Config
	else
		printf "$line\n"
		printf "This script does not support your distribution\n"
		printf "$line\n\n"
	fi

}
COM
