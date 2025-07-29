FROM ubuntu:22.04

LABEL maintainer="atik@we2app.com" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.name="Base Image" \
      org.label-schema.description="Base Image for all images - base on Ubuntu 20.04" 
      
ENV DEBIAN_FRONTEND=noninteractive \
      TERM=xterm

RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*
