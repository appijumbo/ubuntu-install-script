#!/bin/bash

echo -e "****************************************\n
This is intended for Ubuntu based distros\n
********************************************\n"

DISTRO_=$(cat /usr/lib/os-release | grep -E "^NAME=" | cut -d'=' -f2)
distro_type="${DISTRO_%\"}"         # remove leading quote
distro_type="${distro_type#\"}"     # remove trailing quote
echo -e "###### ---> This distro is $distro_type\n"

# Check system is up to date
sudo apt -y update && sudo apt -y upgrade

# Neon specific
if [ $distro_type = "KDE neon" ];then pkcon refresh && pkcon update;fi


# check if reebot is required
FILE="/var/run/reboot-required"    
if [ -f $FILE ]; then
   echo "Just updated and upgraded REEBOOT REQUIRED !" && exit 1
fi


#####################################################################
# Traditional apt installs
# ########################
# 
#
sudo apt -y update 
sudo apt install kate yakuake tomboy falkon python python3 filelight redshift speedtest-cli inxi htop latte-dock simple-scan kdevelop mysql-workbench xsane kio-extras ffmpegthumbs kffmpegthumbnailer gnome-xcf-thumbnailer libopenraw7 libopenrawgnome7 gnome-raw-thumbnailer -yy




# Ubuntu general
sudo apt -y update && sudo apt upgrade

# Neon specific
pkcon refresh && pkcon update

# check if reebot is required
FILE="/var/run/reboot-required"    
if [ -f $FILE ]; then
   echo "REEBOOT REQUIRED !" && exit 1
fi



#####################################################################
# Ensure Snap and Flatpak tools are installed
# ###########################################
#
#
if [$(which snap)!="/usr/bin/snap"]; then
    sudo apt update
    sudo apt -y install snapd
    sudo apt -y upgrade
fi

if [$(which flatpak)!="/usr/bin/flatpak"]; then
    sudo add-apt-repository ppa:alexlarsson/flatpak
    sudo apt -y update
    sudo apt -y install flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi



#####################################################################
# Install Snap's
# ##############
#
# Although we can install Snap eg apps 'foo --classic' 'bar --beta' 'woof' via  
# $ snap install foo bar woof
# we also want to setup removable media connection ie
# snap connect foo:removale-media; snap connect bar:removable-media; snap connect woof:removable-media
# hence the loop

SNAPS_=("thunderbird --beta" "telegram-desktop" grv eog vlc ffmpeg "mpv --beta" gimp darktable postgresql10 obs-studio handbrake-jz vidcutter youtube-dl-casept libreoffice chromium keepassxc mailspring konversation "slack --classic" "vscode --classic" "slack --classic" "node --channel=10/stable --classic" gravit-designer inkscape gnome-calendar gnome-calculator wire "shotcut --classic" )


for index in "${SNAPS_[@]}"
    do
        sudo snap install $index
        sudo snap connect $("$index" | cut -d' ' -f1):removable-media 2>/dev/null
    done



#####################################################################
# Install Flatpak's
# #################
# 
#
FLATPAKS=(com.abisource.AbiWord org.kde.kdenlive org.filezillaproject.Filezilla io.github.Hexchat de.haeckerfelix.gradio io.github.rinigus.OSMScoutServer com.calibre_ebook.calibre im.riot.Riot org.kde.krita io.github.wereturtle.ghostwriter org.gottcode.FocusWriter com.bitwarden.desktop)


for index in "${FLATPAKS[@]}"
    do
        flatpak install -y flathub $index
    done




#####################################################################
# ODD-BALL INSTALLATIONS
# ######################
#

# Install Graphical Uncomplicated Firewall
sudo apt install -y gufw
sudo ufw enable
sudo ufw allow 631/tcp
sudo ufw allow 1714:1764/udp
sudo ufw allow 1714:1764/tcp
sudo ufw reload

# MS Fonts
sudo apt install -y ttf-mscorefonts-installer

###############
# Google Fonts
###############

# Get http of all google fonts
# This was done manually by copying the download URL, via Falkon browser 
# having selected desired fonts at https://fonts.google.com/

readonly LOCAL_FONT_DIR="/usr/share/fonts/truetype"
readonly GOOGY_FONTS="/home/$USER/Downloads/googleFonts"
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

if [ $(which libreoffice) = "/usr/bin/libreoffice" ] 
    then
        sudo chmod 775 $LOCAL_FONT_DIR
        cp -r * $LOCAL_FONT_DIR
        sudo chmod 755 $LOCAL_FONT_DIR
        printf "copied fonts to $LOCAL_FONT_DIR\n"
fi


if [ $(which libreoffice) = "/snap/*" ] 
    then
        # cp -r /home/$USERS/Downloads/googleFonts/* /snap/libreoffice/share/fonts/truetype
        printf "WARNING : Code incomplete, need to put correct snap path in!\n"
fi

if [ $(which libreoffice) = "/.var/*" ] 
    then
        # cp -r /home/$USERS/Downloads/googleFonts/* /.var/app/*libreoffice/share/fonts/truetype
        printf "WARNING : Code incomplete, need to put correct Flatpak ./var path in!\n"
fi

popd
rm -r $GOOGY_FONTS


#--------------------------------------------------------------------------------------------
# ---> NOT USING THIS CODE BUT KEEP JUST IN CASE FOR FUTURE

# TO GET A COMPLETE .json list OF ALL GOOGLES FONTS
# -------------------------------------------------
# KEY=AIzaSyBlbHgSARiZxMS5qOu8RpNQwmpHaKquGTM  # FIrst get an API key and substitute in here
# OUTPUT_FILE="./static/googleFonts.json"
# mkdir -p ./static

# echo '[' > $OUTPUT_FILE

