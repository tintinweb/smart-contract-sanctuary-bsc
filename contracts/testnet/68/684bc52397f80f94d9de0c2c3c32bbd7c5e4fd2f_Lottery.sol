/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

contract Lottery {

    address public owner;
    address payable public feeReceiver;
    address payable[] public players;
    int public counter = 0;
    
    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    //This function sets the Fee Receiver
    function setFeeReceiver(address payable _address) public virtual onlyOwner {
        feeReceiver = _address;
    }

    //This function displays balance of the contract
    function getBalance() public view returns (uint){
        return address(this).balance;
    }

    //This function gets players address list
    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    //This function makes you enter the lottery
    function enter() external payable{
        require(msg.value == 0.1 ether);
        //address of player entering lottery
        players.push(payable(msg.sender));
        //increased player count
         counter += 1;
         //if there are 10 participants, pick the winner and send balances.
        if(counter == 10){
            pickWinner();
        }
    }

    //This function generates a random number
    function getRandomNumber() public view returns (uint){
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }

    //This function Picks the winner
    function pickWinner() internal{
        uint index = getRandomNumber() % players.length;
        players[index].transfer(address(this).balance*80/100);
        feeReceiver.transfer(address(this).balance);

        //reset the state of the contract
        players = new address payable[](0);
        counter = 0;
    }
}