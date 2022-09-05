// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

contract RevertContract {
    fallback() external payable {
        revert("Disabled");
    }
}