# ubuntu-install-script
To aid installing and setting up Ubuntu desktop

![intall video](https://raw.githubusercontent.com/appijumbo/ubuntu-install-script/master/gify_install_1200_3fps.gif)


This install script installs

* Traditional apts from the Ubuntu repository

* Flatpaks

* Snaps

* Others (these don't fit into the standard installation methods)

Installation by downloading the installation_script

```
cd ~/Downloads

wget https://raw.githubusercontent.com/appijumbo/ubuntu-install-script/master/install_script.sh 

sudo chmod +x installation_script.sh
```

This will pull in and create other scripts and files as necessary.

Before running it is worth choosing what you wish to install by first checking

* apt_flatpak_snap_install_list

* the 'Main' list at the bottom of the install_script

Comment out what is unrequired



## Code Description

#### apt_flatpak_snap_install_list script 
This features some 77 apps to istall with the given installation method apt, flatpack or snap eg.

```
chromium-browser:apt
org.audacityteam.Audacity:flatpak
"node --classic --channel=10/stable":snap
```

#### install_report.sh
This holds various functions including
* display and reporting methods
* installation app list methods
* firewall, node, google fonts and various 'oddball' app installation methods that don't use the default apt, snap or flatpack approaches
* setting up .bash_aliases aliases


#### install_script.sh
The main script 'imports' the above two scripts via wget from github, then using the list and methods describes installs apps and sets up printers etc, alerting the user as it progresses. Exactly what is installed caqn easily be controlled by commenting out the install command from the main list at the end of the installation-script and editing the apt_flatpak_snap_install_list script.
