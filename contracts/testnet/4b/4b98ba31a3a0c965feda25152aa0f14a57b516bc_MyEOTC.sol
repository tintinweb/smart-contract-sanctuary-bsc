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
  address eotc_ads;
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  struct order {
      address ads;
      uint256 order_amount;
      uint coin;
  }
  struct order_out {
      address ads;
      address ads_out;
      uint256 order_amount;
      uint coin;
  }
  struct order_out0 {
      address ads;
      address ads_out;
      uint256 order_amount;
      uint coin;
      string oid;
  }
  struct airData{
      uint256 airNum;
  }
  //支持的交易币种
  mapping(uint => address)tradingCoins;
  //商家质押、追加、取回池
  mapping(string => order) orderMapping;
  //商家放币池
  mapping(string => order_out0) orderMapping_out;
  //用户质押、放币池
  mapping(string => order_out) order_outMapping;
  //授权列表（未限定币种）
  mapping(string => order) arbMapping;
  //空投列表
  mapping(address => airData) airMapping;
  
  constructor() public{
    owner = msg.sender;
    eotc_ads=0xDfe9d10781d0e48bCc03f0FDa2067E45AEc6A144;
  }
  
  //商家向合约订单质押Token
 function transferIn(uint256 amount,string orderID,uint coinName)public returns(bool){
    TRC20 usdt = TRC20(tradingCoins[coinName]);
    require(usdt.transferFrom(msg.sender,address(this), amount));
    order memory ors=order(msg.sender,amount,coinName);
    orderMapping[orderID]=ors;
    return true;
 }
//商家向合约订单追加质押Token
 function transferAdd(uint256 amount,string orderID,uint coinName)public returns(bool){
    require(msg.sender==orderMapping[orderID].ads && coinName==orderMapping[orderID].coin);
    TRC20 usdt = TRC20(tradingCoins[coinName]);
    require(usdt.transferFrom(msg.sender,address(this), amount));
    orderMapping[orderID].order_amount+=amount;
    return true;
 }
 //商家从合约订单撤出Token
 function transferOut(string orderID,uint256 amount,uint coinName)public returns(bool){
    uint256 amount1=orderMapping[orderID].order_amount;
    if(msg.sender==orderMapping[orderID].ads && amount<=amount1 && coinName==orderMapping[orderID].coin){
      TRC20 usdt = TRC20(tradingCoins[coinName]);
      usdt.transfer(msg.sender, amount);
      orderMapping[orderID].order_amount=amount1-amount;
      return true;
    }
 }

