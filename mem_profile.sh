#!/bin/bash

INTERVAL=300
TOTAL_AS_RSS=0
TOTAL_AS_PSS=0
TOTAL_WPE_RSS=0
TOTAL_WPE_PSS=0

function collectWPEStats {

mainPIDs=$(pgrep $1)
childPIDs=""
allPIDs="$mainPIDs"

for mainPID in $mainPIDs; do
    childs=$((pgrep -P $mainPID) 2>/dev/null);
    if [ "$childs" != "" ] ; then
        childPIDs="${childPIDs}\n${childs}"
    fi
done

if [ "$childPIDs" != "" ] ; then
    allPIDs="${allPIDs}${childPIDs}"
fi


allPIDs=$(echo -e "$allPIDs")
#echo "All PIDs: $allPIDs"


PSS_MEM=0
RSS_MEM=0
for pid in $allPIDs; do
    pss=$(cat /proc/$pid/smaps | grep -w Pss: | awk '{Total+=$2} END {print Total}')
    PSS_MEM=$((PSS_MEM + pss))
    rss=$(cat /proc/$pid/status | grep -w VmRSS: | awk '{Total+=$2} END {print Total}')
    RSS_MEM=$((RSS_MEM + rss))
	cpu=$(top -bc -o +%CPU -n 1 | grep $pid)
done

curr_time=`date +"%d-%m-%y %H:%M:%S"`
echo "${curr_time} | $1 | $RSS_MEM | $PSS_MEM "

    TOTAL_WPE_RSS=$((TOTAL_WPE_RSS + RSS_MEM))
    TOTAL_WPE_PSS=$((TOTAL_WPE_PSS + PSS_MEM))
}

function collectSysStats {
    free | grep Mem: | awk '{Total=$2;Used=$3;Free=$4} END {printf("System Total Mem: %s kB, Used: %s kB, Free: %s kB\r\n",Total,Used,Free); }'
}

function collectStats {

mainPIDs=$(pgrep $1)
childPIDs=""
allPIDs="$mainPIDs"

for mainPID in $mainPIDs; do
    childs=$((pgrep -P $mainPID) 2>/dev/null);
    if [ "$childs" != "" ] ; then
        childPIDs="${childPIDs}\n${childs}"
    fi
done

if [ "$childPIDs" != "" ] ; then
    allPIDs="${allPIDs}${childPIDs}"
fi

allPIDs=$(echo -e "$allPIDs")
#echo "All PIDs: $allPIDs"

PSS_MEM=0
RSS_MEM=0
for pid in $allPIDs; do
    pss=$(cat /proc/$pid/smaps | grep -w Pss: | awk '{Total+=$2} END {print Total}')
    PSS_MEM=$((PSS_MEM + pss))
    rss=$(cat /proc/$pid/status | grep -w VmRSS: | awk '{Total+=$2} END {print Total}')
    RSS_MEM=$((RSS_MEM + rss))
done

curr_time=`date +"%d-%m-%y %H:%M:%S"`
echo "${curr_time} | $1 | $RSS_MEM | $PSS_MEM "

    TOTAL_RSS=$((TOTAL_RSS + RSS_MEM))
    TOTAL_PSS=$((TOTAL_PSS + PSS_MEM))
}

while sleep "$INTERVAL"; do
    echo "                AS Total usage: RSS: $TOTAL_RSS kB, PSS: $TOTAL_PSS kB"
    echo " "
    echo " -----------------------------------------"
    echo "       Time        |  Process   |   RSS kB  |  PSS kB"
    echo " -----------------------------------------"

    TOTAL_WPE_RSS=0
    TOTAL_WPE_PSS=0
    collectWPEStats WPEWebProcess
    collectWPEStats WPENetworkProce
    collectWPEStats WPEFramework
    collectWPEStats WPEWebProcess
    collectWPEStats WPENetworkProce
    echo "                WPE Total usage: RSS: $TOTAL_WPE_RSS kB, PSS: $TOTAL_WPE_PSS kB"

    #Apps 
    collectStats HtmlApp
    collectStats Netflix
    collectStats Cobalt
    collectStats OCDM
    collectStats tee-supplicant

    collectSysStats
    echo "Top command:"
    top -bc -o +%MEM -n 1
done
