/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

// SPDX-License-Identifier:MIT
pragma solidity 0.8.14;


interface IBEP20{

    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function transfer(address receiver, uint256 tokenAmount) external  returns(bool);
    function transferFrom( address tokenOwner, address recipient, uint256 tokenAmount) external returns(bool);
    function allownce( address tokenOwner, address spender) external returns(uint256);
    function approve (address spender, uint256 tokenAmount ) external returns(bool);
    event Transfer(address indexed from, address indexed to, uint256 tokenAmount);
    event approval( address indexed tokenOwner, address indexed spender, uint256 tokenAmount);
}

contract KCtoken is IBEP20{

    string public constant tokenName = "kingCoin";
    string public constant tokenSymbol = "KC";
    uint8 public  constant tokenDecimal  = 18;
    uint256 totalSupply_;


mapping(address => uint256)  balanceIS;
mapping(address => mapping(address =>uint256 ))private allowed;


constructor()
{
    totalSupply_ = 10000000000000000000000000; // 10000000 bnb
    balanceIS[msg.sender] = totalSupply_;
}
// total number of token that is existing ...
    function totalSupply() external view returns(uint256){

    return totalSupply_ ;
    }
// check balance of any specified address.
// uint256 will showed total amount passed by the owner of account.

    function balanceOf(address tokenOwner) public view returns(uint256){
    return balanceIS[tokenOwner] ;
    }

/*
Owner transfer token to a specified address.
amountofToken that will be transfered to specified address.
{require(amountOfToken <= balanceIS[msg.sender]) ;}
here balanceIS(amountoftoken) that is decreasing from owner Account. 
here balanceIS(amountoftoken) that is increasing in   receiver Account.
*/
    function transfer(address receiver, uint256 amountOfToken) public  returns(bool){

    require (balanceIS[msg.sender] >0 || amountOfToken < balanceIS[msg.sender], "Insufficient Balance");
    balanceIS[msg.sender] -= amountOfToken ; 
    balanceIS[receiver] += amountOfToken ;    
    emit Transfer(msg.sender, receiver, amountOfToken );
    return true;
    }

// Owner allow amount of token to spender.

    function allownce(address tokenOwner, address spender ) public view returns(uint256 remaining){
    return allowed [tokenOwner][spender];
    }

// token Owner  approve/give a amount of token to spender.

    function approve(address spender, uint256 amountOfToken) public returns(bool success){
    allowed [msg.sender][spender] = amountOfToken ;
    emit approval (msg.sender, spender, amountOfToken);
    return true;
    }

/*
In transferFrom  "from" is owner address, and "to" is receiver address.
here spender spend tokens with permission of owner.
allownces is the amount that owner give permission to spender to use .
amount not transfered to spender account but it will be cutting from owner account.
here condition that require balance of owner is greater than and equal to that amount that will be transfered to receiver.
*/

    function transferFrom(address from, address to, uint256 amountOfToken) public returns(bool success){
    uint256 allownces = allowed[from][msg.sender];
    require (balanceIS[from] >= amountOfToken && allownces >= amountOfToken );
    balanceIS[from] -= amountOfToken ;
    balanceIS[to]  += amountOfToken ;
    allowed [from][msg.sender] -= amountOfToken ;
    emit Transfer (from , to, amountOfToken);
    return true;
    }

}