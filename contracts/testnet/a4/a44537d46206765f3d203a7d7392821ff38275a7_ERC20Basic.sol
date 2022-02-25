/**
 *Submitted for verification at BscScan.com on 2022-02-24
*/

/*
🆃🅾🅺🅴🅽

mint
burn
transferOwnership

*/

pragma solidity ^0.8.12;
// SPDX-License-Identifier: Unlicensed

contract ERC20Basic {
    
    address public owner;
    string public constant name = "Simple Token";
    string public constant symbol = "ST";
    uint8 public constant decimals = 9;  
    uint256 public totalSupply_ =  21000000 * 10 * decimals;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Mint(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed burner, uint256 value);

    mapping(address => uint256) public balances;
    mapping(address => mapping (address => uint256)) allowed;
    
    address public dead;
    using SafeMath for uint256;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   constructor(address deadaddress) {
    dead = deadaddress;
    balances[msg.sender] = totalSupply_;
    owner = msg.sender;
    }  

    function totalSupply() public view returns (uint256) {
    return totalSupply_;
    }
    
// check how much token address have
    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }

// only owner can send tokens from this fun - token deducted from owner address
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

    function allowance(address owner_address, address delegate) public view returns (uint) {
        return allowed[owner_address][delegate];
    }

    function transferFrom(address owner_address, address buyer, uint numTokens) public returns (bool) {
        require(numTokens <= balances[owner_address]);    
        require(numTokens <= allowed[owner_address][msg.sender]);
        balances[owner_address] = balances[owner_address].sub(numTokens);
        allowed[owner_address][msg.sender] = allowed[owner_address][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner_address, buyer, numTokens);
        return true;
    }

	function burn(address _who, uint256 _value) internal {
		require(_value <= balances[_who]);
		balances[_who] = balances[_who].sub(_value);
		totalSupply_ = totalSupply_.sub(_value);
		emit Burn(_who, _value);
		emit Transfer(_who, address(dead), _value);
	}

     function mint(address account, uint256 amount) onlyOwner public {
        totalSupply_ = totalSupply_.add(amount);
        balances[account] = balances[account].add(amount);
        emit Mint(address(dead), account, amount);
        emit Transfer(address(dead), account, amount);
    }


  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(dead));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
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