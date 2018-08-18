pragma solidity ^0.4.24;

/**@title Abstract LDelayOracle contract*/
contract LDelayOracleInterface {
    function __callback(bytes32, string) public;
    function getLTrainStatus(uint, uint) external payable;
    function setBaseTrainStatus(uint) external;
    function setBaseContractAddress(address) external;
}