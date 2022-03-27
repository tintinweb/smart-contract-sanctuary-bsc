/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

contract Lottery{
    address public owner;
    address payable[] public players;

    constructor() {
        owner = msg.sender;
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }


    function enter() public payable{
        // Követelmény, beküldött pénz és mennyiség
        require(msg.value > 1 / uint256(200) );
        // Játékosok akik részt vesznek a sorsoláson
        players.push(payable(msg.sender));
    }
    function getRandomNumber() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }
    function pickWinner() public onlyOwner {
        
        uint index =  getRandomNumber() % players.length;
        players[index].transfer(address(this).balance);

        //Visszaállítás 
        players = new address payable[](0);
    }
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
}