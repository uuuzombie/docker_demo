
1.build
docker build --rm -t sps-team/webmanager:1.0 .

2.tag
docker tag sps-team/webmanager:1.0 172.22.111.199:80/sps-team/webmanager:1.0

3.push
docker push 172.22.111.199:80/sps-team/webmanager

4.run
docker run -d -P --name webmanager sps-team/webmanager:1.0

for test
docker run -d -P --name webmanager -v /opt/share/conf:/opt/skyguard/tomcat/conf sps-team/webmanager:1.0
