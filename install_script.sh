#!/bin/bash

# Add report functions
. install_report.sh



clear

printf "******************************************************\n"
printf "Installation Script\n"
printf "******************************************************\n"


# ON STARTUP ALWAYS DO
######################################################## 

# Define Global variables

APPIMAGES_DIR=/opt/appimages
FLATPAK_DIR=/var/lib/flatpak/app

FLATPAK_REBOOT=/var/run/flatpak-requires-reboot  
REBOOT=/var/run/reboot-required

SNAP_LO_FONT_DIR=/snap/libreoffice/current/usr/share/fonts
SHARE_FONT_DIR=/usr/share/fonts
# see FHS (https://bit.ly/2AVScrv) 


UPDATE_UBUNTU=sudo apt -qq -y update && sudo apt -qq -y upgrade
# appears no quiet available flag for pkcon so dev/null it
UPDATE_NEON=sudo pkcon -y refresh 1>/dev/null && sudo pkcon -y update 1>/dev/null 

CURRENT_USER="$(who | cut -d' ' -f1)"  
# if installed with root privileges ie $sudo ./install_Script then $USER is root
printf "\nCurrent user is ----> '$CURRENT_USER'\n"

distro_name=""



get_distro_name(){

    #   Instead of grepping via the output from a pipe ie
    #   cat /usr/lib/os-release | grep -E "^NAME=" etc..
    #   'grep' against a pattern and a location, hence
    
    distro_n="$(grep ^NAME /etc/os-release | cut -d'=' -f2)"
    distro_name_a="${distro_n%\"}"     # remove leading quote
    distro_name="${distro_name_a#\"}"     # remove trailing quote
    
     # returned via global variable 'distro_name'
}




# Reset Flatpak reeboot signal
if [ -f $FLATPAK_REBOOT ] ; then sudo rm $FLATPAK_REBOOT ; fi # stdrd reboot is auto reset



# What distro is in use?
check_if_distro_is_ubuntu(){
if [ ! $(which apt) ]
    then
        clear
        printf "******************************************************\n"
        printf "This is intended for Ubuntu based distros\n"
        printf "no apt present so assume this is not an Ubuntu base\n"
        printf "will exit in a few seconds......\n"
        printf "******************************************************\n"
        sleep 6
        exit 2
fi
}




# Check system is up to date
update_n_refresh(){
    printf "******************************************************\n"
    printf "*\n* Checking up-to-date\n"
    
    get_distro_name
    
        if [ "$distro_type" = "KDE neon" ]
            then $UPDATE_NEON
            else $UPDATE_UBUNTU
        fi

    # check if reboot is required
        if [ -f $REBOOT ]
            then 
                printf "**********************************************"
                printf "Just updated and upgraded REEBOOT REQUIRED !\n"
                report_restart
                exit 1
        fi
}





#  sudo apt install -y python python3 curl git ttf-mscorefonts-installer gufw kate yakuake tomboy virtualbox virtualbox-guest-additions-iso virtualbox-ext-pack falkon filelight redshift speedtest-cli inxi htop latte-dock simple-scan kdevelop mysql-workbench xsane kio-extras ffmpegthumbs kffmpegthumbnailer gnome-xcf-thumbnailer libopenraw7 libopenrawgnome7 gnome-raw-thumbnailer zsh fonts-powerline imagemagick chromium-browser


apt_installs(){

    # check if reboot is required
   
    APT_LIST=(python curl chromium-browser)
        if [ -f $REBOOT ]
            then
                printf "**********************************************"
                printf "Just updated and upgraded REEBOOT REQUIRED !\n" 
                exit 1
            else
                for index in "${APT_LIST[@]}"
                    do
                        sudo apt -y install $index
                        if [ $(which $index) ]; then echo "$index   Apt" >> report_list; fi

                    done
        fi
    
}




# SNAPS_=("thunderbird --beta" "telegram-desktop" "node --classic --channel=10/stable" grv eog vlc ffmpeg "mpv --beta" darktable postgresql10 obs-studio handbrake-jz vidcutter libreoffice chromium keepassxc mailspring konversation "slack --classic" "vscode --classic" "slack --classic" insomnia postman gravit-designer inkscape gnome-calendar gnome-calculator wire "shotcut --classic" )


