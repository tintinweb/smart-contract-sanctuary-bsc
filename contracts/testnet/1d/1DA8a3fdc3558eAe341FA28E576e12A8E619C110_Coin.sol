/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

//下面一行注释是许可证，有用，没仔细研究，随便找了一个
// SPDX-License-Identifier: MIT

// pragma solidity >=0.5.0;
// pragma experimental ABIEncoderV2;
pragma solidity ^0.8.0;

contract Coin {
  address public minter;//管理员地址
  address payable public owner;

  //struct首字母必须大写 function首字母必须小写
  struct HeroInfo {
      uint level;//英雄等级
      uint basePower;//基础攻击力
      uint baseHp;//基础血量
  }
  mapping (address => HeroInfo[] ) private userHeroInfo;//玩家英雄

  mapping(address => uint) private userCoin;//玩家金币


  //event事件 用户或是server应用可以花很低的代价 来监听事件的触发
  event TransferSend(address from, address to, uint amount);//交易事件

  constructor() {//合约产生的时候系统会调用，而且之后不允许被调用
    minter = msg.sender;
    owner = payable(msg.sender);
    userCoin[minter] = 100000000;//管理员初始给钱
  }
  function getsender() public view returns(address){//看自己的地址
    return msg.sender;
  }

  function getMinter() public view returns(address){//获得管理员账号地址
    return minter;
  }
  function getowner() public view returns(address){//获得管理员账号地址
    return owner;
  }

  function getUserHero(address address1) public view returns(HeroInfo[] memory){
    return userHeroInfo[address1];
  }
  function getMyHero() public view returns(HeroInfo[] memory){
    return userHeroInfo[msg.sender];
  }
  function getMyheroLen() public view returns(uint){
    uint length = userHeroInfo[msg.sender].length;//好像可以
    return length;
  }

  function getUserCoin(address address1) public view returns(uint){
    return userCoin[address1];
  }
  function addMyCoin(uint num) public {//ok
    userCoin[msg.sender] += num;
  }
  function getMyCoin() public view returns(uint){//ok
    return userCoin[msg.sender];
  }

  //好像return客户端也无法接收
  function creatHero() public payable{
    //玩家都转账了，结果数值不对也回不去啊
    uint need = 0.01 ether;//1以太币=1币安币
    if(msg.value < need){//给的钱不够
      return;
    }

    uint level1 = 1;
    uint basePower1 = Coin.getRandNum(10,20);
    uint baseHp1 = Coin.getRandNum(100,200);
    HeroInfo memory _heroInfo = HeroInfo({level:level1,basePower:basePower1,baseHp:baseHp1});

    userHeroInfo[msg.sender].push(_heroInfo);
  }

  
  function getThis() public view returns(address){
      return address(this);//this 代表当前部署的合约地址
  }
  function getbalance() public view returns(uint){//获取合约账户余额
     return address(this).balance;
  }
  
  //给管理员转账
  function transferToowner(uint value)public payable{
    if(msg.sender != minter){//没有权限
      return;
    }
    if(Coin.getbalance() < value){//没钱
      return;
    }
    owner.transfer(value);
  }
  
  //拼接两个字符串
  function strConcat(string memory _a, string memory _b) internal pure returns (string memory){
      bytes memory _ba = bytes(_a);
      bytes memory _bb = bytes(_b);
      string memory ret = new string(_ba.length + _bb.length);
      bytes memory bret = bytes(ret);
      uint k = 0;
      for (uint i = 0; i < _ba.length; i++)bret[k++] = _ba[i];
      for (uint i = 0; i < _bb.length; i++) bret[k++] = _bb[i];
      return string(ret);
   } 

  //随机整数 [min,max]
  function getRandNum(uint32 min,uint32 max) public view returns (uint) {
    // uint now1 = now;
    uint now1 = block.timestamp;
    uint32 maxNum = max - min + 1;
    uint rand = min + uint(keccak256(abi.encodePacked(now1))) % maxNum;
    return rand;
  }


  
 




}