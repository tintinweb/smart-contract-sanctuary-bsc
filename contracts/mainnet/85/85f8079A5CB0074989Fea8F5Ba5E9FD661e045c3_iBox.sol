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
contract iBox is ERC20, ERC20Detailed {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("iBox", "iBox", 18) {
        _mint(0x0d7Fd19688dC51A93a0c306d1d7bE49589f49332, 21000000 * 10**18 );
    }

}