pragma solidity ^0.8.0;

import "./ERC20.sol";

contract OrbsToken is ERC20 {
    constructor() ERC20("OrbsToken", "ORB") public {
        _mint(msg.sender, 1000000 * (10**decimals()));
    }
}