from brownie import accounts, network, config, MockV3Aggregator,VRFCoordinatorV2Mock, LinkToken, Contract;

FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork", "mainnet-fork-dev"];
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"];

def get_account(index=None, id=None):
    # We have seen two ways of using accounts
    # 1. accounts[0]
    # 2. accounts.add("env")
    # But learned another way of using account that isn't defined here
    # 3. accounts.load("id")
    if index:
        return accounts[index]
    if id:
        return accounts.load(id)
    if (
        network.show_active() in "LOCAL_BLOCKCHAIN_ENVIRONMENTS"
        or network.show_active() in "FORKED_LOCAL_ENVIRONMENTS"
        ):
            return accounts[0]
    return accounts.add(config["wallets"]["from_key"])


contract_to_mock = {
    "eth_usd_price_feed": MockV3Aggregator,
    "vrf_coordinator": VRFCoordinatorV2Mock,
    "link_token": LinkToken,
    }

def get_contract(contract_name):
    """ This function will grab the contract addresses of vrfcoordinator and price feed from brownie config
        if defined, otherwise it will deploy the mock version of that contract and return that contract back.

        Args: For argument of this function we'll take contract_name which is a string
        returns: It will return a contract which is brownie.network.contract.ProjectContract which will be the most recently
                 deployed contract. For example: MockV3Aggregator[-1] """
    
    # contract_type = contract_to_mock[contract_name]
    # if network.show_active() == LOCAL_BLOCKCHAIN_ENVIRONMENTS:
    #     if len(contract_type) <= 0:
    #         deploy_mocks()
    #     # Now after deploying, we want to get that mock
    #     contract = contract_type[-1]
    #     # MockV3Aggregator[-1]
    # else:
    #     contract_address = config["networks"][network.show_active()][contract_name]
    #     # To interact with the aggregator THAT IS ON A ACTUAL CHAIN we'll need the address and abi.
    #     # We got the address in the above line of code
    #     contract = Contract.from_abi(contract_type._name, contract_address, contract_type.abi)
    # return contract

    contract_type = contract_to_mock[contract_name]
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        if len(contract_type) <= 0:
            # MockV3Aggregator.length
            deploy_mocks()
        contract = contract_type[-1]
        # MockV3Aggregator[-1]
    else:
        contract_address = config["networks"][network.show_active()][contract_name]
        # address
        # ABI
        contract = Contract.from_abi(
            contract_type._name, contract_address, contract_type.abi
        )
        # MockV3Aggregator.abi
    return contract
        

DECIMALS=8
INITIAL_VALUE=200000000000

def deploy_mocks(decimals=DECIMALS, initial_value=INITIAL_VALUE):
    account = get_account()
    print("Deploying mocks...")
    mock_price_feed = MockV3Aggregator.deploy(decimals, initial_value, {'from': account})
    link_token = LinkToken.deploy({"from": account})
    VRFCoordinatorV2Mock.deploy(initial_value, 2000000, {"from": account})
    print("Hurray, mocks deployed!")
