pragma solidity ^0.4.24;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/LDelayOracle.sol";

contract TestLDelayOracle {

    address oracleAddress = DeployedAddresses.LDelayOracle();
    LDelayOracle ldelayoracle = LDelayOracle(oracleAddress);

  /** @dev Test to check initial contract balance is set correctly on deployment */ 
    function testInitialBalanceUsingDeployedContract() public {
        uint expected = 1000000000000000000;
        Assert.equal(oracleAddress.balance, expected, "Contract should have a balance of 1 ether to start");
    }
}