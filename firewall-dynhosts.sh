#!/bin/bash
# filename: firewall-dynhosts.sh
#
# A script to update iptable records for dynamic dns hosts.
# Written by: Dave Horner (http://dave.thehorners.com)
# Released into public domain.
#
# Run this script in your cron table to update ips.
#
# You might want to put all your dynamic hosts in a sep. chain.
# That way you can easily see what dynamic hosts are trusted.
#
# create the chain in iptables.
# /sbin/iptables -N dynamichosts
# insert the chain into the input chain @ the head of the list.
# /sbin/iptables -I INPUT 1 -j dynamichosts
# flush all the rules in the chain
# /sbin/iptables -F dynamichosts
# block incoming traffic to port 4022
# /sbin/iptables -A dynamichosts -dport 4022 -j DROP
 
HOST=$1
HOSTFILE="/root/dynhosts/host-$HOST"
CHAIN="dynamichosts"  # change this to whatever chain you want.
IPTABLES="/sbin/iptables"
 
# check to make sure we have enough args passed.
if [ "${#@}" -ne "1" ]; then
    echo "$0 hostname"
    echo "You must supply a hostname to update in iptables."
    exit
fi
 
# lookup host name from dns tables
IP=`/usr/bin/dig +short $HOST | /usr/bin/tail -n 1`
if [ "${#IP}" = "0" ]; then
    echo "Couldn't lookup hostname for $HOST, failed."
    exit
fi
 
OLDIP=""
if [ -a $HOSTFILE ]; then
    OLDIP=`cat $HOSTFILE`
    # echo "CAT returned: $?"
fi
 
# has address changed?
if [ "$OLDIP" == "$IP" ]; then
    # echo "Old and new IP addresses match."
    exit
fi
 
# save off new ip.
echo $IP>$HOSTFILE
 
echo "Updating $HOST in iptables."
if [ "${#OLDIP}" != "0" ]; then
    echo "Removing old rule ($OLDIP)"
    `$IPTABLES -D $CHAIN -s $OLDIP/32 -p tcp --dport 4022 -j ACCEPT`
fi
echo "Inserting new rule ($IP)"
`$IPTABLES -A $CHAIN -s $IP/32 -p tcp --dport 4022 -j ACCEPT`
