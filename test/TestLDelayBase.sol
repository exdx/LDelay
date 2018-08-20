pragma solidity ^0.4.24;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/LDelayBase.sol";

contract TestLDelayBase {

    address base = DeployedAddresses.LDelayBase();
    LDelayBase ldelaybase = LDelayBase(base);


  /** @dev Test to check initial contract balance is set correctly on deployment */ 
    function testInitialBalanceUsingDeployedContract() public {
        uint expected = 2000000000000000000;
        Assert.equal(base.balance, expected, "Contract should have a balance of 2 ether to start");
    }

}