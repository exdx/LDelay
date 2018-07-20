pragma solidity ^0.4.24;

//pay coverage to beneficiary here

import "./LDelayBase.sol";

contract LDelayPayout is LDelayBase {

    mapping (address => uint) private balances;
    mapping (address => uint) private coverages;
    mapping (address => uint) private claims;

    function postClaim(uint amount, string reason) external inPool {
        //send request to start a claim
        //cannot make a claim for more than your limit coverage 
        require(amount <= coverages[msg.sender]);

        claimants.push(msg.sender);
        claims[msg.sender] = claimid;
        claimid++;

        emit LogClaimPosted(msg.sender, amount, reason);
    }

    function approveClaim(address beneficiary, uint _claimid, uint amount) internal onlyOwner {
        //approve claim - only allowed by pool administrator
        delete claimants[_claimid];
        beneficiary.transfer(amount); 
    }

}