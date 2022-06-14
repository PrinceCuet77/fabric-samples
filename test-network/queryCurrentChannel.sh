#!/bin/bash

peer chaincode query -C channelforcustomcc -n invoketrack -c '{"Args":["GetCurrentChannelID"]}' >&querycurrentchannellog.txt
cat querycurrentchannellog.txt