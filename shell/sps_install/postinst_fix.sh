#!/bin/sh

# post install of sps
filepath=$(pwd)
echo 'current folder=' $filepath

rootPath='/opt/skyguard'
tomcatFolderName='tomcat'
tomcatPath=$rootPath/$tomcatFolderName
applicationDeployFolder=$tomcatPath/webapps
applicationConfFolder=$tomcatPath/conf

sourceFolder='/skyguard-sps'
buildFile=$sourceFolder/build.txt

echo "tomcatFolderName=$tomcatFolderName"
echo "applicationDeployFolder=$applicationDeployFolder"

applicationFile='webManager.war'
webserviceFile='sps.war'
applicationFolder='WebManager'
webserviceFolder='sps'
spsFolder=$rootPath/'sps'
sps_cert_path=$spsFolder/ssl

# deploy sps services if tomcat folder exists.

if [ -d $tomcatPath ]; then

	
	# create sps folder under /opt/skyguard if the folder doesn't exist
	if [ ! -d $spsFolder ]; then 
		mkdir $spsFolder
		chown -R tomcat:tomcat $spsFolder
		chmod -R 775 $spsFolder
	fi

	# cp build number file into /opt/skyguard folder
	cp $buildFile $spsFolder

	# copy new wars into deploy folder
	cp $sourceFolder/$applicationFile $applicationDeployFolder
	cp $sourceFolder/$webserviceFile $applicationDeployFolder


	# copy configuration files into tomcat/conf folder
	echo "copy configuration files file into tomcat conf folder..."
	cp $sourceFolder/config.properties $applicationConfFolder
	cp $sourceFolder/server_config.properties $applicationConfFolder
	cp $sourceFolder/simsun.ttc $applicationConfFolder
	cp $sourceFolder/server.xml $applicationConfFolder
	
	# mv ssl certificate folder into tomcat/conf folder
	if [ ! -d $sps_cert_path ]; then 
		mkdir $sps_cert_path
		chown -R tomcat:tomcat $sps_cert_path
		chmod -R 775 $sps_cert_path
	fi

	cp -r $sourceFolder/ssl/* $sps_cert_path




	# append 8080 port configuration into apache configuration
	apacheConfFile=/etc/apache2/ports.conf
	if [ -e $apacheConfFile ]; then
		echo 'append 8080 port to apache server'
		cat $apacheConfFile|grep 8447
		if [ $? -ne 0 ]; then
			cat >> $apacheConfFile << LJS	
	NameVirtualHost *:8443
	Listen 8443
	NameVirtualHost *:8447
	Listen 8447
LJS
		fi

		# cp relevant files into folder /etc/apache2/sites-enabled/
		if [ ! -e '/etc/apache2/sites-enabled/001-webManager-ssl.conf' ]; then
			cp $sourceFolder/001-webManager-ssl.conf /etc/apache2/sites-enabled/
		fi
		if [ ! -e '/etc/apache2/sites-enabled/001-webService-ssl.conf' ]; then
			cp $sourceFolder/001-webService-ssl.conf /etc/apache2/sites-enabled/
		fi
			
		if [ ! -e '/etc/apache2/mods-enabled/proxy_ajp.load' ]; then 
			ln -s /etc/apache2/mods-available/proxy_ajp.load /etc/apache2/mods-enabled/
			ln -s /etc/apache2/mods-available/proxy.load /etc/apache2/mods-enabled/
			ln -s /etc/apache2/mods-available/proxy.conf /etc/apache2/mods-enabled/
		fi
		echo "enable apache ssl"
		a2enmod ssl
	fi



	# install simsun font
	fontfolder=/usr/share/fonts/myfonts
	simsunfont=$fontfolder/simsun.ttc

	if [ ! -d $fontfolder ]; then 
		mkdir -p $fontfolder
	fi
	
	if [ ! -e $simsunfont ]; then
		cd $fontfolder
		cp -p /opt/skyguard/tomcat/conf/simsun.ttc $fontfolder
		mkfontscale
		echo "mkfontscale return : "$?
		mkfontdir
		echo "mkfontdir return  : "$?
	fi


	exe_path=/opt/skyguard/sps/setup
    if [ ! -d "$exe_path" ]; then
        mkdir $exe_path
		chown -R tomcat:tomcat $exe_path
		chmod -R 775 $exe_path
    fi
	if [ -f "$sourceFolder/skyguardsetup.exe" ]; then
       cp $sourceFolder/skyguardsetup.exe $exe_path
    fi
	# start tomcat
	echo "starting tomcat..."
	/etc/init.d/tomcat start
	sleep 30s
	echo "installed webManager tomcat successful!"
	
else
	echo "please install tomcat correct before install sps services!"
fi


if [ -d $tomcatPath1 ]; then
	# get pid of webManager tomcat1
	tomcatID1=$(ps -ef|grep $tomcatPath1 |grep -v 'grep'|awk '{print $2}')
	
	if [ $tomcatID1 ]; then
		echo "tomcat1 is running, stop it"
		/etc/init.d/tomcat1 stop
		sleep 5s
		
		# kill tomcat1 if it still alive
		tomcatID1=$(ps -ef|grep $tomcatPath1 |grep -v 'grep'|awk '{print $2}')
		echo "tomcatID1 is: $tomcatID1"
		if [ $tomcatID1 ]; then
			kill -9 $tomcatID1
		fi
	fi
	
	if [ -e $applicationDeployFolder1/$webserviceFile ]; then
		echo 'delete old sps.war file under event tomcat'
		rm $applicationDeployFolder1/$webserviceFile
	fi

	# copy new wars into deploy folder
	cp $sourceFolder/$webserviceFile $applicationDeployFolder1

	# delete deployed folder if exists
	if [ -e $applicationDeployFolder1/$webserviceFolder ]; then
		echo 'delete sps folder under event tomcat'
		rm -r $applicationDeployFolder1/$webserviceFolder
	fi

	# copy configuration files into tomcat1/conf folder
	echo "copy configuration files file into tomcat1 conf folder..."
	cp $sourceFolder/config1.properties $applicationConfFolder1/config.properties
	cp $sourceFolder/server_config.properties $applicationConfFolder1
	cp $sourceFolder/simsun.ttc $applicationConfFolder1
	cp $sourceFolder/server1.xml $applicationConfFolder1/server.xml

	echo "cp $sourceFolder/server1.xml $applicationConfFolder1/server.xml"
	
	# mv ssl certificate folder into tomcat1/conf folder
	cp -r $sourceFolder/ssl $applicationConfFolder1/ssl

	# start tomcat1
	echo "starting tomcat1..."
	/etc/init.d/tomcat1 start
	sleep 30s
	echo "installed event tomcat successful!"
	
else
	echo "please install tomcat1 correct before install sps services!"
fi
count=120
while [ ! -e /opt/skyguard/sps/ssl/webManager.crt -a $count -gt 0 ]; do
	$(( count=$count-1 ))
	echo "webManager.crt not create, count down: $count";
	sleep 1s;
done
echo "restart apache2"
service apache2 restart || true
