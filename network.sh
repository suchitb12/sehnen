ROOTDIR=$(cd "$(dirname "$0")" && pwd)
export PATH=${ROOTDIR}/../bin:${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx
export VERBOSE=false

changeDirectory $ROOTDIR
trap "popd > /dev/null 2>&1" EXIT

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
  pushd "$1" > /dev/null 2>&1
  infoln "Changing to directory $1"
}

CONTAINER_CLI="docker"

if command -v ${CONTAINER_CLI} > /dev/null 2>&1; then
    infoln "${CONTAINER_CLI} is installed"
    : ${CONTAINER_CLI_COMPOSE:="${CONTAINER_CLI}-compose"}
else
    fatalln "${CONTAINER_CLI} is not installed"
    exit 1
fi

function clearContainers() {
  infoln "Removing remaining containers"
  ${CONTAINER_CLI} rm -f $(${CONTAINER_CLI} ps -aq --filter label=service=hyperledger-fabric) 2>/dev/null || true
  ${CONTAINER_CLI} rm -f $(${CONTAINER_CLI} ps -aq --filter name='dev-peer*') 2>/dev/null || true
  ${CONTAINER_CLI} kill "$(${CONTAINER_CLI} ps -q --filter name=ccaas)" 2>/dev/null || true
}
