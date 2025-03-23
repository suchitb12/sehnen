#!/bin/bash

ROOTDIR=$(cd "$(dirname "$0")" && pwd)
export PATH=${ROOTDIR}/../bin:${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx
export VERBOSE=false
export HOME=${ROOTDIR}
export NONWORKING_VERSIONS="^1\.0\. ^1\.1\. ^1\.2\. ^1\.3\. ^1\.4\."
export COMPOSE_FILE_BASE=compose-test-net.yaml

. ${HOME}/scripts/utils.sh
. ${HOME}/scripts/networkCRUD.sh
. ./network.config

changeDirectory $ROOTDIR
trap "popd > /dev/null 2>&1" EXIT

CONTAINER_CLI="docker"

if command -v ${CONTAINER_CLI} >/dev/null 2>&1; then
    infoln "${CONTAINER_CLI} is installed"
    : ${CONTAINER_CLI_COMPOSE:="${CONTAINER_CLI}-compose"}
else
    fatalln "${CONTAINER_CLI} is not installed"
    exit 1
fi
