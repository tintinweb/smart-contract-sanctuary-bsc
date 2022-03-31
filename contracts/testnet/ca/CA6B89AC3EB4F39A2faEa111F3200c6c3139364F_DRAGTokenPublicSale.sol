pragma solidity ^0.8.0;

import "DRAGTokenUnlock.sol";

contract DRAGTokenPublicSale is DRAGTokenUnlock
{
    uint256 private intervalMonth = 3;

    uint256[] private unlockTokens = [uint256(29700000), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0)];

    constructor(address dragTokenAddress) DRAGTokenUnlock(dragTokenAddress) public
    {
    }

    function withdraw(uint256 amount) external
    {
        require(getOwner() != msg.sender, "no permission");
        withdrawUnlockTokenToWallet(amount, intervalMonth, unlockTokens);
    }

    function withdrawableTokenNum() external view returns (uint256)
    {
        return getUnlockAvailableToken(intervalMonth, unlockTokens);
    }

    function unlockTotalTokenNum() external view returns (uint256)
    {
        return getUnlockTotalToken(intervalMonth, unlockTokens);
    }
}