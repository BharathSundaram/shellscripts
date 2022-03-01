loop=1
url=https://r-live-cache.akamaized.net/USL19/index.zip
while [ $loop -eq 1 ]
do
	wget --timeout=10  $url > /dev/null
	if [[ $? -eq 0 ]]; then
  	   echo "TODAY=$(date "+%r %d-%m-%Y") Download is successful"
       rm index.zip
	else
           echo "TODAY=$(date "+%r %d-%m-%Y") Download failed $?"
        fi
	sleep 5 
done
