# LDelay
A decentralized application running on Ethereum which enables users to purchase parametric microinsurance covering L train delays. LDelay utilizes a live oracle feed which queries data directly from the MTA to establish whether your train was delayed and if you are eligible for a payout. 

Context for folks outside NYC: The L is a subway line in NYC that connects Lower Manhattan to Brooklyn. The neighborhoods it passes through in Brooklyn are Williamsburg and Bushwick (considered very trendy areas). In fact, ConsenSys offices are off the L line in Bushwick. The MTA is the name of the agency responsible for adminstering subway train service in NYC. [See the wiki article](https://en.wikipedia.org/wiki/L_(New_York_City_Subway_service)) for more details.

## What's LDelay about?
We all hate the feeling when our train is delayed right when we need to make an important trip - what if there were a way to buy a small amount of insurance to cover such an event? In the case of a delay you would get a payout above the small amount you paid for it. It would make the whole commute process a little more pleasant. The only way to provide such a service, cutting through all the red tape and bureacracy of established insurance channels, is through a public blockchain with rich smart contract capabilities.

![alt text](https://i.imgur.com/OqqXrq3.png "LDelay Interface")

## User Story
A user knows he or she has to take the L train in 15 minutes to get to work - let's say it's 8:00 AM and they plan to arrive at the subway stop around 8:15 AM. They have a big meeting at work and can't be late! They go on LDelay to purchase a small amount of Ethereum based microinsurance (say a few dollars) to hedge against the train being delayed 15 minutes into the future (*right when they arrive at the station*). Using MetaMask they are able to send a transaction in to deposit a small premium and obtain coverage. Their deposit triggers a call to the data feed to obtain the status of the train in 15 minutes. The data feed comes directly from the MTA, the train service provider, and is as accurate as possible. After they purchase microinsurance they proceed to get ready and head to work. Fifteen minutes later there are two possible states of the world:
* A) The data feed reports that the train is in fact delayed at 8:15 AM. How unfortunate! The smart contract updates the user's final policy status to delayed, which enables the user to initiate a claim in the future. The contract knows the user's address and how much of a payout they are entitled to. The user ends up late to work but has a few more dollars worth of ETH to show for it.
* B) The train is on time. The smart contract updates the user's final policy status to normal, which does not allow the user to initiate a claim in the future. The user does not recieve a payout and their premium is left in the pool (to help insure the following users). Whatever small monetary loss they experience is offset by the knowledge they are on time to their meeting!

The end result in either case is the customer is given an opportunity to efficiently deploy their capital to fulfill their needs at that point in time. Only through a distributed virtual machine like Ethereum could such an application exist. 

