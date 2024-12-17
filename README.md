# Docker container with Wireguard and Mullvad VPN

## Overview

#### This container sets up a Mullvad WireGuard VPN and exposes a SOCKS5 proxy, so you can route traffic through Mullvad.  
   
I'm brand new to docker, and this is my first container (please be nice!).  
This is not a fully optimized container in any way - but a start.

------
#### About the image  
Base image:  [Ubuntu](https://hub.docker.com/_/ubuntu/):20.04  
Extra packages: wireguard-tools, iproute2, iptables, dante-server, curl, openresolv



#### My build environment:
Debian 12 VM (docker host)  
Docker Compose version v2.31.0  
Git version 2.39.5
Portainer Standalone 27.4.0 for container management


### Prerequisites
* A valid Mullvad WireGuard configuration file. 
* Docker and Docker Compose installed. 
* Git - Not needed, but "nice to have". 


## Get started 
### Step 1: Generate and download the config file
1.	Log in to your account on [Mullvad.net](https://mullvad.net)
2.	Open the [WireGuard configuration file generator](https://mullvad.net/en/account/wireguard-config)
3.	Click "Generate a key" and scroll to the bottom of the page.
4.	Select a country, city and one server
5.	Generate and download configuration -> Download file
6.	Rename to `wg0.conf` and put it where you map your container volume.

Ensure that the file contains `[Interface]` and `[Peer]` settings.

### Step 2: Get the files
1. `cd` into the empty directory you want to store the sourcefiles.
2. Clone this repo: `git clone https://github.com/nixern/wireguard-mullvad.git`
3. Make sure you have all the files needed:
	```bash
	/projectdir/
	├─ docker-compose.yml
	├─ Dockerfile
	├─ dante.conf
	└─ start.sh

	./wg-configs/
	└─ wg0.conf
	```

### Step 3: Configure docker-compose file
```yaml
services:
  wireguard-mullvad:
    build: .
    container_name: wireguard-mullvad	# Name it whatever you like.
    network_mode: "host"				# Using host network creates a wg0 interface.
    ports:								# Remove ports if networkmode host is used.
      - "1080:1080"						# If you change the container port here, change port in dante.conf accordingly.
    cap_add:
      - NET_ADMIN						# Required so container can manage network interfaces and routing on the host.
    privileged: true					# Same as above
    volumes:
      - ./wg-configs:/etc/wireguard 	# Location of your Mullvad WireGuard configuration file
    environment:
      - WG_CONFIG=wg0.conf				# The name of your WireGuard config
    restart: unless-stopped
```

### Step 4: Start it!
1. `cd`to the directory with the source files
2. Run `docker compose build`
3. Run `docker compose up` or `docker compose up -d` for detached mode  

### Step 5: Use it
You can now route your traffic through the SOCKS5 proxy:
```
Protocol: SOCKS v5
SOCKS Host: Docker Host IP (or local dns name)
SOCKS Port: 1080
```



## Confirming that VPN is connected:
1.	Make sure the container is listening on the specified port  
	On the host, run: ```nmap -p1010 localhost```  
    Expected output:
	```console
	PORT     STATE SERVICE
	1080/tcp open  socks
	```
2. Set a browser to use SOCKS5 proxy and visit [Mullvad connection check](https://mullvad.net/en/check)  
   Expected output: "Using Mullvad VPN"

3. Check VPN connection inside the running container:  
Find the name of the running container with `docker ps`.  
Run curl command inside the container: `docker exec -it <containername> curl https://am.i.mullvad.net/connected`  
If the VPN connection is up, it outputs:
```console
You are connected to Mullvad (server "your vpn server choice" ). Your IP address is "your vpn ip"
```
### Safe anonymous browsing!

---

### Things to improve
* Add support for kill switch if VPN is down.
* Slimmer base image! Currently 1.3GB :(
* Add support for multiple vpn endpoint servers (multiple configs)
* Run in its own docker network and let other containers use same network with `--network container: <name|id>`