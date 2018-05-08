#!/bin/bash
date

echo -e "[ \e[0;36m++++++++++\e[0m ] CHECK IF RUNNING AS ROOT"
export XUID=`id -u`
if [ "$XUID" != "0" ]; then
    echo "$0 MUST BE RUN AS ROOT"
    echo "EXAMPLE: sudo $0"
    echo "ABORTING INSTALATION"
    sleep 2
    exit 1
fi
echo -e "[ \e[0;36m++++++++++\e[0m ] $XUID USER OK!"

echo -e "[ \e[0;36m++++++++++\e[0m ] INSTALL ARPING"
apt-get update
apt-get -y install arping
echo -e "[ \e[0;36m++++++++++\e[0m ] DONE"


echo -e "[ \e[0;36m++++++++++\e[0m ] COPY THE FILES AND SET PERMISSIONS"
cp lan_watchdog.sh /usr/local/bin/
chmod +x /usr/local/bin/lan_watchdog.sh
cp lan_watchdog.service /lib/systemd/system
chmod 644 /lib/systemd/system/lan_watchdog.service
systemctl daemon-reload
systemctl enable lan_watchdog
systemctl start lan_watchdog
echo -e "[ \e[0;36m++++++++++\e[0m ] ALL DONE"
