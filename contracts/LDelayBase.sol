pragma solidity ^0.4.24;

import "./Ownable.sol";
//import "./SafeMath.sol" as SafeMath;

contract LDelayBase is Ownable {
     	
    //using SafeMath for uint256; - Library import

    mapping (address => uint) private balances;
    mapping (address => uint) private coverages;
    mapping (uint => Policy) policies;
    mapping (uint => Beneficiary) beneficiaries;

    struct Beneficiary {
        uint policyID;
        address beneficiaryAddress;
    }

    struct Policy {
        uint policyID;
        uint premium;
        uint coverageLimit;
        uint coverageTimeLimit;
    }

    uint totalCoverage;
    uint policyID;

    //contract state: Active (Train is running normally, customers can purchase insurance)
    //or Inactive (Train is delayed, customers cannot purchase insurance)

    string[] LTRAINSTATE = ["Active", "Inactive"];

    uint premiumAmount = 3 ether;  //customer pays as a premium for coverage. this is dynamic but static to start.
    uint coverageAmount = 5 ether; //beneficiary is due to recieve in case delay. this is dynamic but static to start.

    event LogDepositMade(address accountAddress, uint amount);
    event LogClaimPosted(uint claimID);

    function depositPremium() payable external returns (bool) {
        //deposit premium into pool for the expected coverage
        //to begin premium is $3 in ETH and coverage limit is $5 in ETH. This will be represented in ETH to start (testnet)
        //limit each customer to one deposit per instance (each hour) to limit inside info trading and exploits

        //require LTRAINSTATE to be active
        require(coverages[msg.sender] == 0);
        
        //customer deposits correct amount
        require(msg.value >= premiumAmount);
        uint amountToSend = premiumAmount;
        uint change = msg.value - amountToSend;
        msg.sender.transfer(change); // return change to sender

        beneficiaries[policyID] = Beneficiary(policyID, msg.sender);

        balances[msg.sender] = premiumAmount;
        emit LogDepositMade(msg.sender, premiumAmount);

        issuePolicy(policyID);
        policyID++;

        return true;
    }

    function issuePolicy(uint _policyID) internal {
        policies[_policyID] = Policy(_policyID, premiumAmount, coverageAmount, 0);
        coverages[msg.sender] = coverageAmount;
        totalCoverage += coverageAmount;
    }

    function postClaim(uint _policyid) external {
        //send request to start a claim
        //cannot make a claim for more than your limit coverage 
        require(coverages[beneficiaries[_policyid].beneficiaryAddress] > 0);

        emit LogClaimPosted(_policyid);
    }

    function approveClaim(uint _policyid) external onlyOwner {
        //approve claim - only allowed by pool administrator

        coverages[beneficiaries[_policyid].beneficiaryAddress] -= policies[_policyid].coverageLimit;
        balances[beneficiaries[_policyid].beneficiaryAddress] -= policies[_policyid].premium;
        totalCoverage -= policies[_policyid].coverageLimit;

        beneficiaries[_policyid].beneficiaryAddress.transfer(policies[_policyid].coverageLimit);
    }

    function getTotalCoverage() public view returns (uint) {
        //get balance of LDelay pool
        return totalCoverage;
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