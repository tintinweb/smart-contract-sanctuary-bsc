/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract test {

    struct Simple {
        address ssss;
        uint256 vvvv;
	}

	struct GGG {
        uint256 rand;
        Simple[] abc;
        Simple[] efg;
	}

    mapping (uint256 => mapping(address => GGG)) internal _ggg;

    function viewGGG(
        uint256 _vI
    ) external view returns(
        GGG memory _gggg
    ) {
        _gggg = _ggg[_vI][address(0)];
    }

}