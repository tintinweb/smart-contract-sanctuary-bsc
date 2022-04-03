pragma solidity ^0.4.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";


contract Token is ERC20, ERC20Detailed {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("AIDOG","AIDOG",18) {
       _mint(msg.sender, 100000000000 * (10 ** uint256(decimals())));
    }
}