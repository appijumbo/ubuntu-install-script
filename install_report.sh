#!/bin/bash

CURRENT_USER="$(who | cut -d' ' -f1)"  

# This contains the functions to provide a report for the installation script

touch report_list

clear_lists(){
    rm alias_list_raw flat_list_raw snap_list_raw
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
flat_list_raw >> report_list
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
snap_list_raw >> report_list
}



report_gufw(){

    if [ $(which gufw) ] 
        then 
            echo "Gufw installed" >> report_list
            cat << _EOF_ >> report_list
Printer/scanner (CUPS) Ports set : Firewall
KDE Connect Ports set : Firwwall
_EOF_
    fi
}



report_node(){

    if [ $(which node) ]; then echo "Node Installed :   Node" >> report_list ; fi
    if [ $(which npm) ]; then echo "NPM :   Node" >> report_list ; fi
    if [ $(which yarn) ]; then echo "Yarn   : Node" >> report_list ; fi
}



report_google_fonts(){

    if [ -d /usr/share/fonts/truetype/Zilla_Slab ]
        then echo "Google Fonts   :   Fonts" >> report_list
    fi
}



report_gimp(){
    if [ -d /var/lib/flatpak/app/org.gimp.GIMP/current/active/files/lib/gimp/2.0/plug-ins/wavelet-denoise ] || [ -e /usr/lib/gimp/2.0/plug-ins/wavelet-denoise ]
        then echo "Gimp 2.8 Filters added   :   Gimp" >> report_list
    fi
}



report_appimages(){
    if [ -d /opt/appimages ]
        then 
            ls -1 /opt/appimages | cut -d'-' -f1 > appimage_raw_list
            appimage_raw_list >> report_list
        fi
}



report_gitit(){

    if [ -f /usr/share/Git-it-linux-x64/Git-it ] || [ -f /home/$CURRENT_USER/.local/share/Git-it-linux-x64/Git-it ]
        then echo "Git-it   :   Git" >> report_list
    fi

}



report_ring(){

    if [ -f /usr/bin/ring.cx ]
        then echo "Ring :   Communication" >> report_list
    fi

}



report_abricotine(){

    if [ $(which Abricotine) ]
        then echo "Abricotine   :   Markdown editor" >> report_list
    fi
}



report_youtube-dl(){

    if [ $(which youtube-dl) ]
        then echo "youtube-dl   :   media downloader" >> report_list
    fi
}


report_oh-my-zsh(){
    if [ $(which zsh) ]
        then 
            echo "zsh   :   z shell" >> report_list
    fi
    
    if [ -d /home/tomdom/.oh-my-zsh ]
        then 
            echo "oh-my-zsh :   z shell framework" >> report_list
    fi
    
}



report_aliases(){

    cat /home/$CURRENT_USER/.bash_aliases | cut -d' ' -f2 | cut -d'=' -f1 >> alias_list_raw
    sed -i '/^$/d' alias_list_raw
    echo "Aliases added :   " >> report_list
    alias_list_raw >> report_list
}



report_printer(){

    printer_name=$(lpstat -p | awk '{print $2}')

    
    if [ $(lpstat -p | grep -E "lpstat: No destinations added.") ]
        
        then echo "No Printer attached  :   Printer" >> report_list
        else echo "$printer_name    :   Printer" >> report_list
        
    fi
}



report_autostarts(){

    echo "yakuake off   :   autostart" >> report_list
    
    if [ cat $TOMBOY_DESKTOP_CONFIG | tail -n 1 | grep "Exec=tomboy" ]
    
        then echo "Tomboy Notes off  :   autostart" >> report_list
    fi
}




display_report(){
cat report_list
}


