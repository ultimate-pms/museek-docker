FROM ubuntu:trusty

# Set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="ned-kelly"

RUN apt-get update; apt-get install -y museekd museekd-tools museeq git && \
    apt-get install -y curl net-tools novnc openbox patch supervisor x11vnc xvfb

COPY ui.patch /tmp

RUN curl -fL# https://github.com/novnc/noVNC/archive/v1.0.0.tar.gz -o /tmp/novnc.tar.gz && \
    tar -xvzf /tmp/novnc.tar.gz -C /tmp && \
    rm -rf /usr/share/novnc/* && \
    bash -c 'cp -r /tmp/noVNC*/{app,core,karma.conf.js,package.json,po,tests,utils,vendor,vnc.html,vnc_lite.html} /usr/share/novnc' && \
    curl -fL# https://use.fontawesome.com/releases/v5.0.10/svgs/solid/cloud-download-alt.svg -o /usr/share/novnc/app/images/downloads.svg && \
    curl -fL# https://use.fontawesome.com/releases/v5.0.10/svgs/solid/comments.svg -o /usr/share/novnc/app/images/logs.svg && \
    bash -c 'sed -i "s/<path/<path style=\"fill:white\"/" /usr/share/novnc/app/images/{downloads,logs}.svg' && \
    patch /usr/share/novnc/vnc.html < /tmp/ui.patch

ADD etc /etc
ADD usr /usr

RUN git clone https://github.com/eLvErDe/museek-plus.git /museek-plus && \
    mkdir -p /root/.museekd/logs/ && \
    ln -s /museek-plus/python-clients/museekcontrol /root/.museekd/museekcontrol

COPY museekd_config.xml.default /root/.museekd/config.xml
COPY museekcontrol.config.default /root/.museekd/museekcontrol.config
COPY museeq.conf.default /root/.config/MuseekPlus.org/museeq.conf

## Build Newsoul server - Uncomment and built at your own risk, seems to be somewhat stable on older ubuntu builds but not trusty. NB This is only the museekd daemon, the museek+ front-end and pythons scripts still need to stay...
#
# RUN apt-get install -y nano premake4 cpputest build-essential libjson-c-dev libpcre++-dev libsqlite3-dev nettle-dev \
#    libtaglib-ocaml-dev libtaglib-cil-dev libtag-extras-dev libghc-libtagc-dev python-pycryptopp libevent-dev \
#    nanogit clone https://github.com/KenjiTakahashi/newsoul.git /newsoul/ && \
#    cd /newsoul/build && premake4 gmake && make newsoul

RUN apt-get install -y python-pip && pip install supervisor-stdout

# Set the cron file from volume mounted in
RUN crontab /scripts/cron

EXPOSE 2234
EXPOSE 2235
EXPOSE 2236
EXPOSE 2237
EXPOSE 2238
EXPOSE 2239
EXPOSE 2240

ENTRYPOINT ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
#CMD ["museekd"]

