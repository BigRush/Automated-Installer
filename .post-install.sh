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
	sudo pacman -Syu --noconfirm 2>> $errorpath >> $outputpath &

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


	## Understanding the logic behind the code
	############################################################################
	## If I don't use this method of:
	## 1. Sending the process to the backgroud.
	## 2. Save its PID.
	## 3. Call Progress_Spinner function
	## 4. Executing wait command.
	## 5. Save the process exit status.
	## 6. Make sure the exit status is 0.
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

	sudo echo

	## Wait for 0.5 seconds for preventing unwanted errors
	# sleep 0.5

	printf "$line\n"
	printf "Installing Xorg...\n"
	printf "$line\n\n"

	output_text="Xorg installation"
	error_txt=" while installing Xorg"
	sudo pacman -S xorg xorg-xinit --needed --noconfirm 2>> $errorpath >> $outputpath &
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

		sudo echo

		sudo pacman -S xf86-video-intel --needed --noconfirm 2>> $errorpath >> $outputpath &
		Progress_Spinner
		BPID=$!
		wait $BPID
		status=$?
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
}

## Enable multilib repo
Pacman_Multilib () {

	## Validate the multilib section is in the place that we are going to replace

	## Set conf file under a variable
	pac_path=/etc/pacman.conf
	## If you can't find '#[multilib]'
	if ! [[ -z $(cat $pac_path |egrep "^\#\[multilib\]$") ]]; then
		## Set line counter to 1
		i=1
		## On each loop increase i value by 1 until 100
		for ((i; i<=100; i++)); do
			## Set the output of line "i" unser a variable
			pac_line=$(sed -n "$i"p $pac_path)
			## Check if "#[multilib]" is in that line,
			## then check if it's line 93 (because i know that the specific
			## "#[multilib]" should be in line 93 for the time i wrote this),
			## If it's on line 93 remove the first characters in lines 93 & 94
			## (which will be '#') to apply multilib repo, then break the loop,
			## If it's not on line 93 tell the user that file probably changed
			## and he should do it manually,
			## If it didn't find it at all then tell the user: multib failed
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
			elif [[ $i -eq 100 && ! "#[multilib]" == "$pac_line" ]];then
				printf "$line\n"
				printf "Adding multilib repo failed...\n"
				printf "$line\n\n"

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
		done

		printf "$line\n"
		printf "Syncing multilib...\n"
		printf "$line\n\n"

		output_text="Multilib sync"
		error_txt="while syncing multilib"

		sudo pacman -Sy 2>> $errorpath >> $outputpath &
		Progress_Spinner
		BPID=$!
		wait $BPID
		status=$?
		Exit_Status
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
		sudo runuser -l $orig_user -c "mkdir $user_path/Pictures"
	fi

	## If the background picture doesn't already exists, download it
	if ! [[ -e $user_path/Pictures/archbk.jpg ]]; then
		sudo runuser -l $orig_user -c "wget -O $user_path/Pictures/archbk.jpg http://getwallpapers.com/wallpaper/full/f/2/a/1056675-download-free-arch-linux-wallpaper-1920x1080.jpg" 2>> $errorpath >> $outputpath
		status=$?
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

	if [[ -z $(sudo grep "alias log=/var/log" /root/.bashrc) ]]; then
		sudo runuser -l "root" -c "printf \"alias log=/var/log\n\" >> /root/.bashrc"
	fi
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
	sudo printf "exec startkde\n" > $user_path/.xinitrc

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

## Configure ugly arch kde fonts
KDE_Font_Config () {

	sudo echo

	output_text="Font installation"
	error_txt="while installting fonts"

	## Install some nice fonts
	sudo pacman -S ttf-dejavu ttf-liberation noto-fonts --needed --noconfirm 2>> $errorpath >> $outputpath &
	BPID=$!
	Progress_Spinner
	wait $BPID
	status=$?
	Exit_Status

	## Enable font presets by creating symbolic links
	## It will disable embedded bitmap for all fonts
	## Enable sub-pixel RGB rendering
	## Enable the LCD filter which is designed to reduce colour fringing when subpixel rendering is used.
	sudo ln -sf /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
	sudo ln -sf /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
	sudo ln -sf /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d

	sudo sed -ie "s/\#export.*/export FREETYPE_PROPERTIES=\"truetype:interpreter-version=40\"/" /etc/profile.d/freetype2.sh

	CWD=$(pwd)
	printf '
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
	' > $CWD/tmp_font

	sudo runuser -l "root" -c "cat $CWD/tmp_font > /etc/fonts/local.conf"
	rm tmp_font
}

## Installs Deepin desktop environment
Deepin_Installation () {

	sudo echo

	## Add the option to start the deepin desktop environment with xinit
	sudo printf "exec startdde\n" > $user_path/.xinitrc

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
		aurman -S lightdm-webkit2-greeter lightdm-webkit-theme-litarvan --noconfirm 2>> $errorpath >> $outputpath &
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
		yay -S lightdm-webkit2-greeter lightdm-webkit-theme-litarvan --noconfirm 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status
	fi

	## Change LightDm's greeter and theme
	sudo sed -ie "s/\#greeter-session=.*/greeter-session=lightdm-webkit2-greeter/" $lightconf
	sudo sed -ie "s/webkit_theme.*/webkit_theme        = litarvan/" $lightwebconf

	## Disable deepin's login and log out sound
	mv $deepin_sound_path/desktop-login.ogg $deepin_sound_path/disable.login
	mv $deepin_sound_path/desktop-logout.ogg $deepin_sound_path/disable.logout

	## Copy the wallpaper to deepin's wallpaper folder
	sudo cp $user_path/Pictures/archbk.jpg /usr/share/wallpapers/deepin/
}

## Full system update for manjaro
Manjaro_Sys_Update () {

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
	sudo pacman -Syu --noconfirm 2>> $errorpath >> $outputpath &

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

	if [[ -z $(egrep "^GRUB_TIMEOUT=0$" /etc/default/grub) ]] && \
	[[ -z $(egrep "^GRUB_HIDDEN_TIMEOUT=1$" /etc/default/grub) ]] && \
	[[ -z $(egrep "^GRUB_HIDDEN_TIMEOUT_QUIET=true$" /etc/default/grub) ]]; then

		sudo sed -ie 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
		sudo sed -ie 's/#GRUB_HIDDEN_TIMEOUT=.*/GRUB_HIDDEN_TIMEOUT=1/' /etc/default/grub
		sudo sed -ie 's/#GRUB_HIDDEN_TIMEOUT_QUIET=.*/GRUB_HIDDEN_TIMEOUT_QUIET=true/' /etc/default/grub

		## apply changes to grub
		sudo grub-mkconfig -o /boot/grub/grub.cfg
	fi

	## Ask the user if he wants to install refined boot manager
	read -p "Would you like to install refined boot manager?[y/N]: " answer
	printf "\n"
	if [[ -z $answer ]]; then
		Main_Menu
	elif [[ $answer =~ [y|Y] || $answer =~ [y|Y]es ]]; then
		:
	elif [[ $answer =~ [n|N] || $answer =~ [n|N]o ]]; then
		printf "$line\n"
		printf "Exiting...\n"
		printf "$line\n\n"
		Main_Menu
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
	printf "Configuring refind with 'mkrlconf'...\n"
	printf "$line\n\n"

	output_text="'mkrlconf'"
	error_txt="while configuring refind with 'mkrlconf'"

	sudo mkrlconf 2>> $errorpath >> $outputpath
	status=$?
	Exit_Status
}
