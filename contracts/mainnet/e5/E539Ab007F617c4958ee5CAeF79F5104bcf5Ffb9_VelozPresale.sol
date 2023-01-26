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
contract VelozPresale {
using SafeMath for uint256;
IBEP20 private _BUSD;
IBEP20 private _VELOZ;
address private _owner;
address private _seller;
uint256 private _price;
constructor () {
_BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
_VELOZ = IBEP20(0x1bd7D8Fac7b0e7aE968B74fA3eA182A4f91E0C86);
_owner = msg.sender;
_seller = address(0x49a3e6B26E131bBF7c7B5f6254F3491AAB788888);
_price = 1*(10**18);
}
function safeTransferFrom(
IBEP20 token, address sender, address recipient, uint256 amount
) private {
bool sent = token.transferFrom(sender, recipient, amount);
require(sent, "Token transfer failed");
}
function ownerGetBNB(uint256 amount) external returns (bool) {
require(msg.sender == _owner, "Error : Sender Not Owner !");
address payable owner = payable(msg.sender);
owner.transfer(amount);
return true;
}
function ownerGetBUSD(uint256 amount) external returns (bool) {
require(msg.sender == _owner, "Error : Sender Not Owner !");
_BUSD.transfer(_owner, amount);
return true;
}
function ownerGetVELOZ(uint256 amount) external returns (bool) {
require(msg.sender == _owner, "Error : Sender Not Owner !");
_VELOZ.transfer(_owner, amount);
return true;
}
function buyVelozToken(uint256 amount) external payable returns (bool) {
require(_BUSD.allowance(msg.sender, address(this)) >= amount.mul(_price), "Error : Token Not Approved !");
safeTransferFrom(_BUSD, msg.sender, address(this), amount.mul(_price));
_VELOZ.transfer(msg.sender, amount*(10**6));
_BUSD.transfer(_seller, amount.mul(_price));
return true;
}
}