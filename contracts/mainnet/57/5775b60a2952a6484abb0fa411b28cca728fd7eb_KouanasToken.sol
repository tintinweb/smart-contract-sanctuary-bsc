// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./ERC20.sol";

contract KouanasToken is ERC20 {
    constructor() ERC20("Kouana", "KOU") {
        _mint(address(0x256E2138c30E8C233E717F28853eBac05f079aD3), 1000000 * 10**18);
    }
}