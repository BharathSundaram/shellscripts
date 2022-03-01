#!/bin/bash
#Core Testing files Bharath
checkMountUSB(){
for disk in `fdisk -l | grep FAT | awk '{ print $1 }'`; do
    echo $DEBUG "found FAT disk $disk"
       already_mounted=$(df |grep $disk| awk '{print $6}')
       echo $DEBUG $already_mounted
       if [ "$already_mounted" == "${USB_MOUNT}" ] ; then
           echo $DEBUG "$disk already mounted in proper location $already_mounted"
           MOUNT_SUCCESS=2 # already mounted
       else
	   echo $DEBUG  "Trying to mount"
           echo $DEBUG  "mount  \"$disk\" "${USB_MOUNT}" "
	   mount -t  vfat "$disk" "${USB_MOUNT}" 
           if [ $? -ne 0 ] ; then 
               echo $DEBUG "failed to mount $disk" 
               MOUNT_SUCCESS=0
           else
               echo $DEBUG "mount $disk is successful" 
	       MOUNT_SUCCESS=2
	   fi
       fi
done
}
enumerateLogs(){
   echo $DEBUG "Enumerate logfile"
   if [ $MOUNT_SUCCESS -gt 1 ]; then

        LOGFILE=log_00000.log
        if [ -f ${USB_MOUNT}/${LOG_DIR_NAME}/${LOGFILE} ]; then
                echo $DEBUG "log file exists, increment counter"
                LATEST=$(ls ${USB_MOUNT}/${LOG_DIR_NAME}| tail -1 | cut -d'_' -f2| sed 's/\.log//' | sed 's/^0//')
                while [ -f ${USB_MOUNT}/${LOG_DIR_NAME}/log_$(printf "%05d".log $LATEST) ]; do
                        LATEST=$((10#$LATEST+1))
                done
                LOGFILE=log_$(printf "%05d".log $LATEST)
        fi
    else
        echo $DEBUG "could not mount ${disk}"
    fi
}

# Prefix for logs
DEBUG="SYSMGR: "

# Mount point
USB_MOUNT=/usb

# Logging directory name
LOG_DIR_NAME=ott_logs

# Build type constants (from version.txt)
READWRITE_STR="READWRITE"
READONLY_STR="READONLY"

MOUNT_SUCCESS=0

LOGGING_ENABLED=0

# Extract the MAC
MACADDR=`ifconfig | grep 'eth0 ' | awk '{print $5}' | sed s/://g`
echo $DEBUG "Found MAC: " $MACADDR

# Compute the token based on the MAC
TOKEN=`/usr/bin/tokgen_streama $MACADDR`
echo $DEBUG "Token file expected: " $TOKEN

# Extract the build type
BUILD_TYPE=`cat /version.txt | grep '^VERSION' | cut -d ':' -f 3`

# Enable logging to USB only for "Read-write" builds
if [ $BUILD_TYPE == $READWRITE_STR ]; then
	echo $DEBUG "RW build detected"
	# enable logging for RW builds
	LOGGING_ENABLED=1
elif [ $BUILD_TYPE == $READONLY_STR ]; then
	echo $DEBUG "RO build detected"
	LOGGING_ENABLED=0
else 
	echo $DEBUG "Could not determine build type - disable logging"
	LOGGING_ENABLED=0
fi

# Check for USB drive
checkMountUSB

if [ $MOUNT_SUCCESS -gt 1 ]; then
	# look for token to enable logging
        if [ -e ${USB_MOUNT}/${TOKEN} ]; then
	        echo $DEBUG "Found debug token"
		LOGGING_ENABLED=1
	else
        	echo $DEBUG "No debug token"
	fi
fi

# Enabled logging irrespective of build type and token. We shall enable after netflix certification.
LOGGING_ENABLED=1
MOUNT_SUCCESS=0
# If USB is mounted, and ogging enabled, then increment the log file and start logging.
if [ $MOUNT_SUCCESS -gt 1 ]; then
	if [ $LOGGING_ENABLED == 1 ]; then
		if [ ! -e $USB_MOUNT/$LOG_DIR_NAME ]; then
		    mkdir $USB_MOUNT/$LOG_DIR_NAME
		    echo $DEBUG "Created log directory in USB"
	        else
		    echo $DEBUG "Log directory already exists in USB"
	        fi
	        enumerateLogs

	        echo $DEBUG "Started logging to: " $USB_MOUNT/$LOG_DIR_NAME/$LOGFILE
		# Log from the beginning
		journalctl > $USB_MOUNT/$LOG_DIR_NAME/$LOGFILE
		# Append rest
	        journalctl -f >> $USB_MOUNT/$LOG_DIR_NAME/$LOGFILE
	else
        	echo $DEBUG "No USB logging"
	fi
else
	echo $DEBUG "USB is not mounted!" $MOUNT_SUCCESS 
fi
