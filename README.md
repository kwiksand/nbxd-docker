# nbxd-docker
Netbox (NBX) Damon / Wallet Blockchain in Docker

This container uses the cryptocoin-base container (https://quay.io/repository/kwiksand/cryptocoin-base) which installs ubuntu and all the bitcoin build dependencies (miniupnp, berkelyDB 4.8, system build tools, etc)

## Usage

This repository contains the docker build if you'd like to manually build, but also points back at the quay.io docker build image (i.e `docker pull quay.io/kwiksand/nbxd:latest`).

To setup in the simplest way:
* Install docker-ce (any recent docker version) on your machine/VPS/Raspberry Pi
* Checkout git repository - `git clone https://github.com/kwiksand/nbxd-docker.git`
* Make a directory for the wallet/blockchain/logs to sit/write to - `mkdir /media/crypto/nbx`
* Edit docker-compose.yml, changing the volume line to the directory chosen above:
```bash
  volumes:
   - /media/crypto/nbx:/home/nbx/.nbx
```
* Copy the example config, moving it to the directory chosen above:
```bash
  cp nbx.conf.example /media/crypto/nbx/nbx.conf
```
* Edit the new config, changing the username and password (something long/random)
* Start via docker-compose - `docker-compose up -d`
* After a short while downloading the image and starting the container you should start to see the directory (/media/crypto/nbx) fill with content
* Wait for the blockchain sync to complete - `tail -f /media/crypto/nbx/debug.log`

By this stage you have a working nbx wallet/blockchain setup, now we need to set up the masternode itself:
