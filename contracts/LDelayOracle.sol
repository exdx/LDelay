pragma solidity ^0.4.24;

import "./Oraclize.sol";
//import "./LDelayBaseInterface.sol";

/** @title Use oraclize to hit custom AWS endpoint to get train status */ 
contract LDelayOracle is usingOraclize {
    uint externalPolicyID;

    address LDelayBaseAddress;

    event NewOraclizeQuery(string description);
    event LTrainStatusUpdate(string result);

    /** @dev Holds result of oraclize query in mtaFeedAPIresult string
      * @return Three possibilities: "Normal", "Delayed", or "Unknown"
    */
    function __callback(bytes32 /*myid */, string result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        emit LTrainStatusUpdate(result);

        setBaseTrainStatus(result, externalPolicyID);
    }

    /** @dev Returns string of train status after querying MTA GTFS feed and deserializing result in a lambda function
      * @dev Allows to pass in delay variable in case of callback */
    function getLTrainStatus(uint _futureTime, uint _externalPolicyID) external payable {
       // if (msg.sender != address(baseInterface)) revert();
        externalPolicyID = _externalPolicyID;
        uint delaySeconds = _futureTime * 60;

        emit NewOraclizeQuery("Oraclize callback query was sent, standing by for the answer..");
        oraclize_query(delaySeconds, "URL", "https://lchink7hq2.execute-api.us-east-2.amazonaws.com/Live/");
    }

/** @dev Calls setter function in base contract to update train state */
    function setBaseTrainStatus(string result, uint _policyID) internal {
        LDelayBaseAddress.call(bytes4(keccak256("setLTRAINSTATUS(string, uint)")), result, _policyID);
    }

/** @dev Sets the LDelayBase address via LDelayBase calling this function upon deployment 
  * @dev Can only be called once to set the Base address
  */
    function setBaseContractAddress(address _baseAddress) external {
        require(LDelayBaseAddress == address(0), "Base Address has already been set");
        LDelayBaseAddress = _baseAddress;
    }
}