// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Math.sol";

contract Greeter {
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        return Math.add(a, b);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Math {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
}