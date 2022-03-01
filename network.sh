loop=1
while [ $loop -eq 1 ]
do
	if ping -q -c 1 -W 1 10.100.80.135:8080 >/dev/null; then
  	   echo "TODAY=$(date "+%r %d-%m-%Y") The network is up"
	else
           echo "TODAY=$(date "+%r %d-%m-%Y") The network is down"
        fi
	sleep 2 
done
