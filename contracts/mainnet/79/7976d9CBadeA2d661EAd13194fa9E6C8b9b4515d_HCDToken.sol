// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ERC20.sol";

contract HCDToken is ERC20 {
    constructor() ERC20("HCDToken", "HCD") {
        _mint(_msgSender(), 100000000 * (10**decimals()));
    }
}