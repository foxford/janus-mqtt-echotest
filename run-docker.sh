#!/bin/sh

PROJECT='janus-ws-ex'
PROJECT_DIR="/opt/sandbox/${PROJECT}"
DOCKER_CONTAINER_NAME="sandbox/${PROJECT}"
DOCKER_CONTAINER_COMMAND=${DOCKER_CONTAINER_COMMAND:-'/bin/bash'}

read -r DOCKER_RUN_COMMAND <<-EOF
	service rsyslog start \
		&& service nginx start \
		&& vernemq start
EOF

docker build -t ${DOCKER_CONTAINER_NAME} .
docker run -ti --rm \
	-p 8080:8080 \
	-p 8088:8088 \
	-p 8089:8089 \
	-p 5002:5002/udp \
	-p 5004:5004/udp \
	-p 1935:1935 \
	-p 8188:8188 \
	-p 8989:8989 \
	-p 7800:7800 \
	-p 7880:7880 \
	${DOCKER_CONTAINER_NAME} \
	/bin/bash -c "set -x && ${DOCKER_RUN_COMMAND} && set +x && ${DOCKER_CONTAINER_COMMAND}"
