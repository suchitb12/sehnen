#!/bin/bash

CHANNEL_NAME="$1"
DELAY="$2"
MAX_RETRY="$3"
VERBOSE="$4"
: ${CHANNEL_NAME:="mychannel"}
: ${DELAY:="3"}
: ${MAX_RETRY:="5"}
: ${VERBOSE:="false"}

createChannelGenesisBlock() {
  setGlobals 1
	which configtxgen
	if [ "$?" -ne 0 ]; then
		fatalln "configtxgen tool not found."
	fi
	set -x
    configtxgen -profile ChannelUsingRaft -outputBlock ./channel-artifacts/${CHANNEL_NAME}.block -channelID $CHANNEL_NAME
	res=$?
	{ set +x; } 2>/dev/null

  verifyResult $res "Failed to generate channel configuration transaction..."
}

createChannel() {
    local rc=1
    local COUNTER=1

    while [ $rc -ne 0 -a $COUNTER -lt 5 ]; do
        sleep $DELAY
        set -x
    
    . scripts/orderer.sh ${CHANNEL_NAME}> /dev/null 2>&1

        res=$?
		{ set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
    done

    if [ $rc -ne 0 ]; then
        fatalln "After $DELAY seconds, orderer command has failed"
    fi
}

## Create channel genesis block
FABRIC_CFG_PATH=$PWD/configtx/
BLOCKFILE="./channel-artifacts/${CHANNEL_NAME}.block"

infoln "Generating channel genesis block '${CHANNEL_NAME}.block'"
FABRIC_CFG_PATH=${PWD}/configtx
createChannelGenesisBlock

# ## Create channel
# infoln "Creating channel ${CHANNEL_NAME}"
# createChannel $BFT
# successln "Channel '$CHANNEL_NAME' created"

# ## Join all the peers to the channel
# infoln "Joining org1 peer to the channel..."
# joinChannel 1
# infoln "Joining org2 peer to the channel..."
# joinChannel 2

# ## Set the anchor peers for each org in the channel
# infoln "Setting anchor peer for org1..."
# setAnchorPeer 1
# infoln "Setting anchor peer for org2..."
# setAnchorPeer 2

# successln "Channel '$CHANNEL_NAME' joined"
