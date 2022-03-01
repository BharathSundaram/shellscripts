#!/bin/sh

#Section to define the defaults
OPT_PATH=/opt/logs

time=$(date +'%s')
uniquename="opt_logs_$time"
echo "File name: $uniquename"

ls ${OPT_PATH}/*.* | tar -cvf $uniquename.tar.gz -T -

if [ $? -ne 0 ]; then
    echo "Error: ls for log file find or tar execution failed - errcode= $?"
else
    echo "Copying the file to usb root folder..."
    mv $uniquename.tar.gz /usb/
    if [ $? -ne 0 ]; then
        echo "Error: moving the file failed - errcode= $?"
    else
        echo "Success: file moved to usb path named: $uniquename.tar.gz"
    fi
fi