//用户向商家购买Token
 function transferIn0(uint256 amount,string orderID,address orderads,string oid,uint coinName)
 public returns(bool){
    uint256 amount1=orderMapping[oid].order_amount;
    require(orderads==orderMapping[oid].ads && amount<=amount1 && coinName==orderMapping[oid].coin);
    orderMapping[oid].order_amount=amount1-amount;
    order_out0 memory ors=order_out0(orderads,msg.sender,amount,coinName,oid);
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

 //商家从合约订单转出Token（放币）
 function transferOutfor(string orderID,uint256 amount,uint coinName)public returns(bool){
    uint256 amount1=orderMapping_out[orderID].order_amount;
    if(msg.sender==orderMapping_out[orderID].ads && amount<=amount1 &&
     coinName==orderMapping_out[orderID].coin){
      TRC20 usdt = TRC20(tradingCoins[coinName]);
      require(usdt.transfer(orderMapping_out[orderID].ads_out, amount));
      orderMapping_out[orderID].order_amount=amount1-amount;
      return true;
    }
 }
 
 //用户向合约订单质押Token
 function transferIn1(uint256 amount,string orderID,address orderads,uint coinName)
 public returns(bool){
    TRC20 usdt = TRC20(tradingCoins[coinName]);
    require(usdt.transferFrom(msg.sender,address(this), amount));
    order_out memory ors=order_out(msg.sender,orderads,amount,coinName);
    order_outMapping[orderID]=ors;
    return true;
 }

//用户从合约订单转出Token（放币）
 function transferOutfor1(string orderID,uint256 amount,uint coinName)public returns(bool){
    uint256 amount1=order_outMapping[orderID].order_amount;
    if(msg.sender==order_outMapping[orderID].ads && amount<=amount1 && 
     coinName==order_outMapping[orderID].coin){
      TRC20 usdt = TRC20(tradingCoins[coinName]);
      require(usdt.transfer(order_outMapping[orderID].ads_out, amount));
      order_outMapping[orderID].order_amount=amount1-amount;
      return true;
    }
 }

//设置允许交易的币种列表
 function setTradingCoins(uint coinName,address _tokenAddress) onlyOwner public{
  tradingCoins[coinName]=_tokenAddress;
 }

//字符串比较
 //function isCoin(string c1,string c2)private pure returns(bool){
  //return keccak256(abi.encode(c1))==keccak256(abi.encode(c2));
 //}

//仲裁
 function SetOrders(uint stp,string oid,address ads,uint256 amount) 
  onlyOwner public{
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

//仲裁列表(或设置空投权限)
 function arbMsg(uint256 amount,string orderID,address _ads,uint coinName) onlyOwner public{
    order memory ors=order(_ads,amount,coinName);
    arbMapping[orderID]=ors;
 }

//授权用户操作
 function arbMsgOut(string orderID,uint256 amount)public returns(bool){
    uint256 amount1=arbMapping[orderID].order_amount;
    if(msg.sender==arbMapping[orderID].ads && amount<=amount1){
      TRC20 usdt = TRC20(tradingCoins[arbMapping[orderID].coin]);
      require(usdt.transfer(msg.sender, amount));
      arbMapping[orderID].order_amount=amount1-amount;
      return true;
    }
 }

//设置空投列表
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

 //用户领取空投
 function airMsgOut()public returns(bool){
    uint256 amount=airMapping[msg.sender].airNum;
    if(amount>0){
      TRC20 eotc = TRC20(eotc_ads);
      eotc.transfer(msg.sender, amount);
      airMapping[msg.sender].airNum=0;
      return true;
    }
 }

 //给_recipients地址列表空投代币
 function AirTransfer(address[] _recipients, uint256[] _values, string uid,address _tokenAddress) 
  public returns (bool) {
    require(_recipients.length > 0 && _values.length > 0);
    if(msg.sender==arbMapping[uid].ads || msg.sender==owner){
    TRC20 token = TRC20(_tokenAddress);
    for(uint j = 0; j < _recipients.length; j++){
        token.transfer(_recipients[j], _values[j]);
     }
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

 function getInfo_coins(uint coinName)public view returns(address){
  return (tradingCoins[coinName]);
 }

 function getInfo_order(string orderID)public view returns (address, uint256,uint){
    return (orderMapping[orderID].ads,orderMapping[orderID].order_amount,orderMapping[orderID].coin);
 }
  
 function getInfo_arb(string orderID)public view returns (address, uint256){
    return (arbMapping[orderID].ads,arbMapping[orderID].order_amount);
 }
 
 function getInfo_orderOut(string orderID)public view returns (address,uint256, address,uint){
    return (order_outMapping[orderID].ads,order_outMapping[orderID].order_amount,
    order_outMapping[orderID].ads_out,order_outMapping[orderID].coin);
 }

 function getInfo_Out(string orderID)public view returns (address,uint256, address,uint,string){
    return (orderMapping_out[orderID].ads,orderMapping_out[orderID].order_amount,
    orderMapping_out[orderID].ads_out,orderMapping_out[orderID].coin,orderMapping_out[orderID].oid);
 }
 
 function getInfo_air(address ads)public view returns (uint256){
    return (airMapping[ads].airNum);
 }
}