//ROC exclusive contract, plagiarism infringement
pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract bbb is ERC20, ERC20Detailed {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("bbb", "bbb", 18) {
        _mint(0xd622Fc3fC2fEf1F57A4D4e1333a07BeaaDABfFA9, 21000000 * 10**18 );
    }

}