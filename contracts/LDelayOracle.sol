pragma solidity ^0.4.24;

import "./Oraclize.sol";
import "./LDelayBaseInterface.sol";

/** @title Use oraclize to hit custom AWS endpoint to get train status */ 
contract LDelayOracle is usingOraclize {
    string public mtaFeedAPIresult;
    uint externalPolicyID;
    address baseAddress;

    event NewOraclizeQuery(string description);
    event LTrainStatusUpdate(string result);

    /** @dev Holds result of oraclize query in mtaFeedAPIresult string
      * @return Three possibilities: "Normal", "Delayed", or "Unknown"
    */
    function __callback(bytes32 myid, string result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        emit LTrainStatusUpdate(result);
        mtaFeedAPIresult = result;

        setBaseTrainStatus(baseAddress, result);
    }

    /** @dev Returns string of train status after querying MTA GTFS feed and deserializing result in a lambda function
      * @dev Allows to pass in delay variable in case of callback */
    function getLTrainStatus(uint _futureTime, uint _externalPolicyID) external payable {
        //require that only the Base contract can call this function
        externalPolicyID = _externalPolicyID;
        uint delaySeconds = _futureTime * 60 seconds;

        if (delaySeconds > 0) {
            emit NewOraclizeQuery("Oraclize callback query was sent, standing by for the answer..");
            oraclize_query(delaySeconds, "URL", "https://lchink7hq2.execute-api.us-east-2.amazonaws.com/Live/");
        } else {
            emit NewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclize_query("URL", "https://lchink7hq2.execute-api.us-east-2.amazonaws.com/Live/");
        }
    }

/** @dev Calls setter function in base contract to update train state */
    function setBaseTrainStatus(address _baseAddress, string result) internal {
        LDelayBaseInterface ldelaybase = LDelayBaseInterface(_baseAddress);
        ldelaybase.setLTRAINSTATUS(result, externalPolicyID);
    }
}