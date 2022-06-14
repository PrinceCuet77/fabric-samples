#!/bin/bash

CHANNEL_NAME="channelforcustomcc"
VERSION="1"
CC="invoketrack"

# Packaged the invoketrack chaincode
peer lifecycle chaincode package invoketrack.tar.gz --path ../chaincode/invoketrack/ --lang golang --label invoketrack_1 >&log.txt
cat log.txt
echo "===================== Chaincode '$CC' is packaged on peer0.org1 on channel '$CHANNEL_NAME' ===================== "
echo

# Environment variables for Org1
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

# Installed the invoketract chaincode for Org1
peer lifecycle chaincode install invoketrack.tar.gz >&log.txt
cat log.txt
echo "===================== Chaincode '$CC' is installed on peer0.org1 on channel '$CHANNEL_NAME' ===================== "
echo

# queryInstalled the invoketract chaincode
peer lifecycle chaincode queryinstalled >&log.txt
cat log.txt
PACKAGE_ID=$(sed -n "/invoketrack_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
echo ${PACKAGE_ID}
echo "===================== Query installed successful on peer0.org1 on channel '$CHANNEL_NAME' ===================== "
echo

# Approve the chaincode for Org1
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --channelID $CHANNEL_NAME --name invoketrack --version ${VERSION} --package-id ${PACKAGE_ID} --sequence ${VERSION}
echo "===================== Chaincode '$CC' definition approved on peer0.org1 on channel '$CHANNEL_NAME' ===================== "
echo

# Environment variables for Org2
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051

# Approve the chaincode for Org2
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --channelID $CHANNEL_NAME --name invoketrack --version ${VERSION} --package-id ${PACKAGE_ID} --sequence ${VERSION}
echo "===================== Chaincode '$CC' definition approved on peer0.org2 on channel '$CHANNEL_NAME' ===================== "
echo

# Export the environment variable
export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG1_CA=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export PEER0_ORG3_CA=${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt

# Committed the chaincode
parsePeerConnectionParameters 1 2
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --channelID $CHANNEL_NAME --name invoketrack --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA --version ${VERSION} --sequence ${VERSION}
echo "===================== Query chaincode '$CC' definition successful on peer0.org1 on channel '$CHANNEL_NAME' ===================== "
echo

# Installed the invoketract chaincode for Org1
peer lifecycle chaincode install invoketrack.tar.gz >&log.txt
cat log.txt
echo "===================== Chaincode '$CC' is installed on peer0.org2 on channel '$CHANNEL_NAME' ===================== "
echo

# Invoke
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $ORDERER_CA -C $CHANNEL_NAME -n invoketrack --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA -c '{"function":"InitLedger","Args":[]}'

sleep 10

# Query
peer chaincode query -C $CHANNEL_NAME -n invoketrack -c '{"Args":["QueryAllTracks"]}'
