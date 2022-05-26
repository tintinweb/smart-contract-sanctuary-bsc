// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AmazingBEP20.sol";

contract Token is AmazingBEP20 {
    constructor() AmazingBEP20("Elonex", "ELX", 18, 168000000000000000000000000) {
    }
}