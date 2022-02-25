/**
 *Submitted for verification at BscScan.com on 2022-02-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Swap {
    address private constant OLD_TOKEN = 0xfbbcDE9aC45bF5a32B950A6aED5834Ba5C15D091; 
    address private constant NEW_TOKEN = 0xdF8E11aec6A457b99a941d30E2D107839AE273aC; 
    
    mapping(address => uint256) private _balances;
    address private owner;
    bool    private _acceptingSwap = false;
    bool    private _acceptingWithdraw = false;

    constructor(){
        owner = msg.sender;
    }

    function acceptingSwap() external view returns (bool) {
        return _acceptingSwap;
    }

    function acceptingWithdraw() external view returns (bool) {
        return _acceptingWithdraw;
    }

    function enableSwap(bool acceptingSwap_) external {
        require (owner == msg.sender, "Operation not allowed");
        _acceptingSwap = acceptingSwap_;
    }  

    function enableWithdraw(bool acceptingWithdraw_) external {
        require (owner == msg.sender, "Operation not allowed");
        _acceptingWithdraw = acceptingWithdraw_;
    }

    function swap() external returns (bool) {
        require(_acceptingSwap, "Disabled Swap");
        uint amount = IERC20(OLD_TOKEN).allowance(msg.sender, address(this));
        IERC20(OLD_TOKEN).transferFrom(msg.sender, address(this), amount);
        _balances[msg.sender] += amount;
        return true;                
    }    

    function swapWithdraw() external returns (bool) {
        require(_acceptingWithdraw, "Disabled Withdraw");
        uint amount = _balances[msg.sender];       
        uint myBalance = IERC20(NEW_TOKEN).balanceOf(address(this));     
        require(myBalance >= amount, "Insufficient funds");
        IERC20(NEW_TOKEN).transfer(msg.sender, amount);
        _balances[msg.sender] = 0;
        return true;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function withdraw() external returns (bool) {
        require (owner == msg.sender, "Operation not allowed");
        uint amount = IERC20(OLD_TOKEN).balanceOf(address(this));     
        return IERC20(OLD_TOKEN).transfer(owner, amount);
    }

    function withdrawNewToken() external returns (bool) {
        require (owner == msg.sender, "Operation not allowed");
        uint amount = IERC20(NEW_TOKEN).balanceOf(address(this));     
        return IERC20(NEW_TOKEN).transfer(owner, amount);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
}