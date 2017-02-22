# janus-mqtt-echotest
Janus websocket (over MQTT) connection test

#Setup

##Run docker (first-tab)
````
./run-docker.sh
````
##Execute in docker container
````
/opt/janus/bin/janus
````
##Install dependencies: (second-tab)
````
npm install
bower install
````
##Start application
````
npm start
````

##Execute video (third-tab)
````
 ffmpeg \
   -f lavfi -re -i "testsrc=duration=-1:size=1280x720:rate=15" \
   -f lavfi -re -i "sine=f=50:beep_factor=6" \
   -pix_fmt yuv420p \
   -c:v libvpx -g 180 -deadline realtime -an -f rtp rtp://$(docker-machine ip):5004 \
   -c:a libopus -vn -f rtp rtp://$(docker-machine ip):5002
````