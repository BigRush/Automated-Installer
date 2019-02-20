#!/usr/bin/env bash


################################################################################
# Author :	BigRush
#
# License :	GPLv3
#
# Description :	Update the system
#
#
# Version :	1.0.0
################################################################################

## Install aurman manually
Aurman_Install () {

	## Propmet the user with what the script will now do (with cosmetics :D)
	printf "$line\n"
	printf "Updating the system...\n"
	printf "$line\n\n"

	## Will be used in Exit_Status function to output text for the user
	output_text="Update"
	error_text="while updating"

	## Update the system, send stdout and sterr to log files
	sudo pacman -Syu 2>> $errorpath >> $outputpath &
	status=$?
	Progress_Spinner
	Exit_Status

	## Create a tmp-working-dir if it does't exits and navigate into it
	if ! [[ -e $user_path/Automated-Installer-Log/aurman_install_tmp ]]; then
		mkdir -p $user_path/Automated-Installer-Log/aurman_install_tmp
	fi

	pushd . 2>> $errorpath >> $outputpath
	cd $user_path/Automated-Installer-Log/aurman_install_tmp

	## Check if "aurman" exists, if not, install "aurman" from AUR
	if [[ -z $(command -v aurman) ]]; then
		output_text="Getting aurman with curl from AUR"
		error_text="while getting aurman with curl from AUR"

		## Get the build files for AUR
    	curl -s -L -O https://aur.archlinux.org/cgit/aur.git/snapshot/aurman.tar.gz 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

		tar -xf aurman.tar.gz 2>> $errorpath >> $outputpath

		cd aurman

		output_text="Aurman building"
		error_text="while building aurman"

		## Add gpg key
		gpg --recv-keys 465022E743D71E39 2>> $errorpath >> $outputpath

		## Compile
		makepkg -si PKGBUILD --noconfirm --needed 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status
	fi

	## Clean up on aisle four
	popd 2>> $errorpath >> $outputpath
	rm -rf $user_path/aurman_install_tmp
}

## Install yay manually
Yay_Install () {

	## Propmet the user with what the script will now do (with cosmetics :D)
	printf "$line\n"
	printf "Updating the system...\n"
	printf "$line\n\n"

	## Will be used in Exit_Status function to output text for the user
	output_text="Update"
	error_text="while updating"

	## Update the system, send stdout and sterr to log files
	sudo pacman -Syu 2>> $errorpath >> $outputpath &
	status=$?
	Progress_Spinner
	Exit_Status

	## Create a tmp-working-dir if it does't exits and navigate into it
	if ! [[ -e $user_path/Automated-Installer-Log/yay_install_tmp ]]; then
		mkdir -p $user_path/Automated-Installer-Log/yay_install_tmp
	fi

	pushd . 2>> $errorpath >> $outputpath
	cd $user_path/Automated-Installer-Log/yay_install_tmp

	## Check if "yay" exists, if not, install "yay" from AUR
	if ! [[ -n "$(pacman -Qs yay)" ]]; then
		output_text="getting yay with curl from AUR"
		error_text="while getting yay with curl from AUR"

		## Get the build files for AUR
    	curl -s -L -O https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status

		tar -xf yay.tar.gz 2>> $errorpath >> $outputpath

		cd yay

		output_text="yay building"
		error_text="while building yay"

		## Add gpg key
		# gpg --recv-keys 465022E743D71E39 2>> $errorpath >> $outputpath

		## Compile
		makepkg -si PKGBUILD --noconfirm --needed 2>> $errorpath >> $outputpath &
		BPID=$!
		Progress_Spinner
		wait $BPID
		status=$?
		Exit_Status
	fi

	## Clean up on aisle four
	popd 2>> $errorpath >> $outputpath
	rm -rf $user_path/yay_install_tmp
}

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
	error_text="while updating"

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
	##    "error_text" variable (before implementing this method of wait command,
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
	error_text=" while installing Xorg"
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
	lspci |grep VGA |grep Intel &> /dev/null
	if [[ $? -eq 0 ]]; then
		printf "$line\n"
		printf "Installing video drivers...\n"
		printf "$line\n\n"

		output_text="Video card drivers installationl"
		error_text="while installing video card's drivers"

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
		error_text="while syncing multilib"

		sudo pacman -Sy 2>> $errorpath >> $outputpath &
		Progress_Spinner
		BPID=$!
		wait $BPID
		status=$?
		Exit_Status
	fi
}


## Configure ugly arch kde fonts
KDE_Font_Config () {

	sudo echo

	output_text="Font installation"
	error_text="while installting fonts"

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
	' > $(pwd)/tmp_font

	sudo runuser -l "root" -c "cat $(pwd)/tmp_font > /etc/fonts/local.conf"
	rm tmp_font
}
