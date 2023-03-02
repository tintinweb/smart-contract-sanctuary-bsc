/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

pragma solidity ^0.8.0;

contract TokenRelease {
    uint256 public constant TOTAL_SUPPLY = 1000000000 * 10 ** 18; // Total supply of 1000 million tokens
    uint256 public releaseAmount = TOTAL_SUPPLY / 100; // 1% release amount
    uint256 public releaseInterval = 1 minutes; // Release interval of 1 minute
    uint256 public lastReleaseTime = block.timestamp; // Timestamp of the last release
    
    function releaseTokens() external {
        require(block.timestamp >= lastReleaseTime + releaseInterval, "TokenRelease: It's not time to release tokens yet.");
        uint256 currentTime = block.timestamp;
        uint256 timeSinceLastRelease = currentTime - lastReleaseTime;
        uint256 releaseCount = timeSinceLastRelease / releaseInterval;
        uint256 tokensToRelease = releaseCount * releaseAmount;
        require(tokensToRelease > 0, "TokenRelease: No tokens to release yet.");
        require(tokensToRelease <= address(this).balance, "TokenRelease: Not enough tokens in the contract.");
        lastReleaseTime += releaseCount * releaseInterval;
        // TODO: distribute tokens to your designated beneficiaries
    }
}