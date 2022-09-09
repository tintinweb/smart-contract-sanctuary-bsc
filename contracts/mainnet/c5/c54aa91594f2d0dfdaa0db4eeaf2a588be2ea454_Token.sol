pragma solidity ^0.4.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";


contract Token is ERC20, ERC20Detailed {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("My time","MT",18) {
       _mint(0x22679D51e4837BD0110ddc883F571eAEdaE92823, 9999* (10 ** uint256(decimals())));
    }
}