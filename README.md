# LDelay
A decentralized application running on Ethereum which enables users to purchase parametric microinsurance covering L train delays. LDelay utilizes a live oracle feed which queries data directly from the MTA to establish whether your train was delayed and if you are eligible for a payout. 

## What's LDelay about?
We all hate the feeling when our train is delayed right when we need to make an important trip - what if there were a way to buy a small amount of insurance to cover such an event? In the case of a delay you would get a payout above the small amount you paid for it. It would make the whole commute process a little more pleasant. The only way to provide such a service, cutting through all the red tape and bureacracy of established insurance channels, is through a public blockchain with rich smart contract capabilities.

![alt text](https://i.imgur.com/OqqXrq3.png "LDelay Interface")

## Implementation Details
* Separation of concerns
* Oraclize
* Security
* Metamask
* React.js
* Docs for more info on attacks/security patterns

## User Story
A user knows he or she has to take the L train in 15 minutes to get to work - let's say it's 8:00 AM and they plan to arrive at the subway stop around 8:15 AM. They have a big meeting at work and can't be late! They go on LDelay to purchase a small amount of Ethereum based microinsurance (say a few dollars) to hedge against the train being delayed 15 minutes into the future (*right when they arrive at the station*). Using MetaMask they are able to send a transaction in to deposit a small premium and obtain coverage. Their deposit triggers a call to the data feed to obtain the status of the train in 15 minutes. The data feed comes directly from the MTA, the train service provider, and is as accurate as possible. After they purchase microinsurance they proceed to get ready and head to work. Fifteen minutes later there are two possible states of the world:
* A) The data feed reports that the train is in fact delayed at 8:15 AM. How unfortunate! The smart contract updates the user's final policy status to delayed, which enables the user to initiate a claim in the future. The contract knows the user's address and how much of a payout they are entitled to. The user ends up late to work but has a few more dollars worth of ETH to show for it.
* B) The train is on time. The smart contract updates the user's final policy status to normal, which does not allow the user to initiate a claim in the future. The user does not recieve a payout and their premium is left in the pool (to help insure the following users). Whatever small monetary loss they experience is offset by the knowledge they are on time to their meeting!

The end result in either case is the customer is given an opportunity to efficiently deploy their capital to fulfill their needs at that point in time. Only through a decentralized, autonomous system like an Ethereum could such an application exist. 

# Setup
LDelay can be run in two ways:
1. By running a preconfigured Ubuntu 16.04 Vagrant environment which comes complete with Truffle, ethereum-bridge, Node.js and LDelay (__works on any machine__). Only
Metamask will have to be installed manually. __*Not ready, please use the second method.*__
2. By downloading LDelay and locally running Truffle and ethereum-bridge on a *nix machine or VM.

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
and [VirtualBox](https://www.virtualbox.org/wiki/Downloads).
2. Start the VM and install node (v8.0+), npm, git, truffle and Metamask. I recommend provisioning 4GB RAM for the VM.
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


# Improvements
* Seperate payout/claims into separate contract
* Variable premiums/limits
* Deanonymization to prevent adverse selection
* Only allow deposits when train status is normal (requiring additional oracle queries)



