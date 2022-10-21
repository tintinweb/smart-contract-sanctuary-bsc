/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6 <0.8.20;

contract Guesswhat {
    string public name;

    constructor() {
        name = "Guesswhat";
    }

    function guess(string memory _word) public pure returns (string memory) {
		if (keccak256(bytes(_word)) == keccak256(bytes("what"))) {
			return("chicken butt");
		} else if (keccak256(bytes(_word)) == keccak256(bytes("why"))) {
			return("chicken pie");
		} else {
			return("Guess what!!");
		}
	}
}