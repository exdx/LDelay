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
    uint256 nextPayeeIndex;

    //contract state: Active (Train is running normally, customers can purchase insurance)
    //or Inactive (Train is delayed, customers cannot purchase insurance)

    string[2] LTRAINSTATES = ["Normal", "Delayed"];
    string LTRAINSTATUS;

    uint premiumAmount = 3 ether;  //customer pays as a premium for coverage. this is dynamic but static to start.
    uint coverageAmount = 5 ether; //beneficiary is due to recieve in case delay. this is dynamic but static to start.

    event LogDepositMade(address accountAddress, uint amount);
    event LogClaimPosted(uint claimID);

    // modifier isStatusNormal() {
    //     require(keccak256(LTRAINSTATUS) == keccak256(LTRAINSTATES[0]));
    //     _;
    // }

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

    function issuePolicy(uint _policyid) internal {
        policies[_policyid] = Policy(_policyid, premiumAmount, coverageAmount, 0);
        coverages[beneficiaries[_policyid].beneficiaryAddress] = coverageAmount;
        totalCoverage += coverageAmount;
    }

    function postClaim(uint _policyid) external {
        //send request to start a claim
        //cannot make a claim for more than your limit coverage 
        require(coverages[beneficiaries[_policyid].beneficiaryAddress] > 0);

        emit LogClaimPosted(_policyid);
    }

    function approveClaim(uint _policyid) external payable onlyOwner {
        //approve claim - require that enough equity is left in the pool to cover claim
        require(totalCoverage >= policies[_policyid].coverageLimit);

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

    // function liquidate() private onlyOwner returns (bool) {
    //     //returns all posted premiums to owners and closes pool
    //     //watch for out of gas spam attack
    //     uint256 i = nextPayeeIndex;
    //     while (i < policyID && msg.gas > 200000) {
    //         beneficiaries[i].beneficiaryAddress.transfer(policies[i].premium);
    //         i++;
    //     }
    //     nextPayeeIndex = i;

    // }

    // function emergencyStop() private  onlyOwner returns (bool) {
    //     //stops all contract functions
    //     //use emergey stop library

    //     bool isStopped = false;
    //     return isStopped;
    // }

    function () public {
        revert();
    }

}