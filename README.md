dynhosts
========

1. sudo -s

2. Append to /etc/rc.local
# restore udpxy iptables
/sbin/iptables-restore < /root/dynhosts/udpxy.iptables
# remove all host files
rm /root/dynhosts/host-*

3. Copy this folder into /root/

4. Create udpxy.cron into /etc/cron.d/
# Run the dynamic firewall script every 5 minutes
*/5 * * * * root /root/dynhosts/firewall-dynhosts.sh <domain-name>
