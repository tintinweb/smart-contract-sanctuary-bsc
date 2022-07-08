/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

library EnumerableSet {
    struct Set {bytes32[] _values; mapping(bytes32 => uint256) _indexes;}

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {set._values.push(value); set._indexes[value] = set._values.length; return true;
        } else {return false;}
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];
        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];
                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex;}
            set._values.pop();
            delete set._indexes[value]; return true;} else { return false;}
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
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

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
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

    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

contract treeGrow {
    using EnumerableSet for EnumerableSet.UintSet; 

    mapping(address => EnumerableSet.UintSet) private whitelist;


    constructor() {
    }

    function setWhitelist() external {
        whitelist[0x3C8eEc63D0eB8EcD0451B29cEb1a715e2bda573F].add(1);
        whitelist[0x3C8eEc63D0eB8EcD0451B29cEb1a715e2bda573F].add(2);
        whitelist[0xB4C11d8353C3cD41D99Ac36F7f05890a76ea9396].add(3);
        whitelist[0x623CF8aA50101d87A841b4498dd7E9Eca94F5f63].add(4);
        whitelist[0xB4C11d8353C3cD41D99Ac36F7f05890a76ea9396].add(5);
        whitelist[0x3C8eEc63D0eB8EcD0451B29cEb1a715e2bda573F].add(6);
        whitelist[0x3b0218eB9A1D3f0C2313D9EDc2E256dBC8dac9Dd].add(7);
        whitelist[0x623CF8aA50101d87A841b4498dd7E9Eca94F5f63].add(8);
        whitelist[0x3b0218eB9A1D3f0C2313D9EDc2E256dBC8dac9Dd].add(9);
        whitelist[0x3b0218eB9A1D3f0C2313D9EDc2E256dBC8dac9Dd].add(10);
    }

    function viewWhitelist(address _add, uint256 _id) public view returns (bool){
        bool result;
        if(whitelist[_add].contains(_id)){result = true;}
        else{result = false;}
        return result;
    }

}