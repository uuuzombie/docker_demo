#!/bin/bash

set -e

CURRENT_HOME=`pwd`

VERSION_FILE=${CURRENT_HOME}/version
BUILD_FOLDER=build
BUILD_HOME=${CURRENT_HOME}/${BUILD_FOLDER}
BUILD_FILE=${BUILD_HOME}/build.txt


if [ -n $"VERSION_FILE" ]; then
    echo -e "begin update version"
    OLD_VERSION=`awk '{print $1}'` ${VERSION_FILE}
    echo -e "old version :  ${OLD_VERSION}"

    NEW_VERSION=$(($OLD_VERSION+1))
    echo -e "new version :  ${NEW_VERSION}"

    echo cld1.1_${NEW_VERSION} > ${BUILD_FILE}

    tar zcvf cloud_build_${NEW_VERSION}.tar.gz ${BUILD_FOLDER}

    rm -rf ${BUILD_HOME}/*
    echo -e "\n release success!"
fi