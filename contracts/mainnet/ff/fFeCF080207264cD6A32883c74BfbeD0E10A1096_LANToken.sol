// 0.5.1-c8a2
// Enable optimization
pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./Ownable.sol";

contract LANToken is ERC20, ERC20Detailed, Ownable {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("LAN", "LAN", 18) {
        _mint(msg.sender, 400000000 * (10 ** uint256(decimals())));
    }
}