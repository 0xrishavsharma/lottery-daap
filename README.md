# Smart Lottery

A decentralized lottery application that anyone can enter with a minimum entrance fee and a truly provable random person is selected with the help of Chainlink VRF, who wins the lottery. It's like a traditional lottery but in a decentralized way. So, there is no way anyone could get some advantage (You see the advantage of Decentralization?).

#### Why Chainlink VRF? 

If we use an easy way to get a random number i.e using block variables like block.timestamp, nonce, block.difficulty, msg.sender, etc.

We know that some of those variables can be manipulated by miners. Giving them the advantage and we don't want that to happen. That's why Chainlink VRF.


#### How this DApp works?
    1. Use enters the lottery with an entry price in Ethereum based on USD Fee.

    2. An admin will choose when the lottery should end.
        Although, the admin part makes the lottery a little more centralized. This problem can be solved in two ways:
            (i) By making a DAO, where the DAO members collectively votes on important decisions like this.
            (ii) Automatically open or close lottery based on some time parameters predefined in the smart contract before deployment. 

    3. Lottery chooses the winner randomly with the help of Chainlink VRF(request and receive model)

#### For testing our contract and specific function 
    To use priceFeed contract in our development chain or on testnets we'll be using mocks or we'll fork the main Ethereum chain.
    - Mainnet-fork
    - 'Development' with mocks
    - 'Testnets'
    

#### Technologies used:
    1. Languages used: Solidity, Python and Yaml(for brownie config)
    2. Framework, Libraries and Oracles: Brownie, OpenZeppelin and ChainLink VRF
    3. Blockchain used: Local Blockchain(Ganache) spined up by Brownie and Rinkeby Ethereum Testnet.
    4. RPC client: Infura
    5. Wallet used: Metamask