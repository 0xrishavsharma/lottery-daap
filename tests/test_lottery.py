# We should be getting approximately 50/2828 = 0.017 0r 17000000000000000

from brownie import Lottery, accounts, config, network ;
from web3 import Web3;

def test_get_price_function():
    account = accounts[0];
    lottery = Lottery.deploy( config["networks"][network.show_active()]["eth_usd_price_feed"], {"from": account} );
    assert lottery.getEntranceFee() > Web3.toWei(0.016 , "ether");
    assert lottery.getEntranceFee() < Web3.toWei(0.018 , "ether");