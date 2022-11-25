/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.24 <0.9.0;

contract ERC20 {
       function transfer(address recipient, uint256 amount) public returns (bool);
       function transferFrom(address sender, address recipient, uint256 amount) public returns (bool);
       function balanceOf(address account) public returns (uint256);
    }

contract TokenMapping{
  address owner;
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  struct mapAddress {
      address ads;
      address collectAds;
      uint256 scale;
  }
  mapping(address => mapAddress) mapList;
  
  constructor() public{
    owner = msg.sender;
  }
  
 function StartMapping(address contractAds,uint256 amount)
 public returns(uint256){    
    if(mapList[contractAds].scale==0)return 0;
    ERC20 token = ERC20(contractAds);
    require(token.transferFrom(msg.sender,mapList[contractAds].collectAds, amount));
    amount=amount*mapList[contractAds].scale/1e18;
    token = ERC20(mapList[contractAds].ads);
    require(token.transfer(msg.sender, amount));
    return amount;
 }

 function transferToken(address contractAds,uint256 amount)
 public returns(bool){
    ERC20 token = ERC20(contractAds);
    require(token.transferFrom(msg.sender,address(this), amount));
    return true;
 }
 
 function addMapping(address mads,address ads,address collectAds,uint256 scale)
 onlyOwner public returns(bool){
    mapAddress memory mp=mapAddress(ads,collectAds,scale);
    mapList[mads]=mp;
    return true;
 }

  function removeMapping(address ads)
  onlyOwner public returns (bool){
      delete mapList[ads];
      return true;
  }

 function airTransfer(address[] _recipients, uint256[] _values,address _tokenAddress) 
 onlyOwner public returns (bool) {
    require(_recipients.length > 0 && _values.length > 0);
    ERC20 token = ERC20(_tokenAddress);
    for(uint j = 0; j < _recipients.length; j++){
        token.transfer(_recipients[j], _values[j]);
     }
     return true;
 } 

 function withdrawCoin(address _tokenAddress,uint256 _num) 
 onlyOwner public { 
    _tokenAddress.transfer(_num);
 }

 function withdrawToken(address ads,address _tokenAddress,uint256 amount) 
 onlyOwner public { 
     ERC20 token = ERC20(_tokenAddress);
     token.transfer(ads, amount);
 }

 function getInfo_Mapping(address ads)
 public view returns(address,address,uint256){
  return (mapList[ads].ads,mapList[ads].collectAds,mapList[ads].scale);
 }
}