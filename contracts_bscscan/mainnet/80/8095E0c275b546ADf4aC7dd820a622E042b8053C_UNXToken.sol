pragma solidity ^0.5.0;

import "./BEP20.sol";
import "./BEP20Detailed.sol";

contract UNXToken is BEP20 {
    constructor () public BEP20Detailed(msg.sender,"UNION FINEX", "UNX", 8) {
        _mint(msg.sender, 100000000 * (10 ** uint256(decimals())));
    }
}