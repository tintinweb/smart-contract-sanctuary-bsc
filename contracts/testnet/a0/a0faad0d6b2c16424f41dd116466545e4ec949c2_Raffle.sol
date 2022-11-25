/**
 *Submitted for verification at BscScan.com on 2022-11-24
*/

pragma solidity ^0.4.17;
    
  contract Raffle {
      address public organizer;
      address[] public players;
        
      function Raffle() public{
          organizer = msg.sender;
      }
       
      function enter() public payable{
          require(msg.value > .001 ether);
          players.push(msg.sender);
      }
       
      function random() private view returns(uint){
        return uint(keccak256(block.difficulty, now, players));
      }
       
      function pickWinner() public{
          uint index = random() % players.length;
          players[index].transfer(this.balance);
      }
  }