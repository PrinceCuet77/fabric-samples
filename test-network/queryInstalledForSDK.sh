#!/bin/bash

sleep 15

# . scripts/envVar.sh
. ./scripts/envVar.sh

export FABRIC_CFG_PATH=$PWD/../config/

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

CHANNEL_NAME="$2"
VERSION="1"
CC_NAME="basic"

ORG=1
setGlobals $ORG
set -x
/home/prince-11209/Desktop/Fabric/RnD-Task/fabric-samples/bin/peer lifecycle chaincode queryinstalled >&package.txt
res=$?
set +x
cat log.txt
PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" package.txt)
# verifyResult $res "Query installed on peer0.org${ORG} has failed"
echo PackageID is ${PACKAGE_ID}
echo "===================== Query installed successful on peer0.org${ORG} on channel '$CHANNEL_NAME' ===================== "
echo

# Aprove for Org1
ORG=1
# setGlobals $ORG
setGlobals 1
set -x
# peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name fabcar --version ${VERSION} --init-required --package-id ${PACKAGE_ID} --sequence ${VERSION} >&log.txt
/home/prince-11209/Desktop/Fabric/RnD-Task/fabric-samples/bin/peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --signature-policy "OR ('Org1MSP.peer')" --version ${VERSION} --package-id ${PACKAGE_ID} --sequence ${VERSION} >&log.txt

# echo "FOR ORG 1"
# echo "peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name fabcar --version ${VERSION} --package-id ${PACKAGE_ID} --sequence ${SEQ}"
set +x
cat log.txt
# verifyResult $res "Chaincode definition approved on peer0.org${ORG} on channel '$CHANNEL_NAME' failed"
echo "===================== Chaincode definition approved on peer0.org${ORG} on channel '$CHANNEL_NAME' ===================== "
echo

# Aprove for Org1
ORG=1
# setGlobals $ORG
setGlobals 1
set -x
/home/prince-11209/Desktop/Fabric/RnD-Task/fabric-samples/bin/peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name $CC_NAME --signature-policy "OR ('Org1MSP.peer')" --version ${VERSION} --sequence ${VERSION} --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --output json >&log.txt
set +x
cat log.txt
echo "===================== Checking the commit readiness of the chaincode definition successful on peer0.org${ORG} on channel '$CHANNEL_NAME' ===================== "
echo

# APPROVE FOR MY ORG 2
ORG=2
# setGlobals $ORG
setGlobals 2
set -x

# echo "VERSION: ${VERSION} & SEQUENCE: ${VERSION}"
# echo $CORE_PEER_MSPCONFIGPATH
# peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name fabcar --version ${VERSION} --init-required --package-id ${PACKAGE_ID} --sequence ${VERSION} >&log.txt
/home/prince-11209/Desktop/Fabric/RnD-Task/fabric-samples/bin/peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --signature-policy "OR ('Org1MSP.peer')" --version ${VERSION} --package-id ${PACKAGE_ID} --sequence ${VERSION} >&log.txt

# Aprove for Org1
ORG=2
# setGlobals $ORG
setGlobals 2
set -x
/home/prince-11209/Desktop/Fabric/RnD-Task/fabric-samples/bin/peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name $CC_NAME --signature-policy "OR ('Org1MSP.peer')" --version ${VERSION} --sequence ${VERSION} --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --output json >&log.txt
set +x
cat log.txt
echo "===================== Checking the commit readiness of the chaincode definition successful on peer0.org${ORG} on channel '$CHANNEL_NAME' ===================== "
echo

# ----------------
# parsePeerConnectionParameters $@
parsePeerConnectionParameters 1 2
res=$?
# verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

# while 'peer chaincode' command can get the orderer endpoint from the
# peer (if join was successful), let's supply it directly as we know
# it using the "-o" option
set -x
# peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name fabcar $PEER_CONN_PARMS --version ${VERSION} --sequence ${VERSION} --init-required >&log.txt
/home/prince-11209/Desktop/Fabric/RnD-Task/fabric-samples/bin/peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --signature-policy "OR ('Org1MSP.peer')" $PEER_CONN_PARMS --version ${VERSION} --sequence ${VERSION} >&log.txt
res=$?
set +x
cat log.txt
# verifyResult $res "Chaincode definition commit failed on peer0.org${ORG} on channel '$CHANNEL_NAME' failed"
echo "===================== Chaincode definition committed on channel '$CHANNEL_NAME' ===================== "
echo

# peer lifecycle chaincode queryinstalled >&log.txt
# peer lifecycle chaincode queryinstalled >&log.txt

# echo "FOR ORG 2"
# echo "peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name fabcar --version ${VERSION} --package-id ${PACKAGE_ID} --sequence ${SEQ}"

set +x
cat log.txt
# verifyResult $res "Chaincode definition approved on peer0.org${ORG} on channel '$CHANNEL_NAME' failed"
echo "===================== Chaincode definition approved on peer0.org${ORG} on channel '$CHANNEL_NAME' ===================== "
echo

# ----------------
# # parsePeerConnectionParameters $@
# parsePeerConnectionParameters 1 2
# res=$?
# verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

# # while 'peer chaincode' command can get the orderer endpoint from the
# # peer (if join was successful), let's supply it directly as we know
# # it using the "-o" option
# set -x
# # peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name fabcar $PEER_CONN_PARMS --version ${VERSION} --sequence ${VERSION} --init-required >&log.txt
# /home/prince-11209/Desktop/Fabric/RnD-Task/fabric-samples/bin/peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --signature-policy "OR ('Org1MSP.peer')" $PEER_CONN_PARMS --version ${VERSION} --sequence ${VERSION} >&log.txt
# res=$?
# set +x
# cat log.txt
# # verifyResult $res "Chaincode definition commit failed on peer0.org${ORG} on channel '$CHANNEL_NAME' failed"
# echo "===================== Chaincode definition committed on channel '$CHANNEL_NAME' ===================== "
# echo
