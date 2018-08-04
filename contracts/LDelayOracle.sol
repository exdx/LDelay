pragma solidity ^0.4.24;

import "./Oraclize.sol";

/** @title Use oraclize to hit custom AWS endpoint to get train status */ 
contract LDelayOracle is usingOraclize {
    string public mtaFeedAPIresult;

    event NewOraclizeQuery(string description);
    event LTrainStatusUpdate(string result);

    /** @dev Holds result of oraclize query 
      * @return Three possibilities: "Normal", "Delayed", or "Unknown"
    */
    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) revert();
        emit LTrainStatusUpdate(result);
        mtaFeedAPIresult = result;
    }

    /** @dev Returns string of train status after querying MTA GTFS feed and deserializing result in a lambda function */
    function getLTrainInitialStatus() payable {
        emit NewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        oraclize_query("URL", "https://lchink7hq2.execute-api.us-east-2.amazonaws.com/Live/");
    }

    /** @dev Delayed return of string of train status after querying MTA GTFS feed and deserializing result in a lambda function */
    function getLTrainFollowupStatus(uint _futureTime) payable {
        uint delaySeconds = _futureTime * 60 seconds;
        emit NewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        oraclize_query(delaySeconds, "URL", "https://lchink7hq2.execute-api.us-east-2.amazonaws.com/Live/");
    }
}