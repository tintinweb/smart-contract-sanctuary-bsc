/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

// Sources flattened with hardhat v2.5.0 https://hardhat.org

// File contracts/A.sol

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev Base contract of nest
contract A {

    uint public _a;
    uint public _b;
    uint public _c;

    function initialize(uint a, uint b) external {
        _a = a;
        _b = b;
    }

    function add(uint index, uint v) external {
        if (index == 0) {
            _a = _a + v; 
        } else if (index == 1) {
            _b = _b + v;
        } else if (index == 2) {
            _c = _c + v;
        } else revert("A:ERROR");
    }
}


// File contracts/C.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Base contract of nest
contract C is A {

    // uint public _a;
    // uint public _b;
    // uint public _c;

}


// File contracts/B.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Base contract of nest
contract B is A, C {

    uint public _x;
    uint public _y;
    uint public _z;

    function addb(uint index, uint v) external {
        if (index == 0) {
            _b = _b + v; 
        } else if (index == 1) {
            _b = _b + v;
        } else if (index == 2) {
            _c = _c + v;
        } else if (index == 3) {
            _x = _x + v;
        } else if (index == 4) {
            _y = _y + v;
        } else if (index == 5) {
            _z = _z + v;
        }
        
        else revert("A:ERROR");
    }
}