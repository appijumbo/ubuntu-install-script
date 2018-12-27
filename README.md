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
