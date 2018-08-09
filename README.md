# LDelay
A decentralized application running on Ethereum which enables users to purchase parametric microinsurance covering L train delays. LDelay utilizes a live oracle feed which queries data directly from the MTA to establish whether your train was delayed and if you are eligible for a payout. 

## What's LDelay about?
We all hate the feeling when our train is delayed right when we need to make an important trip - what if there were a way to buy a small amount of insurance to cover such an event? In the case of a delay you would get a payout above the small amount you paid for it. It would make the whole commute process a little more pleasant. The only way to provide such a service, cutting through all the red tape and bureacracy of established insurance channels, is through a public blockchain with rich smart contract capabilities.

## Implementation Details
* Separation of concerns
* Oraclize
* Automation
* Security
* Metamask
* Docs for more info on attacks/security patterns

## User Story
A user knows he or she has to take the L train in 15 minutes to get to work - let's say it's 8:00 AM and they plan to arrive at the subway stop around 8:15 AM. They have a big meeting at work and can't be late! They go on LDelay to purchase a small amount of Ethereum based microinsurance (say a few dollars) to hedge against the train being delayed 15 minutes into the future (*right when they arrive at the station*). Using MetaMask they are able to send a transaction in to deposit a small premium and obtain coverage. Their deposit triggers a call to the data feed to obtain the status of the train in 15 minutes. The data feed comes directly from the MTA, the train service provider, and is as accurate as possible. After they purchase microinsurance they proceed to get ready and head to work. Fifteen minutes later there are two possible states of the world:
* A) The data feed reports that the train is in fact delayed at 8:15 AM. How unfortunate! The smart contract updates the user's final policy status to delayed, which enables the user to initiate a claim in the future. The contract knows the user's address and how much of a payout they are entitled to. The user ends up late to work but has a few more dollars worth of ETH to show for it.
* B) The train is on time. The smart contract updates the user's final policy status to normal, which does not allow the user to initiate a claim in the future. The user does not recieve a payout and their premium is left in the pool (to help insure the following users). Whatever small monetary loss they experience is offset by the knowledge they are on time to their meeting!

The end result in either case is the customer is given an opportunity to efficiently deploy their capital to fulfill their needs at that point in time. Only through a decentralized, autonomous system like an Ethereum could such an application exist. 

# Setup
* Vagrant running Ubuntu 16.04 LTS
* Truffle

# Improvements
* Seperate payout/claims into separate contract
* Variable premiums/limits
* Deanonymization to prevent adverse selection
* Only allow deposits when train status is normal (requiring additional oracle queries)



