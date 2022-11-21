/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

pragma solidity ^0.4.18;

contract GuessTheNum{

    // simple game guess the number system smart contract generate 0-10
    // bet and win 
    uint number;

    // event ==> stores the arguments passed in the transaction logs when emitted
    event playerWon(address player, uint randomNumber);
    event playerLost(address player, uint randomNumber);

    // public ==> can call outside
    // payble ==> allow to send and recived ether
    function playGame(uint playerGuessNum) public payable returns(uint){

        // generate a random number upto 10
        uint randomNumber = uint(keccak256(block.blockhash(block.number), number)) % 10;
        number++;
        
        if(randomNumber == playerGuessNum) {
            playerWon(msg.sender, randomNumber); // msg.sender ==> sending the to event 
        } else {
            playerLost(msg.sender, randomNumber);
        }


    }
}