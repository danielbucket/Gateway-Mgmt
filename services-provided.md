# The BucketLab Gateway / LAN Access Point
**Machine Specifics**:
- **Operating System**: `Ubuntu 24.04.4 LTS (GNU/Linux 6.8.0-1060-raspi aarch64)`
- **IP ADDRESS (DHCP-eth0)**: `192.168.2.202`
- **IP ADDRESS (Wireguard-wg0)**: `10.0.0.1`


### The gateway server provides these services:
- Wireguard Server
- Pi-Hole
- Prometheus
- BucketLab API
- SAMBA Client
- Timemachine Backup
- UFW
- MQQT
- Cloudflare
- SSH

## Wireguard Server
### This is the the top-level VPN that encapsulates the BucketLab LAN. Two VPNs are enabled. The first, `wg0`, encrypts local data. The second, `wg-mullvad` is daisy-chained in-line with wg0 and routes internet traffic annonymously to a Mullvad VPN server. When enabled, `the default interface is deleted and replaced with wg0`.
- **Network Address Range**: `10.0.0.0/32`
- **Config Files**:
  - `/etc/wireguard/wg-mullvad.conf`
  - `/etc/wireguard/wg0.conf`

## Pi-Hole
### Ad-blocking for the BucketLab network. This is the DNS server for the BucketLab network and all internet traffic passes through here.
  - **DNS IP ADDRESS**: `10.0.0.1`
  - **URL**: `192.168.2.202/admin/login`

## Prometheus
### Monitoring the BucketLab Gateway, but also various other services that are being run on other machines on the LAN. Another service called Node_Exporter is dependant on Prometheus and provides local hardware data.
- **Startup Command**: `/usr/bin/prometheus --web.listen-address=0.0.0.0:9090`
- **URL**: `10.0.0.1:9090/classic/graph`
- **Config Files**:
  - **Default/Environmental Files**: `/etc/default/prometheus`
  - **Prometheus Config File**: `/etc/prometheus/prometheus.yml`
  - **Prometheus Rules File**: `/etc/prometheus/prometheus.rules.yml`
  - **Service Config File**: `/usr/lib/systemd/system/prometheus.service`

## BucketLab API
### This is the core database for the bucketlab.io web app. User data and images relevant to the web app are stored here.
  - **Test URL**: `https://api.bucketlab.io/health`

## Samba
### Samba serves files for local media streaming (movies, music), and for the Timemachine backup.
- **Directories Served**:
  - /srv/samba/movies
  - /srv/samba/music


## Timemachine Backup:
### The main Macbook Pro computer backup source. It is made available on the network by Samba.

## UFW
### Certain rules have been added, restricting data traffic to specified routes and adding a layer of security to the network.

## SSH
### SSH has been configured to communicate only over the 10.0.0.1:22 address.
- **Config File**: `~/etc/ssh/sshd_config`