pragma solidity ^0.4.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";


contract Token is ERC20, ERC20Detailed {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("COMR","COMR",18) {
       _mint(msg.sender, 49000000 * (10 ** uint256(decimals())));
    }
}