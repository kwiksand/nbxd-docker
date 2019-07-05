libgl1-mesa-dev libopenal-dev libsndfile-dev libmpg123-dev libgmp-dev ruby-devFROM ubuntu:18.04 as builder

RUN useradd -m netbox

ENV DAEMON_RELEASE="v3.3.0"
#ENV DAEMON_RELEASE="master"
#ENV GIT_COMMIT="cabbdc220a6d35fb4b00d9c4655b217b2a4d62b3"
ENV netbox_DATA=/home/netbox/.netbox

USER root

RUN apt-get update \
    && apt-get install -y libcurl4 libcurl4-openssl-dev \
    && apt-get install --no-install-recommends --yes \
        software-properties-common git ssh automake autoconf pkg-config libtool build-essential \
        curl bsdmainutils gosu \
    && rm -rf /var/lib/apt/lists/*

USER netbox

RUN cd /home/netbox && \
    mkdir /home/netbox/bin && \
    mkdir .ssh && \
    chmod 700 .ssh && \
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts && \
    ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts && \
    git clone --branch $DAEMON_RELEASE https://github.com/NetboxGlobal/Netbox.Wallet.git nbxd && \
    cp nbxd/contrib/debian/examples/nbx.conf /home/netbox/netbox.conf && \
    cd /home/netbox/nbxd/depends && \
    make -j$(nproc)

RUN cd /home/netbox/nbxd && \
    ./autogen.sh && \
    CONFIG_SITE=$PWD/depends/x86_64-pc-linux-gnu/share/config.site ./configure --without-gui && \
    make -j$(nproc) && \
    strip .//src/nbxd .//src/nbx-cli .//src/nbx-tx

#RUN chmod 755 /home/netbox/bin/nbxd && \

RUN cd /home/netbox/nbxd && \
    cp ./src/nbxd /home/netbox/bin/nbxd && \
    cp ./src/nbx-cli /home/netbox/bin/nbx-cli && \
    cp ./src/nbx-tx /home/netbox/bin/nbx-tx && \
    chmod 755 /home/netbox/bin/nbxd && \
    chmod 755 /home/netbox/bin/nbx-cli && \
    chmod 755 /home/netbox/bin/nbx-tx && \
    rm -rf /home/netbox/nbxd
    
EXPOSE 28734 28735

USER root

COPY docker-entrypoint.sh /entrypoint.sh

RUN chmod 777 /entrypoint.sh && \
    mv /home/netbox/bin/* /usr/bin && \
    echo "\n# Some aliases to make the netbox clients/tools easier to access\nalias nbxd='/usr/bin/nbxd -conf=/home/netbox/.netbox/netbox.conf'\nalias nbx-cli='/usr/bin/nbx-cli -conf=/home/netbox/.netbox/netbox.conf'\n\n[ ! -z \"\$TERM\" -a -r /etc/motd ] && cat /etc/motd" >> /etc/bash.bashrc && \
    echo "netbox (NBX) Cryptocoin Daemon\n\nUsage:\n nbx-cli help - List help options\n nbx-cli listtransactions - List Transactions\n\n" > /etc/motd

#ENTRYPOINT ["/entrypoint.sh"]

#CMD ["nbxd"]
