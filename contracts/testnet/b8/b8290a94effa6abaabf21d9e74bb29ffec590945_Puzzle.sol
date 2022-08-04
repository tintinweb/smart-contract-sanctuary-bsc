/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT

contract Puzzle {

    uint[] xxA1;
    uint[] xxA2 = new uint[](1);

	function whyDoesThisNotWork() public pure returns (uint256[] memory) {
        uint[] memory xx;
        xx[0] = 1;
        xx[1] = 2;
        return xx;
	}

	function whyDoesThisWork1() public pure returns (uint256[2] memory) {
        uint[2] memory xx = [uint256(0), uint256(1)];
        return xx;
	}

	function whyDoesThisWork2() public pure returns (uint256[2] memory) {
        uint[2] memory xx = [uint256(0), uint256(1)];
        xx[1] = uint256(3);
        return xx;
	}

	function whyDoesThisWork3( ) public pure returns (uint256[] memory) {
        uint[] memory xx;
        return xx;
	}

	function whyDoesMayWork() public pure returns (uint256[] memory) {
        uint[] memory xx = new uint[](2);
        xx[0] = 1;
        xx[1] = 2;
        return xx;
	}

	function whyDoesMayWork2() public returns (uint) { //
        xxA1[0] = 1;
        return xxA1[0];
	}

	function whyDoesMayWork2a() public returns (uint) { //
        xxA2[0] = 1;
        return xxA2[0];
	}

	function whyDoesMayWork3() public pure returns (uint) {
        uint[] memory xx2;
        xx2[0] = 1;
        return xx2[0];
	}

	function whyDoesMayWork4() public pure returns (uint) {
        uint[] memory xx2 = new uint[](1);
        xx2[0] = 1;
        return xx2[0];
	}

}