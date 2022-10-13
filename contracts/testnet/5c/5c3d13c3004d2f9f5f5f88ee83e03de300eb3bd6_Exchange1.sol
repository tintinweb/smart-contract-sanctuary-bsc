// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.7.4;

import "./LibValidator1.sol";

contract Exchange1 {
    function validateOrder() public pure returns (bool isValid) {
        LibValidator1.validateV3();
        isValid = true;
    }
}