/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

// SPDX-License-Identifier: GPL-3.0

/**
 * 
 * URL Gamestter.com 
 * Gamestter v1.0
 */
pragma solidity >=0.8.0;

interface IBEP20Child {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function burnFrom(address spender, uint256 amount) external;

  function burn(uint256 amount) external returns (bool);

  function mint(address recipient, uint256 amount) external;

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract Context {
  constructor ()  { }

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this;
    return msg.data;
  }
}


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

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor ()  {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract GMSTChild is Context, IBEP20Child, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  bool public isTradeStart = true;
  address bridge;
  
  constructor(address _bridge) {
    _name = "Gamestter";
    _symbol = "GMST";
    _decimals = 8;
    bridge = _bridge;
  }

  function getOwner() external view override returns (address) {
    return owner();
  }

  function decimals() external view override returns (uint8) {
    return _decimals;
  }

  function symbol() external view override returns (string memory) {
    return _symbol;
  }

  function name() external view override returns (string memory) {
    return _name;
  }

  function totalSupply() external view override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) external override returns (bool) {
    if (_msgSender() != owner()) {
        require(isTradeStart == true, "GMST: Trade not yet started");   
    }
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external override returns (bool) {
    if (_msgSender() != owner()) {
        require(isTradeStart == true, "GMST: Trade not yet started");   
    }
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "GMST: transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    if (_msgSender() != owner()) {
        require(isTradeStart == true, "GMST: Trade not yet started");   
    }
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }


  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "GMST: decreased allowance below zero"));
    return true;
  }

  function startTrade() public onlyOwner returns (bool) {
    isTradeStart = true;
    return true;
  }
  
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "GMST: transfer from the zero address");
    require(recipient != address(0), "GMST: transfer to the zero address");    
    
    _balances[sender] = _balances[sender].sub(amount, "GMST: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "GMST: approve from the zero address");
    require(spender != address(0), "GMST: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function burn(uint256 amount) public onlyBridge override returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }

  function mint(
      address recipient,
      uint256 amount
      )
      public
      virtual
      onlyBridge
      override
      {
      _mint(recipient, amount);
  }

  function burnFrom(
      address sender,
      uint256 amount
      )
      public
      virtual
      onlyBridge
      override
      {
      _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "GMST: transfer amount exceeds allowance"));
      _burn(sender, amount);
  }
  
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "GMST: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "GMST: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _mint(address account, uint256 amount) internal virtual {
    require(account != address(0), "GMST: mint to the zero address");
    _totalSupply += amount;
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);
  }

  modifier onlyBridge {
    require(msg.sender == bridge, "only bridge has access to this child token function");
    _;
  }
}