/**
 *Submitted for verification at BscScan.com on 2022-12-29
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
function allowance(address owner, address spender) external view returns (uint256);
function transfer(address recipient, uint256 amount) external returns (bool);
function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
event Transfer(address indexed from, address indexed to, uint256 value);
}
interface IVSP20 {
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
contract VelozToken is IBEP20 {
using SafeMath for uint256;
IVSP20 private _contract;
address private _owner;
string private _name;
string private _symbol;
uint256 private _totalSupply;
uint256 private _maxSupply;
uint8 private _decimals;
uint256 private _blockSpacing;
uint256 private _blockRewards;
uint256 private _totalBurned;
uint256 private _totalMinted;
uint256 private _totalValidators;
mapping (address => uint256) private _balances;
mapping (address => uint256) private _burnOf;
mapping (address => uint256) private _mintOf;
mapping (address => uint256) private _timeOf;
mapping (address => mapping (address => uint256)) private _allowances;
constructor () {
_owner = msg.sender;
_name = "Veloz Token";
_symbol = "VELOZ";
_totalSupply = 210000 * (10 ** 8);
_maxSupply = 21000000 * (10 ** 8);
_decimals = 8;
_blockSpacing = 300;
_blockRewards = 100000;
_balances[msg.sender] = _totalSupply;
emit Transfer(address(0), msg.sender, _totalSupply);
}
function getTimestamp() external view returns (uint256) {
return block.timestamp;
}
function getContract() external view returns (address) {
return address(_contract);
}
function setContract(address _newContract) external returns (bool) {
require(msg.sender == _owner, "BEP20: caller is not the owner");
_contract = IVSP20(_newContract);
return true;
}
function getOwner() override external view returns (address) {
return _owner;
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
function decimals() override external view returns (uint8) {
return _decimals;
}
function totalBurned() external view returns (uint256) {
return _totalBurned;
}
function totalMinted() external view returns (uint256) {
return _totalMinted;
}
function totalValidators() external view returns (uint256) {
return _totalValidators;
}
function balanceOf(address account) override external view returns (uint256) {
uint256 _fromBurning = _getBalance(account);
uint256 _fromStaking = _contract.getBalance(account);
return _balances[account].add(_fromBurning.add(_fromStaking));
}
function burnOf(address account) external view returns (uint256) {
return _burnOf[account];
}
function mintOf(address account) external view returns (uint256) {
return _mintOf[account];
}
function timeOf(address account) external view returns (uint256) {
return _timeOf[account];
}
function _approve(address owner, address spender, uint256 amount) internal {
require(owner != address(0), "BEP20: approve from the zero address");
require(spender != address(0), "BEP20: approve to the zero address");
_allowances[owner][spender] = amount;
emit Approval(owner, spender, amount);
}
function approve(address spender, uint256 amount) override external returns (bool) {
_moveBalance(msg.sender);
_approve(msg.sender, spender, amount);
return true;
}
function allowance(address owner, address spender) override external view returns (uint256) {
return _allowances[owner][spender];
}
function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
_moveBalance(msg.sender);
_approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
return true;
}
function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
_moveBalance(msg.sender);
_approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
return true;
}
function _transfer(address sender, address recipient, uint256 amount) internal {
require(sender != address(0), "BEP20: transfer from the zero address");
require(recipient != address(0), "BEP20: transfer to the zero address");
_balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
_balances[recipient] = _balances[recipient].add(amount);
if (_balances[sender] == uint256(0)) {
_balances[sender] = _balances[sender].add(1);
}
emit Transfer(sender, recipient, amount);
}
function transfer(address recipient, uint256 amount) override external returns (bool) {
_moveBalance(msg.sender);
_transfer(msg.sender, recipient, amount);
return true;
}
function transferFrom(address sender, address recipient, uint256 amount) override external returns (bool) {
_moveBalance(sender);
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "BEP20: transfer amount exceeds allowance"));
return true;
}
function _burn(address account, uint256 amount) internal {
require(account != address(0), "BEP20: burn from the zero address");
_balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
_totalSupply = _totalSupply.sub(amount);
emit Transfer(account, address(0), amount);
}
function burn(uint256 amount) external returns (bool) {
_moveBalance(msg.sender);
_burn(msg.sender, amount);
return true;
}
function _mint(address account, uint256 amount) internal {
require(account != address(0), "BEP20: mint to the zero address");
_balances[account] = _balances[account].add(amount);
_totalSupply = _totalSupply.add(amount);
emit Transfer(address(0), account, amount);
}
function mint(uint256 amount) external returns (bool) {
require(_owner == msg.sender, "BEP20: caller is not the owner");
_moveBalance(msg.sender);
_mint(msg.sender, amount);
return true;
}
function _getBalance(address account) internal view returns (uint256) {
uint256 _seconds = block.timestamp.sub(_timeOf[account], "BEP20: decreased time below zero");
uint256 _blocks = _seconds.div(_blockSpacing);
if (_burnOf[account] > 0 && _timeOf[account] > 0 && _seconds > 0 && _blocks > 0) {
uint256 _perBlock = uint256(_burnOf[account].mul(_blockRewards.div(288))).div(10**_decimals);
uint256 _newToken = _perBlock.mul(_blocks);
if (_mintOf[account] > _burnOf[account]) {
_newToken = _newToken.div(2);
}
return _newToken;
} else {
return 0;
}
}
function getBalance(address account) external view returns (uint256) {
return _getBalance(account);
}
function _moveBalance(address account) internal {
require(account != address(0), "BEP20: move to the zero address");
uint256 _seconds = block.timestamp.sub(_timeOf[account], "BEP20: decreased time below zero");
uint256 _blocks = _seconds.div(_blockSpacing);
if (_burnOf[account] > 0 && _timeOf[account] > 0 && _seconds > 0 && _blocks > 0) {
uint256 _perBlock = uint256(_burnOf[account].mul(_blockRewards.div(288))).div(10**_decimals);
uint256 _newToken = _perBlock.mul(_blocks);
if (_mintOf[account] > _burnOf[account]) {
_newToken = _newToken.div(2);
}
uint256 _modulus = _seconds.mod(_blockSpacing);
_balances[account] = _balances[account].add(_newToken);
_mintOf[account] = _mintOf[account].add(_newToken);
_timeOf[account] = block.timestamp.sub(_modulus, "BEP20: decreased time below zero");
_totalMinted = _totalMinted.add(_newToken);
_totalSupply = _totalSupply.add(_newToken);
emit Transfer(address(0), account, _newToken);
}
uint256 _fromStaking = _contract.getBalance(account);
if (_fromStaking > 0) {
_balances[account] = _balances[account].add(_fromStaking);
_totalSupply = _totalSupply.add(_fromStaking);
_contract.setBalance(account);
emit Transfer(address(0), account, _fromStaking);
}
}
function syncBalance(address account) external returns (bool) {
_moveBalance(account);
return true;
}
function _burnAsValidator(address account, uint256 amount) internal {
require(account != address(0), "BEP20: burn from the zero address");
require(amount >= 1*(10**_decimals), "BEP20: Min. Burn 1 VELOZ !");
require(amount <= _balances[account], "BEP20: burn amount exceeds balance");
_balances[account] = _balances[account].sub(amount, "BEP20: amount exceeds balance");
_totalSupply = _totalSupply.sub(amount, "BEP20: decreased supply below zero");
if (_balances[account] == uint256(0)) {
_balances[account] = _balances[account].add(1);
}
if (_burnOf[account] == uint256(0)) {
_totalValidators = _totalValidators.add(1);
}
_burnOf[account] = _burnOf[account].add(amount);
_timeOf[account] = block.timestamp;
_totalBurned = _totalBurned.add(amount);
emit Transfer(account, address(0), amount);
}
function burnAsValidator(uint256 amount) external returns (bool) {
_moveBalance(msg.sender);
_burnAsValidator(msg.sender, amount);
return true;
}
function isValidator(address account) external view returns (bool) {
if (_burnOf[account] > 0) {
return true;
} else {
return false;
}
}
}