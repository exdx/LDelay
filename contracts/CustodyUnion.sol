pragma solidity ^0.4.24;

import "./Ownable.sol";
import "./SafeMath.sol" as SafeMath;

/*
This contract implements the main functions of the DCU: managing an insurance pool covering all
assets of the participating custodians. The contract should not store all the custodian funds directly - instead the
custodians hold their own customer funds via cold storage, HSMs and other secure offline methods. The CustodyUnion contract holds the collateral haircut
that each custodian posts in order to participate in the pool. It then adminsters all the required insurance logic. 
*/

contract CustodyUnion is Ownable {
     	
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

    function depositCollateral(uint coverageAmount) payable external returns (uint) {
        //deposit collateral into pool specifying the amount of coverage you are expecting
        require(coverageAmount > 0);

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
        //approve claim - only allowed for by DCU administrator
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
        //returns all posted collateral to owners and closes pool
    }

    function payDividend(uint dividend) internal onlyOwner returns (bool) {
        //return share of collateral to custodians in case of profits
    }

    function emergencyStop() private onlyOwner {
        //stops all contract functions
    }

    function () public {
        revert();
    }

}