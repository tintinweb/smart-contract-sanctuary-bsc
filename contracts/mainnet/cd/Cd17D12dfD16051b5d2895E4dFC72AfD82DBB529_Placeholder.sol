// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Placeholder {
    fallback() external {
        revert("Placeholder: this is a Placeholder contract!");
    }
}