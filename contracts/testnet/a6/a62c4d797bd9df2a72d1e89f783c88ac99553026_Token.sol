pragma solidity ^0.4.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";


contract Token is ERC20, ERC20Detailed {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("My time","MT",18) {
       _mint(0x7494402dCC7c5eEa749Cac298BB247c02F3354C0, 9999* (10 ** uint256(decimals())));
    }
}