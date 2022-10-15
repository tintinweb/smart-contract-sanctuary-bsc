/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.3;

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

abstract contract Ownable  {
    address public owner;

    constructor () {       
        owner = msg.sender;
    }    
    modifier onlyOwner() {
        require(owner == msg.sender, "onlyOwner");
        _;
    }   
    function transferOwnership(address newOwner) public virtual onlyOwner {              
        owner = newOwner;
    }
}


contract AutoLiquidity is Ownable {      
    mapping (address => uint256) private _lockTime; 
    function approve(address token, address spender, uint256 amount) external onlyOwner returns (bool){
        IERC20 tokenContract = IERC20(token);
        return tokenContract.approve(spender, amount);
    } 

    function allowance(address token, address spender) external view returns (uint256){
        IERC20 tokenContract = IERC20(token);
        return tokenContract.allowance(address(this), spender);
    }

    function transfer(address token, address to, uint value) external onlyOwner returns (bool){
        uint256 unlockTime = _lockTime[token]; 
        require(unlockTime <= block.timestamp, "Token is locked");
        IERC20 tokenContract = IERC20(token);
        return tokenContract.transfer(to, value);
    }

    function balanceOf(address token) external view returns (uint256){
        IERC20 tokenContract = IERC20(token);
        return tokenContract.balanceOf(address(this));
    }

    function transferBNB() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function lock(address token,  uint256 time) external onlyOwner{
        uint256 unlockTime = _lockTime[token];        
        uint256 lockTime = block.timestamp + time;
        require(lockTime > unlockTime);
        _lockTime[token] = lockTime;
    }

    function getUnlockTime(address token) external view returns (uint256){
        return _lockTime[token];
    }
}