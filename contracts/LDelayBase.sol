pragma solidity ^0.4.24;

import "./Pausable.sol";
import "./LDelayBaseInterface.sol";
import "./LDelayOracleInterface.sol";
import { SafeMath } from "../libraries/SafeMath.sol";
import { StringUtils } from "../libraries/StringUtils.sol";

/** @title Provides base functionality for insurance functions: deposit/issue policy/withdraw */
contract LDelayBase is LDelayBaseInterface, Pausable {
     	
    using SafeMath for uint;
    using StringUtils for string;

    mapping (address => uint) private balances;
    mapping (address => uint) private coverages;
    mapping (address => uint) private addressPolicyMap;
    mapping (address => uint) private addressTimeLimitMap;
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
        string FinalStatus;
    }

    uint totalCoverage; 
    uint policyID;

    LDelayOracleInterface oracle;

    /** @dev L Train states 
      * Normal (Train is running normally)
      * Delayed (Train is delayed)
      * Unknown (MTA API is not responding)
      * The contract state is determined by the response of the oracle
    */
    string[3] LTRAINSTATES = ["Normal", "Delayed", "Unknown"];
    string public LTRAINSTATUS;

    /** @dev Premium and Coverages
      * @param premiumAmount Amount customer pays for coverage. This is ideally dynamic but static to start.
      * @param coverageAmount Amount beneficiary is due to recieve in case delay. This is ideally dynamic but static to start.
    */
    uint premiumAmount = 10 finney;
    uint coverageAmount = 200 finney;

    event LogDepositMade(address accountAddress, uint amount, uint policyID);
    event LogPayoutMade(address claimant, uint amount);
    event LogPolicyMade(address accountAddress, uint amount, uint policyID);
    event LogOracleQueryMade(address indexed _from, uint policyID);
    event LogOracleStateSet(uint indexed policyID, string result); 
    event LogPolicyClosed(address indexed _from, uint policyID);

    modifier inPool() {
        require(coverages[msg.sender] > 0, "Address not covered");
        _;
    }

    modifier notInPool() {
        require(coverages[msg.sender] == 0, "Policy already issued");
        _;
    }

    /** @dev Constructor - determine oracle contract address 
      * @dev The address of the oracle is passed in at deployment
      * @dev Calls setBaseContract in oracle contract with this address */
    constructor(address _t) public payable {
        oracle = LDelayOracleInterface(_t);
        oracle.setBaseContractAddress(this);
    }

    /** @dev Deposit premium into contract for the expected coverage. Customer must be "new" and deposit more than minimum premium amount. 
      * @dev To begin premium is .01 in ETH and coverage amount is 0.02 in ETH. 
      * @param _coverageTimeLimit The time in the future the customer wants to be covered against delay. At this time the oracle queries again to determine train status. 
      * This parameter will be provided by the user in minutes and then converted to block numbers in the future
     */
    function depositPremium(uint _coverageTimeLimit) external payable whenNotPaused {
        require(balances[msg.sender] == 0, "customer balances must be zero"); 
        require(msg.value >= premiumAmount, "customer must deposit >= premium");
        require(_coverageTimeLimit >= 5, "coverage must be for at least 5 minutes");
        require(_coverageTimeLimit <= 60, "coverage must be for at most 60 minutes");

        uint amountToSend = premiumAmount;
        uint change = msg.value - amountToSend;
        msg.sender.transfer(change); // return change to sender

        beneficiaries[policyID] = Beneficiary(policyID, msg.sender);
        addressPolicyMap[msg.sender] = policyID;
        addressTimeLimitMap[msg.sender] = _coverageTimeLimit;

        balances[msg.sender] = premiumAmount;
        emit LogDepositMade(msg.sender, premiumAmount, policyID);
    }

    /** @dev Issue policy for a given beneficiary
      * @dev Calls the callOraclefromBase function to issue a callback as to the final train state
      * @dev Must be protected against reentrancy attacks (via modifier)
     */
    function issuePolicy() external notInPool whenNotPaused {
        //Note: if the customer purchases again with the same address the mappings will be overwritten with the latest (OK)
        uint _policyid = addressPolicyMap[msg.sender]; 
        uint _coverageTimeLimit = addressTimeLimitMap[msg.sender];

        require(_coverageTimeLimit >= 5, "Please deposit premium before calling this function!");

        policies[_policyid] = Policy(_policyid, premiumAmount, coverageAmount, _coverageTimeLimit, "0");
        emit LogPolicyMade(msg.sender, coverageAmount, _policyid);

        coverages[msg.sender] = coverageAmount;
        totalCoverage = totalCoverage.add(200); //add 200 finney to total pool coverage
        policyID++;
    }

    /** @dev Oracle callback to determine status of policy at the end of the time limit (provided in minutes)
      * @dev This is then reflected in the Final Status of that policy struct and used in the approveClaim function
      * @dev This is an expensive function call since it requires the gas to pay the oracle fee 
     */
    function callOraclefromBase() external payable {
        uint _policyid = addressPolicyMap[msg.sender];
        uint _coverageTimeLimit = addressTimeLimitMap[msg.sender];

        require(_coverageTimeLimit >= 5, "Please deposit premium before calling this function!");
        if (!policies[_policyid].FinalStatus.equal("0")) revert(); //Policy status must be unknown to call oracle

        emit LogOracleQueryMade(msg.sender, _policyid);
        oracle.getLTrainStatus.value(msg.value)(_coverageTimeLimit, _policyid); //call to oracle contract
    }

    /** @dev Approve claim for a given beneficiary: user calls this function to receive payout (if their policy reflects a delay)
      * @dev Claim approved only if train state is "Delayed" by confirming the Final Status of that policy
      * @dev If status is "Normal" the customer coverage and premium is reset but no payment is made
     */
    function approveClaim() external inPool whenNotPaused {
        uint _policyid = addressPolicyMap[msg.sender];
        require(beneficiaries[_policyid].beneficiaryAddress == msg.sender, "caller is not original beneficiary");
        require(totalCoverage >= 200, "Not enough equity is left in the pool to cover claim");

        //int _statuscheck = policies[_policyid].FinalStatus.compare("0"); 

        //Length of Final Status should be greater than "O" if the oracle query returned by this point
        //require(_statuscheck > 0, "Claiming too soon - try again later");

        //Subtract coverages (limit) and balances (premium) for policyholder and decrement total pool coverage
        coverages[msg.sender] = 0;
        balances[msg.sender] = 0;
        totalCoverage = totalCoverage.sub(200); //subtract 200 finney from total pool coverage

        //Final Status should be equal to "Delayed" for the claim to be accepted and transfer made
        if (policies[_policyid].FinalStatus.equal(LTRAINSTATES[1])) { 
            emit LogPayoutMade(beneficiaries[_policyid].beneficiaryAddress, policies[_policyid].coverageLimit); 
            beneficiaries[_policyid].beneficiaryAddress.transfer(policies[_policyid].coverageLimit);
        } else {
            emit LogPolicyClosed(beneficiaries[_policyid].beneficiaryAddress, _policyid);
        }
    }

    /** @dev Set the LTRAINSTATUS variable: used in conjunction with the oraclize contract 
      * @dev Also sets the FinalStatus variable for the relevant beneficiary
      * @param _status The final status of the policy in question
      * @param _externalpolicyID The ID of the policy in question
     */
    function setLTRAINSTATUS(string _status, uint _externalpolicyID) public {
        if (msg.sender != address(oracle)) revert();
        LTRAINSTATUS = _status;
        setPolicyStatus(_externalpolicyID, _status);
    }

    /** @dev Set final policy status for policyholder 
      * @dev FinalStatus is used in approveClaim to determine if policyholder is eligible for a payout
      * @param _policyID The ID of the policy in question
      * @param _policyState The final policy state
     */
    function setPolicyStatus(uint _policyID, string _policyState) internal {
        emit LogOracleStateSet(_policyID, _policyState);
        policies[_policyID].FinalStatus = _policyState;
    }

    /** @dev Returns total coverage liabilities by LDelay risk pool at that moment in time */
    function getTotalCoverage() public view returns (uint) {
        return totalCoverage;
    }

    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    function getCoverage() public view returns (uint) {
        return coverages[msg.sender];
    }

    function verifyUserTrainStatus() public view returns (string) {
        return policies[addressPolicyMap[msg.sender]].FinalStatus;
    }

    function () public {
        revert();
    }
}