# VERSION 0.1
FROM debian:jessie
MAINTAINER Michael Eden <themichaeleden@gmail.com>

ARG password=toor
ARG plex_home
ENV PLEX_HOME ${plex_home}

# runit depends on /etc/inittab which is not present in debian:jessie
RUN touch /etc/inittab

# install software
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
        wget \
        openssh-server \
        dbus \
        runit

# Install Plex
RUN wget "https://plex.tv/downloads/latest/1?channel=8&build=linux-ubuntu-x86_64&distro=ubuntu" \
    -q -O /tmp/plexmediaserver.deb && \
    ln -s /bin/true /usr/sbin/start && \
    dpkg -i /tmp/plexmediaserver.deb && \
    rm -f /tmp/plexmediaserver.deb

COPY etc /etc

# setup runit services by running the `setup` script
# in each service directory
RUN for SETUP in /etc/sv/*/setup; do \
        $SETUP ; \
    done

# enable every runit service
RUN for SERVICE in /etc/sv/*; do \
        ln -s "$SERVICE" /etc/service/ ; \
    done

# remove weird getty service
RUN rm -rf /etc/service/getty*

# get a wrapper for runit, see:
# https://peter.bourgon.org/blog/2015/09/24/docker-runit-and-graceful-termination.html
RUN wget "https://github.com/peterbourgon/runsvinit/releases/download/v2.0.0/runsvinit-linux-amd64.tgz" \
    -q -O /tmp/runsvinit.tar.gz && \
    tar -C /tmp -xf /tmp/runsvinit.tar.gz && \
    cp /tmp/runsvinit /usr/sbin/init && \
    chmod 755 /usr/sbin/init && \
    rm -rf /tmp/runsvinit

RUN echo "root:$password" | chpasswd

# list exposed ports
# sshd & plex
EXPOSE 22 32400 32400/udp 32469 32469/udp 5353/udp 1900/udp

# save all the environment variables
RUN env > /etc/environment

ENTRYPOINT ["/usr/sbin/init"]

