FROM gliderlabs/alpine:3.6

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.docker.dockerfile="Dockerfile" \
      org.label-schema.license="MIT" \
      org.label-schema.name="ZNC with SASL and TOR support" \
      org.label-schema.description="This docker container was designed as a simple to use TOR with ZNC bouncer service for use on Freenode IRC server. This can however easily be adapted to be used on any server whether you require TOR or not." \
      org.label-schema.url="https://github.com/netspeedy/docker-torznc" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/netspeedy/docker-torznc.git" \
      org.label-schema.version=$VERSION \
org.label-schema.vcs-type="Git"

# Dockerfile author / maintainer 
MAINTAINER Simon Oakes <simon.oakes@netspeedy.co.uk> 

RUN apk add --no-cache \
    	bash \
        curl \
	tzdata \
	shadow \
	coreutils \
	ca-certificates \
	openssl \
    	oidentd \
   	proxychains-ng \
    	tor \
    	znc \
	znc-modtcl \
	znc-modperl \
	znc-extra \
	znc-modpython \
	supervisor \

# removes package cache 
&& rm -rf /var/cache/apk/* \
# purge old znc user
&& deluser znc \
# adds znc user/group
&& addgroup -S -g 1000 znc \
&& adduser -S znc -u 1000 -h /var/lib/znc -G znc -g "ZNC Bouncer" \ 
# purge old tor user
&& deluser tor \
# adds tor user/group
&& addgroup -S -g 1001 tor \
&& adduser -S tor -u 1001 -h /var/lib/znc -G tor -g "TOR" \ 
# creates logfile dir
&& mkdir /var/log/supervisor \
&& mkdir /etc/supervisor.d \
# creates supervisor user/group
&& addgroup -S -g 10000 supervisord \
&& adduser -S supervisord -u 10000 -h /etc/supervisor.d -G supervisord -g "Supervisor Daemon" \ 
# does the magic
&& touch /firstrun 

WORKDIR /usr/local/bin

# Copies overlay files
COPY ./files/overlay-etc/ /etc
COPY ./files/overlay-usr/ /usr

# Healthcheck
HEALTHCHECK --interval=5m --timeout=3s CMD curl -f http://localhost:9082/ || exit 1

# expose these ports 
# Port: 113 (ident), Port: 9082 (web server - non-ssl), Port: 6697 IRC (SSL)
EXPOSE 113 9082 6697
VOLUME ["/etc/znc", "/etc/tor", "/var/log" ]
ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
