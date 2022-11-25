/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract NumberGuessingGame {
    uint8 private answer;
    address public winner;
    address public owner;
    uint public jackpot = address(this).balance;
    uint count = 0;
    bool isGameOn = true;
    //Upon initiation of the contract, owner of the contract has to put in 30 ether as jackpot
    constructor(uint8 number) payable {
        require(0 < number && number <= 10, "Number provided should be 1-10");
        require(msg.value == 3000 gwei, "3000 gwei initial funding required for reward");
        answer = number;
        owner = msg.sender;
    }

    //Player can participate by paying 1 ether and take a guess
    function guess(uint8 number) payable public{
        jackpot = address(this).balance;
        require(0 < number && number <= 10, "Number provided should be 1-10");
        require(isGameOn == true, "The game is over!");
        require(msg.value == 1 gwei, "You have to pay 1 gwei to play the game");
        require(msg.sender != owner, "you are the owner. You are not allowed to play!");
        count += 1;
        if (number == answer){
            winner = msg.sender;
            payable(winner).transfer(jackpot);
            isGameOn = false;
        }
        if (count == 5){
            payable(owner).transfer(jackpot);
            isGameOn = false;
        }
    }
}