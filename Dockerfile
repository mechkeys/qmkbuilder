# Build an image:
#       docker build -t qmkbuilder ~/dev/qmkbuilder
#       docker run -it qmkbuilder bash
#
#   docker run --name="qmkbuilder" --rm -it -p 8080:80 -v ~/dev/qmkbuilder:/var/www/qmkbuilder qmkbuilder /bin/bash
#

FROM ubuntu:16.10
MAINTAINER Scott Wilson <scott.t.wilson@gmail.com>
EXPOSE 80

# Set the TZ
RUN echo "US/Eastern" > /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN apt-get update && apt-get upgrade -y && apt-get install --no-install-recommends -y \
 git\
 npm\
 vim\
 telnet\
 curl\
 build-essential\
 gcc\
 unzip\
 wget\
 zip\
 gcc-avr\
 binutils-avr\
 avr-libc\
 dfu-programmer\
 dfu-util\
 gcc-arm-none-eabi\
 binutils-arm-none-eabi\
 libnewlib-arm-none-eabi\
 apache2\
 supervisor

# final cleanup
# RUN apt-get clean
# RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/tmp/mod_auth_openidc

# Link for nodejs so that in can be found where some scripts expect it
RUN ln -s /usr/bin/nodejs /usr/bin/node

# Enable/disable relevant apache sites/modules
COPY apache.conf /etc/apache2/sites-available/qmkbuilder.conf
RUN a2dissite 000-default.conf default-ssl.conf
RUN a2ensite qmkbuilder.conf
RUN a2enmod proxy proxy_http
RUN mkdir -p /var/lock/apache2 /var/run/apache2

# Copy the supervisor file, and set the default command
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
