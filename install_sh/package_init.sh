#! /bin/bash

# package init shell scripts and sqls


CURRENT_HOME=`pwd`

SRC_HOME=/home/rg/gitproject/code_sps_manager/WebManager/sps_src
BASE_HOME=$SRC_HOME/base/base-config/deploy
DLP_HOME=$SRC_HOME/dlp/dlp-config/deploy/sql


echo "begin package ..."

mkdir -p init

if [ -n "$BASE_HOME" ]; then
	cp -r $BASE_HOME/* init
fi

if [ -n "${DLP_HOME}" ]; then
	cp -r ${DLP_HOME}/* init/base/sql
fi


tar zcvf init.tar.gz init

rm -rf init

echo -e "\n\n package finish..."

