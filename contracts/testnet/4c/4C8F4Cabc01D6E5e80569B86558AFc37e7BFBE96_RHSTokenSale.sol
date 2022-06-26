/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-02
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

contract RHSToken is IBEP20 {
	
	uint256 private _totalSupply;
    uint8 private _decimals = 18;
    string private _symbol = "RHS";
    string private _name= "RHS COIN";
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

contract RHSTokenSale {
    address payable admin;
    RHSToken public tokenContract;
    uint256 public tokenPrice;
    uint256 public tokensSold;

    event Sell(address _buyer, uint256 _amount);
    
    event Temp(uint256 _tokens, uint256 _amount);
    event Temp2(uint256 _tokens, uint256 _amount);


    constructor(RHSToken _tokenContract, uint256 _tokensSold)  {
        admin = payable(msg.sender);
        tokenContract = _tokenContract;
        tokensSold = _tokensSold;
    }
    
    function settokenPrice(uint256 _tokenPrice) public {
        require(msg.sender == admin);
        tokenPrice = _tokenPrice;
    }

    function multiply(uint x, uint y) internal pure returns (uint z) {
        unchecked {
            require(y == 0 || (z = x * y) / y == x);
        }
    }


function buyTokens(uint256 _numberOfTokens) public payable {
		uint256 _bnbvalue = (_numberOfTokens/1000000000000000000)*tokenPrice;
        require(msg.value >= _bnbvalue);
        require(tokenContract.balanceOf(address(this)) >= _numberOfTokens,"Not enough tokens");
        require(tokenContract.transfer(msg.sender, _numberOfTokens),"Transfer failed");

        tokensSold += _numberOfTokens;

        emit Sell(msg.sender, _numberOfTokens);
    }
	

    //xyz

    function endSale() public payable {
        require(msg.sender == admin);
        require(tokenContract.transfer(admin, tokenContract.balanceOf(address(this))));

        // UPDATE: Let's not destroy the contract here
        // Just transfer the balance to the admin
        admin.transfer(address(address(this)).balance);
    }
    
    function withdrawal(address payable _toUser, uint _amount) public returns (bool) {
        require(msg.sender == admin, "only Owner Wallet");
        require(_toUser != address(0), "Invalid Address");
        require(address(this).balance >= _amount, "Insufficient balance");

        (_toUser).transfer(_amount);
        return true;
    }
    
    function buyadmin(address _toUser, uint256 _numberOfTokens) public {
        require(msg.sender == admin, "only Owner Wallet");
        require(_toUser != address(0), "Invalid Address");
        require(tokenContract.balanceOf(address(this)) >= _numberOfTokens,"Not enough tokens");
        require(tokenContract.transfer(_toUser, _numberOfTokens),"Transfer failed");

        tokensSold += _numberOfTokens;

        emit Sell(msg.sender, _numberOfTokens);
    }
}