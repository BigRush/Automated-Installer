# Automated-Installer
Configures and installs application and services 
for my needs on Debian, Ubuntu, and Arch distributions

# The Script Will Do The Following:

## Arch Specifically:

* Install Aurman or Yay AUR helper by user's choice (default = yay)

* Install xorg and video drivers for Intel

* Enable Pacman multilib

* Install desktop environment of choice: Plasma or Deepin 

* Install desktop manager of choice: LightDM or SDDM.

* Configure Plasma's fonts to make them look better

### Notes

* If Deepin was chosen as desktop environment then only LightDM will be installed

* I disabled some of Deepin login and logout sounds because I find them annoying.
They can be re-enabled by doing the following commands:
```sh
$ sudo mv /usr/share/sounds/deepin/stereo/disable.login /usr/share/sounds/deepin/stereo/desktop-login.ogg

$ sudo mv /usr/share/sounds/deepin/stereo/disable.logout /usr/share/sounds/deepin/stereo/desktop-logout.ogg
```

## Install Themes:

* [Chili](https://store.kde.org/p/1214121/) login theme (for Plasma only)

* [Bibata](https://www.opendesktop.org/p/1197198/) cursor pack

* [Zafiro](https://www.gnome-look.org/p/1209330/) icons

* [La-Capitaine](https://www.gnome-look.org/p/1148695/) icons

* [Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) icons

* [Shadow](https://www.gnome-look.org/p/1012532/) icons

* [Arc](https://github.com/horst3180/arc-theme) theme

* [Adapta](https://github.com/adapta-project/adapta-gtk-theme) theme

* [Foggy](https://www.gnome-look.org/p/1201603) theme for plank

* [Transparent](https://www.gnome-look.org/p/1214417) theme for plank

* [Zero](https://www.gnome-look.org/p/1212812) theme for plank

## Boot Manager:

* Configure GRUB for faster boot time

* Change GRUB theme to [Vimix](https://www.gnome-look.org/p/1009236)

* Install Refind (For Arch only)

* Change Refind theme to [rEFInd-minimal](https://github.com/EvanPurkhiser/rEFInd-minimal.git) (For Arch only)

## Install Applications:

* Discord

* Ncdu

* Guake

* TeamViewer

* VLC

* Atom

* ScreenFetch

* Etcher

* Speedtest-cli

* Megatools

* FireFox (For Arch only)

* Openssh (For Arch only)

## Install Virtualization & Container Environment:

* VirtualBox 

* Docker

* Vagrant

### Note

* All other packages the script installs are dependencies

# Installing The Script:

Change to your user's home directory
so you will clone the project there later (you can choose any other loacation) 

```sh
$ cd ~
```

Clone the project:

```sh
$ git clone https://github.com/BigRush/Automated-Installer.git
```



# Running The Script

Change to the project's directory:

```sh
$ cd Automated-Installer
```

Run the script:


```sh
$ bash Main.sh
```
# Usage

 ### Flags with arguments:

 -a <argument>          &nbsp;&nbsp;&nbsp;&nbsp;Choose which AUR helper you would
                        like to use [ 'aurman' or 'yay' ]
                        ('yay' is the default option if '-a' is not triggered)

 -d <argument>          &nbsp;&nbsp;&nbsp;&nbsp;Choose which display manager
                        you would tlike to use [ 'SDDM' or 'LightDM' ]

 -e <argument>          &nbsp;&nbsp;&nbsp;&nbsp;Choose which desktop environment
                        you would tlike to use [ 'Plasma' or 'Deepin' ]
 
 -t <arguments>		       &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Choose which theme you would like to install,
                     			arguments should be separated by spaces.
      		               	<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Possible themes:
                     			['bibata' 'zafiro' 'capitaine' 'shadow' 'papirus' 'arc' 'adapta']


 ### Flags without arguments:

 -D                     &nbsp;&nbsp;&nbsp;&nbsp;Install Docker

 -h                     &nbsp;&nbsp;&nbsp;&nbsp;Show help

 -H                     &nbsp;&nbsp;&nbsp;&nbsp;Install Vagrant

 -O                     &nbsp;&nbsp;&nbsp;&nbsp;Install VirtualBox


# Logs
All log files are under hidden directory: `$HOME/.Automated-Installer-Log` in the user's home directory : 
 * error.log - All **stderr** from the commands of the script will be there
 
 * output.log - All **stdout** from the commands of the script will be there




## Built With

* [Atom](https://atom.io/) - The text editor used


## Authors

* **Tom H.** - [BigRush](https://github.com/bigrush)


## License

This project is licensed under the GPLv3 License - see the [LICENSE](https://github.com/BigRush/Automated-Installer/blob/master/LICENSE) file for details


## Acknowledgments

Thanks to [silent-mobius](https://github.com/silent-mobius) for giving the idea and mentoring me through the process.
