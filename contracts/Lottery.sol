//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink-brownie-contracts/contracts/src/v0.8/VRFConsumerBase.sol";

contract Lottery is Ownable, VRFConsumerBase {

    address payable[] public players; // List of participants who are participating
    uint256 public entryFeeUsd;
    AggregatorV3Interface public ethUsdPriceFeed;
    enum LOTTERY_STATE { 
        OPEN, 
        CLOSED, 
        CALCULATING_WINNER
    }
    LOTTERY_STATE public lottery_state;
    uint public fee = 0.1 * 10 ** 18;
    
    // We are changing the fee because while interacting with different networks the fee might be different so we'll updated that
    // while deploying the contract
    constructor(address _priceFeedAddress, address _vrfCoordinator, address _link, uint256 _fee, string memory _keyhash)
     public
     VRFConsumerBase(_vrfCoordinator, _link)
     {
        entryFeeUsd  = 50 * (10 ** 18);
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        lottery_state = LOTTERY_STATE.CLOSED;
        fee=_fee;
    }

    function enter() public payable{
        require(lottery_state == LOTTERY_STATE.OPEN);
        require(msg.value >= getEntranceFee(), "Not enough ETH");
        players.push(payable(msg.sender));
    }

    function getEntranceFee() public view returns( uint256 ) {
        (,int price, , , ) = ethUsdPriceFeed.latestRoundData();
        uint256 adjustedUintPrice = uint256(price) * (10 **10); //Here we use 10**10 as the priceFeed already comes with 8 decimal points.
        // $50, $2,828/eth
        // To convert $50 to Eth, $50/$2,828
        // 50 * someBigNumber/2828 to avoid decimals and at some point we'll divide it by someBigNumber to get our actual value
        uint256 priceToEnter = (entryFeeUsd * (10 ** 18))/ adjustedUintPrice;
        return priceToEnter;
    }

    function startLottery() public onlyOwner{
        require(lottery_state == LOTTERY_STATE.CLOSED, "Lottery is already running. Can't start a new lottery.");
        lottery_state = LOTTERY_STATE.OPEN;
    }

    // Predictable way of choosing a (not so)random number and it is giving MINERS the ability to win the lottery
    // function endLottery() public onlyOwner{
    //     uint256 ( 
    //        keccak256(
    //             abi.encodePacked(
    //                 nonce, // Is predictable(aka transaction number in this case)
    //                 msg.sender, // msg.sender is predictable
    //                 block.difficulty, // Can be manupulated by the miners
    //                 block.timestamp // timestamp is predictable
    //             )
    //         )
    //     ) % players.length;
    // }

    // Keyhash uniquely identifies the Chainlink node we are going to use to get our random number
    function endLottery(string memory keyhash) public onlyOwner{
        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
        requestId = requestRandomness(keyhash, fee);
    }
}