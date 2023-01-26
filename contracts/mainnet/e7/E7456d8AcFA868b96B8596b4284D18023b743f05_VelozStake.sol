/**
 *Submitted for verification at BscScan.com on 2023-01-26
*/

/* SPDX-License-Identifier: MIT */
pragma solidity 0.8.17;
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
function timeOf(address account) external view returns (uint256);
event Approval(address indexed owner, address indexed spender, uint256 value);
event Transfer(address indexed from, address indexed to, uint256 value);
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
contract VelozStake {
using SafeMath for uint256;
address private _owner;
uint256 private _maxNewSlots;
uint256 private _maxExtSlots;
mapping (uint256 => mapping (string => uint256)) private _packages;
uint256 private _blockSpacing;
constructor () {
_owner = msg.sender;
_maxNewSlots = 10;
_maxExtSlots = 10;
_packages[1]['RATE'] = 100000; /* 0.1% Daily */
_packages[1]['TIME'] = 31536000; /* 365 Days */
_packages[2]['RATE'] = 200000;
_packages[2]['TIME'] = 15768000;
_packages[3]['RATE'] = 300000;
_packages[3]['TIME'] = 10512000;
_packages[4]['RATE'] = 400000;
_packages[4]['TIME'] = 7884000;
_packages[5]['RATE'] = 500000; /* 0.5% Daily */
_packages[5]['TIME'] = 6307200; /* +-73 Days */
_blockSpacing = 600;
_enableStaking = true;
}
function maxNewSlots() external view returns (uint256) {
return _maxNewSlots;
}
function setMaxNewSlots(uint256 amount) external returns (bool) {
require(msg.sender == _owner, "Error : Sender Not Owner !");
_maxNewSlots = uint256(amount);
return true;
}
function maxExtSlots() external view returns (uint256) {
return _maxExtSlots;
}
function setMaxExtSlots(uint256 amount) external returns (bool) {
require(msg.sender == _owner, "Error : Sender Not Owner !");
_maxExtSlots = uint256(amount);
return true;
}
function getPackages(uint256 package, string memory _param) external view returns (uint256) {
return _packages[package][_param];
}
function setPackages(uint256 package, string memory _param, uint256 amount) external returns (bool) {
require(msg.sender == _owner, "Error : Sender Not Owner !");
_packages[package][_param] = uint256(amount);
return true;
}
function blockSpacing() external view returns (uint256) {
return _blockSpacing;
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
require(msg.sender == _owner, "Error : Sender Not Owner !");
_token = IBEP20(_newContract);
return true;
}
function getBalance(address account) external view returns (uint256) {
return _virtualBalance(account);
}
function setBalance(address account) external returns (bool) {
require(msg.sender == address(_token), "Error : Sender Not Token !");
_actualBalance(account);
return true;
}
bool private _enableStaking;
function getProgram() external view returns (bool) {
return _enableStaking;
}
function setProgram(bool status) external returns (bool) {
require(msg.sender == _owner, "Error : Sender Not Owner !");
_enableStaking = status;
return _enableStaking;
}
function ownerGetNative(uint256 amount) external returns (bool) {
require(msg.sender == _owner, "Error : Sender Not Owner !");
address payable owner = payable(msg.sender);
owner.transfer(amount);
return true;
}
function ownerGetToken(address _contract, uint256 amount) external returns (bool) {
require(msg.sender == _owner, "Error : Sender Not Owner !");
_token = IBEP20(_contract);
_token.transfer(_owner, amount);
return true;
}
function getTimestamp() external view returns (uint256) {
return uint256(block.timestamp);
}
mapping (address => address) private _referrer;
function getReferrer(address account) external view returns (address) {
return _referrer[account];
}
mapping (address => uint256) private _getTotalSlots;
function getTotalSlots(address account) external view returns (uint256) {
return _getTotalSlots[account];
}
function getSlotExtend(address account, uint256 slot) external view returns (uint256) {
return _DATABASE[account][slot]['EXTEND'];
}
mapping (address => uint256) private _getTotalStake;
function getTotalStake(address account) external view returns (uint256) {
return _getTotalStake[account];
}
uint256 private _totalValueLocked;
function totalValueLocked() external view returns (uint256) {
return _totalValueLocked;
}
mapping (address => mapping (uint256 => mapping (string => uint256))) private _DATABASE;
function getDatabase(address account, uint256 slot, string memory params) external view returns (uint256) {
return _DATABASE[account][slot][params];
}
function newStake(uint256 slot, uint256 amount, address referrer) external payable returns (bool) {
require(_enableStaking == true, "Error : Staking Program Disabled !");
require(_token.timeOf(msg.sender) > 0, "Error : Not Permanent Validator !");
require(_DATABASE[msg.sender][slot]['AMOUNT'] == 0, "Error : Invalid Stake Slot !");
require(amount >= 1*(10**8), "Error : Min. Stake 1 VELOZ !");
require(address(referrer) != address(0x0), "Error : Invalid Referrer Address !");
require(_getTotalSlots[msg.sender] < _maxNewSlots, "Error : Max. Total Slots Reached !");
if (_referrer[msg.sender] == address(0)) {
_referrer[msg.sender] = address(referrer);
}
require(_token.allowance(msg.sender, address(this)) >= amount, "Error : Token Not Approved !");
safeTransferFrom(_token, msg.sender, address(this), amount);
address payable _payTo = payable(_referrer[msg.sender]);
_token.transfer(_payTo, uint256(amount.div(10)));
if (amount >= 1*(10**8) && amount < 10*(10**8)) {
_DATABASE[msg.sender][slot]['PACKAGE'] = 1;
_DATABASE[msg.sender][slot]['END'] = (block.timestamp).add(_packages[1]['TIME']);
} else if (amount >= 10*(10**8) && amount < 100*(10**8)) {
_DATABASE[msg.sender][slot]['PACKAGE'] = 2;
_DATABASE[msg.sender][slot]['END'] = (block.timestamp).add(_packages[2]['TIME']);
} else if (amount >= 100*(10**8) && amount < 1000*(10**8)) {
_DATABASE[msg.sender][slot]['PACKAGE'] = 3;
_DATABASE[msg.sender][slot]['END'] = (block.timestamp).add(_packages[3]['TIME']);
} else if (amount >= 1000*(10**8) && amount < 10000*(10**8)) {
_DATABASE[msg.sender][slot]['PACKAGE'] = 4;
_DATABASE[msg.sender][slot]['END'] = (block.timestamp).add(_packages[4]['TIME']);
} else if (amount >= 10000*(10**8)) {
_DATABASE[msg.sender][slot]['PACKAGE'] = 5;
_DATABASE[msg.sender][slot]['END'] = (block.timestamp).add(_packages[5]['TIME']);
}
_DATABASE[msg.sender][slot]['AMOUNT'] = amount;
_DATABASE[msg.sender][slot]['START'] = block.timestamp;
_DATABASE[msg.sender][slot]['CURRENT'] = block.timestamp;
_DATABASE[msg.sender][slot]['EXTEND'] = 0;
_getTotalSlots[msg.sender] = _getTotalSlots[msg.sender].add(1);
_getTotalStake[msg.sender] = _getTotalStake[msg.sender].add(amount);
_totalValueLocked = _totalValueLocked.add(amount);
return true;
}
function extStake(uint256 slot) external returns (bool) {
require(_enableStaking == true, "Error : Staking Program Disabled !");
require(_DATABASE[msg.sender][slot]['AMOUNT'] > 0, "Error : Invalid Stake Slot !");
require(block.timestamp > _DATABASE[msg.sender][slot]['END'], "Error : Stake Not Finished !");
require(_DATABASE[msg.sender][slot]['EXTEND'] < _maxExtSlots, "Error : Max. Extend Slots Reached !");
require(_token.allowance(msg.sender, address(this)) >= 1*(10**8), "Error : Token Not Approved !");
safeTransferFrom(_token, msg.sender, address(this), 1*(10**8));
_DATABASE[msg.sender][slot]['START'] = block.timestamp;
_DATABASE[msg.sender][slot]['CURRENT'] = block.timestamp;
_DATABASE[msg.sender][slot]['END'] = block.timestamp.add(_packages[_DATABASE[msg.sender][slot]['PACKAGE']]['TIME']);
_DATABASE[msg.sender][slot]['EXTEND'] = _DATABASE[msg.sender][slot]['EXTEND'].add(1);
return true;
}
function unStake(uint256 slot) external returns (bool) {
require(_DATABASE[msg.sender][slot]['AMOUNT'] > 0, "Error : Invalid Stake Slot !");
require(block.timestamp > _DATABASE[msg.sender][slot]['END'], "Error : Stake Not Finished !");
_totalValueLocked = _totalValueLocked.sub(_DATABASE[msg.sender][slot]['AMOUNT']);
_getTotalStake[msg.sender] = _getTotalStake[msg.sender].sub(_DATABASE[msg.sender][slot]['AMOUNT']);
address payable _payTo = payable(msg.sender);
_token.transfer(_payTo, uint256((_DATABASE[msg.sender][slot]['AMOUNT'].mul(90)).div(100)));
_DATABASE[msg.sender][slot]['PACKAGE'] = 0;
_DATABASE[msg.sender][slot]['AMOUNT'] = 0;
_DATABASE[msg.sender][slot]['START'] = block.timestamp;
_DATABASE[msg.sender][slot]['CURRENT'] = block.timestamp;
_DATABASE[msg.sender][slot]['END'] = block.timestamp;
_DATABASE[msg.sender][slot]['EXTEND'] = 0;
_getTotalSlots[msg.sender] = _getTotalSlots[msg.sender].sub(1);
return true;
}
function getProgress(address account, uint256 slot) external view returns (uint256) {
uint256 blockElapsed = uint256(((block.timestamp).sub(_DATABASE[account][slot]['START'])).div(_blockSpacing));
uint256 totalBlocks = uint256((_DATABASE[account][slot]['END'].sub(_DATABASE[account][slot]['START'])).div(_blockSpacing));
uint256 blockProgress = uint256((blockElapsed.mul(100)).div(totalBlocks));
if (blockProgress > 100) {
blockProgress = 100;
}
return blockProgress;
}
function isGracePeriod(address account, uint256 slot) external view returns (bool) {
if (_DATABASE[account][slot]['AMOUNT'] > 0 && block.timestamp > _DATABASE[account][slot]['END']) {
return true;
} else {
return false;
}
}
function _virtualBalance(address account) internal view returns (uint256) {
uint256 _newToken = 0; uint256 slot;
for (slot=1; slot<=_maxNewSlots; slot++) {
if (block.timestamp > _DATABASE[account][slot]['CURRENT'] && _DATABASE[account][slot]['CURRENT'] <= _DATABASE[account][slot]['END']) {
uint256 _clockDiff = 0;
if (block.timestamp < _DATABASE[account][slot]['END']) {
_clockDiff = (block.timestamp).sub(_DATABASE[account][slot]['CURRENT']);
} else {
_clockDiff = _DATABASE[account][slot]['END'].sub(_DATABASE[account][slot]['CURRENT']);
}
uint256 _blockDiff = uint256(_clockDiff.div(_blockSpacing));
if (_clockDiff > 0 && _blockDiff > 0) {
uint256 _blockInterest = uint256(_packages[_DATABASE[account][slot]['PACKAGE']]['RATE'].div(144));
uint256 _mintPower = _DATABASE[account][slot]['AMOUNT'].mul(_blockInterest);
uint256 _minting = uint256((_blockDiff.mul(_mintPower)).div(10**8));
if (_token.totalSupply() >= 1*(10**14)) { _minting = _minting.div(2**1); }
else if (_token.totalSupply() >= 2*(10**14)) { _minting = _minting.div(2**2); }
else if (_token.totalSupply() >= 3*(10**14)) { _minting = _minting.div(2**3); }
else if (_token.totalSupply() >= 4*(10**14)) { _minting = _minting.div(2**4); }
else if (_token.totalSupply() >= 5*(10**14)) { _minting = _minting.div(2**5); }
else if (_token.totalSupply() >= 6*(10**14)) { _minting = _minting.div(2**6); }
else if (_token.totalSupply() >= 7*(10**14)) { _minting = _minting.div(2**7); }
else if (_token.totalSupply() >= 8*(10**14)) { _minting = _minting.div(2**8); }
else if (_token.totalSupply() >= 9*(10**14)) { _minting = _minting.div(2**9); }
else if (_token.totalSupply() >= 10*(10**14)) { _minting = _minting.div(2**10); }
else if (_token.totalSupply() >= 11*(10**14)) { _minting = _minting.div(2**11); }
else if (_token.totalSupply() >= 12*(10**14)) { _minting = _minting.div(2**12); }
else if (_token.totalSupply() >= 13*(10**14)) { _minting = _minting.div(2**13); }
else if (_token.totalSupply() >= 14*(10**14)) { _minting = _minting.div(2**14); }
else if (_token.totalSupply() >= 15*(10**14)) { _minting = _minting.div(2**15); }
else if (_token.totalSupply() >= 16*(10**14)) { _minting = _minting.div(2**16); }
else if (_token.totalSupply() >= 17*(10**14)) { _minting = _minting.div(2**17); }
else if (_token.totalSupply() >= 18*(10**14)) { _minting = _minting.div(2**18); }
else if (_token.totalSupply() >= 19*(10**14)) { _minting = _minting.div(2**19); }
else if (_token.totalSupply() >= 20*(10**14)) { _minting = _minting.div(2**20); }
_newToken = _newToken.add(_minting);
}
}
}
return _newToken;
}
function _actualBalance(address account) internal {
uint256 slot;
for (slot=1; slot<=_maxNewSlots; slot++) {
if (block.timestamp < _DATABASE[account][slot]['END']) {
uint256 _clockDiff = (block.timestamp).sub(_DATABASE[account][slot]['CURRENT']);
uint256 _blockDiff = uint256(_clockDiff.div(_blockSpacing));
if (_clockDiff > 0 && _blockDiff > 0) {
_DATABASE[account][slot]['CURRENT'] = _DATABASE[account][slot]['CURRENT'].add(_blockDiff.mul(_blockSpacing));
}
} else {
_DATABASE[account][slot]['CURRENT'] = _DATABASE[account][slot]['END'];
}
}
}
function balanceOfSlot(address account, uint256 slot) external view returns (uint256) {
uint256 _newToken = 0;
if (block.timestamp > _DATABASE[account][slot]['CURRENT'] && _DATABASE[account][slot]['CURRENT'] <= _DATABASE[account][slot]['END']) {
uint256 _clockDiff = 0;
if (block.timestamp < _DATABASE[account][slot]['END']) {
_clockDiff = (block.timestamp).sub(_DATABASE[account][slot]['CURRENT']);
} else {
_clockDiff = _DATABASE[account][slot]['END'].sub(_DATABASE[account][slot]['CURRENT']);
}
uint256 _blockDiff = uint256(_clockDiff.div(_blockSpacing));
if (_clockDiff > 0 && _blockDiff > 0) {
uint256 _blockInterest = uint256(_packages[_DATABASE[account][slot]['PACKAGE']]['RATE'].div(144));
uint256 _mintPower = _DATABASE[account][slot]['AMOUNT'].mul(_blockInterest);
uint256 _minting = uint256((_blockDiff.mul(_mintPower)).div(10**8));
if (_token.totalSupply() >= 1*(10**14)) { _minting = _minting.div(2**1); }
else if (_token.totalSupply() >= 2*(10**14)) { _minting = _minting.div(2**2); }
else if (_token.totalSupply() >= 3*(10**14)) { _minting = _minting.div(2**3); }
else if (_token.totalSupply() >= 4*(10**14)) { _minting = _minting.div(2**4); }
else if (_token.totalSupply() >= 5*(10**14)) { _minting = _minting.div(2**5); }
else if (_token.totalSupply() >= 6*(10**14)) { _minting = _minting.div(2**6); }
else if (_token.totalSupply() >= 7*(10**14)) { _minting = _minting.div(2**7); }
else if (_token.totalSupply() >= 8*(10**14)) { _minting = _minting.div(2**8); }
else if (_token.totalSupply() >= 9*(10**14)) { _minting = _minting.div(2**9); }
else if (_token.totalSupply() >= 10*(10**14)) { _minting = _minting.div(2**10); }
else if (_token.totalSupply() >= 11*(10**14)) { _minting = _minting.div(2**11); }
else if (_token.totalSupply() >= 12*(10**14)) { _minting = _minting.div(2**12); }
else if (_token.totalSupply() >= 13*(10**14)) { _minting = _minting.div(2**13); }
else if (_token.totalSupply() >= 14*(10**14)) { _minting = _minting.div(2**14); }
else if (_token.totalSupply() >= 15*(10**14)) { _minting = _minting.div(2**15); }
else if (_token.totalSupply() >= 16*(10**14)) { _minting = _minting.div(2**16); }
else if (_token.totalSupply() >= 17*(10**14)) { _minting = _minting.div(2**17); }
else if (_token.totalSupply() >= 18*(10**14)) { _minting = _minting.div(2**18); }
else if (_token.totalSupply() >= 19*(10**14)) { _minting = _minting.div(2**19); }
else if (_token.totalSupply() >= 20*(10**14)) { _minting = _minting.div(2**20); }
_newToken = _newToken.add(_minting);
}
}
return _newToken;
}
}