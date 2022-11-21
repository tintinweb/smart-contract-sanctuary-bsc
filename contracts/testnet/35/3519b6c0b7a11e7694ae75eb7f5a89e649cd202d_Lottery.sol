/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.15;

contract Lottery{
    //State /Storage Variable
    address public owner;
    address payable[] public players;
    address[] public winners;
    uint public lotteryId;

    //Constructor runs when the cintract is deployed
    constructor(){
        owner= msg.sender;
        lotteryId = 0;
    }

    //Enter Function to enter in lottery
    function enter()public payable{
        require(msg.value >= 0.1 ether);
        players.push(payable(msg.sender));
    }

    //Get Players
    function  getPlayers() public view returns(address payable[] memory){
        return players;
    }

    //Get Balance 
    function getbalance() public view returns(uint){
        return address(this).balance;
    }
     
    //Get Lottery Id
    function getLotteryId() public view returns(uint){
        return lotteryId;
    }
    
    //Get a random number (helper function for picking winner)
    function getRandomNumber() public view returns(uint){
        return uint(keccak256(abi.encodePacked(owner,block.timestamp)));
    }

    //Pick Winner
    function pickWinner() public onlyOwner{
        uint randomIndex =getRandomNumber()%players.length;
        players[randomIndex].transfer(address(this).balance);
        winners.push(players[randomIndex]);
        //Current lottery done
        lotteryId++;
        //Clear the player array
        players =new address payable[](0);
    }
  
    function getWinners() public view returns(address[] memory){
        return winners;
    }

    modifier onlyOwner(){
        require(msg.sender == owner,"Only owner have control");
        _;
    }

}