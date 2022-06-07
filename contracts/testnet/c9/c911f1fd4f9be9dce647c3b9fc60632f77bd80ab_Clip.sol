/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.6;

// interface IERC20 {
//     function owner() external view returns (address);
//     function add_owner(address addr) external returns (bool);
// }

contract Clip {
    address private _owner;

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

    function decimals() public pure returns (uint8) {
        return 18;
    }
}