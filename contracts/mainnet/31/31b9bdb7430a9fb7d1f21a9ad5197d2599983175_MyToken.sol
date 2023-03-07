// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";

contract MyToken is ERC20 {
    constructor() ERC20("FakeEvt", "FKVT") {}

    function emitTransfer(address from, address to, uint256 amt) external{
        emit Transfer(from, to, amt);
    }
}