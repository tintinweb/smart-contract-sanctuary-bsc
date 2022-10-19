//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "./ERC20.sol";

contract MetavillToken is ERC20 {
    constructor() ERC20("Metavill.io", "MV") {
        _mint(msg.sender, 1 * 10 ** 9 * (10 ** 18));
    }
}