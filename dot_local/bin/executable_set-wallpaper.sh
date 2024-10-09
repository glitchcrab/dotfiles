#!/bin/bash

MONCOUNT=`xrandr | grep connected | grep -v disconnected | wc -l`
#BG_DIR=$HOME/Dropbox/Wallpaper/1920x1200
BG_DIR=$HOME/Documents/nextcloud/images/Wallpaper/1920x1200

# ensure array is empty
unset files

i=0
while read line ; do files[ $i ]="$line" ; (( i++ )) ; done < <(find $BG_DIR/ -type f \( -iname \*.jpg -o -iname \*.png \) | shuf -n $MONCOUNT)

if [ $MONCOUNT == "1" ]; then
    feh --bg-fill ${files[0]} /dev/null 2>&1
elif [ $MONCOUNT == "2" ]; then
    feh --bg-fill ${files[0]} feh --bg-fill ${files[1]} /dev/null 2>&1
elif [ $MONCOUNT == "3" ]; then
    feh --bg-fill ${files[0]} feh --bg-fill ${files[1]} feh --bg-fill ${files[2]} > /dev/null 2>&1
fi

# clean up afer execution
unset files

exit
