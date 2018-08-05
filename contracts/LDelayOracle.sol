pragma solidity ^0.4.24;

import "./Oraclize.sol";
import "./LDelayBaseInterface.sol";
import "./LDelayBase.sol";

/** @title Use oraclize to hit custom AWS endpoint to get train status */ 
contract LDelayOracle is usingOraclize {
    uint externalPolicyID;

    LDelayBase base;

    event NewOraclizeQuery(string description);
    event LTrainStatusUpdate(string result);

    /** @dev Constructor - determine base contract address */
    constructor(address _t) {
        base = LDelayBase(_t);
    }


    /** @dev Holds result of oraclize query in mtaFeedAPIresult string
      * @return Three possibilities: "Normal", "Delayed", or "Unknown"
    */
    function __callback(bytes32 myid, string result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        emit LTrainStatusUpdate(result);

        setBaseTrainStatus(result, externalPolicyID);
    }

    /** @dev Returns string of train status after querying MTA GTFS feed and deserializing result in a lambda function
      * @dev Allows to pass in delay variable in case of callback */
    function getLTrainStatus(uint _futureTime, uint _externalPolicyID) external payable {
        if (msg.sender != address(base)) revert();
        externalPolicyID = _externalPolicyID;
        uint delaySeconds = _futureTime * 60;

        emit NewOraclizeQuery("Oraclize callback query was sent, standing by for the answer..");
        oraclize_query(delaySeconds, "URL", "https://lchink7hq2.execute-api.us-east-2.amazonaws.com/Live/");
    }

/** @dev Calls setter function in base contract to update train state */
    function setBaseTrainStatus(string result, uint _policyID) internal {
        LDelayBase ldelaybase = LDelayBase(address(base));
        ldelaybase.setLTRAINSTATUS(result, _policyID);
    }
}