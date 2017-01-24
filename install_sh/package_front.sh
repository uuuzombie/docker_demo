#! /bin/bash

# package init shell scripts and sqls


CURRENT_HOME=`pwd`

SRC_HOME=/home/rg/gitproject/code_sps_manager/WebManager/sps_src
CSS_HOME=$SRC_HOME/webManager/webManager-client/src/main/webapp/css
JS_HOME=$SRC_HOME/webManager/webManager-client/src/main/webapp/js
IMAGES_HOME=$SRC_HOME/webManager/webManager-client/src/main/webapp/images

DEPOLY_HOME=/home/rg/depoly
FRONT_HOME=$DEPOLY_HOME/frontroot
DES_HOME=$FRONT_HOME/opt/skyguard/tomcat/webapps/webManager



echo "begin package ..."

if [ ! -d "$DES_HOME" ]; then
	mkdir -p $DES_HOME
fi

if [ -n "$CSS_HOME" ]; then
	echo "copy css"
	cp -r $CSS_HOME $DES_HOME
fi

if [ -n "$JS_HOME" ]; then
	echo "copy js..."
	cp -r $JS_HOME $DES_HOME
fi

if [ -n "$IMAGES_HOME" ]; then
	echo "copy images..."
	cp -r $IMAGES_HOME $DES_HOME
fi 


cd $DEPOLY_HOME
dpkg -b frontroot/ front.deb

rm -rf $FRONT_HOME/opt

echo -e "\n\n package finish..."

