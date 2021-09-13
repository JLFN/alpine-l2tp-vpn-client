alpine-l2tp-vpn-client
---
![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/ghostry/alpine-l2tp-vpn-client)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/ghostry/alpine-l2tp-vpn-client)
[![](https://images.microbadger.com/badges/image/ghostry/alpine-l2tp-vpn-client.svg)](https://microbadger.com/images/ghostry/alpine-l2tp-vpn-client "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/ghostry/alpine-l2tp-vpn-client.svg)](https://microbadger.com/images/ghostry/alpine-l2tp-vpn-client "Get your own version badge on microbadger.com")
![GitHub](https://img.shields.io/github/license/ghostry/alpine-l2tp-vpn-client)


An Alpine based docker image to setup an L2TP over IPsec VPN client w/ PSK (and optionally Socks5) within the container.


## Run
Setup environment variables for your credentials and config:

```bash
export VPN_SERVER='YOUR VPN SERVER IP OR FQDN'
export VPN_PSK='my pre shared key'
export VPN_USERNAME='myuser@myhost.com'
export VPN_PASSWORD='mypass'
export SCOKS5_ENABLE=0
```
Now run it (you can daemonize of course after debugging):
```bash
docker run --rm -it --privileged \
           -e VPN_SERVER \
           -e VPN_PSK \
           -e VPN_USERNAME \
           -e VPN_PASSWORD \
           --dns=114.114.114.114 \
              ghostry/alpine-l2tp-vpn-client
```
You can use `.env` file:
```bash
source .env;docker run --rm -it --privileged --env-file .env -p ${SCOKS5_PORT}:1080 ghostry/alpine-l2tp-vpn-client
```

## Socks5
If you set `SCOKS5_ENABLE` to `1` (default value is `0`), the container will run `dante` at startup to provide a socks5 proxy (via VPN). Don not forget to expose port 1080.
```bash
export SCOKS5_ENABLE=0
export SCOKS5_PORT=1080
docker run --rm -it --privileged \
           -e VPN_SERVER \
           -e VPN_PSK \
           -e VPN_USERNAME \
           -e VPN_PASSWORD \
           -e SCOKS5_ENABLE \
           -p ${SCOKS5_PORT}:1080 \
           --dns=114.114.114.114 \
              ghostry/alpine-l2tp-vpn-client
```

## Debugging
On your VPN client localhost machine you may need to `sudo modprobe af_key`
if you're getting this error when starting:
```
pluto[17]: No XFRM/NETKEY kernel interface detected
pluto[17]: seccomp security for crypto helper not supported
```


---

This project is forked from [Wolffsohn/alpine-l2tp-vpn-client](https://github.com/Wolffsohn/alpine-l2tp-vpn-client)
