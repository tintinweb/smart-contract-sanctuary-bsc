// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./ERC20.sol";
import "./Ownable.sol";

contract DEFI is ERC20, Ownable{

    constructor() ERC20("DEFI", "DEFI") {
        _mint(msg.sender, 100000000 * 10 ** 18 );

    }
}