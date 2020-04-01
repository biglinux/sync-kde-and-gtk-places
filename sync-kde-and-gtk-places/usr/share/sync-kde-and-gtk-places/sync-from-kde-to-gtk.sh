#!/bin/bash
#
# From user-places.xbel to gtk-3.0/bookmarks
# By Bruno Goncalves < www.biglinux.com.br >
# 29/03/2020
#

# if another session of this script is running, just exit
if [ "$(ps -aux | grep -c "/bin/bash /usr/share/sync-kde-and-gtk-places/sync-from")" -gt "3" ]; then
    exit 0
fi

OIFS=$IFS
IFS=$'\n'
KDE_PLACES="$(/usr/share/sync-kde-and-gtk-places/read-kde.sh)"


# Read all places from kde
for i  in  $KDE_PLACES; do

    # Filter to select only link and change space to %20 like used in gtk bookmarks
    LINK="$(echo "${i%\|\|\|*}" | sed 's| |%20|g')"
    # Filter only name
    NAME="${i#*\|\|\|}"

    # Verify if bookmarks gtk have this link and apply changes
    if [ "$(grep "$LINK" ~/.config/gtk-3.0/bookmarks)" = "" ]; then

        echo "$LINK $NAME" >> ~/.config/gtk-3.0/bookmarks
    else
        sed -i "s|$LINK.*|$LINK $NAME|g" ~/.config/gtk-3.0/bookmarks
    fi

done

# Read gtk bookmarks filtering to only LINK and delete removed links
for LINK_GTK  in  $(cut -f1 -d" " ~/.config/gtk-3.0/bookmarks); do
    
    if [ "$(echo "$KDE_PLACES" | sed 's| |%20|g' | grep "^$LINK_GTK|||")" = "" ]; then

        sed -i "\|$LINK_GTK |d;\|$LINK_GTK$|d" ~/.config/gtk-3.0/bookmarks
    fi

    
done


# Copy bookmarks file to use in gtk to kde and remove duplicates
uniq ~/.config/gtk-3.0/bookmarks ~/.config/gtk-3.0/bookmarks-sync
cp -f ~/.config/gtk-3.0/bookmarks-sync ~/.config/gtk-3.0/bookmarks


IFS=$OIFS

sleep 0.3
