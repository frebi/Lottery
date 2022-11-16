// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

error Raffle__NotEnoughEthEntered();
error Raffle__TransferFailed();

contract Raffle is VRFConsumerBaseV2{

    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint32 private constant NUM_WORDS = 1;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;

    address private s_recentWinner;

    event RaffleEntered(address indexed player);
    event RequestedRaffleWinner(uint256 indexRequestId);
    event WinnerPicked(address indexed winner);

    //vrfCoordinatorV2 variable will be passed into VRFConsumerBaseV2 constructor
    constructor(address vrfCoordinatorV2, uint256 entranceFee, bytes32 gasLane, uint64 subscriptionId, uint32 callbackGasLimit) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_entranceFee = entranceFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    function enterRaffle() public payable{
        //require (msg.value > i_entranceFee, "Not enough ETH!")
        if(msg.value < i_entranceFee){
            revert Raffle__NotEnoughEthEntered();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }



    //---- request a random number using Chainlink VRF ----

    function requestRandomWinner() external {
        //1.Request the random number
        //2.Once we get it, do something with it
        // See variables detailes here https://docs.chain.link/docs/vrf/v2/subscription/examples/get-a-random-number/
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane, // keyHash
            i_subscriptionId, // subscription Id that you get once you create the subscription (https://chain.link/vrf)
            REQUEST_CONFIRMATIONS, //how many blocks we wanna wait
            i_callbackGasLimit,
            NUM_WORDS
        );
        emit RequestedRaffleWinner(requestId);
    }

    function fulfillRandomWords(uint256 /*requestId*/, uint256[] memory randomWords) internal override{
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        //require(success)
        if(!success){
            revert Raffle__TransferFailed();
        }
        emit WinnerPicked(recentWinner);
    }
    //----------------------------------------------




    function getEntranceFee() public view returns(uint256){
        return i_entranceFee;
    }

    function getPlayer(uint256 index) public view returns(address){
        return s_players[index];
    }

    function getRecentWinner() public view returns(address){
        return s_recentWinner;
    }
}