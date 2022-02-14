// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./BEP20.sol";

contract HKSToken is BEP20 {
    constructor() BEP20("HKS", "HKS") {
        _mint(msg.sender, 1000000000000 * 10**18);
    }
}