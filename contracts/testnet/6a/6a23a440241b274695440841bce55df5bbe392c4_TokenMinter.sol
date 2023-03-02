/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

pragma solidity ^0.8.0;

contract TokenMinter {
    uint256 public tokenCount;
    uint256 public lastMinted;

    constructor() {
        tokenCount = 0;
        lastMinted = block.timestamp;
    }

    function mintToken() public {
        require(block.timestamp >= lastMinted + 1 minutes, "Wait for at least 1 minute before minting again.");
        require(block.timestamp < lastMinted + 365 days, "Token minting period has ended.");
        tokenCount += 1;
        lastMinted = block.timestamp;
    }
}