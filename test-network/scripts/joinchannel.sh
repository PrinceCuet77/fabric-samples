#!/bin/bash
. scripts/envVar.sh

# Approve for Org2
ORG=2

# setGlobals $ORG
setGlobals 2
set -x
CHANNEL_NAME="$1"

peer channel fetch 0 vcc.block -c $CHANNEL_NAME -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem >&log.txt
cat log.txt

sleep 2

peer channel join -b vcc.block >&log.txt
cat log.txt
