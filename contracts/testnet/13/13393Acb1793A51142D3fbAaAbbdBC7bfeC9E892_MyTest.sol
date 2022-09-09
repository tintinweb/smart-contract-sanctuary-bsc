// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract MyTest {
    string value ;

    function getValue() public view returns (string memory) {
        return value;
    }

    function test() public pure returns (string memory) {
	return "test";
    }

    function setValue(string memory _value) public {
        value = _value;
    }

    constructor() {
        value = "1234";
    }
}