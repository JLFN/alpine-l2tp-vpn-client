#!/bin/sh
echo "successful: VPN connection successful";
date

# Wolffsohn - add router functionality to server https://www.tecmint.com/setup-linux-as-router/
echo 1 > /proc/sys/net/ipv4/ip_forward    # or /etc/sysctl.conf  and add net.ipv4.ip_forward = 1
iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE
iptables -A FORWARD -i ppp0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o ppp0 -j ACCEPT

# Get Default Gateway
DEAFULT_ROUTE_IP=$(route | grep eth0 | grep default | awk '{print $2}')
# Get VPN Gateway
VPN_ROUTE_IP=$(ip a show ppp0  | grep peer | sed -e 's/.*peer\s\+\(\d\+\.\d\+\.\d\+\.\d\+\).*/\1/g')
# Get IPs of VPN's FQDN if presented
if echo "${VPN_SERVER}" | grep -E '\d+\.\d+\.\d+\.\d+'; then
    echo "${VPN_SERVER}" > /tmp/all_ips.txt
else
    dig $VPN_SERVER a | grep "$VPN_SERVER" | grep -E '\d+\.\d+\.\d+\.\d+' | awk '{print $5}' > /tmp/all_ips.txt
fi

echo "successful: Default Gateway=$DEAFULT_ROUTE_IP"
echo "successful: VPN Gateway=$VPN_ROUTE_IP"
echo -e "successful: VPN servers: \n$(cat /tmp/all_ips.txt | sed -e 's/^/ - /g')"
echo "successful: wait for 3 secs";sleep 3
# ip route add $VPN_SERVER via $DEAFULT_ROUTE_IP dev eth0
while read p;do
    echo "successful: Adding $p to route table...";
    ip route add $p via $DEAFULT_ROUTE_IP dev eth0;
done < /tmp/all_ips.txt

# Wolffsohn - remove route to network, as default route is now via ppp0 VPN
route del default eth0

# Check routes
route -n
traceroute 8.8.8.8 -m 1

# Set default gateway to VPN
route add -net default gw $VPN_ROUTE_IP dev ppp0

# Check routes
route -n
traceroute 8.8.8.8 -m 1

# Show Public IP
# curl icanhazip.com
echo "successful: Your Public IP: $(curl https://api64.ipify.org -s)"
fi # Wolffsohn - extra loop
