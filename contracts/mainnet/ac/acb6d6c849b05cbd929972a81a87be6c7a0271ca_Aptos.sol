// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

/**
 * @title Aptos
 * @dev Standard ERC20 Token, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract Aptos is ERC20, ERC20Detailed, Ownable {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint _total) public ERC20Detailed(_name, _symbol, _decimals) {
        _mint(msg.sender, _total * (10 ** uint256(decimals())));
    }
}