from brownie import SmartLottery, network, config
from scripts.helpful_scripts import get_account, get_contract

def deploy_smart_lottery():
    account = get_account()
    smart_lottery = SmartLottery
    smart_lottery.deploy(
        get_contract("eth_usd_price_feed").address,
        get_contract("vrf_coordinator").address,
        get_contract("link_token").address,
        config["networks"][network.show_active()]["fee"],
        config["networks"][network.show_active()]["keyhash"],
        {"from": account},
        # publish_source=config["networks"][network.show_active()].get{"verify", False},
        publish_source=config["networks"][network.show_active()].get("verify", False),
    )
    print("Deployed Smart Lottery!")




def main():
    deploy_smart_lottery()