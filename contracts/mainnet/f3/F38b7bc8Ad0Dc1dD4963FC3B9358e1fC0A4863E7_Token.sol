// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
import "ERC20.sol";

contract Token is ERC20 {
    constructor ()  ERC20 ("Crysta Coin", "CRST"){
        _mint(msg.sender, 99999999  * (10 ** uint256(decimals())));
    }
}