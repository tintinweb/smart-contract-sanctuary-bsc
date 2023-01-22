/**
 *Submitted for verification at BscScan.com on 2023-01-22
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
contract ETHERP2P {
using SafeMath for uint256;
address private _owner;
IBEP20 private _ETPOS;
IBEP20 private _BUSD;
constructor () {
_owner = msg.sender;
_ETPOS = IBEP20(0xdE7B72c2c2828A81bEe8D7FA86c7FC22B58A713d);
_BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
}
function safeTransferFrom(
IBEP20 token, address sender, address recipient, uint256 amount
) private {
bool sent = token.transferFrom(sender, recipient, amount);
require(sent, "Token transfer failed");
}
uint256 private _lastPrice;
function getLastPrice() external view returns (uint256) {
return _lastPrice;
}
uint256 private _buyPrice;
function getBuyPrice() external view returns (uint256) {
return _buyPrice;
}
uint256 private _sellPrice;
function getSellPrice() external view returns (uint256) {
return _sellPrice;
}
mapping(uint256 => address) private _orderIdToOwner;
function getIdToOwner(uint256 orderID) external view returns (address) {
return _orderIdToOwner[orderID];
}
mapping(uint256 => string) private _orderIdToType;
function getIdToType(uint256 orderID) external view returns (string memory) {
return _orderIdToType[orderID];
}
mapping(uint256 => mapping(string => uint256)) private _orderIdToDetail;
function getIdToDetail(uint256 orderID, string memory params) external view returns (uint256) {
return _orderIdToDetail[orderID][params];
}
function buyMaker(uint256 orderID, uint256 price, uint256 amount) external returns (bool) {
require(_orderIdToOwner[orderID] == address(0), "Error : Invalid Order ID !");
require(price > 0, "Error : Invalid Price !");
require(amount > 0, "Error : Invalid Amount !");
require(_BUSD.allowance(msg.sender, address(this)) >= (price.mul(amount)).div(100), "Error : BUSD Not Approved !");
safeTransferFrom(_BUSD, msg.sender, address(this), (price.mul(amount)).div(100));
_orderIdToOwner[orderID] = msg.sender;
_orderIdToType[orderID] = "BUY";
_orderIdToDetail[orderID]['PRICE'] = price;
_orderIdToDetail[orderID]['AMOUNT'] = amount;
_orderIdToDetail[orderID]['TOTAL'] = (price.mul(amount)).div(100);
return true;
}
function cancelBuy(uint256 orderID) external returns (bool) {
require(_orderIdToOwner[orderID] != address(0), "Error : Invalid Order ID !");
require(_orderIdToOwner[orderID] == msg.sender, "Error : Not Your Order ID !");
require(_orderIdToDetail[orderID]['AMOUNT'] > 0, "Error : Invalid Amount !");
require(keccak256(abi.encodePacked(_orderIdToType[orderID])) == keccak256(abi.encodePacked("BUY")), "Error : Invalid Type !");
_BUSD.transfer(_orderIdToOwner[orderID], (_orderIdToDetail[orderID]['PRICE'].mul(_orderIdToDetail[orderID]['AMOUNT'])).div(100));
_orderIdToOwner[orderID] = address(0);
_orderIdToType[orderID] = "";
_orderIdToDetail[orderID]['PRICE'] = 0;
_orderIdToDetail[orderID]['AMOUNT'] = 0;
return true;
}
function sellMaker(uint256 orderID, uint256 price, uint256 amount) external returns (bool) {
require(_orderIdToOwner[orderID] == address(0), "Error : Invalid Order ID !");
require(price > 0, "Error : Invalid Price !");
require(amount > 0, "Error : Invalid Amount !");
require(_ETPOS.allowance(msg.sender, address(this)) >= amount, "Error : ETPOS Not Approved !");
safeTransferFrom(_ETPOS, msg.sender, address(this), amount);
_orderIdToOwner[orderID] = msg.sender;
_orderIdToType[orderID] = "SELL";
_orderIdToDetail[orderID]['PRICE'] = price;
_orderIdToDetail[orderID]['AMOUNT'] = amount;
_orderIdToDetail[orderID]['TOTAL'] = (price.mul(amount)).div(100);
return true;
}
function cancelSell(uint256 orderID) external returns (bool) {
require(_orderIdToOwner[orderID] != address(0), "Error : Invalid Order ID !");
require(_orderIdToOwner[orderID] == msg.sender, "Error : Not Your Order ID !");
require(_orderIdToDetail[orderID]['AMOUNT'] > 0, "Error : Invalid Amount !");
require(keccak256(abi.encodePacked(_orderIdToType[orderID])) == keccak256(abi.encodePacked("SELL")), "Error : Invalid Type !");
_ETPOS.transfer(_orderIdToOwner[orderID], _orderIdToDetail[orderID]['AMOUNT']);
_orderIdToOwner[orderID] = address(0);
_orderIdToType[orderID] = "";
_orderIdToDetail[orderID]['PRICE'] = 0;
_orderIdToDetail[orderID]['AMOUNT'] = 0;
return true;
}
function buyTaker(uint256 orderID) external returns (bool) {
require(_orderIdToOwner[orderID] != address(0), "Error : Invalid Order ID !");
require(_orderIdToOwner[orderID] != msg.sender, "Error : Your Own Order ID !");
require(_orderIdToDetail[orderID]['AMOUNT'] > 0, "Error : Invalid Amount !");
require(keccak256(abi.encodePacked(_orderIdToType[orderID])) == keccak256(abi.encodePacked("SELL")), "Error : Invalid Type !");
require(_BUSD.allowance(msg.sender, address(this)) >= (_orderIdToDetail[orderID]['PRICE'].mul(_orderIdToDetail[orderID]['AMOUNT'])).div(100), "Error : BUSD Not Approved !");
safeTransferFrom(_BUSD, msg.sender, address(this), (_orderIdToDetail[orderID]['PRICE'].mul(_orderIdToDetail[orderID]['AMOUNT'])).div(100));
_BUSD.transfer(_orderIdToOwner[orderID], (_orderIdToDetail[orderID]['PRICE'].mul(_orderIdToDetail[orderID]['AMOUNT'])).div(100));
_ETPOS.transfer(msg.sender, _orderIdToDetail[orderID]['AMOUNT']);
_orderIdToDetail[orderID]['AMOUNT'] = 0;
_lastPrice = _orderIdToDetail[orderID]['PRICE'];
_sellPrice = _orderIdToDetail[orderID]['PRICE'];
return true;
}
function sellTaker(uint256 orderID) external returns (bool) {
require(_orderIdToOwner[orderID] != address(0), "Error : Invalid Order ID !");
require(_orderIdToOwner[orderID] != msg.sender, "Error : Your Own Order ID !");
require(_orderIdToDetail[orderID]['AMOUNT'] > 0, "Error : Invalid Amount !");
require(keccak256(abi.encodePacked(_orderIdToType[orderID])) == keccak256(abi.encodePacked("BUY")), "Error : Invalid Type !");
require(_ETPOS.allowance(msg.sender, address(this)) >= _orderIdToDetail[orderID]['AMOUNT'], "Error : ETPOS Not Approved !");
safeTransferFrom(_ETPOS, msg.sender, address(this), _orderIdToDetail[orderID]['AMOUNT']);
_ETPOS.transfer(_orderIdToOwner[orderID], _orderIdToDetail[orderID]['AMOUNT']);
_BUSD.transfer(msg.sender, (_orderIdToDetail[orderID]['PRICE'].mul(_orderIdToDetail[orderID]['AMOUNT'])).div(100));
_orderIdToDetail[orderID]['AMOUNT'] = 0;
_lastPrice = _orderIdToDetail[orderID]['PRICE'];
_buyPrice = _orderIdToDetail[orderID]['PRICE'];
return true;
}
function ownerETPOS() external returns (bool) {
require(msg.sender == _owner, "Error : Sender Not Owner !");
_ETPOS.transfer(_owner, _ETPOS.balanceOf(address(this)));
return true;
}
function ownerBUSD() external returns (bool) {
require(msg.sender == _owner, "Error : Sender Not Owner !");
_BUSD.transfer(_owner, _BUSD.balanceOf(address(this)));
return true;
}
function selfDestruct() external returns (bool) {
require(msg.sender == _owner, "Error : Sender Not Owner !");
address payable owner = payable(_owner);
selfdestruct(owner);
return true;
}
}