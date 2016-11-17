FROM debian:7.10
#FROM 172.22.111.199:80/sps_demo/debian:7.10
MAINTAINER grong@skygurad.com

# apt
COPY sources.list /etc/apt
RUN apt-get update && apt-get install -y sudo procps net-tools less vim curl ttf-mscorefonts-installer \
    libxtst-dev libxrender-dev

# set timezone
RUN echo "Asia/Shanghai" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata


# install jdk & tomcat


RUN mkdir -p /opt/sps
COPY deb_files/ /opt/sps
RUN dpkg -i /opt/sps/java_1.8.0_45.deb && \
    dpkg -i /opt/sps/tomcat_8.0.24.deb && \
	rm -rf /skyguard-jre && \
	rm -rf /skyguard-tomcat && \
	rm -rf /opt/sps


# environment
ENV JAVA_HOME /usr/skyguardtools/java
ENV JRE_HOME /usr/skyguardtools/java/jre
ENV PATH $JAVA_HOME/bin:$JRE_HOME/bin:$PATH

ENV CATALINA_HOME /opt/skyguard/tomcat
ENV CATALINA_BASE /opt/skyguard/tomcat
ENV CLASSPATH /usr/skyguardtools/java/lib:/usr/skyguardtools/java/jre/lib
#RUN /bin/bash -c "source /etc/profile"

# copy resources
COPY conf/ /opt/skyguard/tomcat/conf/

RUN mkdir -p /usr/share/fonts/myfonts
COPY simsun.ttc /usr/share/fonts/myfonts
WORKDIR /usr/share/fonts/myfonts
RUN mkfontscale && mkfontdir

RUN mkdir -p /opt/skyguard/sps/setup
COPY skyguardsetup.exe /opt/skyguard/sps/setup
COPY conf/ssl /opt/skyguard/sps/ssl

RUN chown -R tomcat:tomcat /opt/skyguard/tomcat && \
    chown -R tomcat:tomcat /opt/skyguard/sps

WORKDIR /opt/skyguard/tomcat

#
VOLUME /opt/skyguard/tomcat/webapps
