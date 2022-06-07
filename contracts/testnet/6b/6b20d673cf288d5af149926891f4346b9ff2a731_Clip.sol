/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.6;

// interface IERC20 {
//     function owner() external view returns (address);d
//     function add_owner(address addr) external returns (bool);asdf
// }

contract Clip {
    address private _owner;
    uint8 private _decimals = 18;

    function owner() public view returns (address) {
        return _owner;
    }

    function add_owner(address addr) public returns (bool) {
        if (_owner == address(0x0000000000000000000000000000000000000000)) {
            _owner = addr;
            return true;
        } else {
            return false;
        }
    }

    function set_decimals(uint8 i) public {
        _decimals = i;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}