// SPDX-License-Identifier: MIT
// solidity style guide: https://docs.soliditylang.org/en/v0.8.13/style-guide.html
// pragma
pragma solidity ^0.8.8;

// import

// interface, library

/** @title A simple contract for funding
 * @author Nguyen Khanh
 * @notice This contract is only demo for education
 * @dev This anotation is for developer, nothing in this contract
 */
contract Simple {
    uint256 public value;

    // Type Declarations
    function test() public {
        value += 1;
    }
}