pragma solidity ^0.4.24;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/LDelayBase.sol";

contract TestLDelayBase {

    address baseAddress = DeployedAddresses.LDelayBase();
    LDelayBase ldelaybase = LDelayBase(baseAddress);

  /** @dev Test to check initial contract balance is set correctly on deployment */ 
    function testInitialBalanceUsingDeployedContract() public {
        uint expected = 2000000000000000000;
        Assert.equal(baseAddress.balance, expected, "Contract should have a balance of 2 ether to start");
    }

  /** @dev Test ownership */ 
    function testOwernshipOfDeployedContract() public {
        address _owner = 0x5AEDA56215b167893e80B4fE645BA6d5Bab767DE; //accounts[9]
        Assert.equal(ldelaybase.owner(), _owner, "Contract owner is not expected owner");
    }

    //Test Pause/Unpause functionality

}