pragma solidity ^0.4.24;

import "./Ownable.sol";
import "./SafeMath.sol" as SafeMath;

contract LDelayBase is Ownable {
     	
    //using SafeMath for uint256; - Library import

    mapping (address => uint) private balances;
    mapping (address => uint) private coverages;
    mapping (address => uint) private claims;

    uint totalCoverage;
    uint claimid;
    address[] claimants;

    event LogDepositMade(address accountAddress, uint amount);
    event LogClaimPosted(address beneficiary, uint amount, string reason);

    modifier inPool() {
        require(coverages[msg.sender] > 0);
        _;
    }

    function depositPremium() payable external returns (uint) {
        //deposit premium into pool for the expected coverage

        uint coverageAmount = 5; //this is the amount that the beneficiary is due to recieve in the case of a delay. this is dynamic.

        balances[msg.sender] = balances[msg.sender] + msg.value;
        emit LogDepositMade(msg.sender, msg.value);
        
        coverages[msg.sender] = coverages[msg.sender] + coverageAmount;
        totalCoverage += coverageAmount;

        return coverage();
    }

    function getTotalCoverage() public view returns (uint) {
        //get balance of custody union pool
        return totalCoverage;
    }
 
    function postClaim(uint amount, string reason) external inPool {
        //send request to start a claim
        //only someone already in the pool should be able to call this function
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

    function balance() public view returns (uint) {
        return balances[msg.sender];
    }

    function coverage() public view returns (uint) {
        return coverages[msg.sender];
    }

    function liquidate() private onlyOwner returns (bool) {
        //returns all posted premiums to owners and closes pool
    }

    function emergencyStop() private onlyOwner {
        //stops all contract functions
    }

    function () public {
        revert();
    }

}