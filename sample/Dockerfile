#FROM 172.22.111.199:80/sps-team/tomcat:1.0
FROM 172.22.111.199:80/sps_demo/tomcat:8-jre8
MAINTAINER grong@skyguard.com

# copy webapp
RUN rm -rf /usr/local/tomcat/webapps/*
COPY web_demo.war /usr/local/tomcat/webapps

EXPOSE 8009 8080

#USER tomcat

