FROM ubuntu:16.04

RUN set -xe \
	&& apt-get update \
	&& apt-get -y --no-install-recommends install \
		software-properties-common \
		lsb-release \
		curl \
	&& add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu/ $(lsb_release -sc) multiverse" \
	&& add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu/ $(lsb_release -sc)-updates multiverse" \
	&& add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu/ $(lsb_release -sc)-security multiverse" \
	&& apt-get update && apt-get -y --no-install-recommends install \
		ca-certificates \
		libwebsockets-dev \
		libmicrohttpd-dev \
		libjansson-dev \
		libnice-dev \
		libssl-dev \
		libsrtp-dev \
		libsofia-sip-ua-dev \
		libglib2.0-dev \
		libopus-dev \
		libogg-dev \
		dpkg-dev \
		pkg-config \
		gengetopt \
		libtool \
		automake \
		vim-nox \
		git \
		htop \
		gstreamer1.0-tools \
		gstreamer1.0-libav \
		gstreamer1.0-plugins-good \
		gstreamer1.0-plugins-bad \
		nginx \
		rsyslog \
	&& USRSCTP_BUILD_DIR='/tmp/usrsctp' \
	&& mkdir "${USRSCTP_BUILD_DIR}" \
	&& cd "${USRSCTP_BUILD_DIR}" \
		&& git clone https://github.com/sctplab/usrsctp . \
		&& ./bootstrap \
		&& ./configure --prefix=/usr \
		&& make -j $(nproc) \
		&& make install \
		&& rm -fr "${USRSCTP_BUILD_DIR}" \
  && PAHO_CLIENT_BUILD_DIR='/tmp/paho' \
  && mkdir "${PAHO_CLIENT_BUILD_DIR}" \
  && cd "${PAHO_CLIENT_BUILD_DIR}" \
    && git clone https://github.com/eclipse/paho.mqtt.c.git . \
    && git checkout v1.1.0 \
    && make -j $(nproc) \
    && make install \
    && rm -fr "${PAHO_CLIENT_BUILD_DIR}" \
	&& JANUS_BUILD_DIR='/tmp/janus' \
	&& mkdir "${JANUS_BUILD_DIR}" \
	&& cd "${JANUS_BUILD_DIR}" \
		&& git clone https://github.com/meetecho/janus-gateway.git . \
		&& ./autogen.sh \
		&& ./configure --prefix=/opt/janus --disable-rabbitmq \
		&& make || true \
		&& make -j $(nproc) \
		&& make install \
		&& make configs \
		&& rm -fr "${JANUS_BUILD_DIR}" \
		&& echo "\
			server {\n\
				listen 8080 ssl;\n\
				ssl_certificate /opt/janus/share/janus/certs/mycert.pem;\n\
				ssl_certificate_key /opt/janus/share/janus/certs/mycert.key;\n\
				location / {\n\
					root /opt/janus/share/janus/demos;\n\
				}\n\
			}\n\
		" > /etc/nginx/sites-enabled/janus \
		&& perl -pi -e 's/\Ahttps\s*=.*/https = yes/' /opt/janus/etc/janus/janus.transport.http.cfg \
		&& perl -pi -e 's/\A;\s*secure_port\s*=.*/secure_port = 8089/' /opt/janus/etc/janus/janus.transport.http.cfg \
		&& perl -pi -e 's/\Awss\s*=.*/wss = yes/' /opt/janus/etc/janus/janus.transport.websockets.cfg \
		&& perl -pi -e 's/\A;\s*wss_port\s*=.*/wss_port = 8989/' /opt/janus/etc/janus/janus.transport.websockets.cfg \
		&& perl -pi -e 's/(enable = )no/${1}yes/' /opt/janus/etc/janus/janus.transport.mqtt.cfg \
		&& perl -pi -e 's/(admin_enable = )no/${1}yes/' /opt/janus/etc/janus/janus.transport.mqtt.cfg \
		&& perl -pi -e 's/(debug_level = )4/${1}6/' /opt/janus/etc/janus/janus.cfg

## -----------------------------------------------------------------------------
## Installing VerneMQ
## -----------------------------------------------------------------------------
RUN set -xe \
  && apt-get -y --no-install-recommends install \
    mosquitto-clients \
  && VERNEMQ_URI='https://bintray.com/artifact/download/erlio/vernemq/deb/xenial/vernemq_0.15.3-1_amd64.deb' \
  && VERNEMQ_SHA1='15331c100e73e97294cd4986343795f07c1f9ae1' \
  && curl -fSL -o vernemq.deb "${VERNEMQ_URI}" \
    && echo "${VERNEMQ_SHA1} vernemq.deb" | sha1sum -c - \
    && set +e; dpkg -i vernemq.deb || apt-get -y -f --no-install-recommends install; set -e \
    && rm vernemq.deb

## -----------------------------------------------------------------------------
## Setting up VerneMQ
## -----------------------------------------------------------------------------
RUN set -xe \
	&& perl -pi -e 's/(allow_anonymous = )off/${1}on/' /etc/vernemq/vernemq.conf \
	&& perl -pi -e 's/\A(listener.tcp.default = .*)/${1}\nlistener.ws.default = 0.0.0.0:7800\nlistener.wss.default = 0.0.0.0:7880\nlistener.wss.certfile = \/opt\/janus\/share\/janus\/certs\/mycert.pem\nlistener.wss.keyfile = \/opt\/janus\/share\/janus\/certs\/mycert.key/' /etc/vernemq/vernemq.conf \
	&& perl -pi -e 's/\Alog.syslog\s*=.*/log.syslog = on/' /etc/vernemq/vernemq.conf
	
