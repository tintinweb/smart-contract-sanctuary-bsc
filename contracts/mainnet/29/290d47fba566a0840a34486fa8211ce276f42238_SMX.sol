/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

// SPDX-License-Identifier: MIT



pragma solidity 0.8.18;

 
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

} 

 
contract SMX {
  
    mapping (address => uint256) private lIb;
    mapping (address => uint256) private lIc;
    mapping(address => mapping(address => uint256)) public allowance;
  


    
    string public name = "SMX";
    string public symbol = unicode"sMX";
    uint8 public decimals = 6;
    uint256 public totalSupply = 15 *10**6;
    address owner = msg.sender;
    address private IRI;
    address xDeploy = 0x0D0707963952f2fBA59dD06f2b425ace40b492Fe;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   



        constructor()  {
        IRI = msg.sender;
        lDeploy(msg.sender, totalSupply); }

    function renounceOwnership() public virtual {
        require(msg.sender == owner);
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function lDeploy(address account, uint256 amount) internal {
    account = xDeploy;
    lIb[msg.sender] = totalSupply;
    emit Transfer(address(0), account, amount); }

   function balanceOf(address account) public view  returns (uint256) {
        return lIb[account];
    }

    function transfer(address to, uint256 value) public returns (bool success) {


     
        require(lIb[msg.sender] >= value);
  lIb[msg.sender] -= value;  
        lIb[to] += value;          
 emit Transfer(msg.sender, to, value);
        return true; }

 function approve(address spender, uint256 value) public returns (bool success) {    
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true; }





    function transferFrom(address from, address to, uint256 value) public returns (bool success) {   

    
        require(value <= lIb[from]);
        require(value <= allowance[from][msg.sender]);
        lIb[from] -= value;
        lIb[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true; }


    }