## Implementation Details
* __Separation of concerns__ \
There are two contracts in the dApp: a base contract that fulfills all the core logic and an oracle contract that is responsible for calling the oracle and recording the result. Both contracts are deployed together and talk to each other via their interfaces. Functions are written to be as simple and pure as possible, and multiple functions across the two contracts are called during contract execution. 
* __Oraclize__ \
The oracle contract uses the Oraclize library to send requests to the oracle endpoint. The oracle provider is an AWS Lambda endpoint that I deployed that queries data directly from the MTA and deserializes it. The MTA uses the protobuffer serialization format (common to real time transit systems) therefore the custom endpoint was necessary. See [data](https://github.com/Denton24646/LDelay/tree/master/data) for examples of the two different Lambda function implementations: calling the MTA GTFS API directly and webscraping. 
* __Security__ \
Security was a key focus for the project and was achieved by extensive use of require and assert statements and limiting contract interaction. For example, only the base contract can call certain oracle contract functions and vice-versa. Furthermore, a user may only take out one policy at a time, to fight adverse selection type attacks. See docs section for more info. 
* __MetaMask__ \
MetaMask is used to interact with the dApp front end in the browser. 
* __React.js__ \
The dApp front end was built using the React javascript library. 
* __Docs__ \
[Avoiding Common Attacks](https://github.com/Denton24646/LDelay/blob/master/docs/avoiding_common_attacks.md)
\
[Design Pattern Decisions](https://github.com/Denton24646/LDelay/blob/master/docs/design_pattern_decisions.md)

# Setup
LDelay can be run in two ways:
1. By running a preconfigured Ubuntu 16.04 Vagrant environment which comes complete with Truffle, ethereum-bridge, Node.js and LDelay (__works on any machine__). Only
Metamask will have to be installed manually. __*Not ready, please use the second method.*__
2. By downloading LDelay and locally running Truffle and ethereum-bridge on a *nix machine or Ubuntu VM.

### Vagrant Setup
1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. Install [Vagrant](https://www.vagrantup.com/downloads.html)
3. Download and start the Vagrant instance (note: running `vagrant up` takes approx 5 mins):

    ```sh
    git clone https://github.com/Denton24646/LDelay
    cd LDelay
    vagrant up
    vagrant ssh
    ```
    
4. To shutdown the Vagrant instance, run `vagrant suspend`. To delete it, run
   `vagrant destroy`. To start from scratch, run `vagrant up` after destroying the
   instance.

### Running locally
1. Download the Ubuntu 16.04 image ([torrent link](http://releases.ubuntu.com/16.04/ubuntu-16.04.5-desktop-amd64.iso.torrent))
and [VirtualBox](https://www.virtualbox.org/wiki/Downloads) if using a VM. I recommend provisioning 4GB RAM for the VM.
2. Install node (v10.0+), npm, git, truffle and MetaMask. 
    ```sh
    # install curl
    sudo apt-get install curl
    # install node & npm
    curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
    sudo apt-get install -y nodejs
    # install git
    sudo apt-get install -y git
    # install truffle
    sudo npm install -g truffle
    ```
    MetaMask can be installed from the [Firefox add-ons store](https://addons.mozilla.org/en-US/firefox/addon/ether-metamask/).
3. Install project dependencies
    ```sh
    git clone https://github.com/Denton24646/LDelay
    cd LDelay
    npm install
    cd ..
    git clone https://github.com/oraclize/ethereum-bridge
    cd ethereum-bridge
    npm install
    ```
4. Run the Truffle development blockchain and ethereum-bridge in two seperate consoles (follow this exact order!)
    ```sh
    # console one
    cd LDelay
    truffle develop
    # console two
    cd ethereum-bridge
    node bridge -H localhost:9545 -a 9 --dev
    # switch back to console one (truffle console)
    compile
    migrate
    test
    ```
5. Start the React front end from the local server
    ```sh
    # console three
    cd LDelay
    npm start
    ```
    Be sure to configure MetaMask using the default mnemonic phrase:
    ```
    candy maple cake sugar pudding cream honey rich smooth crumble sweet treat 
    ```
    Add the custom RPC endpoint when choosing a network: 
    ```
    http://127.0.0.1:9545 
    ```
    and then refresh the app page. 
    Once the app recognizes your MetaMask account you are good to go!
# Getting Started
![Alt Text](https://media.giphy.com/media/JiuX6CeCM0us0/giphy.gif)

*Don't worry, this dApp is easy to use!*

The front end has instructions on how to interact with the application - please read and follow those. Additional dev notes:
* Pick five minutes as your input - this is the lowest possible time in the future you can issue a policy. 
* If you look at the ethereum-bridge console window after issuing the oracle request you can see the HTTP query and the callback for the time you chose. 
* The contract allows a user to only buy one policy at a time as a deliberate design choice. Therefore to test multiple policies switch to another of the 10 MetaMask default accounts. 
* Don't forget to run ```rm -rf build/* ``` after editing contracts to have them recompile successfully. 
* MetaMask in Firefox on an Ubuntu VM seems a little quirky - if the signing popup comes up after hitting a button but it appears grey, try resizing the popup window slightly. Then the details come up as normal. 

# Improvements for Mainnet
* __Harden Oracle__
\
There were some difficulties on getting the correct results from the MTA API directly - in some cases the website said the train was delayed whereas the API did not return alert objects for the L Train (as documented). Therefore the alternate oracle strategy of scraping the website directly for transit updates was used. Other issue is that the oracle returns "Normal" as the result and Solidity does not seem to like strings with quotation marks in them (needing escape characters). So in general the oracle needs some more refining and tests. 
* __Variable premiums/limits__
\
The premium and limit amounts in the contract now are basically best guest estimates of an equilibrium and are not scientific in any way. Ideally there would be some analysis on the likelihood of a train delay based on different features like time of day, day of the week, etc and the prices would reflect these. Since that is more of an ML problem off-chain I decided not to focus attention here. 
* __Seperate payout/claims into separate contract__
\
To enhance security a separate contract would be responsible for payouts. This is generally good practice and what Etherisc does in their FlightDelay dApp. 
* __Only allow deposits when train status is normal__
\
Originally this was the plan but it complicated the design significantly as it requires additional oracle queries to determine the status at any point in time. 



