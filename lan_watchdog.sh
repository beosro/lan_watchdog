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

# host we should always be able to reach when wi-fi is up
WIFI_GW="192.168.1.1"

# number of seconds to wait before checking arping again
SLEEP_SECS=60

# number of times arping is allowed to fail before a reboot
MAX_TIMES_DOWN=5

# number of consecutive times, in loop, that WIFI_GW has been unreachable
down_count=0

# loop forever
while [ 1 ]; do

   # check using two  arp packets - if arping returns non-zero status, assume it's an error
   arping -c 2 ${WIFI_GW}
   result=$?

   # if ping result is non-zero, add to the down counter
   #   if result is zero (successful) reset down_count (temp network hiccup?)
   test ${result} -ne 0 && let down_count="$down_count+1"
   test ${result} -eq 0 && down_count=0

   # if arping fails in the loop MAX_TIMES_DOWN (consecutively) then reboot
   test $down_count -gt ${MAX_TIMES_DOWN} && reboot_host

   # wait a while before checking again
   sleep ${SLEEP_SECS};

done
