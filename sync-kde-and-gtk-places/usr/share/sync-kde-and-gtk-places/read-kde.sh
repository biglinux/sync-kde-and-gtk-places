#!/bin/bash
#
# From user-places.xbel to gtk-3.0/bookmarks
# By Bruno Goncalves < www.biglinux.com.br >
# 29/03/2020
#


# Filter bookmark lines and show one line after too, to read <title>
grep -A1 "<bookmark " ~/.local/share/user-places.xbel | \
#
# Filter by protocol
grep -A1 "file:/\|ftp:/\|smb:/" | \
#
# Remove <title> tags, remove -- and change "> to |||
#
sed 's|.*<title>||g;s|</title>||g;s|^--$||g;s/">/|||/g' | \
#
# Remove all break lines
sed ':a;N;$!ba;s/\n//g' | \
#
# Remove <bookmark tag and add newline
sed 's|<bookmark href="|\n|g' | \
#
# Remove all blank lines, remove whitespace from end of each line, remove remove all whitespace from left to first word
sed 's/^[ \t]*//;s/[ \t]*$//;/^$/d' | \
#
# Remove default folders from KDE
grep -ve "|||Home$" -ve "|||Desktop$" -ve "|||Documents$" -ve "|||Downloads$"


