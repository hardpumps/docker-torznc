# ZNC with SASL and TOR support using Alpine linux
[![](https://images.microbadger.com/badges/image/netspeedy/tor-znc.svg)](https://microbadger.com/images/netspeedy/tor-znc "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/netspeedy/tor-znc.svg)](https://microbadger.com/images/netspeedy/tor-znc "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/license/netspeedy/tor-znc.svg)](https://microbadger.com/images/netspeedy/tor-znc "Get your own license badge on microbadger.com")

This docker container was designed as a simple to use TOR with ZNC bouncer service for use on Freenode IRC server.  This can however easily be adapted to be used on any server whether you require TOR or not.

# Usage
```
docker create \
    --name tor-znc \
    -p 113:113 \
    -p 8092:8092 \
    -p 6697:6697 \
    -e TZ=<timezone> \ 
    -v /etc/localtime:/etc/localtime:ro \
    -v </path/to/znc-conf>:/etc/znc \
    -v <path/to/tor-conf>:/etc/tor \
    -v <path/to/logs>:/var/log \
    netspeedy/tor-znc
```
# Additional required configuration
  
After you have launched the docker container, you will need to issue the following command to finish the setup of SASL.

``` docker exec -it tor-znc create-sasl-user ```
  
This will create the SASL user configuration.  Please take note that if you do not give it any params, it will create the default user from the tweaked znc config which I have provided.

You should see an output something like as shown below.

````
$ docker exec -it tor-znc create-sasl-user
Generating a 2048 bit RSA private key...
writing new private key to '/etc/znc/users/admin/networks/freenode/..'
/msg NickServ CERT ADD a7df212a58b15d72f0bd5feb5a653e6e0116e46e  
````

Due to IRC services like Freenode won't let you connect unless you give them your SASL cert fingerprint, you will need to type the last line posted above in the **create-sasl-user** output **(/msg)** into your IRC client.  

This instructs NickServ to add the SASL cert fingerprint to your NickServ account which is required if you're coming from a TORified IP.  This will need to be done manually by connecting to IRC without ZNC and then auth with your NickServ account follow by the **/msg** line.  

This will add your SASL cert fingerprint to your NickServ account which will then allow you to connect using the cert instead.

# Inform ZNC that you want to connect via SAL 

The final commands you need to do is instruct ZNC to connect using your NickServ account with your SASL cert.

```
/msg *status loadmod sasl
/msg *sasl set {NickServUser} {NickServPass}
/msg *sasl RequireAuth yes
/msg *sasl MECHANISM external 
```
| NickServUser | NickServPass |
| -------- | -------- |
| Your NickServ Username  | Your NickServ Password |


This will complete the configuration and you will then be able to connect to IRC via ZNC bouncer.

# create-sasl-user (optional parameters)

```
docker exec -it tor-znc create-sasl-user {USER} {NEYWORK} {NICK}
```

| USER | NETWORK | NICK |
| -------- | -------- | -------- |
| ZNC Username | IRC Network Name | IRC Nickname |

# Web UI
The WebUI is accessable by visting http://IP:9082 in your web browser.  
This **PORT** isn't SSL enabled by design as its intended to be run behind a reverse proxy.  

I highly recomend [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy) with the [letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion) to accomplish this.

| Username (default) | Password (default) |
| -------- | -------- |
| admin  | admin |

Please make sure you change your login password.
  


