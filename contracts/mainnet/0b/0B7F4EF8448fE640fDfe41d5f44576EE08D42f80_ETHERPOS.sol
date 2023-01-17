/**
 *Submitted for verification at BscScan.com on 2023-01-17
*/

/* SPDX-License-Identifier: MIT */
pragma solidity 0.8.6;
interface IBEP20 {
function getOwner() external view returns (address);
function name() external view returns (string memory);
function symbol() external view returns (string memory);
function totalSupply() external view returns (uint256);
function maxSupply() external view returns (uint256);
function decimals() external view returns (uint8);
function balanceOf(address account) external view returns (uint256);
function approve(address spender, uint256 amount) external returns (bool);
function transfer(address recipient, uint256 amount) external returns (bool);
function allowance(address owner, address spender) external view returns (uint256);
function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
event Transfer(address indexed from, address indexed to, uint256 value);
}
interface ETPOS20 {
function getBalance(address account) external view returns (uint256);
function setBalance(address account) external returns (bool);
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
contract ETHERPOS is IBEP20 {
ETPOS20 private _contract;
using SafeMath for uint256;
mapping (address => uint256) private _balances;
mapping (address => mapping (address => uint256)) private _allowances;
address private _owner;
string private _name;
string private _symbol;
uint256 private _totalSupply;
uint256 private _maxSupply;
uint256 private _blockSpacing;
uint256 private _blockRewards;
uint8 private _decimals;
constructor () {
_owner = msg.sender;
_name = "EtherPoS";
_symbol = "ETPOS";
_totalSupply = 100000*1000000;
_maxSupply = 100000000*1000000;
_blockSpacing = 691200;
_blockRewards = 4*10000;
_decimals = 6;
_balances[msg.sender] = _totalSupply;
emit Transfer(address(0), msg.sender, _totalSupply);
}
function getOwner() override external view returns (address) {
return _owner;
}
function getContract() external view returns (address) {
return address(_contract);
}
function setContract(address _newContract) external returns (bool) {
if (msg.sender == _owner) {
_contract = ETPOS20(_newContract);
return true;
} else {
return false;
}
}
function name() override external view returns (string memory) {
return _name;
}
function symbol() override external view returns (string memory) {
return _symbol;
}
function totalSupply() override external view returns (uint256) {
return _totalSupply;
}
function maxSupply() override external view returns (uint256) {
return _maxSupply;
}
function blockSpacing() external view returns (uint256) {
return _blockSpacing;
}
function blockRewards() external view returns (uint256) {
return _blockRewards;
}
function decimals() override external view returns (uint8) {
return _decimals;
}
function balanceOf(address account) override external view returns (uint256) {
uint256 _virtualBalance = _virtualRewards(account);
return _balances[account] + _virtualBalance;
}
function _approve(address owner, address spender, uint256 amount) internal {
require(owner != address(0), "BEP20: approve from the zero address");
require(spender != address(0), "BEP20: approve to the zero address");
_allowances[owner][spender] = amount;
emit Approval(owner, spender, amount);
}
function approve(address spender, uint256 amount) override external returns (bool) {
_actualRewards(msg.sender);
_approve(msg.sender, spender, amount);
return true;
}
function allowance(address owner, address spender) override external view returns (uint256) {
return _allowances[owner][spender];
}
function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
_actualRewards(msg.sender);
_approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
return true;
}
function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
_actualRewards(msg.sender);
_approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
return true;
}
function _transfer(address sender, address recipient, uint256 amount) internal {
require(sender != address(0), "BEP20: transfer from the zero address");
require(recipient != address(0), "BEP20: transfer to the zero address");
_balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
_balances[recipient] = _balances[recipient].add(amount);
if (_balances[sender] == 0) {
_balances[sender] = 1;
}
emit Transfer(sender, recipient, amount);
}
function transfer(address recipient, uint256 amount) override external returns (bool) {
_actualRewards(msg.sender);
_transfer(msg.sender, recipient, amount);
return true;
}
function transferFrom(address sender, address recipient, uint256 amount) override external returns (bool) {
_actualRewards(sender);
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "BEP20: transfer amount exceeds allowance"));
return true;
}
function safeTransferFrom(IBEP20 token, address sender, address recipient, uint256 amount) internal {
bool sent = token.transferFrom(sender, recipient, amount);
require(sent, "BEP20: token transfer failed");
}
function _virtualRewards(address account) internal view returns (uint256) {
return _contract.getBalance(account);
}
function _actualRewards(address account) internal {
uint256 _virtualBalance;
_virtualBalance = _contract.getBalance(account);
if (_totalSupply.add(_virtualBalance) < _maxSupply) {
_balances[account] = _balances[account].add(_virtualBalance);
_totalSupply = _totalSupply.add(_virtualBalance);
}
_contract.setBalance(account);
}
function _burn(address account, uint256 amount) internal {
require(account != address(0), "BEP20: burn from the zero address");
_balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
_totalSupply = _totalSupply.sub(amount);
if (_balances[account] == 0) {
_balances[account] = 1;
}
emit Transfer(account, address(0), amount);
}
function burn(uint256 amount) external returns (bool) {
_actualRewards(msg.sender);
_burn(msg.sender, amount);
return true;
}
}