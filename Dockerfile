# ------------------------------------------------------------------------------
# Docker provisioning script for the docker-laravel web server stack
#
# 	e.g. docker build -t samuelterra22/docker-laravel:version .
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Start with a base image
# ------------------------------------------------------------------------------

FROM samuelterra22/docker-base

MAINTAINER Samuel Terra <samuelterra22@hotmail.com>

# Use Supervisor to run and manage all other services
CMD ["supervisord", "-c", "/etc/supervisord.conf"]

# ------------------------------------------------------------------------------
# Provision the server
# ------------------------------------------------------------------------------

RUN mkdir /provision
ADD provision /provision
RUN /provision/provision.sh

# ------------------------------------------------------------------------------
# Clean up
# ------------------------------------------------------------------------------

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
