pragma solidity ^0.4.24;

import "./usingOraclize.sol";
import "./LDelayOracleInterface.sol";
import "./LDelayBaseInterface.sol";

/** @title Use oraclize to hit custom AWS endpoint to get train status */ 
contract LDelayOracle is LDelayOracleInterface, usingOraclize {
    mapping (bytes32 => uint) policyIDindex; // used to correlate queryID with order in which policy oracle queries were made
    mapping (bytes32 => bool) public pendingQueries;
    mapping (bytes32 => string) resultIDindex;

    LDelayBaseInterface base;

    event NewOraclizeQuery(string description);
    event LTrainStatusUpdate(string result);
    event QueryIDEvent(bytes32 queryID);

    /** @dev Holds result of oraclize query in mtaFeedAPIresult string
      * @return Three possibilities: "Normal", "Delayed", or "Unknown"
    */

    /** @dev Constructor is payable to allow ether in be sent on migration to pay for oraclize calls  */
    constructor() public payable {}

    function __callback(bytes32 myid, string result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        require (pendingQueries[myid] == true, "Query is not processed properly");
        emit LTrainStatusUpdate(result);

        resultIDindex[myid] = result;
        delete pendingQueries[myid]; // This effectively marks the query id as processed.
    }

    /** @dev Returns string of train status after querying MTA GTFS feed and deserializing result in a lambda function
      * @dev Allows to pass in delay variable in case of callback */
    function getLTrainStatus(uint _futureTime, uint _externalPolicyID) external payable {
        /*if (msg.sender != address(base)) revert();  TESTING */
        uint delaySeconds = _futureTime * 60;
        // require ETH to cover callback gas costs
        require(msg.value >= 0.000175 ether, "Cannot cover oraclize costs"); // 175,000 gas * 1 Gwei = 0.000175 ETH

        emit NewOraclizeQuery("Oraclize callback query was sent, standing by for the answer..");
        bytes32 queryId = oraclize_query(delaySeconds, "URL", "https://lchink7hq2.execute-api.us-east-2.amazonaws.com/Live/");
        pendingQueries[queryId] = true;
        policyIDindex[queryId] = _externalPolicyID;
    }

/** @dev Calls setter function in base contract to update train state */
    function setBaseTrainStatus(bytes32 _queryID) internal {
        string _result = resultIDindex[_queryID];
        uint _policyID = policyIDindex[_queryID];
        
        base.setLTRAINSTATUS(_result, _policyID);
    }

/** @dev Sets the LDelayBase address via LDelayBase calling this function upon deployment 
  * @dev Can only be called once to set the Base address
  */
    function setBaseContractAddress(address _baseAddress) external {
        require(address(base) == address(0), "Base Address has already been set");
        base = LDelayBaseInterface(_baseAddress);
    }

    function () public {
        revert();
    }
}