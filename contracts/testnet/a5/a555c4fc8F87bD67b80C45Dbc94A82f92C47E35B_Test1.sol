/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Test1 {

    // event for EVM logging
    event Packed(bytes indexed packed);

    event Decoded(uint indexed a, bool indexed b, string indexed c);

    function foo(uint a, bool b, string memory c) public {
        bytes memory packed = abi.encodePacked(a, b, c);
        emit Packed(packed);
    }

    function foodecode(bytes memory packed) public {
        (uint a, bool b, string memory c) = abi.decode(packed, (uint, bool, string));
        emit Decoded(a, b, c);
    }
}