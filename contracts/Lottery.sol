//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Lottery is Ownable {

    address payable[] public players; // List of participants who are participating
    uint256 public entryFeeUsd;
    AggregatorV3Interface public ethUsdPriceFeed;
    enum LOTTERY_STATE { 
        OPEN, 
        CLOSED, 
        CALCULATING_WINNER
    }
    LOTTERY_STATE public lottery_state;

    constructor(address _priceFeedAddress) public{
        entryFeeUsd  = 50 * (10 ** 18);
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        lottery_state = LOTTERY_STATE.CLOSED;
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

    function endLottery() public onlyOwner{
        
    }
}