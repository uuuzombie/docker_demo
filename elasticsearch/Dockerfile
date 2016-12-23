FROM debian:7.10
MAINTAINER grong@skygurad.com

# apt
COPY sources.list /etc/apt
RUN apt-get update && apt-get install -y sudo procps net-tools less vim curl ttf-mscorefonts-installer \
    libxtst-dev libxrender-dev

# set timezone
RUN echo "Asia/Shanghai" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


# install elasticsearch

RUN mkdir -p /opt/program
COPY deb_files/ /opt/program
RUN dpkg -i /opt/program/elasticsearch-5.0.0.deb && \
	rm -rf /opt/program


# config


# environment

# copy resources


# es-head
