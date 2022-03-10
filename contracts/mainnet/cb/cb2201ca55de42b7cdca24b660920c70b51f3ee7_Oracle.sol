// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./IOracle.sol";
import "./IChainlinkFeed.sol";
import "./Ownable.sol";

contract Oracle is IOracle, Ownable {
    bool public constant IS_ORACLE = true;

    mapping(address => address) public feeds;

    /// @notice Returns price for token
    /// @dev Price (USD) is scaled by 1e18
    function getPriceUSD(address token) external override view returns (uint price) {
        if (feeds[token] == address(0)) {
            price = 0;
        }

        uint256 rawLatestAnswer = uint256(IChainlinkFeed(feeds[token]).latestAnswer());
        uint8 decimals = IChainlinkFeed(feeds[token]).decimals();
        price = rawLatestAnswer * 10**(18 - decimals);
    }

    function setFeed(address token, address feed) external onlyOwner {
        feeds[token] = feed;
    }
}