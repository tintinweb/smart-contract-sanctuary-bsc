/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

pragma solidity ^0.4.17;
 
 //Contract creation file
 
 contract Lottery{
     
     address public manager;
     address[] public players;
     
     constructor() public{
         manager = msg.sender;
     }
     
     function enter() public payable{
         
         require(msg.value > 0.1 ether);
         players.push(msg.sender);
     }
     
     function random() private view returns(uint){
         return uint(keccak256(abi.encodePacked(block.difficulty, now, players)));
     }
     
     function pickWinner() public restricted{
         
         uint index = random() % players.length;
         players[index].transfer(this.balance);
         players = new address[](0);
     }
     
     modifier restricted(){
         require(msg.sender == manager);
         _;
     }
     
     function getPlayers() public view returns(address[]){
         return players;
     } 
 }