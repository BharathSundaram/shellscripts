#!/bin/sh

#Section to copy opt logs
OPT_PATH=/opt/logs
USB_ROOT=/usb/
time=$(date +'%s')
uniquename="opt_logs_$time"
echo "File name: $uniquename"

ls ${OPT_PATH}/*.* | tar -cvf $uniquename.tar.gz -T -

if [ $? -ne 0 ]; then
    echo "Error: ls for log file find or tar execution failed - errcode= $?"
else
    echo "Copying the file to usb root folder..."
    mv $uniquename.tar.gz $USB_ROOT
    if [ $? -ne 0 ]; then
        echo "Error: moving the file failed - errcode= $?"
    else
        echo "Success: file moved to usb path named: $uniquename.tar.gz"
    fi
fi


#Section to copy top

time=$(date +'%s')
uniquenamef="top_$time.txt"
echo "Top File name: $uniquenamef"
usbpath=/usb/$uniquenamef
top -bc -o +%MEM -n 1 >> $usbpath

#Section to copy ps

time=$(date +'%s')
uniquenamef="ps_$time.txt"
echo "PS File name: $uniquenameps"
usbpath=/usb/$uniquenameps
ps -aux >> $usbpath



#Section to core if available
time=$(date +'%s')
uniquenamec="core_$time.txt"
echo "Core File name: $uniquenamec"
usbpath=/usb/$uniquenamec

c_available=$(ls -l /tmp/*core* | wc -l)
if [ $c_available -ne 0 ]; then
   
   cd $USB_ROOT
   ls /tmp/*core* | tar -cvf $uniquenamec.tar.gz -T -
   echo "Core file found copied - $uniquenamec"
    
else
    echo "No core file found..."
fi

