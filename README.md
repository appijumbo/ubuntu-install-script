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

./installation_script.sh

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
The main script 'imports' the above two scripts via wget from github, then using the list and methods describes installs apps and sets up printers etc, alerting the user as it progresses. Exactly what is installed can easily be controlled by commenting out the install command from the main list at the end of the installation-script and editing the apt_flatpak_snap_install_list script.


#### Future - A web GUI version ie. Node + Bash
Rather than having to edit a list of apps, an alternative approach is to create a GUI that provides checkboxes for the apps and contains the URL to the info on the app. This list/ database could be on a server so it could be up-dated, containing updated installation scripts for each app to be assembled into a complete downloadable script. Initially however this could just be a simple localhost server just allowing the basic apt_flatpak_snap_install_list to be edited. On installation the bash could ensure node and browser is installed first then open the browser eg. via bash eg 

``` 
    xdg-open 'http://localhost:3000' 

```

and via say the node file system (fs), the desired apps to be installed would be checked and when ready a new 'apt_flatpak_snap_install_list script' file would be ceated using FS. 

Need to use objects and JSON to write a file in CSV format, to be read by the bash. Currently the list uses ' : ' as delimeter not ' , ' but this can be easily changed. Possibly could use npm module csv-writer or fast-csv.

Alternativley might be better long term to rewrite the bash to use a JSON format not CSV

```
    // get a JSON of the apt_flatpak_snap_install_list  list
    
    fs.writeFile('/foo/bar/apt_flatpak_snap_install_list.txt', list, (err) => {
        // If an error occurred, show it and return
        if(err) return console.error(` Error --> ${err}`);
        // Successfully created file
        })
```

Once the file has written successfully, Node could change the status of a file (bash uses files as signals) and then the rest of the installation script should be run. Need to figure out how to get node and bash to 'drive' each other ie execute scripts from each other.





