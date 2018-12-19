#!/bin/bash

CURRENT_USER="$(who | cut -d' ' -f1)"  
distro_name="UNKNOWN"
ufw_ports_set="no"
gufw_installed="no"
node_installed="no"
npm_installed="no"
yarn_installed="no"
google_fonts_installed="no"
gimp_filters_installed="no"
appimages_installed="no"
etcher_installed="no"
gitit_installed="no"
ring_installed="no"
abricotine_installed="no"
youtube_dl_installed="no"
zsh_installed="no"
oh_my_zsh_installed="no"
bash_aliases_installed="no"
printer_installed="no"


# This contains the functions to provide a report for the installation script

if [ ! -f report_list ]; then touch report_list; fi


clear_lists(){
    rm alias_list_raw flat_list_raw snap_list_raw
}


print_line(){
    printf "********************************************* \n" >> report_list
}


report_restart(){
    print_line
    printf "*******************  RESTARTED ************** \n" >> report_list
}



print_distro_name(){
    printf "This distro is $distro_name \n"
}



report_distro_name(){
    print_line
    printf "This distro is $distro_name \n" >> report_list
}




# Ensure Snap and Flatpak tools are installed
install_snapd_flatpak(){

    if [ ! $(which snap) ]; then
        sudo apt update
        sudo apt -y install snapd
        print_line
        printf "Snap installed \n" >> report_list
    fi

    if [ ! $(which flatpak) ]; then
        sudo add-apt-repository ppa:alexlarsson/flatpak
        sudo apt -y update
        sudo apt -y install flatpak gnome-software-plugin-flatpak
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        sudo touch /var/run/flatpak-requires-reboot
        print_line
        printf "Flatpak installed \n" >> report_list
        report_restart
        printf " **** Just installed Flatpaks - REEBOOT REQUIRED ! \n"
        exit 1
    fi

}



get_apt_list(){
    comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u) > apt_list_raw
}



report_apt_list(){
get_apt_list
print_line
cat apt_list_raw >> report_list
}



# Flatpak seems to have no standard labeling 
# gimp.GIMP, gottcode.FocusWriter, bitwarden.desktop, gnome.Boxes etc...
# Also 'gnome' , 'desktop' produces many results if searched ie $ flatpak search gnome
# Could test for number of lines produced as well as 'no match found' for $ flatpak search
# A future complexity: Will just stick to two-part label for now eg 'gnome.Boxes'

get_flatpak_list(){
flatpak list | cut -d'/' -f1 | cut -d'.' -f2,3 > flat_list_raw
# remove standard desktop Flatpaks from list
sed -i '/freedesktop.Platform/d' ./flat_list_raw
sed -i '/kde.Platform/d' ./flat_list_raw
sed -i '/gnome.Platform/d' ./flat_list_raw
sed -i '/gtk.Gtk3theme/d' ./flat_list_raw

}


report_flatpak_list(){
get_flatpak_list
print_line
cat flat_list_raw >> report_list
}



get_snap_list(){
snap list | cut -d' ' -f1 > snap_list_raw
# remove standard desktop Flatpaks from list
sed -i '/Name/d' ./snap_list_raw
sed -i '/gnome-3*/d' ./snap_list_raw
sed -i '/gtk-common-themes/d' ./snap_list_raw
sed -i '/kde-frameworks-5/d' ./snap_list_raw
sed -i '/core*/d' ./snap_list_raw
}



report_snap_list(){
get_snap_list
print_line
cat snap_list_raw >> report_list
}



check_gufw_installed(){
    if [ ! $(which gufw) ] 
        then gufw_installed="no"
        else gufw_installed="yes"
    fi
}


check_ufw_ports_set() {

    if [ $ufw_ports_set = "no" ]
      then
        printf "************************************************** \n"
        printf "Setup Firewall \n"
        sudo ufw enable
        sudo ufw allow 631/tcp
        sudo ufw allow 1714:1764/udp
        sudo ufw allow 1714:1764/tcp
        sudo ufw reload
        sudo ufw status
        printf "************************************************** \n"
        ufw_ports_set="yes"
    fi
    
}


