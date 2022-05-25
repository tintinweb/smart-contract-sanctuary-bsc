pragma solidity 0.5.16;

import "./BEP20Token.sol";

contract Token is BEP20Token {
    constructor() public {
        _initialize("Sybatcoin", "SBT", 8, 1000000 * 10**8, false);
    }
}