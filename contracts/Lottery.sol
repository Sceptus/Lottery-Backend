// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "hardhat/console.sol";

contract Lottery is VRFConsumerBaseV2 {
    address public owner;

    uint64 private immutable subscriptionId;
    address private constant vrfCoordinator =
        0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    bytes32 private constant keyHash =
        0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    uint32 private constant callbackGasLimit = 200000;
    uint16 private constant minimumRequestConfirmations = 3;
    uint32 private constant numWords = 1;

    uint public randomNumber;
    address[] public entrants;
    address public latestWinner;

    mapping(address => uint) public ticketsOwned;

    VRFCoordinatorV2Interface private immutable coordinator;

    modifier onlyOwner() {
        require(msg.sender == owner, "Sender is not owner");
        _;
    }

    constructor(uint64 subId) VRFConsumerBaseV2(vrfCoordinator) {
        coordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        subscriptionId = subId;
        owner = msg.sender;
    }

    function buyTicket() public payable {
        uint numTickets = msg.value / (2 * (10 ** 16));

        ticketsOwned[msg.sender] += numTickets;

        for (uint i = 0; i < numTickets; i++) {
            entrants.push(msg.sender);
        }
    }

    function endLottery() public onlyOwner {
        coordinator.requestRandomWords(
            keyHash,
            subscriptionId,
            minimumRequestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(
        uint256,
        uint256[] memory randomWords
    ) internal override {
        randomNumber = randomWords[0] % entrants.length;

        latestWinner = entrants[randomNumber];
        payable(latestWinner).transfer(address(this).balance);

        for (uint i = 0; i < entrants.length; i++) {
            delete ticketsOwned[entrants[i]];
        }

        delete entrants;
    }

    function withdrawEth() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function getTicketsOwned(address account) public view returns (uint) {
        return ticketsOwned[account];
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
