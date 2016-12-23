#FROM 172.22.111.199:80/sps-team/tomcat:1.0
FROM 172.22.111.199:80/sps_demo/tomcat:8-jre8
MAINTAINER grong@skyguard.com

# apt
COPY sources.list /etc/apt
RUN apt-get update && apt-get install -y sudo procps net-tools less vim curl ttf-mscorefonts-installer
#    libxtst-dev libxrender-dev

# set timezone
RUN echo "Asia/Shanghai" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata


# copy resources
COPY conf/ /usr/local/tomcat/conf/

RUN mkdir -p /usr/share/fonts/myfonts
COPY simsun.ttc /usr/share/fonts/myfonts
WORKDIR /usr/share/fonts/myfonts
RUN mkfontscale
RUN mkfontdir

RUN mkdir -p /opt/skyguard/sps/setup
COPY skyguardsetup.exe /opt/skyguard/sps/setup
COPY conf/ssl /opt/skyguard/sps/ssl

# add user
RUN groupadd tomcat && useradd tomcat -g tomcat && usermod -a -G adm tomcat


ENV JRE_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre
ENV CATALINA_HOME /usr/local/tomcat
ENV CATALINA_BASE /usr/local/tomcat
ENV CATALINA_TMPDIR /usr/local/tomcat/temp
ENV CLASSPATH /usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar


# copy webapp
RUN rm -rf /usr/local/tomcat/webapps/*
COPY sps.war /usr/local/tomcat/webapps

# change owner
RUN chown -R tomcat:tomcat /usr/local/tomcat
RUN chown -R tomcat:tomcat /opt/skyguard/sps

EXPOSE 8009 8080

WORKDIR /usr/local/tomcat

USER tomcat
