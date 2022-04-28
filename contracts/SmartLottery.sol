//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink-brownie-contracts/contracts/src/v0.8/VRFConsumerBase.sol";

contract SmartLottery is Ownable, VRFConsumerBase {

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
    bytes32 public keyhash;
    address payable public recentWinner;
    uint public recentRandomness;
    
    // We are changing the fee because while interacting with different networks the fee might be different so we'll updated that
    // while deploying the contract
    constructor(address _priceFeedAddress, address _vrfCoordinator, address _link, uint256 _fee, bytes32 _keyhash)
     public
     VRFConsumerBase(_vrfCoordinator, _link)
     {
        entryFeeUsd  = 50 * (10 ** 18);
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        lottery_state = LOTTERY_STATE.CLOSED;
        fee = _fee;
        keyhash = _keyhash;
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


    // While requesting a random number from the VRF we create two transactions. First we request and second we recieve.
    // Keyhash uniquely identifies the Chainlink VRF node we are going to use to get our random number
    function endLottery(bytes32 keyhash) public onlyOwner{
        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
        bytes32 requestId = requestRandomness(keyhash, fee);
    }

    function fulfillRandomness( bytes32 _requestId, uint256 _randomness)
    internal override
    {
        require(lottery_state == LOTTERY_STATE.CALCULATING_WINNER, "You aren't there yet!");
        require(_randomness > 0, "Error: random-not-found. The number is not random");
        uint256 indexOfWinner = (_randomness % players.length);
        recentWinner = players[indexOfWinner];
        // Transferring all the money that this contract has collected to the lottery winner
        recentWinner.transfer(address(this).balance);

        // Resetting the lottery 
        players = new address payable[](0);
        lottery_state = LOTTERY_STATE.CLOSED;
        recentRandomness = _randomness;
    } 
}