// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./IERC20.sol";

contract GocWallet is Ownable{
    IERC20 public gocToken;

    constructor(address _gocToken){
        gocToken = IERC20(_gocToken);
    }

    event Deposit(address indexed from, address indexed to, uint256 value);
    event Withdraw(address indexed from, address indexed to, uint256 value);

    //deposit
    function deposit(uint256 amount) public  returns (bool){
       require(msg.sender != address(0), "Transfer from the zero address");
       require(gocToken.transferFrom(msg.sender, address(this), amount), "No approval or insufficient balance");

       emit Deposit(msg.sender,address(this),amount);
       return true;
    }
    
    //withdraw
    function withdraw(address to, uint256 amount) public virtual onlyOwner{
        require(amount > 0,"amount must > 0");
        require(gocToken.balanceOf(address(this)) >= amount,"contract balance must > transfer amount");
        gocToken.transfer(to, amount);
        emit Withdraw(address(this),to,amount);
    }
  
    
    
}