pragma solidity >=0.6.12;

import "./ERC20.sol";

contract MockBEP20 is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 supply
    ) ERC20(name, symbol) {
        _mint(msg.sender, supply);

    }
}