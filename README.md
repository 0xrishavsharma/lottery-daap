# Smart Contract Lottery

### A decentralized lottery application that anyone can enter with a minimum entrance fee and a random person is selected who wins the lottery. It is like a traditional lottery but in decentralized way. So, there is no way anyone could get some advantage (You see the advantage of Decentralization?).

#### How this DApp works?
    1. Use enters the lottery with an entry price in Ethereum based on USD Fee.

    2. An admin will choose when the lottery should end.
        Although, the admin part makes the lottery a little more centralized. This problem can be solved in two ways:
            (i) By making a DAO, where the DAO members collectively votes on important decisions like this.
            (ii) Automatically open or close lottery based on some time parameters predefined in the smart contract before deployment. 

    3. Lottery chooses the winner randomly

#### For testing our contract and specific function 
    To use priceFeed contract in our development chain or on testnets we'll be using mocks or we'll fork the main Ethereum chain.
    - Mainnet-fork
    - 'Development' with mocks
    - 'Testnets'
    

#### Technologies used:
    1. Languages used: Solidity, Python and Yaml(for brownie config)
    2. Framework, Libraries and Oracles: Brownie, OpenZeppelin and ChainLink
    3. Blockchain used: Local Blockchain(Ganache) spined up by Brownie and Rinkeby Ethereum Testnet.
    4. RPC client: Infura
    5. Wallet used: Metamask