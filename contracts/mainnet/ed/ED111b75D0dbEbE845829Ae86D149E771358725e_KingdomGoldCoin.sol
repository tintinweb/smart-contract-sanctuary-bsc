// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./TokenCore.sol";
import "./IAntisnipe.sol";

contract KingdomGoldCoin is TokenCore {
    uint256 private TOTAL_SUPPLY = 10 * 10**9;

    constructor(
        string memory _name,
        string memory _symbol
    ) TokenCore(_name, _symbol) {
        _mint(address(msg.sender), TOTAL_SUPPLY * 10**decimals());
    }

    IAntisnipe public antisnipe = IAntisnipe(address(0));
    bool public antisnipeDisable;

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (from == address(0) || to == address(0)) return;
        if (!antisnipeDisable && address(antisnipe) != address(0))
            antisnipe.assureCanTransfer(msg.sender, from, to, amount);
    }

    function setAntisnipeDisable() external onlyOwner {
        require(!antisnipeDisable);
        antisnipeDisable = true;
    }

    function setAntisnipeAddress(address addr) external onlyOwner {
        antisnipe = IAntisnipe(addr);
    }
}