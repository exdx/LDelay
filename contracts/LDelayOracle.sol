pragma solidity ^0.4.24;

import "./usingOraclize.sol";
import "./LDelayOracleInterface.sol";
import "./LDelayBaseInterface.sol";

/** @title Use oraclize to query custom AWS Lambda function to get train status. Three possible results: "Normal", "Delayed", or "Unknown" */ 
contract LDelayOracle is LDelayOracleInterface, usingOraclize {
    mapping (uint => bytes32) policyIDindex; // used to correlate policyID with query ID
    mapping (bytes32 => bool) public pendingQueries;
    mapping (bytes32 => string) resultIDindex; // used to correlate queryID with result of API call

    LDelayBaseInterface base;

    event NewOraclizeQuery(string description);
    event LTrainStatusUpdate(string result, bytes32 id);
    event QueryIDEvent(bytes32 queryID);

    /** @dev Constructor is payable to allow ether in be sent on migration to pay for oraclize calls  */
    constructor() public payable {}

    /** @dev Callback of oraclize query - standard oraclize library implementation
      * @param myid The query ID oraclize assigns to the request
      * @param result The result of the API call   
     */
    function __callback(bytes32 myid, string result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        require (pendingQueries[myid] == true, "Query is not processed properly");
        emit LTrainStatusUpdate(result, myid);

        resultIDindex[myid] = result;
        delete pendingQueries[myid]; // This effectively marks the query id as processed.
    }

    /** @dev Returns string of train status after querying MTA GTFS feed and deserializing result in a lambda function
      * @dev Allows to pass in delay variable in case of callback
      * @param _futureTime The time in the future the query will be executed - selected by the customer. Acts as a delay.
      * @param _externalPolicyID The policyID associated with the query request
     */
    function getLTrainStatus(uint _futureTime, uint _externalPolicyID) external payable {
        if (msg.sender != address(base)) revert();
        uint delaySeconds = _futureTime * 60;
        // require ETH to cover callback gas costs
        require(msg.value >= 0.000175 ether, "Cannot cover oraclize costs"); // 175,000 gas * 1 Gwei = 0.000175 ETH

        emit NewOraclizeQuery("Oraclize callback query was sent, standing by for the answer..");
        bytes32 queryId = oraclize_query(delaySeconds, "URL", "https://lchink7hq2.execute-api.us-east-2.amazonaws.com/Live/");
        pendingQueries[queryId] = true;
        policyIDindex[_externalPolicyID] = queryId; 
    }

    /** @dev Calls setter function in base contract to update train state 
      * @dev NOTE: This function is potentially insecure: anyone can set the train status of any policy - but the result information is accurate
      * @param _externalPolicyID The policy ID that is associated with the query result and policy
     */
    function setBaseTrainStatus(uint _externalPolicyID) external {
        string storage _result = resultIDindex[policyIDindex[_externalPolicyID]];
        require(keccak256(abi.encodePacked(_result)) != keccak256(abi.encodePacked("")), "Callback for this policy has not finished executing"); 
        base.setLTRAINSTATUS(_result, _externalPolicyID);
    }

    /** @dev Sets the LDelayBase address via LDelayBase calling this function upon deployment 
      * @dev Can only be called once to set the Base address
      * @param _baseAddress The address of LDelayBase
     */
    function setBaseContractAddress(address _baseAddress) external {
        require(address(base) == address(0), "Base Address has already been set");
        base = LDelayBaseInterface(_baseAddress);
    }

    function () public {
        revert();
    }
}