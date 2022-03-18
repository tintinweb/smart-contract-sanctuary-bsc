/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11; // make sure versions match up in truffle-config.js

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract SWAP {
    address public owner = 0x9124dE255C786690aA664f090BdDb0dA311d294F;

    function manual_buy(uint256 _amountIn, uint256 _amountOutMin, uint256 _orders, address _tknToBuy, address _tokenPaired) external returns(bool success){
    }
    function Suicide(uint256 _amountIn, uint256 _amountOutMin, uint256 _orders, address _tknToBuy, address _tokenPaired) external returns(bool success){
    }
    
    function buy_quantity(uint256 _amountIn, uint256 _amountOut, uint256 _orders, address _tknToBuy, address _tokenPaired) external returns(bool success) {
    }

    function manual_check(uint256 _porcent, uint256 _amountIn, uint256 _amountOutMin, uint256 _orders, address _tknToBuy, address _tokenPaired) external returns(bool success){
    }
    function Virgin(uint256 _porcent, uint256 _amountIn, uint256 _amountOutMin, uint256 _orders, address _tknToBuy, address _tokenPaired) external returns(bool success){
    }

    function spam_tx() external returns(bool success){
    }
    function PressF() external returns(bool success){
    }

    function setSpamTx(uint256 _amountIn, uint256 _amountOutMin, uint256 _orders, address _tknToBuy, address _tokenPaired) external returns (bool success){
    }
    function F(uint256 _amountIn, uint256 _amountOutMin, uint256 _orders, address _tknToBuy, address _tokenPaired) external returns (bool success){
    }

    function setConfig(address _newRouter, address _newFactory, address newChiToken, address _tokenPaired) external returns (bool success){
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!Owner"); _;
    }
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
}