report_gufw() {

check_ufw_ports_set

    if [ $ufw_ports_set = "yes" ]
        then 
            print_line
            printf "Gufw installed \n" >> report_list
            if [[ $(sudo ufw status | grep -E "1714:1764/tcp") ]] ; then printf "KDE Connect set: Firewall \n" >> report_list; fi
            if [[ $(sudo ufw status | grep -E "631/tcp") ]] ; then printf "Printer CUPS set : Firewall \n" >> report_list; fi
    fi
    
}



check_node_installed(){

    if [ $(which node) ]; then node_installed="yes"; else node_installed="no"; fi
    if [ $(which npm) ]; then npm_installed="yes"; else npm_installed="no"; fi
    if [ $(which yarn) ]; then yarn_installed="yes"; else yarn_installed="no"; fi
    
}


report_node(){

    check_node_installed
    print_line
    
    if [ $node_installed = "yes" ]
        then 
            print_line
            printf "Node Installed :   Node \n" >> report_list ; fi
        
    if [ $npm_installed = "yes" ]
        then
            printf "NPM :   Node \n" >> report_list ; fi
        
    if [ $yarn_installed = "yes" ]
        then
            printf "Yarn   : Node \n" >> report_list ; fi
}





check_google_fonts_installed(){

    if [ -d /usr/share/fonts/truetype/Zilla_Slab ]
        then google_fonts_installed="yes"
        else google_fonts_installed="no"
    fi
}




report_google_fonts_installed(){

    check_google_fonts_installed
    print_line
    
    if [ $google_fonts_installed = "yes" ]
        then printf "Google Fonts   :   Fonts \n" >> report_list
    fi
}




check_gimp_filters_installed(){

    if [ -d /var/lib/flatpak/app/org.gimp.GIMP/current/active/files/lib/gimp/2.0/plug-ins/wavelet-denoise ] || [ -e /usr/lib/gimp/2.0/plug-ins/wavelet-denoise ]
        then gimp_filters_installed="yes"
        else gimp_filters_installed="no"
    fi
}



report_gimp(){

    check_gimp_filters_installed
    print_line
    
    if [ $gimp_filters_installed = "yes" ]
        then
            print_line
            printf "Gimp 2.8 Filters added   :   Gimp \n" >> report_list
    fi
}




check_appimages_installed(){

    if [ -d /opt/appimages ]
        then appimages_installed="yes"
        else appimages_installed="no"
    fi
}



# assume that if the /opt/appimages dir exists the appimages themselves exist


report_appimages(){

    check_appimages_installed
    print_line
    
    if [ $appimages_installed = "yes" ]
        then 
            printf_line
            ls -1 /opt/appimages | cut -d'-' -f1 > appimage_raw_list
            appimage_raw_list >> report_list
    fi
}





