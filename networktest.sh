loop=1
while [ $loop -eq 1 ]
do
	wget -q --timeout=10 -O - https://r-live-cache.akamaized.net/USL19/index.zip > /dev/null
	if [[ $? -eq 0 ]]; then
  	   echo "TODAY=$(date "+%r %d-%m-%Y") The network is up"
	   #rm index.zip
	else
           echo "TODAY=$(date "+%r %d-%m-%Y") The network is down"
        fi
	sleep 2 
done
