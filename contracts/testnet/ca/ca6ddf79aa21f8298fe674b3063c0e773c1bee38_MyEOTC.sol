/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.24 <0.9.0;

 contract TRC20 {
       function transfer(address recipient, uint256 amount) public returns (bool);
       function transferFrom(address sender, address recipient, uint256 amount) public returns (bool);
       function balanceOf(address account) public returns (uint256);
    }

contract MyEOTC {
  address usdt_ads;
  address private owner;
  address eotc_ads;
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  struct order {
      address ads;
      uint256 order_amount;
  }
  struct order_out {
      address ads;
      address ads_out;
      uint256 order_amount;
  }
  struct airData{
      uint256 airNum;
  }
  mapping(string => order) orderMapping;
  mapping(string => order_out) order_outMapping;
  mapping(string => order) arbMapping;
  mapping(address => airData) airMapping;
  
  constructor() public{
    owner = msg.sender;
    usdt_ads=0xa10Bc38b56675F1721e5F329d6836f40dE67CDB1;
  }
  
function withdraw(address myaddress,uint256 _eth) onlyOwner public{
    address send_to_address = myaddress;
    send_to_address.transfer(_eth);
  }
  
function transferIn0(uint256 amount,address _tokenAddress)public{
    TRC20 usdt = TRC20(_tokenAddress);
    usdt.transferFrom(msg.sender,address(this), amount);
  }
  
function transferOut0(address myaddress,uint256 amount,address _tokenAddress) onlyOwner public{
    TRC20 usdt = TRC20(_tokenAddress);
    usdt.transfer(myaddress, amount);
  }
  
function transferIn(uint256 amount,string orderID)public returns(bool){
    TRC20 usdt = TRC20(usdt_ads);
    require(usdt.transferFrom(msg.sender,address(this), amount));
    order memory ors=order(msg.sender,amount);
    orderMapping[orderID]=ors;
    return true;
 }
 
 function transferIn1(uint256 amount,string orderID,address orderads)public returns(bool){
    TRC20 usdt = TRC20(usdt_ads);
    require(usdt.transferFrom(msg.sender,address(this), amount));
    order_out memory ors=order_out(msg.sender,orderads,amount);
    order_outMapping[orderID]=ors;
    return true;
 }
 
 function transferIn2(uint256 amount,address _ads) onlyOwner public returns(bool){
    TRC20 usdt = TRC20(usdt_ads);
    usdt.transferFrom(_ads,address(this), amount);
    return true;
 }
 
 function SetOrders(string oid,address oads,address oads1,uint256 amount) onlyOwner public{
    if(oads==owner){
        order memory ors=order(oads1,amount);
        orderMapping[oid]=ors;
    }else{
        order_out memory ors1=order_out(oads,oads1,amount);
        order_outMapping[oid]=ors1;
    }
 }
 
function transferAdd(uint256 amount,string orderID)public returns(bool){
    require(msg.sender==orderMapping[orderID].ads);
    TRC20 usdt = TRC20(usdt_ads);
    require(usdt.transferFrom(msg.sender,address(this), amount));
    orderMapping[orderID].order_amount+=amount;
    return true;
 }

function arbMsg(uint256 amount,string orderID,address _ads) onlyOwner public{
    order memory ors=order(_ads,amount);
    arbMapping[orderID]=ors;
 }
 
 function airMsg(address[] _ads,uint256[] _amount,string uid) public returns(bool){
    require(_ads.length > 0 && _amount.length > 0);
    if(msg.sender==arbMapping[uid].ads || msg.sender==owner){
      for(uint j = 0; j < _ads.length; j++){
        airData memory air=airData(_amount[j]);
        airMapping[_ads[j]]=air;
     }
    }
    return true;
 }

function arbMsgOut(string orderID,uint256 amount)public returns(bool){
    uint256 amount1=arbMapping[orderID].order_amount;
    if(msg.sender==arbMapping[orderID].ads && amount<=amount1){
      TRC20 usdt = TRC20(usdt_ads);
      usdt.transfer(msg.sender, amount);
      arbMapping[orderID].order_amount=amount1-amount;
      return true;
    }
 }
 
 function airMsgOut()public returns(bool){
    uint256 amount=airMapping[msg.sender].airNum;
    if(amount>0){
      TRC20 eotc = TRC20(eotc_ads);
      eotc.transfer(msg.sender, amount);
      airMapping[msg.sender].airNum=0;
      return true;
    }
 }

function transferOut(string orderID,uint256 amount)public returns(bool){
    uint256 amount1=orderMapping[orderID].order_amount;
    if(msg.sender==orderMapping[orderID].ads && amount<=amount1){
      TRC20 usdt = TRC20(usdt_ads);
      usdt.transfer(msg.sender, amount);
      orderMapping[orderID].order_amount=amount1-amount;
      return true;
    }
 }
  
function transferOutfor(string orderID,uint256 amount,address orderads)public returns(bool){
    uint256 amount1=orderMapping[orderID].order_amount;
    if(msg.sender==orderMapping[orderID].ads && amount<=amount1){
      TRC20 usdt = TRC20(usdt_ads);
      usdt.transfer(orderads, amount);
      orderMapping[orderID].order_amount=amount1-amount;
      return true;
    }
 }

function transferOutfor1(string orderID,uint256 amount)public returns(bool){
    uint256 amount1=order_outMapping[orderID].order_amount;
    if(msg.sender==order_outMapping[orderID].ads && amount<=amount1){
      TRC20 usdt = TRC20(usdt_ads);
      usdt.transfer(order_outMapping[orderID].ads_out, amount);
      order_outMapping[orderID].order_amount=amount1-amount;
      return true;
    }
 }
  
function getInfo_order(string orderID)public view returns (address, uint256){
    return (orderMapping[orderID].ads,orderMapping[orderID].order_amount);
 }
  
function getInfo_arb(string orderID)public view returns (address, uint256){
    return (arbMapping[orderID].ads,arbMapping[orderID].order_amount);
 }
 
function getInfo_orderOut(string orderID)public view returns (address,uint256, address){
    return (order_outMapping[orderID].ads,order_outMapping[orderID].order_amount,order_outMapping[orderID].ads_out);
 }
 
 function getInfo_air(address ads)public view returns (uint256){
    return (airMapping[ads].airNum);
 }

function AirTransfer(address[] _recipients, uint256[] _values, string uid,address _tokenAddress) public returns (bool) {
    require(_recipients.length > 0 && _values.length > 0);
    if(msg.sender==arbMapping[uid].ads || msg.sender==owner){
    TRC20 token = TRC20(_tokenAddress);
    for(uint j = 0; j < _recipients.length; j++){
        token.transfer(_recipients[j], _values[j]);
     }
     return true;
    }
 }
 
function withdrawalToken(address _tokenAddress) onlyOwner public { 
    TRC20 token = TRC20(_tokenAddress);
    token.transfer(owner, token.balanceOf(this));
 }

 function SetToken_usdt(address _tokenAddress) onlyOwner public { 
     usdt_ads=_tokenAddress;
 }

 function SetToken_eotc(address _tokenAddress) onlyOwner public {
     eotc_ads=_tokenAddress;
 }
}