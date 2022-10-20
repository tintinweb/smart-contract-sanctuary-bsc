/**
 *Submitted for verification at BscScan.com on 2022-10-19
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.24 <0.9.0;

contract TRC20 {
       function transfer(address recipient, uint256 amount) public returns (bool);
       function transferFrom(address sender, address recipient, uint256 amount) public returns (bool);
       function balanceOf(address account) public returns (uint256);
    }

contract MyEOTC {
  address owner;
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
  struct order_out0 {
      address ads;
      address ads_out;
      uint256 order_amount;
      string oid;
  }
  //商家质押、追加、取回池
  mapping(string => order) orderMapping;
  //商家放币池
  mapping(string => order_out0) orderMapping_out;
  //用户质押、放币池
  mapping(string => order_out) order_outMapping;
  //授权列表（未限定币种）
  mapping(string => order) arbMapping;
  
  constructor() public{
    owner = msg.sender;
  }
  
  //商家向合约订单质押ETH
 function transferIn(string orderID)public payable returns(bool){
    require(msg.value > 0);
    order memory ors=order(msg.sender,msg.value);
    orderMapping[orderID]=ors;
    return true;
 }
//商家向合约订单追加质押ETH
 function transferAdd(string orderID)public payable returns(bool){
    require(msg.value > 0);
    require(msg.sender==orderMapping[orderID].ads);
    orderMapping[orderID].order_amount+=msg.value;
    return true;
 }
 //商家从合约订单撤出ETH
 function transferOut(string orderID,uint256 amount)public returns(bool){
    uint256 amount1=orderMapping[orderID].order_amount;
    if(msg.sender==orderMapping[orderID].ads && amount<=amount1){
      msg.sender.transfer(amount);
      orderMapping[orderID].order_amount=amount1-amount;
      return true;
    }
 }

//用户向商家购买ETH
 function transferIn0(uint256 amount,string orderID,address orderads,string oid)
 public returns(bool){
    uint256 amount1=orderMapping[oid].order_amount;
    require(orderads==orderMapping[oid].ads && amount<=amount1);
    orderMapping[oid].order_amount=amount1-amount;
    order_out0 memory ors=order_out0(orderads,msg.sender,amount,oid);
    orderMapping_out[orderID]=ors;
    return true;
 }

 //用户向商家取消购买订单
 function transferIn01(string orderID) public returns(bool){
    uint256 amount1=orderMapping_out[orderID].order_amount;
    require(amount1>0 && (msg.sender==orderMapping_out[orderID].ads_out || msg.sender==owner));
     orderMapping_out[orderID].order_amount=0;
    string storage oid=orderMapping_out[orderID].oid;   
    orderMapping[oid].order_amount+=amount1;
    return true;
 }

 //商家从合约订单转出ETH（放币）
 function transferOutfor(string orderID,uint256 amount)public returns(bool){
    uint256 amount1=orderMapping_out[orderID].order_amount;
    if(msg.sender==orderMapping_out[orderID].ads && amount<=amount1){
      orderMapping_out[orderID].ads_out.transfer(amount);
      orderMapping_out[orderID].order_amount=amount1-amount;
      return true;
    }
 }
 
 //用户向合约订单质押ETH
 function transferIn1(string orderID,address orderads) public payable returns(bool){
    require(msg.value > 0);
    order_out memory ors=order_out(msg.sender,orderads,msg.value);
    order_outMapping[orderID]=ors;
    return true;
 }

//用户从合约订单转出ETH（放币）
 function transferOutfor1(string orderID,uint256 amount)public returns(bool){
    uint256 amount1=order_outMapping[orderID].order_amount;
    if(msg.sender==order_outMapping[orderID].ads && amount<=amount1){
      order_outMapping[orderID].ads_out.transfer(amount);
      order_outMapping[orderID].order_amount=amount1-amount;
      return true;
    }
 }

//仲裁
 function SetOrders(uint stp,string oid,address ads,uint256 amount) onlyOwner public{
    if(stp==1){
      orderMapping[oid].order_amount=amount;
    }else if(stp==2){
      order_outMapping[oid].ads_out=ads;
      order_outMapping[oid].order_amount=amount;
    }
    else{
      orderMapping_out[oid].ads_out=ads;
      orderMapping_out[oid].order_amount=amount;
    }
 }

//仲裁列表
 function arbMsg(uint256 amount,string orderID,address _ads) onlyOwner public{
    order memory ors=order(_ads,amount);
    arbMapping[orderID]=ors;
 }

//授权用户操作
 function arbMsgOut(string orderID,uint256 amount)public returns(bool){
    uint256 amount1=arbMapping[orderID].order_amount;
    if(msg.sender==arbMapping[orderID].ads && amount<=amount1){
      msg.sender.transfer(amount);
      arbMapping[orderID].order_amount=amount1-amount;
      return true;
    }
 }

 function transferCoin(uint256 amount,address _tokenAddress)public{
    TRC20 usdt = TRC20(_tokenAddress);
    usdt.transferFrom(msg.sender,address(this), amount);
  }

  function transferToken(address ads,uint256 amount,address _tokenAddress) onlyOwner public{
    TRC20 usdt = TRC20(_tokenAddress);
    usdt.transfer(ads, amount);
  }

 function withdrawCoin(address _tokenAddress,uint256 _num) onlyOwner public { 
    _tokenAddress.transfer(_num);
 }

 function withdrawToken(address _tokenAddress) onlyOwner public { 
    TRC20 token = TRC20(_tokenAddress);
    token.transfer(owner, token.balanceOf(this));
 }

 function getInfo_order(string orderID)public view returns (address, uint256){
    return (orderMapping[orderID].ads,orderMapping[orderID].order_amount);
 }
  
 function getInfo_arb(string orderID)public view returns (address, uint256){
    return (arbMapping[orderID].ads,arbMapping[orderID].order_amount);
 }
 
 function getInfo_orderOut(string orderID)public view returns (address,uint256, address){
    return (order_outMapping[orderID].ads,order_outMapping[orderID].order_amount,
    order_outMapping[orderID].ads_out);
 }

 function getInfo_Out(string orderID)public view returns (address,uint256, address,string){
    return (orderMapping_out[orderID].ads,orderMapping_out[orderID].order_amount,
    orderMapping_out[orderID].ads_out,orderMapping_out[orderID].oid);
 } 
}