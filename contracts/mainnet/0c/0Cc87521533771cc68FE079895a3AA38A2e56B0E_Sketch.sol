// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
import "ERC20.sol";

contract Sketch is ERC20 {
    constructor () public ERC20 ("Sketch Finance", "Sketch"){
        _mint(msg.sender, 10000000 * (10 ** uint256(decimals())));
    }
}