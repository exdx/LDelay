pragma solidity ^0.4.24;

import "./Ownable.sol";
import "./SafeMath.sol" as SafeMath;

contract LDelayBase is Ownable {
     	
    //using SafeMath for uint256; - Library import

    mapping (address => uint) private balances;
    mapping (address => uint) private coverages;
    mapping (address => uint) private claims;
    mapping (uint => Policy) policies;

    struct Beneficiary {
        uint beneficiaryID;
        address beneficiaryAddress;
    }

    struct Policy {
        uint beneficiaryID;
        uint premium;
        uint coverageLimit;
        uint coverageTimeLimit;
    }

    uint totalCoverage;
    uint claimid;
    uint beneficiaryID;
    address[] claimants;

    uint premiumAmount = 3 ether;  //customer pays as a premium for coverage. this is dynamic but static to start.
    uint coverageAmount = 5 ether; //beneficiary is due to recieve in case delay. this is dynamic but static to start.

    event LogDepositMade(address accountAddress, uint amount);
    event LogClaimPosted(address beneficiary, uint amount, string reason);

    modifier inPool() {
        require(coverages[msg.sender] > 0);
        _;
    }

    function depositPremium() payable external returns (bool) {
        //deposit premium into pool for the expected coverage
        //to begin premium is $3 in ETH and coverage limit is $5 in ETH. This will be represented in ETH to start (testnet)
        //limit each customer to one deposit per instance (each hour) to limit inside info trading and exploits

        //require(_coverage = 0);
        
        //customer deposits correct amount
        require(msg.value > premiumAmount);
        uint amountToSend = premiumAmount;
        uint change = msg.value - amountToSend;
        msg.sender.transfer(change); // return change to sender

        Beneficiary(beneficiaryID, msg.sender);

        balances[msg.sender] = premiumAmount;
        emit LogDepositMade(msg.sender, premiumAmount);

        issuePolicy(beneficiaryID);
        beneficiaryID++;
    }

    function issuePolicy(uint beneficiaryID) internal returns (uint) {
        policies[beneficiaryID] = Policy(beneficiaryID, premiumAmount, coverageAmount, 0);
        coverages[msg.sender] = coverageAmount;
        totalCoverage += coverageAmount;

        return coverage();
    }

    function getTotalCoverage() public view returns (uint) {
        //get balance of LDelay pool
        return totalCoverage;
    }
 
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