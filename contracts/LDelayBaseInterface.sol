pragma solidity ^0.4.24;

/**@title Abstract LDelayBase contract*/
contract LDelayBaseInterface {
    function depositPremium(uint) external payable;
    function issuePolicy(uint, uint) private;
    function approveClaim() external;
    function setLTRAINSTATUS(string, uint) public;
    function setPolicyStatus(uint, string) internal;
    function getTotalCoverage() public view returns (uint); 
    function getBalance() public view returns (uint); 
    function getCoverage() public view returns (uint); 
}