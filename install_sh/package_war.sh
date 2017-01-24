#! /bin/bash

# package init shell scripts and sqls


CURRENT_HOME=`pwd`

SRC_HOME=/home/rg/gitproject/code_sps_manager/WebManager/sps_src
MANAGER_HOME=$SRC_HOME/webManager/webManager
SERVICE_HOME=$SRC_HOME/webService/webService

DEPOLY_HOME=/home/rg/depoly
DES_HOME=$DEPOLY_HOME/fakeroot


echo "begin package webManager ..."

cd $MANAGER_HOME
mvn clean -U package -DskipTests=true

cp ../webManager-client/target/webManager.war $DES_HOME



echo "begin package webService ..."

cd $SERVICE_HOME
mvn clean -U package -DskipTests=true

cp ../webService-client/target/sps.war $DES_HOME


cd $DEPOLY_HOME
dpkg -b fakeroot war.deb

rm $DES_HOME/webManager.war $DES_HOME/sps.war

echo -e "\n\n package finish..."

