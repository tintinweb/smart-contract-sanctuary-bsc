// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "ERC20.sol";
contract Nyultoken is ERC20 {
    constructor() ERC20("Nyultoken", "NYT") {
    _mint(msg.sender, 10 * 10 ** decimals());
    }
}