install_many_snaps(){
# Install Snap's

# Note: Although we can install Snap eg apps 'foo --classic' 'bar --beta'etc i.e.
#           $ snap install foo bar
#       but we also want to setup removable media connection ie
#           $ snap connect foo:removale-media; snap connect bar:removable-media
#       hence the loop
    printf "**************************************************\n"
    printf "Installing Snaps\n"
    SNAPS_=("node --classic --channel=10/stable" libreoffice chromium )

    for index in "${SNAPS_[@]}"
        do
            sudo snap install $index
            sudo snap connect $("$index" | cut -d' ' -f1):removable-media 2>/dev/null
                # Note when testing this 'removable-media' it may fail in a VM
                # since if confined and unable to access external media,
                # ie a 'permission denied' errors
                
                # Also all errors are by deafult sent to dev/null because
                # they are likley to be 'plugin snap name empty' errors
                # due to the snap eg. 'node' not having an external-media connection.
            
        done
            
    printf "Snap Apps Installed\n"
    snap list
    printf "\n**************************************************\n"
}


# FLATPAKS=(com.abisource.AbiWord org.audacityteam.Audacity org.kde.kdenlive org.gimp.GIMP org.filezillaproject.Filezilla io.github.Hexchat de.haeckerfelix.gradio io.github.rinigus.OSMScoutServer com.calibre_ebook.calibre im.riot.Riot org.kde.krita io.github.wereturtle.ghostwriter org.gottcode.FocusWriter com.bitwarden.desktop org.gnome.Boxes)


install_many_flatpaks(){
# Install Flatpak's
    printf "**************************************************\n"
    printf "Installing Flatpaks\n"
    FLATPAKS=(com.abisource.AbiWord org.gimp.GIMP)


    for index in "${FLATPAKS[@]}"
        do
            flatpak install -y flathub $index
        done
        
    printf "Flatpak Apps Installed\n"
    flatpak list
    printf "\n**************************************************\n"
}


# Setup Gufw
setup_firewall(){


    
    if [ ! $(which gufw) ]
        then 
            sudo apt -y install gufw
            gufw_installed="yes"
    fi
    
    check_ufw_ports_set
    

}



install_node_npm_nvm(){
    printf "**************************************************\n"
    printf "Check node installation is working\n"
    
    # The NodeSource-managed Node.js snap contains the Node.js runtime, along the two most widely-used package managers, npm and Yarn.
    
    # install node via snap for channel selected
    if [ ! $(which node) ]
        then 
            snap install "node --classic --channel=10/stable"
            curl -sL https://deb.nodesource.com/test | bash -
            node_installed="yes"
            npm_installed="yes"
            yarn_installed="yes"
    fi
    
    # Install Node Version Manager (NVM) 
    # - but not sure if required with Snap based node control
    # wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
    
    # Snaps are delivered via "channels", for Node.js, the channel names are the major-version number of Node.js eg.
    #   $ sudo snap install node --classic --channel=8
     
    # To switch to a new channel  --->  $ sudo snap refresh node --channel=10

    # Not for production deployments; use .deb or .rpm
    
    # To test an installation is working
    
}


