# VERSION 0.1
FROM debian:jessie
MAINTAINER Michael Eden <themichaeleden@gmail.com>

ARG password

# runit depends on /etc/inittab which is not present in debian:jessie
RUN touch /etc/inittab

# install software
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
        wget \
        openssh-server \
        dbus \
        avahi-daemon \
        runit

# Download plex
ARG pkg_path
COPY "$pkg_path" /tmp/plexmediaserver.deb

# Install Plex
RUN ln -s /bin/true /usr/sbin/start && \
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
ADD "https://github.com/peterbourgon/runsvinit/releases/download/v2.0.0/runsvinit-linux-amd64.tgz" \
    /tmp/runsvinit.tar.gz
RUN tar -C /tmp -xf /tmp/runsvinit.tar.gz && \
    cp /tmp/runsvinit /usr/sbin/runsvinit && \
    chmod 755 /usr/sbin/runsvinit && \
    rm -rf /tmp/runsvinit

RUN echo "root:$password" | chpasswd

ARG plex_home
RUN mkdir -p "${plex_home}"

# list exposed ports
# sshd & plex
EXPOSE 22 32400 32400/udp 32469 32469/udp 5353/udp 1900/udp

COPY init /usr/sbin/init
RUN chmod 755 /usr/sbin/init
ENTRYPOINT ["/usr/sbin/init"]

