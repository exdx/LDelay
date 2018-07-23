pragma solidity ^0.4.24;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/LDelayBase.sol";

contract TestLDelayBase {
    LDelayBase ldelaybase = LDelayBase(DeployedAddresses.LDelayBase());

}