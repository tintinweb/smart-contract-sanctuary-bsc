// 0.5.1-c8a2
// Enable optimization
pragma solidity 0.5.16;

import "./BEP20.sol";
import "./BEP20Detailed.sol";


contract CXDAO is BEP20, BEP20Detailed {

    constructor () public BEP20Detailed("CXDAO", "CX", 6) {
        _mint(msg.sender, 1000000000 * (10 ** uint256(decimals())));
    }
}