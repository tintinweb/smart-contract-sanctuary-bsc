/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

pragma solidity >=0.8.0;
  contract PVPBotMc{

event matchEnded(address winner, address loser, uint256 winnings);

mapping(address => uint256) bets;

    address payable owner;
    modifier onlyOwner {
      require(msg.sender == owner);
      _;
   }

    constructor(address payable _owner) public payable{
      owner=_owner;

    }
      function retriveFunds() onlyOwner public{
        owner.send(address(this).balance);
      }

     function loseTo( address payable winner) payable public{
        if(!(msg.value >= 14000000 gwei)||winner==msg.sender) return;
         address payable _winner = payable(winner);
         _winner.send(msg.value-999999 gwei+bets[msg.sender] +bets[winner]);
         emit matchEnded(winner, msg.sender, msg.value);

 }
 function bounty(address prospect) payable public{
   require( msg.sender!=prospect);
    uint256 currentBet = bets[prospect];
    bets[prospect] = currentBet+uint256(msg.value);
 }
 }