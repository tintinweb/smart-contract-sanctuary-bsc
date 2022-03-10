pragma solidity ^0.4.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";


contract Token is ERC20, ERC20Detailed {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("FUTURE","FUT",6) {
       _mint(0x84FC3E238d2269b1B26365fFcF3fedB8c06fD579, 10000000 * (10 ** uint256(decimals())));
    }
}