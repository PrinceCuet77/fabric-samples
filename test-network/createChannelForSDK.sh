#!/bin/bash

CHANNEL_NAME="$1"
# DELAY="$2"
# MAX_RETRY="$3"
# VERBOSE="$4"
# : ${CHANNEL_NAME:="mychannel"}
# : ${DELAY:="3"}
# : ${MAX_RETRY:="5"}
# : ${VERBOSE:="false"}

# import utils
. ./scripts/envVar.sh
export FABRIC_CFG_PATH=$PWD/configtx

# if [ ! -d "channel-artifacts" ]; then
#     mkdir channel-artifacts
# fi

createChannelTx() {
    # echo "Path: ${PATH}"
    # var=$(pwd)
    # echo "The current working directory $var."
    # echo "Done ${CHANNEL_NAME} start"

    set -x

    # Working
    # /home/prince-11209/Desktop/Fabric/RnD-Task/fabric-samples/bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx demo.tx -configPath ${PWD}/configtx -channelID demo

    /home/prince-11209/Desktop/Fabric/RnD-Task/fabric-samples/bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
    # res=$?
    set +x
    # if [ $res -ne 0 ]; then
    #     echo "Failed to generate channel configuration transaction..."
    #     exit 1
    # fi
    echo "Tx file is created..."
    echo "Done ${CHANNEL_NAME} end"

}

createAncorPeerTx() {

    for orgmsp in Org1MSP Org2MSP; do

        echo "#######    Generating anchor peer update for ${orgmsp}  ##########"
        set -x
        /home/prince-11209/Desktop/Fabric/RnD-Task/fabric-samples/bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/${orgmsp}anchors.tx -channelID $CHANNEL_NAME -asOrg ${orgmsp}
        # res=$?
        set +x
        # if [ $res -ne 0 ]; then
        #     echo "Failed to generate anchor peer update for ${orgmsp}..."
        #     exit 1
        # fi
        echo
    done
}

createChannel() {
    setGlobals 1
    # Poll in case the raft leader is not set yet
    # local rc=1
    # local COUNTER=1
    # while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
    #     sleep $DELAY
    set -x
    /home/prince-11209/Desktop/Fabric/RnD-Task/fabric-samples/bin/peer channel create -o localhost:7050 -c $CHANNEL_NAME --ordererTLSHostnameOverride orderer.example.com -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    # res=$?
    set +x
    # let rc=$res
    # COUNTER=$(expr $COUNTER + 1)
    # done
    cat log.txt
    # verifyResult $res "Channel creation failed"
    echo
    echo "===================== Channel '$CHANNEL_NAME' created ===================== "
    echo
}

# queryCommitted ORG
joinChannel1() {
    # ORG=$1
    setGlobals 1
    # local rc=1
    # local COUNTER=1
    # ## Sometimes Join takes time, hence retry
    # while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
    #     sleep $DELAY
    set -x
    /home/prince-11209/Desktop/Fabric/RnD-Task/fabric-samples/bin/peer channel join -b ./channel-artifacts/${CHANNEL_NAME}.block >&log.txt
    # res=$?
    set +x
    # let rc=$res
    # COUNTER=$(expr $COUNTER + 1)
    # done
    cat log.txt
    echo
    # verifyResult $res "After $MAX_RETRY attempts, peer0.org${ORG} has failed to join channel '$2' "
}

joinChannel2() {
    # ORG=$1
    setGlobals 2
    # local rc=1
    # local COUNTER=1
    # ## Sometimes Join takes time, hence retry
    # while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
    #     sleep $DELAY
    set -x
    /home/prince-11209/Desktop/Fabric/RnD-Task/fabric-samples/bin/peer channel join -b ./channel-artifacts/${CHANNEL_NAME}.block >&log.txt
    # res=$?
    set +x
    # let rc=$res
    # COUNTER=$(expr $COUNTER + 1)
    # done
    cat log.txt
    echo
    # verifyResult $res "After $MAX_RETRY attempts, peer0.org${ORG} has failed to join channel '$2' "
}

updateAnchorPeers() {
    ORG=$1
    setGlobals $ORG
    # local rc=1
    # local COUNTER=1
    # ## Sometimes Join takes time, hence retry
    # while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
    #     sleep $DELAY
    set -x
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    # res=$?
    set +x
    # let rc=$res
    # COUNTER=$(expr $COUNTER + 1)
    # done
    cat log.txt
    # verifyResult $res "Anchor peer update failed"
    echo "===================== Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL_NAME' ===================== "
    # sleep $DELAY
    echo
}

# verifyResult() {
#     if [ $1 -ne 0 ]; then
#         echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
#         echo
#         exit 1
#     fi
# }

# FABRIC_CFG_PATH=/home/prince-11209/Desktop/Fabric/RnD-Task/fabric-samples/test-network/configtx

# FABRIC_CFG_PATH=/configtx

# PATH=/home/prince-11209/Desktop/Fabric/RnD-Task/fabric-samples/bin:${PWD}:$PATH
# PATH=${PWD}/../bin:${PWD}:$PATH

# FABRIC_CFG_PATH=${PWD}/../../configtx

#
# FABRIC_CFG_PATH=${PWD}/configtx
# var1=$(FABRIC_CFG_PATH)
# echo "The directory $var1."

# var=$(pwd)
# echo "222 The current working directory $var."

# # var=$(PWD)
# # echo "333 The current working directory $var."
# echo "CGF Path: $FABRIC_CFG_PATH"

## Create channeltx
echo "### Generating channel configuration transaction '${CHANNEL_NAME}.tx' ###"
createChannelTx $CHANNEL_NAME

# Create anchorpeertx
echo "### Generating channel configuration transaction '${CHANNEL_NAME}.tx' ###"
createAncorPeerTx

# FABRIC_CFG_PATH=/home/prince-11209/Desktop/Fabric/RnD-Task/fabric-samples/config
export FABRIC_CFG_PATH=$PWD/../config/

## Create channel
echo "Creating channel "$CHANNEL_NAME
createChannel $CHANNEL_NAME

sleep 10

## Join all the peers to the channel
echo "Join Org1 peers to the channel..."
joinChannel1 1 $CHANNEL_NAME
sleep 10

echo "Join Org2 peers to the channel..."
joinChannel2 2 $CHANNEL_NAME
sleep 10

# exit 0