# curl -s "https://www.googleapis.com/webfonts/v1/webfonts?key=$KEY&sort=alpha" | \
#   sed -n 's/ *"family": "\(.*\)",/  "\1",/p' | \
#   sed '$s/\(.*\),/\1/' >> $OUTPUT_FILE

# echo ']' >> $OUTPUT_FILE
# #--------------------------------------------------------------------------------------------


# ######   MOST PEOPLE WONT NEED THIS!   ######
# ######  SPECIFIC PRINTER INSTALLATION  ######
# Add Printer and scanner drivers
# DCPJ-140W at the moment

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

wget -q https://download.brother.com/welcome/dlf006893/linux-brprinter-installer-2.2.1-1.gz
gunzip linux-brprinter-installer-2.2.1-1.gz
sudo bash linux-brprinter-installer-2.2.1-1 DCP-J140W 


# #####################################
# GIMP filters from Gimp 2.8 to 2.10
#
PLUGIN_2_8_PATH="/usr/lib/gimp/2.0/plug-ins"
if [ ! $(which gimp-plugin-registry) ]; then 
  sudo apt -y install gimp-plugin-registry # get gimp 2_8 and its plugins
fi

# Copy 2.8 plugins to Gimp 2.10 Snap
if [ -e "/snap/bin/gimp" ]; then
  PLUGIN_SNAP_PATH=$(find /home/$USER/snap plug-ins | grep GIMP/2.10/plug-ins | head -1)
  cp $PLUGIN_2_8_PATH/* $PLUGIN_SNAP_PATH
fi

# Copy 2.8 plugins to Gimp 2.10 Flatpak
if [ -e "/home/$USER/.var/app/org.gimp.GIMP" ]; then
  PLUGIN_FLATPAK_PATH=$(find /home/$USER/.var plug-ins | grep GIMP/2.10/plug-ins | head -1)
  cp $PLUGIN_2_8_PATH/* $PLUGIN_FLATPAK_PATH
fi

# remove old gimp 2_8
sudo apt -y remove gimp-plugin-registry



# #################################
# Install Calibre - 
# this is fallback should Flatpak install fail
#
# sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin


# #################################
# Install Etcher Appimages
#
# creat Appimages directory in /opt
sudo mkdir -p /opt/appimages
sudo chmod +x /opt/appimages

echo -e"\nInstalling Etcher Appimage 1.4.6\n"

pushd /opt/appimages
wget https://github.com/balena-io/etcher/releases/download/v1.4.6/etcher-electron-1.4.6-linux-x64.zip 
unzip etcher-electron-1.4.6-x86_64.AppImage
sudo chmod +x etcher-electron-1.4.6-x86_64.AppImage 
popd


# #################################
# Install Git-it
#
echo -e"\nInstalling Git-it\n"
sudo chmod 775 /usr/share/applications
sudo chmod 775 /usr/share/pixmaps
pushd /home/$USER/.local/share
wget https://github.com/jlord/git-it-electron/releases/download/4.4.0/Git-it-Linux-x64.zip
popd
pushd /usr/share/pixmaps
wget https://raw.githubusercontent.com/jlord/git-it-electron/master/assets/git-it.png
pushd
sudo chmod 755 /usr/share/applications
sudo chmod 755 /usr/share/pixmaps




# #################################
# Install GNU Ring
#  - assume Ubuntu amd64 'ring-all' version
echo -e"\nInstalling GNU Ring\n"
pushd /home/$USER/Downloads
wget https://dl.ring.cx/ubuntu_18.04/ring-all_amd64.deb
sudo dpkg -i ring-all_amd64.deb
popd


# #################################
# Setup 'updateme' alias

if [ -f /home/$USER/.bash_aliases ]; then
    cp /home/$USER/.bashrc /home/$USER/.bash_aliases
    else touch /home/$USER/.bash_aliases
fi

cat << _EOF_ >> /home/$USER/.bash_aliases
alias updateme='sudo apt update && sudo apt upgrade && sudo apt autoremove --purge && sudo snap refresh && flatpak update'
_EOF_



# #################################
# Install Abricotine markdown editor

sudo apt install gvfs-bin
pushd /home/$USER/Downloads
wget https://github.com/brrd/Abricotine/releases/download/0.6.0/Abricotine-0.6.0-ubuntu-debian-x64.deb
sudo dpkg -i Abricotine-0.6.0-ubuntu-debian-x64.deb
popd



#####################################################################
# Check external drives are mounted
# #################################
echo "Please ensured external drives are mounted?  press y when done"
read mount_prompt
if [$mount_prompt="y"]; then
        lsblk | grep $USER
        sudo chown -R ${USER}:${USER} /$(lsblk | grep $USER | cut -d'/' -f2,3,4)
        # lsblk | grep $USER | cut -d'/' -f1,2,3,4
        # └─sdb3   8:19   0   4.4T  0 part /media/tomdom/F_Drive
fi










#####################################################################
# SET AUTOSTARTS
# ######################
#
#
# Yakuake
# Set yakuake to autostart but closed
# Since Yakuake is a KDE app can use qcbus interface

# qdbus org.kde.yakuake /yakuake/window org.kde.yakuake.toggleWindowState


# Tomboy notes
# Set tomboynotes to autostart
# Tomboynotes isn't a KDE app, its mono so qdbus won't work


# But want Tomboy closed, i.e. no search
# by default the tomboy.desktop Exec has a search flag enabled ie. 
# Exec=tommboy --search
# because .desktop is sequectial(?) append with 'Exec=tomboy' to overide
TOMBOY_DESKTOP_CONFIG=~/.config/autostart/tomboy.desktop
echo "Exec=tomboy" >> $TOMBOY_DESKTOP_CONFIG


echo -e"\n--> DONE\n"
exit 0
