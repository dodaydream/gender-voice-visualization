#!/bin/bash

# Start fcgiwrap using spawn-fcgi
spawn-fcgi -u www-data -g www-data -M 0775 -s /var/run/fcgiwrap.socket -U www-data -G www-data /usr/sbin/fcgiwrap

# Start Nginx in the foreground
nginx -g 'daemon off;'

