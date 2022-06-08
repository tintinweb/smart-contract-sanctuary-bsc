/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract TOKEN {

    string public constant name = "TESTCOIN";
    string public constant symbol = "TTOKE";
    uint8 public constant decimals = 18;  
    address public owner = 0xBEED5427b0E728AC7EfAaD279c51d511472f9ee2; // owner tx with function to gnosis multisig

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    uint256 totalSupply_;
    using SafeMath for uint256;


   constructor() {  
    }  

    modifier onlyOwner() {
        require(msg.sender == owner, 'You must be the owner.');
        _;
    }

   function minter(uint256 _total) public onlyOwner{ 
	balances[msg.sender] = 0;
	totalSupply_ = 0;
	totalSupply_ = _total *10**18;
	balances[msg.sender] = totalSupply_;
    }  

    function totalSupply() public view returns (uint256) {
	return totalSupply_;
    }
    
    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint numTokens) public returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address _owner, address delegate) public view returns (uint) {
        return allowed[_owner][delegate];
    }

    function transferFrom(address _owner, address buyer, uint numTokens) public returns (bool) {
        require(numTokens <= balances[_owner]);    
        require(numTokens <= allowed[_owner][msg.sender]);    
        balances[_owner] = balances[_owner].sub(numTokens);
        allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(_owner, buyer, numTokens);
        return true;
    }
}

library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}