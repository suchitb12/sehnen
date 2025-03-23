#!/bin/bash

function changeDirectory() {
    if [ -z "$1" ]; then
        echo "Usage: changeDirectory <directory>"
        return 1
    fi
    if [ ! -d "$1" ]; then
        echo "Directory $1 does not exist"
        return 1
    fi
    if [ "$1" == "$PWD" ]; then
        echo "Already in directory $1"
        return 0
    fi
    pushd "$1" >/dev/null 2>&1 || exit
    infoln "Changing to directory $1"
}

# Obtain CONTAINER_IDS and remove them
# This function is called when you bring a network down
function clearContainers() {
  infoln "Removing remaining containers"
  ${CONTAINER_CLI} rm -f $(${CONTAINER_CLI} ps -aq --filter label=service=hyperledger-fabric) 2>/dev/null || true
  ${CONTAINER_CLI} rm -f $(${CONTAINER_CLI} ps -aq --filter name='dev-peer*') 2>/dev/null || true
  ${CONTAINER_CLI} kill "$(${CONTAINER_CLI} ps -q --filter name=ccaas)" 2>/dev/null || true
}

# Delete any images that were generated as a part of this setup
# specifically the following images are often left behind:
# This function is called when you bring the network down
function removeUnwantedImages() {
  infoln "Removing generated chaincode docker images"
  ${CONTAINER_CLI} image rm -f $(${CONTAINER_CLI} images -aq --filter reference='dev-peer*') 2>/dev/null || true
}