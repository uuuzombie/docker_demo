FROM debian:7.10
MAINTAINER grong@skygurad.com

# apt
COPY sources.list /etc/apt
RUN apt-get update && apt-get install -y sudo procps net-tools less vim curl \
    perl apache2.2-common apache2-mpm-worker apache2 libapache2-mod-wsgi

# set timezone
RUN echo "Asia/Shanghai" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata


#ServerName
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# conf
RUN rm -rf /etc/apache2/ports.conf && \
	mkdir -p /opt/skyguard/tomcat/webapps/webManager && \
	mkdir -p /opt/skyguard/sps
COPY conf/ports.conf /etc/apache2/

# Remove default VirtualHost
RUN rm -rf /etc/apache2/sites-enabled/000-default /var/www/html

COPY sites-enabled /etc/apache2/sites-enabled
COPY conf/ssl /opt/skyguard/sps/ssl

RUN ln -s /etc/apache2/mods-available/proxy_ajp.load /etc/apache2/mods-enabled/ && \
	ln -s /etc/apache2/mods-available/proxy.load /etc/apache2/mods-enabled/ && \
	ln -s /etc/apache2/mods-available/proxy.conf /etc/apache2/mods-enabled/

# Enable rewrite, ssl module
RUN a2enmod rewrite && a2enmod ssl

# install front and resources
RUN mkdir -p /opt/sps

COPY resources.deb /opt/sps
COPY front.deb /opt/sps
RUN dpkg -i /opt/sps/resources.deb && \
	dpkg -i /opt/sps/front.deb && \
	rm -rf /opt/sps


# Configure Apache2
ENV APACHE_RUN_USER     www-data
ENV APACHE_RUN_GROUP    www-data
ENV APACHE_LOG_DIR      /var/log/apache2
ENV APACHE_PID_FILE     /var/run/apache2.pid
ENV APACHE_RUN_DIR      /var/run/apache2
ENV APACHE_LOCK_DIR     /var/lock/apache2
ENV APACHE_LOG_DIR      /var/log/apache2


# Expose ourselves
EXPOSE 8443 8447

#ADD run.sh /run.sh
#RUN chmod 755 /*.sh

#CMD ["/run.sh"]

# Run!
ENTRYPOINT [ "/usr/sbin/apache2", "-D", "FOREGROUND" ]
#ENTRYPOINT [ "exec", "apache2", "-D", "FOREGROUND" ]