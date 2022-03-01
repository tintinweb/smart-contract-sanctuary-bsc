// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./Ownable.sol";
import "./IERC20.sol";

contract IDESwap is Ownable{
    IERC20 public ide;
    IERC20 public otherToken;

    function withdraw(address to, uint256 amount) public virtual onlyOwner{
        require(amount > 0,"amount must > 0");
        require(ide.balanceOf(address(this)) >= amount,"contract balance must > transfer amount");
        ide.transfer(to, amount);
    }
    
    function withdrawOtherToken(address to, uint256 amount) public virtual onlyOwner {
       require(amount > 0,"amount must > 0");
       require(otherToken.balanceOf(address(this)) >= amount,"contract balance must > transfer amount");
        otherToken.transfer(to, amount);
    }
    
    function setOtherToken(IERC20 _otherToken) public virtual onlyOwner{
        otherToken = _otherToken;
    }
    
    function setIDEToken(IERC20 _IDEToken) public virtual onlyOwner{
        ide = _IDEToken;
    }
    
    
    
}