# Install Google Fonts
get_and_install_google_fonts(){

    check_google_fonts
    
    if [ $google_fonts_installed = "no" ] 
    
        then
            printf "**************************************************\n"
            printf "Downloading and installing Google Fonts"
            
            # Get http of all google fonts
            # This was done manually by copying the download URL, via Falkon browser 
            # having selected desired fonts at https://fonts.google.com/
        
            GOOGY_FONTS=/home/$CURRENT_USER/Downloads/googleFonts
            mkdir -p $GOOGY_FONTS 
            mkdir -p $GOOGY_FONTS/google_font_downloads #create a google font download directory


            # For reasons unkown, wget wouldn't download all the fonts in one single URL
            # Hence the $wget -i witha a URL list created via a heredoc

            cat << __EOF__ > $GOOGY_FONTS/google_font_list.txt
https://fonts.google.com/download?family=ABeeZee|Abel|Abril+Fatface|Aclonica|Acme|Actor|Adamina|Advent+Pro|Aldrich|Alegreya|Alegreya+Sans|Alegreya+Sans+SC|Alex+Brush|Alfa+Slab+One
https://fonts.google.com/download?family=Alice|Allerta|Allura|Amatic+SC|Amiri|Anaheim|Antic+Slab|Anton|Arapey|Arbutus+Slab|Architects+Daughter|Archivo|Archivo+Black|Archivo+Narrow|Aref+Ruqaa|Arimo|Armata|Arvo|Asap|Assistant|Audiowide|Bad+Script|Bai+Jamjuree|Baloo|Baloo+Tamma|Bangers|Barlow|Barlow+Condensed|Barlow+Semi+Condensed
https://fonts.google.com/download?family=Basic|BenchNine|Bevan|Bitter|Black+Han+Sans|Black+Ops+One|Boogaloo|Bowlby+One+SC|Bree+Serif|Cabin|Cabin+Condensed|Cabin+Sketch|Cairo|Candal|Cantarell|Cantata+One|Cardo|Carme|Carter+One|Catamaran|Caveat|Caveat+Brush|Ceviche+One|Chakra+Petch|Chivo|Cinzel|Coda|Comfortaa|Coming+Soon|Concert+One|Cookie|Copse|Cormorant|Cormorant+Garamond|Cormorant+Upright
https://fonts.google.com/download?family=Courgette|Cousine|Covered+By+Your+Grace|Crete+Round|Crimson+Text|Cuprum|Damion|Dancing+Script|Dangrek|Days+One|Didact+Gothic|Domine|Dosis|EB+Garamond
https://fonts.google.com/download?family=Economica|El+Messiri|Electrolize|Encode+Sans+Condensed|Enriqueta|Exo+2|Fahkwang|Fauna+One|Fira+Sans|Fira+Sans+Condensed|Fira+Sans+Extra+Condensed
https://fonts.google.com/download?family=Fjalla+One|Forum|Francois+One|Frank+Ruhl+Libre|Freckle+Face|Fredericka+the+Great|Fredoka+One|Fugaz+One|Gentium+Basic|Gentium+Book+Basic|Glegoo|Gochi+Hand|Gothic+A1
https://fonts.google.com/download?family=Grand+Hotel|Great+Vibes|Gudea|Halant|Hammersmith+One|Handlee|Heebo|Hind|Hind+Guntur|Hind+Madurai|Hind+Siliguri|Hind+Vadodara|Homemade+Apple|IBM+Plex+Mono|IBM+Plex+Sans
https://fonts.google.com/download?family=Inconsolata|Indie+Flower|Istok+Web|Italianno|Jaldi|Josefin+Sans|Josefin+Slab|Julius+Sans+One|Jura|Just+Another+Hand|K2D|Kalam|Kameron|Kanit
https://fonts.google.com/download?family=Karla|Karma|Kaushan+Script|Khand|Khula|Knewave|KoHo|Kodchasan|Kreon|Krub|Kumar+One+Outline|Lalezar|Lato|Leckerli+One|Libre+Barcode+39+Extended|Libre+Baskerville|Libre+Franklin
https://fonts.google.com/download?family=Lobster|Lobster+Two|Lora|Luckiest+Guy|Lusitana|Lustria|M+PLUS+1p
https://fonts.google.com/download?family=Magra|Mali|Marcellus|Marck+Script|Marmelad|Martel|Maven+Pro|Merienda|Merriweather|Merriweather+Sans|Molengo|Monda|Monoton|Montserrat|Montserrat+Alternates
https://fonts.google.com/download?family=Mr+Dafoe|Mukta|Muli|Nanum+Gothic
https://fonts.google.com/download?family=Nanum+Gothic+Coding|Nanum+Myeongjo
https://fonts.google.com/download?family=Neuton|News+Cycle|Niconne|Niramit|Nobile|Nothing+You+Could+Do|Noticia+Text|Noto+Sans|Noto+Sans+JP
https://fonts.google.com/download?family=Noto+Sans+KR
https://fonts.google.com/download?family=Noto+Sans+SC
https://fonts.google.com/download?family=Noto+Sans+TC
https://fonts.google.com/download?family=Noto+Serif|Noto+Serif+JP
https://fonts.google.com/download?family=Nunito|Nunito+Sans|Old+Standard+TT|Oleo+Script|Open+Sans|Open+Sans+Condensed:300|Oranienbaum|Orbitron|Oswald|Overlock|Overpass|Oxygen|PT+Mono|PT+Sans
https://fonts.google.com/download?family=PT+Sans+Caption|PT+Sans+Narrow|PT+Serif|PT+Serif+Caption|Pacifico|Palanquin|Parisienne|Passion+One|Pathway+Gothic+One|Patrick+Hand|Patua+One|Paytone+One|Permanent+Marker|Philosopher|Pinyon+Script|Play|Playball|Playfair+Display|Playfair+Display+SC
https://fonts.google.com/download?family=Poiret+One|Pontano+Sans|Poppins|Pragati+Narrow|Prata|Press+Start+2P|Pridi|Prompt|Prosto+One|Quantico|Quattrocento|Quattrocento+Sans|Questrial|Quicksand|Rajdhani
https://fonts.google.com/download?family=Raleway|Rambla|Rancho|Ranga|Rasa|Reenie+Beanie|Righteous|Roboto|Roboto+Condensed|Roboto+Mono|Roboto+Slab|Rochester|Rock+Salt|Rokkitt
https://fonts.google.com/download?family=Ropa+Sans|Rubik|Ruda|Russo+One|Sacramento|Saira|Saira+Extra+Condensed|Saira+Semi+Condensed|Sanchez|Sarala|Satisfy|Sawarabi+Gothic|Sawarabi+Mincho|Scada|Scheherazade|Sedgwick+Ave|Shadows+Into+Light|Shadows+Into+Light+Two|Shrikhand|Sigmar+One|Signika+Negative|Sintony|Slabo+27px|Sorts+Mill+Goudy|Source+Code+Pro
https://fonts.google.com/download?family=Source+Sans+Pro|Source+Serif+Pro|Space+Mono|Special+Elite|Spinnaker|Squada+One|Srisakdi|Sunflower:300|Syncopate|Tajawal|Tangerine|Taviraj
https://fonts.google.com/download?family=Teko|Telex|Text+Me+One|Tinos|Titan+One|Titillium+Web|Ubuntu|Ubuntu+Condensed|Ubuntu+Mono|Ultra|Underdog|Unica+One|Unlock|Unna|VT323|Varela|Varela+Round|Vidaloka|Viga|Volkhov|Vollkorn
https://fonts.google.com/download?family=Warnes|Work+Sans|Yanone+Kaffeesatz|Yantramanav|Yellowtail|Yrsa|Zilla+Slab
__EOF__



        # Download zipped fonts and unzip
        # To parse a file that contains a list of URLs to fetch each one 
        # $ wget -i url_list.txt
        # file should consist of a series of URLs, one per line
        # Note: OFL.txt is just liscence info

            pushd $GOOGY_FONTS/google_font_downloads
            wget -q -i $GOOGY_FONTS/google_font_list.txt
            for i in *; do mv $i `echo $i | cut -d'=' -f2`.zip; done  # clean up zip filenames
            for i in *; do unzip $i; `if [ -f OFL.txt ]; then rm OFL.txt; fi`; done  # remove OFL.txt, causes errors
            rm *.zip


        # Copy fonts to correct directories

            # create a FHS stadard font directory if dosn't exist (though this is unlikley)
            if [ ! -d $SHARE_FONT_DIR/truetype ] ; then mkdir -p $SHARE_FONT_DIR/truetype ; fi
    
            sudo cp -r $GOOGY_FONTS/google_font_downloads/* $SHARE_FONT_DIR/truetype
            printf "copied fonts to $SHARE_FONT_DIR/truetype\n"

            popd
            rm -r $GOOGY_FONTS
    
            # assume if font 'Zilla_Slab' exists (as last to be downloaded)
            # then Google Fonts are installed
            
            google_fonts_installed="yes"
            
    fi
    
}






# GIMP filters from Gimp 2.8 to 2.10

install_gimp_filters(){

check_gimp_filters_installed

    if [ $gimp_filters_installed = "no" ]
        then

        printf "**************************************************\n"
        printf "Install Gimp 2.8 filter to Gimp 2.10\n"
        PLUGIN_2_8_PATH="/usr/lib/gimp/2.0/plug-ins"
        if [ ! $(which gimp-plugin-registry) ]; then 
        sudo apt -y install gimp-plugin-registry # get gimp 2_8 and its plugins
        fi

        # Simplistically we could copy 2.8 plugins to Gimp 2.10 Snap ie.
        # if [ -e "/snap/bin/gimp" ]; then
        # PLUGIN_SNAP_PATH=/snap/gimp/current/usr/lib/gimp/2.0/plug-ins
        # sudo cp $PLUGIN_2_8_PATH/* $PLUGIN_SNAP_PATH
        # fi

        # BUT this won't work because it's impossible to change the current of a snap without rebuilding a snap.
    
        # Copy 2.8 plugins to Gimp 2.10 Flatpak
        PLUGIN_FLATPAK_PATH=/var/lib/flatpak/app/org.gimp.GIMP/current/active/files/lib/gimp/2.0/plug-ins
        if [ -e "/home/$CURRENT_USER/.var/app/org.gimp.GIMP" ]; then
        sudo chown $CURRENT_USER:$CURRENT_USER -R $PLUGIN_FLATPAK_PATH
        cp -r $PLUGIN_2_8_PATH/* $PLUGIN_FLATPAK_PATH
        fi

        # remove old gimp 2_8
        sudo apt -y purge gimp
        
        gimp_filters_installed="yes"
        
    fi
}



# Install Calibre - this is fallback should Flatpak install fail
# sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin



# create Appimages directory in /opt
create_appimages_dir(){

    check_appimages_installed
    
    if [ $appimages_installed = "no" ]
        then
            printf "**************************************************\n"
            printf "Create Appimage Directory\n"
            sudo mkdir -p $APPIMAGES_DIR
            sudo chmod +xw $APPIMAGES_DIR
            
            appimages_installed="yes"
    fi
}



# Install Etcher via Appimages
install_etcher(){

    check_etcher_installed
    
    if [ $etcher_installed = "no" ]
    then
    
        printf "**************************************************\n"
        printf "Installing Etcher Appimage 1.4.6\n"
    
        etcher_version="etcher-electron-1.4.6-linux-x64.zip"
        etcher_url="https://github.com/balena-io/etcher/releases/download/v1.4.6/"
    
        sudo wget -O $APPIMAGES_DIR/$etcher_version $etcher_url/$etcher_version
        sudo mkdir -p $APPIMAGES_DIR/Etcher/
        sudo unzip -qq -o $APPIMAGES_DIR/$etcher_version -d $APPIMAGES_DIR/Etcher/
        sudo chmod 774 -R $APPIMAGES_DIR/Etcher/*.AppImage
        sudo rm $APPIMAGES_DIR/$etcher_version
        
        etcher_installed="yes"
        
    fi
}




# Install Git-it
install_git-it(){

    check_gitit_installed
    
    if [ $gitit_installed = "no" ]
    then
        printf "**************************************************\n"
        printf "Download and Install Git-it git help tool\n"
    
        usr_share=/usr/share
        usr_applications_dir=/usr/share/applications
        pixmaps_dir=/usr/share/pixmaps
    
        git_it_url="https://github.com/jlord/git-it-electron/releases/download/4.4.0"
        git_it_file="Git-it-Linux-x64.zip"
    
        git_it_png_url="https://raw.githubusercontent.com/jlord/git-it-electron/master/assets/"
    

        sudo chown $CURRENT_USER:$CURRENT_USER -R /usr/share
        sudo wget -O $usr_share/$git_it_file $git_it_url/$git_it_file
        unzip -qq -o $usr_share/$git_it_file -d $usr_share
        sudo chown -R $CURRENT_USER:$CURRENT_USER $usr_share/Git-it-Linux-x64
        sudo rm $usr_share/$git_it_file
        sudo chown $CURRENT_USER:$CURRENT_USER -R /usr/share/applications
    
        cat << _EOF_ > $usr_share/applications/Git-it.desktop
[Desktop Entry]
Name=Gitit
Type=Application
Comment=Guide for Git use
Categories=Git;Github
Exec=/usr/share/Git-it-linux-x64/Git-it %F
Icon=/usr/share/Git-it-linux-x64/icons/git-it-s128.png
MimeType=text/html;
Keywords=Git;Github
_EOF_
    
    
        mkdir -p $usr_share/Git-it-Linux-x64/icons
        sudo wget -O $usr_share/Git-it-Linux-x64/icons/git-it.png $git_it_png_url/git-it.png
        sudo convert $usr_share/Git-it-Linux-x64/icons/git-it.png -resize x128 $usr_share/Git-it-Linux-x64/icons/git-it-s128.png
        
        gitit_installed="yes"
        
    fi

}



# Install GNU Ring - assume Ubuntu amd64 'ring-all' version
install_ring(){

    check_ring_installed
    
    if [ $ring_installed = "no" ]
        then
            printf "**************************************************\n"
            printf "Download and Install GNU Ring\n"
    
            ring_url="https://dl.ring.cx/ubuntu_18.04"
            ring_file="ring-all_amd64.deb"
    
            wget -O /home/$CURRENT_USER/Downloads/$ring_file $ring_url/$ring_file
            sudo dpkg -i /home/$CURRENT_USER/Downloads/$ring_file
            
            ring_installed="yes"
    fi
}





install_abricotine(){

    check_abricotine_installed
    
    if [ $abricotine_installed = "no" ]
        then
            printf "**************************************************\n"
            printf "Install Abricotine markdown editor\n"
    
            abricotine_file="Abricotine-0.6.0-ubuntu-debian-x64.deb"
            abricotine_url="https://github.com/brrd/Abricotine/releases/download/0.6.0"
            downloads_dir=/home/$CURRENT_USER/Downloads
    
    
            # Ensure dependancies are installed
            sudo apt -qq install -y git gconf2 gconf-service python gvfs-bin
    
            wget -O $downloads_dir/$abricotine_file $abricotine_url/$abricotine_file
            sudo dpkg -i $downloads_dir/$abricotine_file
            sudo rm -r $downloads_dir/$abricotine_file
            
            abricotine_installed="yes"
    fi
}




install_youtube-dl(){

    check_youtube_dl_installed
    
    if [ $youtube_dl_installed = "no" ]
        then
            printf "**************************************************\n"
            printf "Install Youtube-dl\n"
    
            # Prefered over an apt install from Ubuntu as the Ubuntu repo is not up-to-date
            sudo wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/bin/youtube-dl
            sudo chmod a+rx /usr/bin/youtube-dl

            # Also added "sudo youtube-dl -U" to alias 'updateme'
            
            youtube_dl_installed="yes"
    fi
}



install_oh_my_zsh(){

    check_oh_my_zsh_installed
    
    if [ $zsh_installed = "no" ]
        then
            printf "**************************************************\n"
            printf "Install oh-my-zsh shell\n"
            # ensure zsh and power fonts (required for some zsh themes) is installed
            if [ ! $(which zsh) ]; then 
            sudo apt -y install zsh fonts-powerline
            fi
            sudo sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
    
            ZSH_CUSTOM_THEMES=/home/$CURRENT_USER/.oh-my-zsh/custom/themes/
            cp /home/$CURRENT_USER/.zshrc /home/$CURRENT_USER/.zshrc_backup
    
            # install oh-my-zsh 'Node' theme
            wget -O $ZSH_CUSTOM_THEMES/node.zsh-theme https://raw.githubusercontent.com/skuridin/oh-my-zsh-node-theme/master/node.zsh-theme
  
            # install oh-my-zsh 'Space ship' theme
            git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM_THEMES/spaceship-prompt"
            ln -s "$ZSH_CUSTOM_THEMES/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM_THEMES/spaceship.zsh-theme"
    
            # Set zsh theme to spaceship
            sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="spaceship"/g' /home/$CURRENT_USER/.zshrc
    
            # Alternativley set theme to node.zsh
            # sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="node.zsh-theme"/g' /home/$USER/.zshrc
    
            # make sure bash shell is the default though
            chsh --shell /bin/bash $CURRENT_USER
            
            zsh_installed="yes"
            
    fi
            
}






backup_bashrc(){
   cp /home/$CURRENT_USER/.bashrc /home/$CURRENT_USER/.bashrc_backup
}





# Setup 'updateme' alias
setup_updateme_alias(){

    check_bash_aliases_installed
    
    if [ $bash_aliases_installed = "no" ]
    
     then

        printf "**************************************************\n"
        printf "Setup aliases\n"
        if [ -f /home/$CURRENT_USER/.bash_aliases ]; then
            cp /home/$CURRENT_USER/.bash_aliases /home/$CURRENT_USER/.bash_aliases_backup
            else touch /home/$CURRENT_USER/.bash_aliases
        fi

        cat << _EOF_ >> /home/$CURRENT_USER/.bash_aliases
alias cdF_="cd /media/tomdom/F_Drive"
alias cdcode="cd '/media/tomdom/F_Drive/My Desktop/CODE'"
alias cdlinux="cd '/media/tomdom/F_Drive/My Documents/HOBBIES & INTERESTS/LINUX'"
alias cddrama="cd '/media/tomdom/F_Drive/My Videos/Drama'"
alias updateme="sudo apt update && sudo apt upgrade && sudo snap refresh && flatpak update && sudo youtube-dl -U"
_EOF_

    bash_aliases_installed="yes"
    
    fi
}






# PRINTER INSTALLATION - Brother DCPJ-140W 
add_printer_driver(){

    check_printer_installed
    
    if [ $printer_installed = "no" ]
    
        then

        printf "Printer and Scanner DCP-J140W Installation Questions and Answers\n"
        printf "****************************************************************\n"
        printf "You are going to install following packages.. --> y\n"
        printf "Brother License Agreement --> y\n"
        printf "Do you agree? --> y\n"
        printf "Will you specify the Device URI? --> y\n"
        printf "select the number of destination Device URI. --> [choose 10  or  12]\n"
        printf "Test Print? [y/N] --> choose y or n\n"
        printf "Do you agree? --> y\n"
        printf "Do you agree? --> y\n"
        printf "enter IP address --> [see printer menu eg. 192.123.456.789]\n"

        linux_brprinter_gz="linux-brprinter-installer-2.2.1-1.gz"
        linux_brprinter_file="linux-brprinter-installer-2.2.1-1"
        linux_brprinter_url="https://download.brother.com/welcome/dlf006893"
    
        downloads_dir=/home/$CURRENT_USER/Downloads
    
        wget -qO $downloads_dir/$linux_brprinter_gz $linux_brprinter_url/$linux_brprinter_gz
        gunzip $downloads_dir/$linux_brprinter_gz
        sudo bash $downloads_dir/$linux_brprinter_file DCP-J140W
        rm $downloads_dir/$linux_brprinter_gz
        rm $downloads_dir/$linux_brprinter_file
        
        printer_installed="yes"
        
    fi
}







# Check external drives are owned by the current owner and group
setup_external_hd_ownership(){

    echo "Please ensured external drives are mounted?  enter y when done"
    read mount_prompt
    if [ $mount_prompt = "y" ]; then
            lsblk | grep $CURRENT_USER
            sudo chown -R $CURRENT_USER:$CURRENT_USER /$(lsblk | grep $CURRENT_USER | cut -d'/' -f2,3,4)
            # lsblk | grep $USER | cut -d'/' -f1,2,3,4
            # └─sdb3   8:19   0   4.4T  0 part /media/tom/F_Drive
    fi
}





config_autostarts(){

    if [ ! -f config_autostarts ]
        then
    
        # Yakuake
        # Set yakuake to autostart but closed
        # Since Yakuake is a KDE app can use qcbus interface

        qdbus org.kde.yakuake /yakuake/window org.kde.yakuake.toggleWindowState

        # Tomboy notes
        #   Set tomboynotes to autostart
        #   Tomboynotes isn't a KDE app, its mono so qdbus won't work
        #   But want Tomboy closed, i.e. no search
        #   by default the tomboy.desktop Exec has a search flag enabled ie. 
        #   Exec=tommboy --search
        #   because .desktop is sequectial(?) append with 'Exec=tomboy' to overide

        TOMBOY_DESKTOP_CONFIG=/home/$CURRENT_USER/.config/autostart/tomboy.desktop
        echo "Exec=tomboy" >> $TOMBOY_DESKTOP_CONFIG
        printf "\n--> DONE\n"
        
        touch config_autostarts_done  
        # create a file as a general marker that autostarts are installed
        
    fi
}






make_report(){
    report_distro_name
    report_snap_list
    report_flatpak_list
    report_gufw
    report_node
    report_google_fonts
    report_gimp
    report_appimages
    report_gitit
    report_ring
    report_abricotine
    report_youtube-dl
    report_oh-my-zsh
    report_aliases
    report_printer
    report_autostarts
}




#######################################################################
############################   MAIN   #################################


check_if_distro_is_ubuntu
get_distro_name
update_n_refresh
apt_installs
update_n_refresh
setup_firewall
check_snapd_flatpak_installed
install_many_snaps
install_many_flatpaks
install_node_npm_nvm
create_appimages_dir
install_etcher
install_git-it
install_abricotine
install_youtube-dl
install_gimp_filters
get_and_install_google_fonts
install_oh_my_zsh
backup_bashrc
setup_updateme_alias
add_printer_driver
setup_external_hd_ownership
config_autostarts

clear_lists
make_report
display_report


exit 0

