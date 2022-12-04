/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function decimal() external view returns(uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient,uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Presale {

    IERC20  erc20;
    address  payable tknOwner;
    constructor(IERC20 tokenaddress, address payable owner){
        erc20 = tokenaddress;
       tknOwner = owner;
    }
    
    uint Ethr1 = 1 ether;
    uint token = 10;
    


    

    function buy() public payable{
		require(msg.sender  != address(0), "Null address can't buy token");
		uint amount = msg.value * token * 10**erc20.decimal();
        amount = amount / Ethr1;
        erc20.transferFrom(tknOwner, msg.sender, amount);
        tknOwner.transfer(msg.value);
    } 
}