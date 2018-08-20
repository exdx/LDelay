pragma solidity ^0.4.24;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/LDelayOracle.sol";

contract TestLDelayOracle {
    function testInitialBalanceUsingDeployedContract() public {
        address oracle = DeployedAddresses.LDelayOracle();
        uint expected = 1000000000000000000;
        Assert.equal(oracle.balance, expected, "Contract should have a balance of 1 ether to start");
    }

}