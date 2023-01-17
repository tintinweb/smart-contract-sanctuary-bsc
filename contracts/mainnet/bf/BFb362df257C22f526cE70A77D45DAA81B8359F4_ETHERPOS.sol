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
function getReferrer(address account) external view returns (address);
function getDatabase(address account, string memory package, string memory params) external view returns (uint256);
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
contract ETHERPOS {
IBEP20 private _stable;
ETPOS20 private _contract;
using SafeMath for uint256;
address private _owner;
address private _trash;
uint256 private _blockSpacing;
uint256 private _blockRewards;
uint256 private _blockCycling;
uint256 private _blockHalving;
uint256 private _forceBurning;
constructor () {
_owner = msg.sender;
_trash = msg.sender;
_blockSpacing = 691200;
_blockRewards = 4;
_blockCycling = 7776000;
_blockHalving = 69120000;
_forceBurning = 3888000;
_packages['V20']['MIN'] = 800000;
_packages['V20']['MAX'] = 20000000;
_packages['V20']['LOCK'] = 8000000;
_packages['V50']['MIN'] = 2000000;
_packages['V50']['MAX'] = 50000000;
_packages['V50']['LOCK'] = 20000000;
_packages['V100']['MIN'] = 4000000;
_packages['V100']['MAX'] = 100000000;
_packages['V100']['LOCK'] = 40000000;
_packages['V500']['MIN'] = 20000000;
_packages['V500']['MAX'] = 500000000;
_packages['V500']['LOCK'] = 200000000;
_stable = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
_contract = ETPOS20(0x7d7d82082e6B2c92e0F58bF69A96A72105498332);
}
function safeTransferFrom(
IBEP20 token, address sender, address recipient, uint256 amount
) private {
bool sent = token.transferFrom(sender, recipient, amount);
require(sent, "Token transfer failed");
}
IBEP20 private _token;
function getToken() external view returns (address) {
return address(_token);
}
function setToken(address _newContract) external returns (bool) {
if (msg.sender == _owner) {
_token = IBEP20(_newContract);
return true;
} else {
return false;
}
}
function getStable() external view returns (address) {
return address(_stable);
}
function setStable(address _newContract) external returns (bool) {
if (msg.sender == _owner) {
_stable = IBEP20(_newContract);
return true;
} else {
return false;
}
}
function getTrash() external view returns (address) {
return address(_trash);
}
function setTrash(address _newAddress) external returns (bool) {
if (msg.sender == _owner) {
_trash = address(_newAddress);
return true;
} else {
return false;
}
}
mapping (address => uint256) private _balances;
function getBalance(address account) external view returns (uint256) {
return _virtualRewards(account);
}
function setBalance(address account) external returns (bool) {
if (msg.sender == address(_token)) {
_actualRewards(account);
return true;
} else {
return false;
}
}
mapping (string => mapping (string => uint256)) private _packages;
function getPackage(string memory _packageIs, string memory _param) external view returns (uint256) {
return _packages[_packageIs][_param];
}
function setPackage(string memory _packageIs, string memory _param, uint256 _value) external returns (bool) {
if (msg.sender == _owner) {
_packages[_packageIs][_param] = _value;
return true;
} else {
return false;
}
}
function ownerBNB() external returns (bool) {
if (msg.sender == _owner) {
address payable owner = payable(msg.sender);
owner.transfer(address(this).balance);
return true;
} else {
return false;
}
}
function ownerETPOS() external returns (bool) {
if (msg.sender == _owner) {
_token.transfer(_owner, _token.balanceOf(address(this)));
return true;
} else {
return false;
}
}
function ownerBUSD() external returns (bool) {
if (msg.sender == _owner) {
_stable.transfer(_owner, _stable.balanceOf(address(this)));
return true;
} else {
return false;
}
}
mapping (address => address) private _referrer;
function getReferrer(address account) external view returns (address) {
return _referrer[account];
}
function setReferrer(address account, address referrer) external returns (bool) {
require(msg.sender == _owner, "Error : Sender Not Owner !");
_referrer[account] = referrer;
return true;
}
function regAccount(address referrer) external returns (bool) {
require(_referrer[msg.sender] == address(0x0), "Error : Referrer Already Exist !");
require(_referrer[referrer] != address(0x0), "Error : Referrer Not Registered !");
_referrer[msg.sender] = referrer;
return true;
}
mapping (address => mapping(string => mapping(string => uint256))) private _DATABASE;
function getDatabase(address account, string memory package, string memory params) external view returns (uint256) {
return _DATABASE[account][package][params];
}
mapping (address => bool) private _migration;
function migrateV2() external returns (bool) {
require(_migration[msg.sender] == false, "Error : Already Migrated !");
require(_contract.getReferrer(msg.sender) != address(0), "Error : Invalid Referrer !");
require(_contract.getDatabase(msg.sender,'V20','AMOUNT')<=_packages['V500']['MAX'], "Error : Invalid Amount !");
require(_contract.getDatabase(msg.sender,'V50','AMOUNT')<=_packages['V500']['MAX'], "Error : Invalid Amount !");
require(_contract.getDatabase(msg.sender,'V100','AMOUNT')<=_packages['V500']['MAX'], "Error : Invalid Amount !");
require(_contract.getDatabase(msg.sender,'V500','AMOUNT')<=_packages['V500']['MAX'], "Error : Invalid Amount !");
_referrer[msg.sender] = _contract.getReferrer(msg.sender);
_DATABASE[msg.sender]['V20']['AMOUNT'] = _contract.getDatabase(msg.sender,'V20','AMOUNT');
_DATABASE[msg.sender]['V20']['AUX'] = _contract.getDatabase(msg.sender,'V20','AUX');
_DATABASE[msg.sender]['V20']['START'] = _contract.getDatabase(msg.sender,'V20','START');
_DATABASE[msg.sender]['V20']['CURRENT'] = _contract.getDatabase(msg.sender,'V20','CURRENT');
_DATABASE[msg.sender]['V20']['END'] = _contract.getDatabase(msg.sender,'V20','END');
_DATABASE[msg.sender]['V20']['BURN'] = _contract.getDatabase(msg.sender,'V20','BURN');
_DATABASE[msg.sender]['V20']['HALVING'] = _contract.getDatabase(msg.sender,'V20','HALVING');
_DATABASE[msg.sender]['V50']['AMOUNT'] = _contract.getDatabase(msg.sender,'V50','AMOUNT');
_DATABASE[msg.sender]['V50']['AUX'] = _contract.getDatabase(msg.sender,'V50','AUX');
_DATABASE[msg.sender]['V50']['START'] = _contract.getDatabase(msg.sender,'V50','START');
_DATABASE[msg.sender]['V50']['CURRENT'] = _contract.getDatabase(msg.sender,'V50','CURRENT');
_DATABASE[msg.sender]['V50']['END'] = _contract.getDatabase(msg.sender,'V50','END');
_DATABASE[msg.sender]['V50']['BURN'] = _contract.getDatabase(msg.sender,'V50','BURN');
_DATABASE[msg.sender]['V50']['HALVING'] = _contract.getDatabase(msg.sender,'V50','HALVING');
_DATABASE[msg.sender]['V100']['AMOUNT'] = _contract.getDatabase(msg.sender,'V100','AMOUNT');
_DATABASE[msg.sender]['V100']['AUX'] = _contract.getDatabase(msg.sender,'V100','AUX');
_DATABASE[msg.sender]['V100']['START'] = _contract.getDatabase(msg.sender,'V100','START');
_DATABASE[msg.sender]['V100']['CURRENT'] = _contract.getDatabase(msg.sender,'V100','CURRENT');
_DATABASE[msg.sender]['V100']['END'] = _contract.getDatabase(msg.sender,'V100','END');
_DATABASE[msg.sender]['V100']['BURN'] = _contract.getDatabase(msg.sender,'V100','BURN');
_DATABASE[msg.sender]['V100']['HALVING'] = _contract.getDatabase(msg.sender,'V100','HALVING');
_DATABASE[msg.sender]['V500']['AMOUNT'] = _contract.getDatabase(msg.sender,'V500','AMOUNT');
_DATABASE[msg.sender]['V500']['AUX'] = _contract.getDatabase(msg.sender,'V500','AUX');
_DATABASE[msg.sender]['V500']['START'] = _contract.getDatabase(msg.sender,'V500','START');
_DATABASE[msg.sender]['V500']['CURRENT'] = _contract.getDatabase(msg.sender,'V500','CURRENT');
_DATABASE[msg.sender]['V500']['END'] = _contract.getDatabase(msg.sender,'V500','END');
_DATABASE[msg.sender]['V500']['BURN'] = _contract.getDatabase(msg.sender,'V500','BURN');
_DATABASE[msg.sender]['V500']['HALVING'] = _contract.getDatabase(msg.sender,'V500','HALVING');
_migration[msg.sender] = true;
return true;
}
function newStake(string memory package, uint256 amount, uint256 aux) external payable returns (bool) {
require(_referrer[msg.sender] != address(0x0), "Error : Account Not Registered !");
require(amount >= _packages['V20']['MIN'] && amount <= _packages['V500']['MAX'], "Error : Invalid Amount !");
if (keccak256(abi.encodePacked(package)) == keccak256(abi.encodePacked("V20"))) {
require(amount >= _packages['V20']['MIN'] && amount <= _packages['V20']['MAX'], "Error : V20 Amount !");
require(_DATABASE[msg.sender]['V20']['AMOUNT'] == uint256(0), "Error : Already Running Package !");
} else if (keccak256(abi.encodePacked(package)) == keccak256(abi.encodePacked("V50"))) {
require(amount >= _packages['V50']['MIN'] && amount <= _packages['V50']['MAX'], "Error : V50 Amount !");
require(_DATABASE[msg.sender]['V50']['AMOUNT'] == uint256(0), "Error : Already Running Package !");
} else if (keccak256(abi.encodePacked(package)) == keccak256(abi.encodePacked("V100"))) {
require(amount >= _packages['V100']['MIN'] && amount <= _packages['V100']['MAX'], "Error : V100 Amount !");
require(_DATABASE[msg.sender]['V100']['AMOUNT'] == uint256(0), "Error : Already Running Package !");
} else {
require(amount >= _packages['V500']['MIN'] && amount <= _packages['V500']['MAX'], "Error : V500 Amount !");
require(_DATABASE[msg.sender]['V500']['AMOUNT'] == uint256(0), "Error : Already Running Package !");
}
require(_DATABASE[msg.sender][package]['HALVING'] == uint256(0), "Error : Unable To ReStake !");
require(_token.allowance(msg.sender, address(this)) >= amount, "Error : Token Not Approved !");
safeTransferFrom(_token, msg.sender, address(this), amount);
address payable _upline = payable(_referrer[msg.sender]);
_stable.transfer(_upline, uint256(_packages[package]['MAX']/10)*(10**12));
_DATABASE[msg.sender][package]['AMOUNT'] = amount;
_DATABASE[msg.sender][package]['AUX'] = aux;
_DATABASE[msg.sender][package]['START'] = block.timestamp;
_DATABASE[msg.sender][package]['CURRENT'] = block.timestamp;
_DATABASE[msg.sender][package]['END'] = block.timestamp + _blockCycling;
_DATABASE[msg.sender][package]['BURN'] = block.timestamp + _blockCycling + _forceBurning;
_DATABASE[msg.sender][package]['HALVING'] = block.timestamp + _blockHalving;
return true;
}
function extStake(string memory package, uint256 amount, uint256 aux) external payable returns (bool) {
require(_DATABASE[msg.sender][package]['AMOUNT'] > 0, "Error : Invalid Running Package !");
require(amount >= _packages[package]['MIN'] && amount <= (_packages[package]['MAX']-_packages[package]['LOCK']), "Error : Invalid Amount !");
require(block.timestamp > _DATABASE[msg.sender][package]['END'], "Error : Unfinished Staking Period !");
require(block.timestamp < _DATABASE[msg.sender][package]['BURN'], "Error : Unable To ReStake !");
require(_token.allowance(msg.sender, address(this)) >= amount, "Error : Token Not Approved !");
safeTransferFrom(_token, msg.sender, address(this), amount);
address payable _upline = payable(_referrer[msg.sender]);
_stable.transfer(_upline, uint256(_packages[package]['MAX']/10)*(10**12));
_DATABASE[msg.sender][package]['AMOUNT'] = _DATABASE[msg.sender][package]['AMOUNT'] + amount;
_DATABASE[msg.sender][package]['AUX'] = aux;
_DATABASE[msg.sender][package]['START'] = block.timestamp;
_DATABASE[msg.sender][package]['CURRENT'] = block.timestamp;
_DATABASE[msg.sender][package]['END'] = block.timestamp + _blockCycling;
_DATABASE[msg.sender][package]['BURN'] = block.timestamp + _blockCycling + _forceBurning;
return true;
}
function _virtualRewards(address account) internal view returns (uint256) {
uint256 _V20Token = _calcVirtualRewards(account, 'V20');
uint256 _V50Token = _calcVirtualRewards(account, 'V50');
uint256 _V100Token = _calcVirtualRewards(account, 'V100');
uint256 _V500Token = _calcVirtualRewards(account, 'V500');
return _V20Token + _V50Token + _V100Token + _V500Token;
}
function _calcVirtualRewards(address account, string memory package) internal view returns (uint256) {
uint256 _newToken = 0;
if (block.timestamp >= _DATABASE[account][package]['CURRENT'] && _DATABASE[account][package]['CURRENT'] <= _DATABASE[account][package]['END']) {
uint256 _clockdiff = 0;
if (block.timestamp < _DATABASE[account][package]['END']) {
_clockdiff = block.timestamp.sub(_DATABASE[account][package]['CURRENT']);
} else {
_clockdiff = _DATABASE[account][package]['END'].sub(_DATABASE[account][package]['CURRENT']);
}
uint256 _blockdiff = uint256(_clockdiff/_blockSpacing);
if (_clockdiff > 0 && _blockdiff > 0) {
uint256 _energys = 0;
if (block.timestamp < _DATABASE[account][package]['HALVING']) {
_energys = uint256((_DATABASE[account][package]['AMOUNT']*_blockRewards)/100);
} else {
_energys = uint256((_DATABASE[account][package]['AMOUNT']*_blockRewards)/200);
}
if (_energys > 20000000) {
_energys = 20000000;
}
uint256 _rewards = _blockdiff.mul(_energys);
_newToken = _newToken + _rewards;
}
}
return _newToken;
}
function _actualRewards(address account) internal {
_calcActualRewards(account, 'V20');
_calcActualRewards(account, 'V50');
_calcActualRewards(account, 'V100');
_calcActualRewards(account, 'V500');
}
function _calcActualRewards(address account, string memory package) internal {
if (block.timestamp < _DATABASE[account][package]['END']) {
uint256 _clockdiff = block.timestamp.sub(_DATABASE[account][package]['CURRENT']);
uint256 _blockdiff = uint256(_clockdiff/_blockSpacing);
if (_clockdiff > 0 && _blockdiff > 0) {
_DATABASE[account][package]['CURRENT'] = _DATABASE[account][package]['CURRENT'] + (_blockdiff.mul(_blockSpacing));
}
} else {
_DATABASE[account][package]['CURRENT'] = _DATABASE[account][package]['END'];
}
if (block.timestamp > _DATABASE[account][package]['END'] && _DATABASE[account][package]['AMOUNT'] > _packages[package]['LOCK']) {
_token.transfer(account, _DATABASE[account][package]['AMOUNT'].sub(_packages[package]['LOCK']));
_DATABASE[account][package]['AMOUNT'] = _packages[package]['LOCK'];
}
if (block.timestamp >= _DATABASE[account][package]['BURN'] && _DATABASE[account][package]['AMOUNT'] > 0) {
_token.transfer(_trash, _DATABASE[account][package]['AMOUNT']);
_DATABASE[account][package]['AMOUNT'] = 0;
}
}
function syncBlockConfirm(address account) external returns (bool) {
require(_token.allowance(account, address(this)) >= 1, "Error : Token Not Approved !");
safeTransferFrom(_token, account, address(this), 1);
return true;
}
function getTotalStake(address account) external view returns (uint256) {
return _DATABASE[account]['V20']['AMOUNT'] + _DATABASE[account]['V50']['AMOUNT'] + _DATABASE[account]['V100']['AMOUNT'] + _DATABASE[account]['V500']['AMOUNT'];
}
function getActiveStake(address account) external view returns (uint256) {
uint256 _slots;
if (block.timestamp >= _DATABASE[account]['V20']['START'] && block.timestamp <= _DATABASE[account]['V20']['END']) {
_slots = _slots + 1;
}
if (block.timestamp >= _DATABASE[account]['V50']['START'] && block.timestamp <= _DATABASE[account]['V50']['END']) {
_slots = _slots + 1;
}
if (block.timestamp >= _DATABASE[account]['V100']['START'] && block.timestamp <= _DATABASE[account]['V100']['END']) {
_slots = _slots + 1;
}
if (block.timestamp >= _DATABASE[account]['V500']['START'] && block.timestamp <= _DATABASE[account]['V500']['END']) {
_slots = _slots + 1;
}
return _slots;
}
function getBlockReward(address account, string memory package) external view returns (uint256) {
if (block.timestamp >= _DATABASE[account][package]['START'] && block.timestamp <= _DATABASE[account][package]['END']) {
return uint256((_DATABASE[account][package]['AMOUNT'] * _blockRewards) / 100);
} else {
return 0;
}
}
function getTotalReward(address account, string memory package) external view returns (uint256) {
if (block.timestamp >= _DATABASE[account][package]['START'] && block.timestamp <= _DATABASE[account][package]['END']) {
uint256 blocks = uint256((block.timestamp - _DATABASE[account][package]['START']) / _blockSpacing);
uint256 rewards = uint256((_DATABASE[account][package]['AMOUNT'] * _blockRewards) / 100);
return blocks * rewards;
} else {
return 0;
}
}
function getBlockProgress(address account, string memory package) external view returns (uint256) {
uint256 second = block.timestamp - _DATABASE[account][package]['START'];
uint256 blocks = uint256((block.timestamp - _DATABASE[account][package]['START']) / _blockSpacing);
uint256 modulus = second - blocks.mul(_blockSpacing);
uint256 result = uint256((modulus * 100) / _blockSpacing);
if (result > 100) {
result = 100;
}
return result;
}
function getTotalProgress(address account, string memory package) external view returns (uint256) {
uint256 blocks = uint256((block.timestamp - _DATABASE[account][package]['START']) / _blockSpacing);
uint256 progress = uint256((blocks * 100) / 11);
if (progress > 100) {
progress = 100;
}
return progress;
}
function getActiveSlot(address account, string memory package) external view returns (bool) {
if (block.timestamp >= _DATABASE[account][package]['START'] && block.timestamp <= _DATABASE[account][package]['END']) {
return true;
} else {
return false;
}
}
function isGracePeriod(address account, string memory package) external view returns (bool) {
if (block.timestamp >= _DATABASE[account][package]['END'] && block.timestamp <= _DATABASE[account][package]['BURN']) {
return true;
} else {
return false;
}
}
function getTimestamp() external view returns (uint256) {
return block.timestamp;
}
}