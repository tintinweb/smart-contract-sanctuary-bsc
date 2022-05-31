/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);
  function allowance(address _owner, address spender) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ABCToken is IBEP20 {
	
	uint256 private _totalSupply;
    uint8 private _decimals = 18;
    string private _symbol = "ABC";
    string private _name= "ABC COIN";
    address private _owner;

    mapping(address => uint256) _balances;

    mapping(address => mapping (address => uint256)) allowed;

    using SafeMath for uint256;


   constructor(uint256 _initialSupply)  {
	_owner = msg.sender;
    _totalSupply = _initialSupply;
    _balances[msg.sender] = _totalSupply;
    }
    
    function decimals() external view returns (uint8) {
    return _decimals;
    }
    
    function symbol() external view returns (string memory) {
        return _symbol;
    }
  
    function name() external view returns (string memory) {
    return _name;
    }

    function totalSupply() external view returns (uint256) {
      return _totalSupply;
    }
  
	
	function getOwner() public view returns (address) {
		return _owner;
	}

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address receiver, uint256 numTokens) external returns (bool) {
        require(numTokens <= _balances[msg.sender],"No of tokens should be less that balance");
        _balances[msg.sender] = _balances[msg.sender].sub(numTokens);
        _balances[receiver] = _balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens)external returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) external view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) external returns (bool) {
        require(numTokens <= _balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        _balances[owner] = _balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        _balances[buyer] = _balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}

contract TableSale12 {
    address payable admin;
    ABCToken public tokenContract;
    uint256 public tokenPrice;
    uint256 public tokensSold;

    using SafeMath for uint256;

    event Sell(address _buyer, uint256 _amount);

    constructor(ABCToken _tokenContract, uint256 _tokensSold)  {
        admin = payable(msg.sender);
        tokenContract = _tokenContract;
        tokensSold = _tokensSold;
    }
    
    function settokenPrice(uint256 _tokenPrice) public {
        require(msg.sender == admin);
        tokenPrice = _tokenPrice;
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        require(_numberOfTokens < 10001 && msg.value < 500000000000000000 , "high calculation");
        require(msg.value == _numberOfTokens.multiply(tokenPrice),"Amount does not match");
        require(tokenContract.transfer(msg.sender, _numberOfTokens),"Transfer failed");

        tokensSold += _numberOfTokens;

        emit Sell(msg.sender, _numberOfTokens);
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

    function multiply(uint x, uint y) internal pure returns (uint z) {
        unchecked {
            require(y == 0 || (z = x * y) / y == x);
        }
    }
}