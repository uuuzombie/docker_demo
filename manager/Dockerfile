FROM 172.22.111.199:80/sps-team/tomcat:1.0
MAINTAINER grong@skyguard.com

# copy webapp
COPY webManager.war /opt/skyguard/tomcat/webapps

# change own
RUN chown -R tomcat:tomcat /opt/skyguard/tomcat
RUN chown -R tomcat:tomcat /opt/skyguard/sps

EXPOSE 8009 8080

#start

USER tomcat

CMD ["-Dnop","-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager","-Djava.awt.headless=true -Xmx2048m -Xms2048m",\
    "-XX:+UseConcMarkSweepGC","-Dbuild.compiler=javac","-Djava.endorsed.dirs=/opt/skyguard/tomcat/endorsed","-classpath", \
    "/opt/skyguard/tomcat/bin/bootstrap.jar:/opt/skyguard/tomcat/bin/tomcat-juli.jar","-Dcatalina.base=/opt/skyguard/tomcat" ,\
    "-Dcatalina.base=/opt/skyguard/tomcat","-Dcatalina.home=/opt/skyguard/tomcat","-Djava.io.tmpdir=/tmp/tomcat7-tomcat-tmp", \
    "org.apache.catalina.startup.Bootstrap","start"]

ENTRYPOINT ["/usr/skyguardtools/java/jre/bin/java"]
