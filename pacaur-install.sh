#!/bin/bash

Non_Root_Check () {		## Make sure the script doesn't run as root
	if [[ $EUID -eq 0 ]]; then
		printf "$line\n"
		printf "The script can't run as root\n"
		printf "$line\n"
		exit 1
	fi
}

Pacaur_Install () {

	## Call Non_Root_Check function
	Non_Root_Check

	## Create a tmp-working-dir if it does't exits and navigate into it
	if ! [[ -e $user_pathpacaur_install ]]; then
		runuser -l $orig_user -c "mkdir -p $user_path/pacaur_install"
	fi

	cd $user_path/pacaur_install
	gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53

	printf "$line\n"
	printf "Installing pacaur dependencies...\n"
	printf "$line\n\n"

	output_text="base-devel packages installation"
	error_txt="while installing base-devel packages"

	## If didn't install the "base-devel" group and git
	pacman -S binutils make gcc fakeroot pkg-config git --noconfirm --needed 2>> $errorpath >> $outputpath
	Exit_Status

	output_text="base-devel pacaur dependencies installation"
	error_txt="while installing pacaur dependencies"

	## Install pacaur dependencies from arch repos
	pacman -S expac yajl git --noconfirm --needed 2>> $errorpath >> $outputpath
	Exit_Status

	## Install "cower" from AUR
	if ! [[ -n "$(pacman -Qs cower)" ]]; then
		output_text="cowers installation"
		error_txt="while installing cower"
    	curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cower # 2>> $errorpath >> $outputpath
		Exit_Status
		makepkg PKGBUILD --install --needed # 2>> $errorpath >> $outputpath
		Exit_Status
	fi

	## Install "pacaur" from AUR
	if ! [[ -n "$(pacman -Qs pacaur)" ]]; then
		output_text="pacaur installation"
		error_txt="while installing pacaur"
    	curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=pacaur # 2>> $errorpath >> $outputpath
		Exit_Status
		makepkg PKGBUILD --install --needed # 2>> $errorpath >> $outputpath
		Exit_Status
	fi

	## Clean up on aisle four
	cd ~
	rm -r /tmp/pacaur_install
}


Pac_Main () {	## Call functions and source functions from post-install.sh
	source ./post-install.sh
	Pacaur_Install
	Pacaur_applications
	Vbox_Installation
}
Pac_Main