check_etcher_installed(){

    if [ -f /opt/appimages/Etcher/*.AppImage ] 
        then etcher_installed="yes"
        else etcher_installed="no"
    fi
}


report_etcher(){

    check_etcher_installed
    
    if [ $etcher_installed = "yes" ]
        then
            print_line
            printf "Etcher : Appimage \n" >> report_list
    fi
}



check_gitit_installed(){

    if [ -f /usr/share/Git-it-linux-x64/Git-it ] || [ -f /home/$CURRENT_USER/.local/share/Git-it-linux-x64/Git-it ]
        then gitit_installed="yes"
        else gitit_installed="no"
    fi

}



report_gitit(){

    check_gitit_installed
    print_line
    
    if [ $gitit_installed = "yes" ]
        then
            printf_line
            printf "Git-it   :   Git \n" >> report_list
    fi

}






check_ring_installed(){

    if [ -f /usr/bin/ring.cx ]
        then ring_installed="yes"
        else ring_installed="no"
    fi

}



report_ring(){

    check_ring_installed
    print_line

    if [ $ring_installed = "yes" ]
        then
            print_line
            printf "Ring :   Communication \n" >> report_list
    fi

}





check_abricotine_installed(){

    if [ $(which Abricotine) ]
        then abricotine_installed="yes"
        else abricotine_installed="no"
    fi
}



report_abricotine(){

    check_abricotine_installed
    print_line

    if [ $abricotine_installed = "yes" ]
        then 
            print_line
            printf "Abricotine   :   Markdown editor \n" >> report_list
    fi
}




check_youtube_dl_installed(){

    if [ $(which youtube-dl) ]
        then youtube_dl_installed="yes"
        else youtube_dl_installed="no"
    fi
}



report_youtube-dl(){

    check_youtube_dl_installed
    print_line

    if [ $youtube_dl_installed = "yes" ]
        then 
            printf "youtube-dl   :   media downloader \n" >> report_list
    fi
}




check_oh_my_zsh_installed(){

   if [ $(which zsh) ]
        then zsh_installed="yes"
        else zsh_installed="no"
    fi
    
    if [ -d /home/tomdom/.oh-my-zsh ]
        then oh_my_zsh_installed="yes"
        else oh_my_zsh_installed="no"
    fi

}



report_oh-my-zsh(){

    check_oh_my_zsh_installed
    print_line

    if [ $zsh_installed = "yes" ]
        then 
            printf "zsh   :   z shell \n" >> report_list
    fi
    
    if [ $oh_my_zsh_installed = "yes" ]
        then 
            printf "oh-my-zsh :   z shell framework \n" >> report_list
    fi
    
}



check_bash_aliases_installed(){

    if [ -f /home/$CURRENT_USER/.bash_aliases ]
        then bash_aliases_installed="yes"
        else bash_aliases_installed="no"
    fi
}


report_aliases(){
    
    print_line

    cat /home/$CURRENT_USER/.bash_aliases | cut -d' ' -f2 | cut -d'=' -f1 >> alias_list_raw
    sed -i '/^$/d' alias_list_raw
    printf "Aliases added :   \n" >> report_list
    alias_list_raw >> report_list
}



check_printer_installed(){

    if [ $(lpstat -p | grep -E "lpstat: No destinations added.") ]
        then printer_installed="yes"
        else printer_installed="no"
    fi

}

report_printer(){

    check_printer_installed
    print_line

    if [ $printer_installed = "yes" ]
        then printf "$(lpstat -p | awk '{print $2}')    :   Printer \n" >> report_list
        else printf "No Printer attached  :   Printer \n" >> report_list
        
    fi
}



report_autostarts(){

    print_line

    if [ -f config_autostarts ]
    then
        printf "yakuake off   :   autostart \n" >> report_list
    
        if [ cat $TOMBOY_DESKTOP_CONFIG | tail -n 1 | grep "Exec=tomboy" ]
    
            then printf "Tomboy Notes off  :   autostart \n" >> report_list
        fi
    fi
}


report_install_flags(){

    printf "distro_name $distro_name \n" >> report_list
    printf "ufw_ports_set $ufw_ports_set \n" >> report_list
    printf "gufw_installed $gufw_installed \n" >> report_list
    printf "node_installed $node_installed \n" >> report_list
    printf "npm_installed $npm_installed \n" >> report_list
    printf "yarn_installed $yarn_installed \n" >> report_list
    printf "google_fonts_installed $google_fonts_installed \n" >> report_list
    printf "gimp_filters_installed $gimp_filters_installed \n" >> report_list
    printf "appimages_installed $appimages_installed \n" >> report_list
    printf "etcher_installed $etcher_installed \n" >> report_list
    printf "gitit_installed $gitit_installed \n" >> report_list
    printf "ring_installed $ring_installed \n" >> report_list
    printf "abricotine_installed $abricotine_installed \n" >> report_list
    printf "youtube_dl_installed $youtube_dl_installed \n" >> report_list
    printf "zsh_installed $zsh_installed \n" >> report_list
    printf "oh_my_zsh_installed $oh_my_zsh_installed \n" >> report_list
    printf "bash_aliases_installed $bash_aliases_installed \n" >> report_list
    printf "printer_installed $printer_installed \n" >> report_list
}


display_report(){

cat report_list

}


