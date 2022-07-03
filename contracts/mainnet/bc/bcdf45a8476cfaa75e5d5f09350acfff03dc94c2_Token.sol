pragma solidity ^0.4.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";


contract Token is ERC20, ERC20Detailed {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("TNB","TNB",18) {
       _mint(0x01cbC9419569CBFA70406c78C5263b1819d3214B, 10000000000 * (10 ** uint256(decimals())));
       
    }
}