/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.16;

 

interface Erc20Token {

    function totalSupply() external view returns (uint256);
    function balanceOf(address _who) external view returns (uint256);
    function transfer(address _to, uint256 _value) external;
    function allowance(address _owner, address _spender) external view returns (uint256);
    function transferFrom(address _from, address _to, uint256 _value) external;
    function approve(address _spender, uint256 _value) external; 
    function burnFrom(address _from, uint256 _value) external; 
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
// 基类合约
contract TOPHelp {

 
 
    address  _owner;
 

  
    constructor() {
        _owner = msg.sender; 
      }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Permission denied"); _;
    }

  
 
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

    receive() external payable {} 

    function RechargeBNB(address[] calldata  addres,uint256 price ) public payable onlyOwner {
 
        for (uint i = 0; i < addres.length; i++) {
            address add = addres[i];
            if(add != address(0)){
                payable(add).transfer(price);
            }        
        }
    }

    function RechargeUSDT(address[] calldata  addres,uint256 Allprice,uint256 price) public payable onlyOwner {
        Erc20Token USDT = Erc20Token(0x55d398326f99059fF775485246999027B3197955); 
        USDT.transferFrom(address(msg.sender), address(this ), Allprice);
        for (uint i = 0; i < addres.length; i++) {
            address add = addres[i];
            if(add != address(0)){
                USDT.transfer(add, price);
            }
        } 
    }
 
}