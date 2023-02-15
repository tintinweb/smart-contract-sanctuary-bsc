// 0.5.1-c8a2
// Enable optimization
pragma solidity ^0.5.4;

import "./TRC20.sol";
import "./TRC20Detailed.sol";
/**
 * @title SimpleToken
 * @dev Very simple TRC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `TRC20` functions.
 */
contract ALEOToken is TRC20, TRC20Detailed {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public TRC20Detailed("ALEO", "ALEO", 18) {
        _mint(msg.sender, 300000 * (10 ** uint256(decimals())));
    }
}