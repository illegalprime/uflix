# VERSION 0.1
FROM debian:jessie
MAINTAINER Michael Eden <themichaeleden@gmail.com>

ENV SSH_PORT 2222

# runit depends on /etc/inittab which is not present in debian:jessie
RUN touch /etc/inittab
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
        runit \
        openssh-server

COPY init /usr/sbin/init
RUN chmod 755 /usr/sbin/init

COPY etc /etc

# setup runit services by running the `setup` script
# in each service directory
RUN for SETUP in /etc/sv/*/setup; do \
        $SETUP; \
    done

# enable every runit service
RUN for SERVICE in /etc/sv/*; do \
        ln -s "$SERVICE" /etc/service/ ; \
    done

expose $SSH_PORT 22

ENTRYPOINT ["/usr/sbin/init"]

