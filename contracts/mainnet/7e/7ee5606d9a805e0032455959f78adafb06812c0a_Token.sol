pragma solidity ^0.4.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";


contract Token is ERC20, ERC20Detailed {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("HRD","HRD",18) {
       _mint(0x946EEf9Ab4852fF0A31dDE193176B1024445E93A, 21000000* (10 ** uint256(decimals())));
    }
}