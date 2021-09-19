#!/bin/sh

# Run VPN if VPN_ENABLE is 1
if [[ $VPN_ENABLE -eq 1 ]];then
  echo "startup/vpn: configuring vpn client."
  # template out all the config files using env vars
  sed -i 's/right=.*/right='$VPN_SERVER'/' /etc/ipsec.conf
  echo ': PSK "'$VPN_PSK'"' > /etc/ipsec.secrets
  sed -i 's/lns = .*/lns = '$VPN_SERVER'/' /etc/xl2tpd/xl2tpd.conf
  sed -i 's/name .*/name '$VPN_USERNAME'/' /etc/ppp/options.l2tpd.client
  sed -i 's/password .*/password '$VPN_PASSWORD'/' /etc/ppp/options.l2tpd.client

  # startup ipsec tunnel
  ipsec initnss
  sleep 1
  ipsec pluto --stderrlog --config /etc/ipsec.conf
  sleep 5
  #ipsec setup start
  #sleep 1
  #ipsec auto --add L2TP-PSK
  #sleep 1
  ipsec auto --up L2TP-PSK
  sleep 3
  ipsec --status
  sleep 3


  # startup xl2tpd ppp daemon then send it a connect command
  (sleep 7 \
    && echo "startup/vpn: send connect command to vpn client." \
    && echo "c myVPN" > /var/run/xl2tpd/l2tp-control) &
  echo "startup/vpn: start vpn client daemon."
  exec /usr/sbin/xl2tpd -p /var/run/xl2tpd.pid -c /etc/xl2tpd/xl2tpd.conf -C /var/run/xl2tpd/l2tp-control -D &
else
  echo "startup/vpn: Ignore vpn client."
fi

# Wolffsohn - setup VPN provider route via local network, otherwise when default route set to ppp0 VPN, the VPN will stop working.
# Get Default Gateway
DEFAULT_ROUTE_IP=$(route | grep eth0 | grep default | awk '{print $2}')
echo DEFAULT_ROUTE_IP=$DEFAULT_ROUTE_IP
# route add 90.155.53.19 gw $DEFAULT_ROUTE_IP
# WOlffsohn - following is only needed if in a BRIDGED docker
route add -net $DEFAULT_ROUTE_IP/24 gw $DEFAULT_ROUTE_IP

# Run socks5 server after 10 Seconds if SCOKS5_ENABLE is 1
if [[ $SCOKS5_ENABLE -eq 1 ]];then
  echo "startup/socks5: waiting for ppp0"
  (while ! route | grep ppp0 > /dev/null; do sleep 1; done \
    && echo "startup/socks5: Socks5 will start in $SCOKS5_START_DELAY seconds" \
    && sleep $SCOKS5_START_DELAY \
    && sockd -N $SCOKS5_FORKS) &
else
  echo "startup/socks5: Ignore socks5 server."
fi

# Wolffsohn - add router functionality to server https://www.tecmint.com/setup-linux-as-router/
echo 1 > /proc/sys/net/ipv4/ip_forward    # or /etc/sysctl.conf  and add net.ipv4.ip_forward = 1
iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE
iptables -A FORWARD -i ppp0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o ppp0 -j ACCEPT

while true; do
  sleep 60
  if ! route | grep  ppp0 > /dev/null; then
      date
      echo "startup: wait 30 secs";
      sleep 30
      if  ! route | grep ppp0 > /dev/null;then
        echo "startup: VPN connection failed - restart docker";
        exit;
      else
        /successful.sh
      fi
  fi
done
