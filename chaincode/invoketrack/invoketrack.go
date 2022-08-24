package main

import (
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// SmartContract provides functions for managing an Asset
type SmartContract struct {
	contractapi.Contract
}

type Track struct {
	Shard int `json:"shard"`
}

// QueryResult structure used for handling result of query
type QueryResult struct {
	Key    string `json:"Key"`
	Record *Track
}

// InitLedger adds a base set of tracks to the ledger
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	tracks := []Track{
		Track{Shard: 0},
		Track{Shard: 0},
		Track{Shard: 0},
	}

	for i, track := range tracks {
		trackAsBytes, _ := json.Marshal(track)
		err := ctx.GetStub().PutState("channel"+strconv.Itoa(i), trackAsBytes)

		if err != nil {
			return fmt.Errorf("Failed to put to world state. %s", err.Error())
		}
	}

	return nil
}

// QueryAllTracks returns all tracks found in world state
func (s *SmartContract) QueryAllTracks(ctx contractapi.TransactionContextInterface) ([]QueryResult, error) {
	startKey := "channel0"
	endKey := "channel99"

	resultsIterator, err := ctx.GetStub().GetStateByRange(startKey, endKey)

	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	results := []QueryResult{}

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()

		if err != nil {
			return nil, err
		}

		track := new(Track)
		_ = json.Unmarshal(queryResponse.Value, track)

		queryResult := QueryResult{Key: queryResponse.Key, Record: track}
		results = append(results, queryResult)
	}

	return results, nil
}

// QueryTrack returns the track found in the world state with given channelID
func (s *SmartContract) QueryTrack(ctx contractapi.TransactionContextInterface, channelID string) (*Track, error) {
	trackAsBytes, err := ctx.GetStub().GetState(channelID)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from world state. %s", err.Error())
	}

	if trackAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", channelID)
	}

	track := new(Track)
	_ = json.Unmarshal(trackAsBytes, track)

	return track, nil
}

// QueryTrackForSingle returns the shard stored in the world state with given channelID
func (s *SmartContract) QueryTrackForSingle(ctx contractapi.TransactionContextInterface, channelID string) (int, error) {
	trackAsBytes, err := ctx.GetStub().GetState(channelID)

	if err != nil {
		return -1, fmt.Errorf("Failed to read from world state. %s", err.Error())
	}

	if trackAsBytes == nil {
		return -1, fmt.Errorf("%s does not exist", channelID)
	}

	track := new(Track)
	_ = json.Unmarshal(trackAsBytes, track)

	return track.Shard, nil
}

// UpdateTrack updates the shard field of track with given channelID in world state
func (s *SmartContract) UpdateTrack(ctx contractapi.TransactionContextInterface, channelID string) error {
	track, err := s.QueryTrack(ctx, channelID)

	if err != nil {
		return err
	}

	track.Shard++

	trackAsBytes, _ := json.Marshal(track)

	return ctx.GetStub().PutState(channelID, trackAsBytes)
}

// UpdateCurrentChannelID updates the next current channelID which is given channelID in world state
func (s *SmartContract) UpdateCurrentChannelID(ctx contractapi.TransactionContextInterface, currentChannel string) error {
	return ctx.GetStub().PutState("currentchannel", []byte(currentChannel))
}

// GetCurrentChannelID returns the current channelID stored in the world state
func (s *SmartContract) GetCurrentChannelID(ctx contractapi.TransactionContextInterface) (string, error) {
	trackAsBytes, err := ctx.GetStub().GetState("currentchannel")

	return string(trackAsBytes[:]), err
}

func main() {

	chaincode, err := contractapi.NewChaincode(new(SmartContract))

	if err != nil {
		fmt.Printf("Error create invoketrack chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting invoketrack chaincode: %s", err.Error())
	}
}
