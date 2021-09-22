alpine-l2tp-vpn-client
---
把l2tp转为socks5

## 使用

```bash
docker run -d \
    --name l2tp2scoks5 \
    --privileged \
    -e VPN_SERVER='YOUR VPN SERVER IP OR FQDN' \
    -e VPN_PSK='my pre shared key' \
    -e VPN_USERNAME='myuser@myhost.com' \
    -e VPN_PASSWORD='mypass' \
    -p 1080:1080 \
    --dns=8.8.8.8 \
    ghostry/alpine-l2tp-vpn-client
```

---

This project is forked from [Wolffsohn/alpine-l2tp-vpn-client](https://github.com/Wolffsohn/alpine-l2tp-vpn-client)
