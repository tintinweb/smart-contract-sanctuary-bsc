/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

//SPDX-License-Identifier:GPL-3.0
pragma solidity ^0.8.0;
contract SpeqtoFungibleToken{
    string public constant TokenName="SPEQTO";
    string public constant TokenSymbol="SPQ";
    uint public totalSupply;
    uint public constant tokenPrice= 100;
    uint public soldTokens;
    uint public weiRaised;
    address Owner;
    mapping(address=>uint) balances;
modifier mOwnerOnly{
     require(msg.sender==Owner,"You are not the owner");
     _;
}
event ebuyToken(address buyer, uint numTokens);
event eTransferOwnerShip(address from, address to);
constructor(uint _totalSupply){
    totalSupply=_totalSupply;
    Owner=msg.sender;
    balances[Owner]=totalSupply;
}
function buyToken() public payable returns(bool) {
      require(msg.value!=0);
      uint numTokens = msg.value*100;
      require(numTokens<=balances[Owner], "Owner does not have suffiecient tokens to sale");
      balances[msg.sender]+=numTokens;
      soldTokens+=numTokens;
      balances[Owner]-=numTokens;
      weiRaised+=msg.value;
      emit ebuyToken(msg.sender,numTokens);
      return true;
     }
function balanceOf(address holder) public view returns(uint){
          return balances[holder];
}
function withdraw() public mOwnerOnly {
    payable(Owner).transfer(weiRaised);
    weiRaised=0;
}
function BuyBack(uint _numTokens) public payable{
    require(_numTokens<=balances[msg.sender],"You are sending back more tokens than you have");
    balances[Owner]+=_numTokens;
    balances[msg.sender]-=_numTokens;
    uint amount = _numTokens/tokenPrice;
    require(amount<=weiRaised,"Contract does not have enough fund to transfer");
    payable(msg.sender).transfer(amount);
    weiRaised-=amount;
}
}