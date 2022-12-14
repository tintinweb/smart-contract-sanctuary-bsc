// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./test.sol";

contract Test1 is Test {
     function increment() external {
       value = value + 1;
    }
}