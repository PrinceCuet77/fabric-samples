#!/bin/bash

CC_NAME="basic"

# . scripts/envVar.sh - previous
. ./scripts/envVar.sh

# Export the environment variable
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG1_CA=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

export FABRIC_CFG_PATH=$PWD/../config/
# export FABRIC_CFG_PATH=$PWD/config

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

CHANNEL_NAME="$1"
FUNCTION_NAME="$2"
ID="$3"
COLOR="$4"
SIZE="$5"
OWNER="$6"
APPRAISEDVALUE="$7"

echo $ID
echo $COLOR
echo $SIZE
echo $OWNER
echo $APPRAISEDVALUE

ARGS="\"$ID\",\"$COLOR\",\"$SIZE\",\"$OWNER\",\"$APPRAISEDVALUE\""
echo $ARGS

parsePeerConnectionParameters 1 2

# Query before invocation
# peer chaincode query -C $CHANNEL_NAME -n fabcar -c '{"Args":["queryAllCars"]}'

/home/prince-11209/Desktop/Fabric/RnD-Task/fabric-samples/bin/peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} $PEER_CONN_PARMS -c '{"function":"'$FUNCTION_NAME'","Args":['$ARGS']}'

sleep 10

# Query after invocation
# peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["queryAllCars"]}'
/home/prince-11209/Desktop/Fabric/RnD-Task/fabric-samples/bin/peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["GetAllAssets"]}'
