/**
 *Submitted for verification at BscScan.com on 2022-04-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
       if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

interface IERC20{
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
}

 contract PreSale{

    using SafeMath for uint256;    
    IERC20 Token;
    
    address public owner;
    address public newOwner;
    uint256 public preSalePrice = 0.1 ether;

    event  ownershipTransferred(address indexed from, address indexed to);
    constructor(IERC20 _Token ){
        Token = _Token;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnerShip(address _to) public onlyOwner {
        //   require(msg.sender == owner);
        emit ownershipTransferred(owner, newOwner);
        newOwner = _to;
    }
    
    // --------> New Version <----------
    function calc() private returns(uint256){

        uint256 _Amount = msg.value;
        require(_Amount >= preSalePrice, "Not enough amount");
        uint256 totalTokens = _Amount.div(preSalePrice);
        return totalTokens;
    }

    function buyTokens() public payable returns(uint256 tokens) {
        // Amount = Amount.mul(10**18);
        uint256 Amount = calc();
        Token.transfer(msg.sender,Amount);
        return Amount;
    }
}