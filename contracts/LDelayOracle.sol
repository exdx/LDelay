pragma solidity ^0.4.24;

import "./Oraclize.sol";

// use oraclize to hit custom AWS endpoint - returns string of train status after querying MTA GTFS feed and deserializing result in a lambda function
// https://lchink7hq2.execute-api.us-east-2.amazonaws.com/Live/

contract LDelayOracle is usingOraclize {
    string public mtaFeedAPIresult;

    event NewOraclizeQuery(string description);
    event LTrainStatusUpdate(string result);

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) revert();
        mtaFeedAPIresult = result;
        emit LTrainStatusUpdate(result);
    }

    function getLTrainStatus() payable {
        NewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        oraclize_query("URL", "https://lchink7hq2.execute-api.us-east-2.amazonaws.com/Live/");
    }
}