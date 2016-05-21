# VERSION 0.1
FROM debian:jessie
MAINTAINER Michael Eden <themichaeleden@gmail.com>

# runit depends on /etc/inittab which is not present in debian:jessie
RUN touch /etc/inittab
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
        runit \
        wget \
        openssh-server

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
RUN wget 'https://github.com/peterbourgon/runsvinit/releases/download/v2.0.0/runsvinit-linux-amd64.tgz' \
    -q -O '/tmp/runsvinit.tar.gz' && \
    tar -C '/tmp' -xf '/tmp/runsvinit.tar.gz' && \
    cp '/tmp/runsvinit' '/usr/sbin/init' && \
    chmod 755 '/usr/sbin/init' && \
    rm -rf '/tmp/runsvinit'

# TODO: configurable
RUN echo "root:toor" | chpasswd

ENTRYPOINT ["/usr/sbin/init"]

