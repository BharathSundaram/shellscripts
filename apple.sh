# This script shall cpy necessary files

function trapHandler
{
    retCode=$1
    echo "[$2] exited with status $retCode"
	if [ $retCode -eq 0 ]; then
		echo "$2 command was successful"
	else
		echo "$2 command failed"
		if [ $3 -eq 0 ]; then	    
			exit $retCode
		fi
	fi
}

mv /lib/rdk/referenceApp.sh /lib/rdk/oldreferenceApp.sh

trapHandler $? "move referenceApp.sh" 0

cp /usb/referenceApp.sh /lib/rdk/referenceApp.sh

trapHandler $? "move referenceApp.sh to dest" 0

mv /usr/bin/mcg-setup-logging.sh /usr/bin/Oldmcg-setup-logging.sh

trapHandler $? "move logging.sh" 0

cp /usb/mcg-setup-logging.sh /usr/bin/mcg-setup-logging.sh

trapHandler $? "move logging.sh to dest" 0


grep "Bharath" /lib/rdk/referenceApp.sh

sleep 5

grep "Bharath" /usr/bin/mcg-setup-logging.sh

sleep 5

echo "Files successfully updated .... rebooting ...."

sleep 3

reboot -f
