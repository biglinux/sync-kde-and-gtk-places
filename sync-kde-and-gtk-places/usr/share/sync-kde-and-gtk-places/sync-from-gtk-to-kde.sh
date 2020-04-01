#!/bin/bash
#
# From gtk-3.0/bookmarks to user-places.xbel
# By Bruno Goncalves < www.biglinux.com.br >
# 29/03/2020
#


# if another session of this script is running, just exit
if [ "$(ps -aux | grep -c "/bin/bash /usr/share/sync-kde-and-gtk-places/sync-from")" -gt "3" ]; then
    exit 0
fi
sleep 0.3

OIFS=$IFS
IFS=$'\n'

# Read all places from gtk
for i  in  $(cat ~/.config/gtk-3.0/bookmarks); do

    # Filter to select only link and change %20 to space like used in KDE
    LINK="$(echo "$i" | cut -f1 -d" " | sed 's|%20| |g')"
    # Filter only name and if don't have name, use name of folder, and change %20 to space
    NAME="$( echo "${i#* }" | sed 's|.*/||g;s|%20| |g')"

    # If name don't have name or folder, use link and change %20 to space
    if [ "$NAME" = "" ]; then
        NAME="$(echo "$LINK" | sed 's|%20| |g')"
    fi

    # Verify if KDE places have this link and apply changes
    if [ "$(grep "$LINK" ~/.local/share/user-places.xbel)" = "" ]; then

        # Remove </xbel> line
        sed -i '/<\/xbel>/d' ~/.local/share/user-places.xbel

        # Add new bookmard and </xbel> in last line of file
            echo "<bookmark href=\"$LINK\">
<title>$NAME</title>
</bookmark>
</xbel>" >>  ~/.local/share/user-places.xbel

    fi

done

# Check for removed lines in GTK bookmarks
DIFF_ADD=$(diff ~/.config/gtk-3.0/bookmarks-sync ~/.config/gtk-3.0/bookmarks | grep -m1 "^>" | sed 's|^> ||g')
DIFF_REMOVE=$(diff ~/.config/gtk-3.0/bookmarks-sync ~/.config/gtk-3.0/bookmarks | grep -m1 "^<" | sed 's|^< ||g')

if [ "$DIFF_REMOVE" != "" ]; then
    LINK_DIFF_REMOVE="$(echo "$DIFF_REMOVE" | cut -f1 -d" ")"
    NAME_DIFF_REMOVE="$(echo "${DIFF_REMOVE#* }" | sed 's|.*/||g;s|%20| |g')"
    
            echo "$LINK_DIFF_REMOVE" > /home/bruno/remove.txt

    # Verify if line really removed and remove in KDE
    if [ "$(grep "^$LINK_DIFF_REMOVE \|$LINK_DIFF_REMOVE$" ~/.config/gtk-3.0/bookmarks)" = "" ]; then
        LINK_DIFF_REMOVE_LIKE_KDE="$(echo "$LINK_DIFF_REMOVE" | sed 's|%20| |g')"
        sed -i "\|<bookmark href=\"$LINK_DIFF_REMOVE_LIKE_KDE\">|,\|</bookmark>|d" ~/.local/share/user-places.xbel
        echo "$LINK_DIFF_REMOVE_LIKE_KDE" > /home/bruno/reallyremove.txt
    fi

fi

if [ "$DIFF_ADD" != "" ]; then
    LINK_DIFF_ADD="$(echo "$DIFF_ADD" | cut -f1 -d" " | sed 's|%20| |g')"
    NAME_DIFF_ADD="$(echo "${DIFF_ADD#* }" | sed 's|.*/||g;s|%20| |g')"
    LINK_DIFF_ADD_LIKE_KDE="$(echo "$LINK_DIFF_ADD" | sed 's|%20| |g')"

    # Verify if line really added or just changed name
    if [ "$(grep "<bookmark href=\"$LINK_DIFF_ADD_LIKE_KDE\">" ~/.local/share/user-places.xbel)" = "" ]; then
        # Really added

        # Remove </xbel> line
        sed -i '/<\/xbel>/d' ~/.local/share/user-places.xbel
        
        # Add new bookmark and </xbel> in last line of file
            echo "<bookmark href=\"$LINK_DIFF_ADD_LIKE_KDE\">
<title>$NAME_DIFF_ADD</title>
</bookmark>
</xbel>" >>  ~/.local/share/user-places.xbel

    else

        # Only change name
        sed -i "\|<bookmark href=\"$LINK_DIFF_ADD_LIKE_KDE\">|{ N; s|<title>.*</title>|<title>$NAME_DIFF_ADD</title>| }" ~/.local/share/user-places.xbel
    fi
fi

# Copy bookmarks-file compare in next change
cp -f ~/.config/gtk-3.0/bookmarks ~/.config/gtk-3.0/bookmarks-sync

sleep 0.3

IFS=$OIFS
