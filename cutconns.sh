#!/bin/bash

# start with sudo
# needs tcpkill from apt-get install dsniff

touch cutconns.log

myip=$(curl -s4 checkip.amazonaws.com)
SLEEP1=30  # polls every SLEEP1 sec
SLEEP2=120 # kills connection for SLEEP2 sec

date=$(date +%Y-%m-%d:%H:%M:%S)
echo "$date" >> cutconns.log
echo "script started..." >> cutconns.log
echo "" >> cutconns.log

while true; do

  # threshold 50000 for bandwidth, identifier 1777 for both :17775 and :17776 iguana
  establishedconnections=$( ss -a | grep ":1777" | grep "ESTAB" | awk '$4 > 50000 {print $4 " " $5 " "  $6}' )
  #echo $"$establishedconnections"

  IPs=$( echo $"$establishedconnections" | awk '{print $3}' | sed 's/:[0-9]*[0-9]*[0-9]*[0-9]*//g' | sort | uniq )
  #echo $"$IPs"

  if [ "$IPs" != "" ];then

    date=$(date +%Y-%m-%d:%H:%M:%S)
    echo "$date" >> cutconns.log
    echo "$IPs" >> cutconns.log
    echo "" >> cutconns.log

    while read -r IP; do
      echo "sudo tcpkill host $IP"
      eval "sudo /usr/sbin/tcpkill host $IP &"
    done <<< "$IPs"

    sleep $SLEEP2
    pkill tcpkill

  fi

  echo "sleep $SLEEP1"
  sleep $SLEEP1
  
done
