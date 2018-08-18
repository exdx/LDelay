# Avoiding Common Attacks

Several security decisions were made over the course of implementing the LDelay project. Key among them were heavy use of require statements and user validations. Some design decisions deliberately limited user functionality in order to prevent attacks and adverse selection. Since both LDelayBase and LDelayOracle interacted with one another validations were made that only those two contracts could communicate with one another in the intended ways.

For example, a user can only purchase one policy at a time from a given address. This prevents one attacking contract to perform a reentrancy attack all at once. This is implemented by requiring the balance of msg.sender to be 0 for them to be able to deposit a premium. Furthermore this limits adverse selection where a user buys a lot of microinsurance coverage and then intentionally delays the train, making a profit. Reentrancy attacks are also limited by putting all send() and value transfers at the end of the relavant function after all checks and requirements are met. 

Race conditions are limited by limiting state between contracts and requirements. For example the final policy status has to unknown in order for the oracle to query, and it has to be delayed in order for the payout to process. 

Overflow/underflow attacks are minimized by use of the SafeMath library for a arithmetic operations. 

Gas revert attacks are minimized by the functions being atomic - there are no iterations over arrays or other functions with unknown gas requirements. The user pays the required gas and the transaction either succeeds or does not. There are also no caps or limits on the balance of the contract to prevent attacks where ether is forcibly sent to the contract. 

The address of the Base contract and the Oracle contract are set upon deployment and known to each other. Requirements are in place so that only the addresses of the known contracts can successfully call functions in the other contract. 