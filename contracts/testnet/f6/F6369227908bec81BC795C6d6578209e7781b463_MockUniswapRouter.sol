// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IDexRouter {
    function factory() external view returns (address factory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import './../interfaces/IDexRouter.sol';

contract MockUniswapRouter is IDexRouter {
    address public factory;

    constructor(address f) {
        factory = f;
    }

    function setFactory(address f) external {
        factory = f;
    }
}