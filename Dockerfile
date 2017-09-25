FROM node:4-slim

# install required packages, in one command
RUN apt-get update  && \
    apt-get install -y  python-dev

ENV PYTHON /usr/bin/python2

# install node-red
RUN apt-get install -y build-essential && \
    npm install -g --unsafe-perm  node-red && \
    apt-get autoremove -y build-essential

# install RPI.GPIO python libs including nrgpio patch
RUN apt-get install -y wget && \
     wget http://downloads.sourceforge.net/project/raspberry-gpio-python/raspbian-jessie/python-rpi.gpio_0.6.3~jessie-1_armhf.deb && \
     dpkg -i python-rpi.gpio_0.6.3~jessie-1_armhf.deb && \
     rm python-rpi.gpio_0.6.3~jessie-1_armhf.deb && \
     apt-get autoremove -y wget
RUN touch /usr/share/doc/python-rpi.gpio
COPY ./source /usr/local/lib/node_modules/node-red/nodes/core/hardware
RUN chmod 777 /usr/local/lib/node_modules/node-red/nodes/core/hardware/nrgpio

# prepare python environment
WORKDIR /root/bin
RUN ln -s /usr/bin/python2 ~/bin/python
RUN ln -s /usr/bin/python2-config ~/bin/python-config
env PATH ~/bin:$PATH

# create /data for data directory
RUN mkdir /data

# Create volume for Node-RED storage so that this can be mounted
VOLUME /data

# Expose port 1880
EXPOSE 1880

# Setup start command with options to specify data directory + flow file
ENTRYPOINT ["node-red-pi","-v", "--max-old-space-size=128","--userDir","/data", "flow.json"]
