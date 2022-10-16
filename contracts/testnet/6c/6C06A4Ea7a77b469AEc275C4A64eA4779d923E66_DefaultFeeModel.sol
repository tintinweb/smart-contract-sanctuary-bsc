// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/IFeeModel.sol";

contract DefaultFeeModel is IFeeModel {
    function calculateFee(uint positionSize, uint[3][] memory positionInteractions) external view returns (uint fee) {
        fee = 0;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./IPositionsManager.sol";

interface IFeeModel {
    function calculateFee(uint positionSize, uint[3][] memory positionInteractions) external view returns (uint fee);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


/// @notice Structure representing a liquidation condition
/// @param watchedToken The token whose price needs to be watched
/// @param liquidateTo The token that the position will be converted into
/// @param lessThan Wether liquidation will happen when price is below or above liquidationPoint
/// @param liquidationPoint Price of watchedToken in usd*10**18 at which liquidation should be trigerred
struct LiquidationCondition {
    address watchedToken;
    address liquidateTo;
    bool lessThan;
    uint liquidationPoint;
}

/// @notice Structure representing a position
/// @param user The user that owns this position
/// @param bankId Bank ID in which the assets are deposited
/// @param bankToken Token ID for the assets in the bank
/// @param amount Size of the position
/// @param liquidationPoints A list of conditions, where if any is not met, the position will be liquidated
struct Position {
    address user;
    uint bankId;
    uint bankToken;
    uint amount;
    LiquidationCondition[] liquidationPoints;
}

interface IPositionsManager {

    event KeeperUpdate(address keeper, bool active);
    event BankAdded(address bank, uint bankId);
    event BankUpdated(address newBankAddress, address oldBankAddress, uint bankId);
    event Deposit(uint positionId, uint bankId, uint bankToken, address user, uint amount, LiquidationCondition[] liquidationPoints);
    event IncreasePosition(uint positionId, uint amount);
    event Withdraw(uint positionId, uint amount);
    event PositionClose(uint positionId);
    event LiquidationPointsUpdate(uint positionId, LiquidationCondition[] liquidationPoints);
    event Harvest(uint positionId, address[] rewards, uint[] rewardAmounts);
    event HarvestRecompound(uint positionId, uint lpTokens);
    event FeeClaimed(uint positionId, uint usdcClaimed);

    /// @notice Returns number of positions that have been opened
    /// @return positions Number of positions that have been opened
    function numPositions() external view returns (uint positions);
    
    /// @notice Returns a list of position interactions, each interaction is a two element array consisting of block number and interaction type
    /// @notice Interaction type 0 is deposit, 1 is withdraw, 2 is harvest, 3 is compound and 4 is bot liquidation
    /// @param positionId position ID
    /// @return interactions List of position interactions
    function getPositionInteractions(uint positionId) external view returns (uint[3][] memory interactions);

    /// @notice Returns number of banks
    /// @return positions Number of banks
    function numBanks() external view returns (uint positions);

    /// @notice Set the address for the EOA that can be used to trigger liquidations
    function setKeeper(address keeperAddress, bool active) external;

    /// @notice Set the fee model to be used for specified position
    /// @notice Will be used to discount fees for customers with large positions
    function setFeeModel(uint positionId, address feeModel) external;

    /// @notice Set the default fee model used for all newly created positions
    function setDefaultFeeModel(address feeModel) external;

    /// @notice Add a new bank
    /// @param bank Address of new bank
    function addBank(address bank) external;

    /// @notice Change the address of a bank
    /// @param bankId ID of bank being updated
    /// @param newBankAddress New bank address
    function migrateBank(uint bankId, address newBankAddress) external;

    /// @notice Get a position
    /// @param positionId position ID
    /// @return position Position details
    function getPosition(uint positionId) external view returns (Position memory position);

    /// @notice Get a list of banks and bank tokens that support the provided token
    /// @dev bankToken for ERC721 banks is not supported and will always be 0
    /// @param token The token for which to get supported banks
    /// @return banks List of banks that support the token
    /// @return bankNames Names of recommended banks
    /// @return bankTokens token IDs corresponding to the provided token for each of the banks
    function recommendBank(address token) external view returns (uint[] memory banks, string[] memory bankNames, uint[] memory bankTokens);

    /// @notice Change the liquidation conditions for a position
    /// @param positionId position ID
    /// @param _liquidationPoints New list of liquidation conditions
    function adjustLiquidationPoints(uint positionId, LiquidationCondition[] memory _liquidationPoints) external;

    /// @notice Deposit into existing position
    /// @dev Before calling, make sure PositionsManager contract has approvals according to suppliedAmounts
    /// @param positionId position ID
    /// @param suppliedTokens list of tokens supplied to increase the positions value
    /// @param suppliedAmounts amounts supplied for each of the supplied tokens
    /// @param minAmountsUsed Slippage control, used when supplied tokens don't match the positions underlying and conversion needs to be done
    function deposit(uint positionId, address[] memory suppliedTokens, uint[] memory suppliedAmounts, uint[] memory minAmountsUsed) payable external;

    /// @notice Create new position and deposit into it
    /// @dev Before calling, make sure PositionsManager contract has approvals according to suppliedAmounts
    /// @dev For creating an ERC721Bank position, suppliedTokens will contain the ERC721 contract and suppliedAmounts will contain the tokenId
    /// @param position position details
    /// @param suppliedTokens list of tokens supplied to increase the positions value
    /// @param suppliedAmounts amounts supplied for each of the supplied tokens
    function deposit(Position memory position, address[] memory suppliedTokens, uint[] memory suppliedAmounts) payable external returns (uint);

    /// @notice Withdraw from a position
    /// @dev In case of ERC721Bank position, amount should be liquidity to withdraw like in UniswapV3PositionsManager
    /// @param positionId position ID
    /// @param amount amount to withdraw
    function withdraw(uint positionId, uint amount) external;

    /// @notice Withdraws all funds from a position
    /// @param positionId Position ID
    function close(uint positionId) external;

    /// @notice Close a function and convert all assets to USDC
    /// @notice This function is intended to be called using callstatic, just to check the USD value of the position
    /// @return usdcValue The value of the position in terms of USDC
    function closeToUSDC(uint positionId) external returns (uint usdcValue);

    /// @notice Harvest and receive the rewards for a position
    /// @param positionId Position ID
    /// @return rewards List of tokens obtained as rewards
    /// @return rewardAmounts Amount of tokens received as reward
    function harvestRewards(uint positionId) external returns (address[] memory rewards, uint[] memory rewardAmounts);

    /// @notice Harvest rewards for position and deposit them back to increase position value
    /// @param positionId Position ID
    /// @param minAmountsUsed Slippage control if swap is needed
    /// @return newLpTokens Amount of new tokens added/increase in liquidity for position
    function harvestAndRecompound(uint positionId, uint[] memory minAmountsUsed) external returns (uint newLpTokens);

    /// @notice Liquidate a position that has violated some liquidation condition
    /// @notice Can only be called by a keeper
    /// @param positionId Position ID
    /// @param liquidationIndex Index of liquidation condition that is no longer satisfied
    /// @param minAmountOut Slippage Control
    function botLiquidate(uint positionId, uint liquidationIndex, uint minAmountOut) external;

    /// @notice Function used to claim the fees for a position
    /// @notice claimDevFee will be called on every position interaction
    function claimDevFee(uint positionId) external;
}