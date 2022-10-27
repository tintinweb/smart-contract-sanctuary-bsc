pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Ownable.sol";

contract Token is ERC20, Ownable {
    /**
     * @dev This is similar to event Transfer but is fired only when calling deposit method.
     *
     * Note that `value` may be zero.
     */
    event TokenDepositEvent(address indexed from, address indexed to, uint256 value);

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(0x8Dcb0C83E11030f718506376ABb59305A2361d68, 1000000000 * 10 ** 18);
    }
}