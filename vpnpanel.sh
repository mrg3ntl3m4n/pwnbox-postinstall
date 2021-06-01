#!/bin/bash
vpnip=$(ip addr | grep tun0 | grep inet | cut -d "/" -f 1 | cut -d " " -f 6)

if [[ ! -z $vpnip ]]
then
   echo "VPN: $vpnip"
else
   echo "VPN: Disconnected"
fi
