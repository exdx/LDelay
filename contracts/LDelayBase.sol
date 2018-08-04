pragma solidity ^0.4.24;

import "./Ownable.sol";
import "./LDelayOracle.sol";
import { SafeMath } from "../libraries/SafeMath.sol";
import { StringUtils } from "../libraries/stringUtils.sol";

/** @title Provides base functionality for insurance functions: deposit/issue policy/withdraw */
contract LDelayBase is Ownable {
     	
    using SafeMath for uint256;

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

    /** @dev L Train states 
      * Normal (Train is running normally, customers can purchase insurance)
      * Delayed (Train is delayed, customers cannot purchase insurance)
      * Unknown (MTA API is not responding)
      * The contract state is determined by the response of the oracle
    */
    string[3] LTRAINSTATES = ["Normal", "Delayed", "Unknown"];
    string LTRAINSTATUS;

    /** @dev Premium and Coverages
      * @param premiumAmount Amount customer pays for coverage. This is ideally dynamic but static to start.
      * @param coverageAmount Amount beneficiary is due to recieve in case delay. This is ideally dynamic but static to start.
    */
    uint premiumAmount = 3 ether;
    uint coverageAmount = 5 ether;

    event LogDepositMade(address accountAddress, uint amount);
    event LogPayoutMade(address claimant, uint amount);

    modifier isStatusNormal() {
        //LTRAINSTATUS = LDelayOracle.getLTrainInitialStatus();
        require(StringUtils.equal(LTRAINSTATUS, LTRAINSTATES[0]), "Train status is not normal: cannot buy coverage");
        _;
    }

    modifier isStatusDelayed() {
        //LTRAINSTATUS = LDelayOracle.getLTrainInitialStatus();
        require(StringUtils.equal(LTRAINSTATUS, LTRAINSTATES[1]), "Train status is not delayed: cannot payout claim");
        _;
    }

    /** @dev Constructor - determine train status upon initial deployment */
    constructor() {
            //call oracle once here
    }

    /** @dev Deposit premium into contract for the expected coverage. Customer must be "new" and deposit more than minimum premium amount. 
      * @dev To begin premium is $3 in ETH and coverage limit is $5 in ETH. This will be represented in ETH to start (testnet)
      * @dev Requires LTRAINSTATE to be active (see isStatusNormal modifier)
      * @param coverageTimeLimit The time in the future the customer wants to be covered against delay. At this time the oracle queries again to determine train status. 
      * This parameter will be provided by the user in minutes and then converted to block numbers in the future
     */
    function depositPremium(uint _coverageTimeLimit) external payable isStatusNormal {
        require(coverages[msg.sender] == 0, "customer balances must be zero"); 
        require(msg.value >= premiumAmount, "customer must deposit >= premium");
        require(_coverageTimeLimit <= 60, "coverage must be for less than one hour");
        uint amountToSend = premiumAmount;
        uint change = msg.value - amountToSend;
        msg.sender.transfer(change); // return change to sender

        beneficiaries[policyID] = Beneficiary(policyID, msg.sender);

        balances[msg.sender] = premiumAmount;
        emit LogDepositMade(msg.sender, premiumAmount);

        issuePolicy(policyID, _coverageTimeLimit);
        policyID++;
    }

    /** @dev Issue policy for a given beneficiary
      * @param _policyid The policy id assigned to the beneficiary when they sign up
      * @param _coverageTimeLimit The time in the future at which the customer is hedging against the train being delayed
      * @return totalCoverage The total amount covered in the pool at this time
     */
    function issuePolicy(uint _policyid, uint _coverageTimeLimit) internal returns(uint) {
        policies[_policyid] = Policy(_policyid, premiumAmount, coverageAmount, _coverageTimeLimit);
        coverages[beneficiaries[_policyid].beneficiaryAddress] = coverageAmount;
        totalCoverage += coverageAmount;

        return totalCoverage;
    }

    /** @dev Approve claim for a given beneficiary: only after a train has been confirmed delayed during their time limit coverage
      * @dev Claim gets posted and approved only if train state is "Delayed" at that point
      * @param _policyid The id of the policy that should be paid out
     */
    function approveClaim(uint _policyid) private isStatusDelayed {
        require(coverages[beneficiaries[_policyid].beneficiaryAddress] > 0, "beneficiary must have coverage");
        require(totalCoverage >= policies[_policyid].coverageLimit, "Not enough equity is left in the pool to cover claim");

        coverages[beneficiaries[_policyid].beneficiaryAddress] -= policies[_policyid].coverageLimit;
        balances[beneficiaries[_policyid].beneficiaryAddress] -= policies[_policyid].premium;
        totalCoverage -= policies[_policyid].coverageLimit;

        emit LogPayoutMade(beneficiaries[_policyid].beneficiaryAddress, policies[_policyid].coverageLimit); 
        beneficiaries[_policyid].beneficiaryAddress.transfer(policies[_policyid].coverageLimit);
    }

    /** @dev Returns total coverage liabilities by LDelay risk pool at that moment in time */
    function getTotalCoverage() public view returns (uint) {
        return totalCoverage;
    }

    function balance() public view returns (uint) {
        return balances[msg.sender];
    }

    function coverage() public view returns (uint) {
        return coverages[msg.sender];
    }

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