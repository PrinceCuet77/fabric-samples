#!/bin/bash

ARG="$1"
# echo $ARG

# peer chaincode query -C channelforcustomcc -n invoketrack -c '{"Args":["QueryAllTracks"]}'
peer chaincode query -C channelforcustomcc -n invoketrack -c '{"function":"QueryTrackForSingle","Args":["'$ARG'"]}' >&querycclog.txt
cat querycclog.txt
