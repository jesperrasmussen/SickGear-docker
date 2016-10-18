FROM python:2.7-alpine
MAINTAINER Jesper Rasmussen <me@jesperrasmussen.com>

ENV SICKGEAR_VERSION develop

# Download gosu and SickGear.
RUN apk --update add tar
RUN apk add --update \
      ca-certificates \
      curl \
      gcc \
      gnupg \
      libxml2 \
      libxml2-dev \
      libxslt \
      libxslt-dev \
      musl-dev \
      tar \
      tzdata \
      && \
    gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    ARCH=`uname -m`; if [ $ARCH == "x86_64" ]; then export ARCH="amd64"; else export ARCH="i386"; fi && \
    curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$ARCH" && \
    curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$ARCH.asc" && \
    gpg --verify /usr/local/bin/gosu.asc && \
    rm /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu && \
    mkdir -p /opt/SickGear-${SICKGEAR_VERSION}/ && \
    curl -SL "https://api.github.com/repos/SickGear/SickGear/tarball/${SICKGEAR_VERSION}" | \
      tar xz -C /opt/SickGear-${SICKGEAR_VERSION} --strip-components 1 && \
    mv /opt/SickGear-${SICKGEAR_VERSION} /opt/SickGear && \
    pip install --no-cache-dir lxml && \
    pip install --no-cache-dir -r /opt/SickGear/requirements.txt && \
    apk del \
      ca-certificates \
      curl \
      gcc \
      gnupg \
      libxml2-dev \
      libxslt-dev \
      musl-dev \
      && \
    rm -rf /var/cache/apk/*

ENV APP_DATA="/data" PATH=/opt/SickGear:$PATH

EXPOSE 8081
VOLUME /data /tv /incoming

COPY template /template
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["SickBeard.py"]
