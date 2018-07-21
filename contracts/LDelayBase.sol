pragma solidity ^0.4.24;

import "./Ownable.sol";
//import "./SafeMath.sol" as SafeMath;

contract LDelayBase is Ownable {
     	
    //using SafeMath for uint256; - Library import

    mapping (address => uint) private balances;
    mapping (address => uint) private coverages;
    mapping (uint => uint) private claims;
    mapping (uint => Policy) policies;

    struct Beneficiary {
        uint beneficiaryID;
        address beneficiaryAddress;
    }

    struct Policy {
        uint policyID;
        uint premium;
        uint coverageLimit;
        uint coverageTimeLimit;
    }

    uint totalCoverage;
    uint beneficiaryID;
    uint[] claimants;

    //contract state: Active (Train is running normally, customers can purchase insurance)
    //or Inactive (Train is delayed, customers cannot purchase insurance)

    uint premiumAmount = 3 ether;  //customer pays as a premium for coverage. this is dynamic but static to start.
    uint coverageAmount = 5 ether; //beneficiary is due to recieve in case delay. this is dynamic but static to start.

    event LogDepositMade(address accountAddress, uint amount);
    event LogClaimPosted(uint claimID);

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
        require(msg.value >= premiumAmount);
        uint amountToSend = premiumAmount;
        uint change = msg.value - amountToSend;
        msg.sender.transfer(change); // return change to sender

        Beneficiary(beneficiaryID, msg.sender);

        balances[msg.sender] = premiumAmount;
        emit LogDepositMade(msg.sender, premiumAmount);

        issuePolicy(beneficiaryID);
        beneficiaryID++;

        return true;
    }

    function issuePolicy(uint _beneficiaryID) internal {
        policies[_beneficiaryID] = Policy(_beneficiaryID, premiumAmount, coverageAmount, 0);
        coverages[msg.sender] = coverageAmount;
        totalCoverage += coverageAmount;
    }

    function getTotalCoverage() public view returns (uint) {
        //get balance of LDelay pool
        return totalCoverage;
    }
 
    function postClaim(uint _policyid) external inPool {
        //send request to start a claim
        //cannot make a claim for more than your limit coverage 
        claimants.push(_policyid);
        emit LogClaimPosted(_policyid);
    }

    function approveClaim(address beneficiary, uint _claimid, uint amount) external onlyOwner {
        //approve claim - only allowed by pool administrator
        delete claimants[_claimid];

        coverages[beneficiary] -= amount;
        totalCoverage -= amount;

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