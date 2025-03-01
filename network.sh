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
