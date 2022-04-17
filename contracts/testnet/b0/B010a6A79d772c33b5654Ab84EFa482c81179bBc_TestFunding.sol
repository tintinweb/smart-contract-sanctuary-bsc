/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

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

contract Owned {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner , "Sorry, you are not allowed to process.");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract TestFunding is Owned {
    mapping(address => uint) private arrayUsers;
    uint public minimumDeposit = 10**7;
    uint public totalDeposit;
    
    /**
        * Token LLG
    **/
    IERC20 contractLLG = IERC20(0x5765134ca75595C52Cc36Bef014C97F6D95Cdfc1);
    
    constructor () {
        owner = msg.sender;
    }
    
    function depositToken(uint _amount) public returns(bool){
        require(_amount >= minimumDeposit, "Deposit token must not be less than the minimum.");
        require(_amount != 0 , "Deposit token amount cannot be zero");
        contractLLG.transferFrom(msg.sender, address(this) ,_amount);
        arrayUsers[msg.sender] += _amount;
        totalDeposit++;
        return true ; 
        
    }

    function withdrawToken(uint _amount) public {
        require(_amount <= arrayUsers[msg.sender], "Deposit token must not be less than the maximum.");
        contractLLG.transfer(msg.sender, _amount);
        arrayUsers[msg.sender] -= _amount;

    }

    /////////////////////////////////////////////////////
    // Only the ADMIN
    ////////////////////////////////////////////////////
    function withdrawOwner(uint _amount) public onlyOwner{
        contractLLG.transfer(msg.sender, _amount);

    }
    
    function getArrayUsers() public view returns(uint) {
        return arrayUsers[msg.sender];   
    }
    
    function balanceOf() public view returns(uint) {
        return contractLLG.balanceOf(address(this)) ; 
    }
    
    function balanceOfAddress(address _account) public view returns(uint) {
        return contractLLG.balanceOf(_account) ; 
    }
    
}