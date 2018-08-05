pragma solidity ^0.4.24;

import "./Ownable.sol";
import "./LDelayOracle.sol";
import { SafeMath } from "../libraries/SafeMath.sol";
import { StringUtils } from "../libraries/StringUtils.sol";

/** @title Provides base functionality for insurance functions: deposit/issue policy/withdraw */
contract LDelayBase is Ownable {
     	
    using SafeMath for uint;

    mapping (address => uint) private balances;
    mapping (address => uint) private coverages;
    mapping (address => uint) private addressPolicyMap;
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
    uint coverageAmount = 20 finney;

    LDelayOracle oracle;

    event LogDepositMade(address accountAddress, uint amount);
    event LogPayoutMade(address claimant, uint amount);

    modifier isStatusNormal() {
        require(StringUtils.equal(LTRAINSTATUS, LTRAINSTATES[0]), "Train status is not normal");
        _;
    }

    modifier isPolicyStatusDelayed(uint _policyid) {
        require(StringUtils.equal(policies[_policyid].FinalStatus, LTRAINSTATES[1]), "Final policy status was not delayed - cannot pay claim");
        _;
    }

    modifier inPool() {
        require(coverages[msg.sender] > 0, "Address not covered");
        _;
    }

    /** @dev Constructor - determine oracle contract address */
    constructor(address _t) {
        oracle = LDelayOracle(_t);
    }

    /** @dev Deposit premium into contract for the expected coverage. Customer must be "new" and deposit more than minimum premium amount. 
      * @dev To begin premium is .01 in ETH and coverage amount is 0.02 in ETH. 
      * @param coverageTimeLimit The time in the future the customer wants to be covered against delay. At this time the oracle queries again to determine train status. 
      * This parameter will be provided by the user in minutes and then converted to block numbers in the future
     */
    function depositPremium(uint _coverageTimeLimit) external payable {
        require(coverages[msg.sender] == 0, "customer balances must be zero"); 
        require(msg.value >= premiumAmount, "customer must deposit >= premium");
        require(_coverageTimeLimit >= 5, "coverage must be for at least 5 minutes");
        require(_coverageTimeLimit <= 60, "coverage must be for at most 60 minutes");

        uint amountToSend = premiumAmount;
        uint change = msg.value - amountToSend;
        msg.sender.transfer(change); // return change to sender

        beneficiaries[policyID] = Beneficiary(policyID, msg.sender);
        addressPolicyMap[msg.sender] = policyID;

        balances[msg.sender] = premiumAmount;
        emit LogDepositMade(msg.sender, premiumAmount);

        issuePolicy(policyID, _coverageTimeLimit);
        policyID++;
    }

    /** @dev Issue policy for a given beneficiary
      * @param _policyid The policy id assigned to the beneficiary when they sign up
      * @param _coverageTimeLimit The time in the future at which the customer is hedging against the train being delayed
      * @return coverageAmount The amount the beneficiary is insured for
     */
    function issuePolicy(uint _policyid, uint _coverageTimeLimit) private returns(uint) {
        policies[_policyid] = Policy(_policyid, premiumAmount, coverageAmount, _coverageTimeLimit, "0");
        coverages[beneficiaries[_policyid].beneficiaryAddress] = coverageAmount;
        totalCoverage += coverageAmount;

        /** @dev Oracle callback to determine status of policy at the end of the time limit (provided in minutes)
          * @dev This is then reflected in the Final Status of that policy struct and used in the approveClaim modifier*/
        oracle.getLTrainStatus(_coverageTimeLimit, _policyid);

        return coverageAmount;
    }

    /** @dev Approve claim for a given beneficiary: user calls this function to receive payout (if their policy reflects a delay)
      * @dev Claim gets posted and approved only if train state is "Delayed" by confirming the Final Status of that policy
     */
    function approveClaim() external inPool {
        uint _policyid = addressPolicyMap[msg.sender];
        int _statuscheck = StringUtils.compare(policies[_policyid].FinalStatus, "0"); 

        //Length of Final Status should be greater than "O" if the oracle query returned by this point
        require(_statuscheck > 0, "Claiming too soon - try again later");
        //Final Status should be equal to "Delayed" for the claim to be accepted
        require(StringUtils.equal(policies[_policyid].FinalStatus, LTRAINSTATES[1]), "Final policy status was not delayed - cannot pay claim");

        require(beneficiaries[_policyid].beneficiaryAddress == msg.sender, "caller is not original beneficiary");
        require(totalCoverage >= policies[_policyid].coverageLimit, "Not enough equity is left in the pool to cover claim");

        coverages[beneficiaries[_policyid].beneficiaryAddress] -= policies[_policyid].coverageLimit;
        balances[beneficiaries[_policyid].beneficiaryAddress] -= policies[_policyid].premium;
        totalCoverage -= policies[_policyid].coverageLimit;

        emit LogPayoutMade(beneficiaries[_policyid].beneficiaryAddress, policies[_policyid].coverageLimit); 
        beneficiaries[_policyid].beneficiaryAddress.transfer(policies[_policyid].coverageLimit);
    }

    /** @dev Set the LTRAINSTATUS variable: used in conjunction with the oraclize contract 
      * @dev Also sets the FinalStatus variable for the relevant beneficiary */
    function setLTRAINSTATUS(string _status, uint _externalpolicyID) public {
        if (msg.sender != address(oracle)) revert();
        LTRAINSTATUS = _status;

        setPolicyStatus(_externalpolicyID, _status);
    }

    function setPolicyStatus(uint _policyID, string _policyState) internal {
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