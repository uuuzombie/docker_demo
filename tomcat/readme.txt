
1.build
docker build --rm -t sps-team/tomcat:1.0 .

2.tag
docker tag sps-team/tomcat:1.0 172.22.111.199:80/sps-team/tomcat:1.0

3.push
docker push 172.22.111.199:80/sps-team/tomcat

4.run
docker run -d -P --name tomcat sps-team/tomcat:1.0