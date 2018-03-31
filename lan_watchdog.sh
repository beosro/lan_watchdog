#!/bin/bash
#
# preference: use arping rather than ping since ICMP can be inadvertently firewalled in netfilter
# limitation: host to arping must be on the same subnet
# ping syntax should be very similar - change arping to ping if you want to check host on different subnet

# function gets called to do any cleanup before rebooting
reboot_host()
{
   # add an entry in syslog to keep track of down times
   logger -p0 "WIFI_GW is unreachable - going down for reboot"
   # echo "simulating: un-comment next line to apply a reboot" 
   reboot
}

reboot_wifi()
{
   echo "Network connection down! Attempting reconnection."
   /sbin/ifdown $WLAN
   sleep 5
   /sbin/ifup --force $WLAN
}

# which interface should the script listen to
WLAN="wlan0"

# host we should always be able to reach when wi-fi is up
WIFI_GW="192.168.1.1"

# number of seconds to wait before checking arping again
SLEEP_SECS=600

# number of times arping is allowed to fail before a reboot
MAX_TIMES_DOWN=3

# number of consecutive times, in loop, that WIFI_GW has been unreachable
down_count=0

# loop forever
while [ 1 ]; do

  # check using two  arp packets - if arping returns non-zero status, assume it's an error
  arping -c 2 ${WIFI_GW}
  result=$?

  if [ ${result} -ne 0 ]
  then
    let down_count="$down_count+1"
  else
    down_count=0
  fi

  if [ $down_count -gt 0 ]; then
    if [ $down_count -le ${MAX_TIMES_DOWN} ]; then
      reboot_wifi
    else
      reboot_host
    fi
  fi

  sleep ${SLEEP_SECS};

done
