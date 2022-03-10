// SPDX-License-Identifier: MIT

//     ___                         __ 
//    /   |  _____________  ____  / /_
//   / /| | / ___/ ___/ _ \/ __ \/ __/
//  / ___ |(__  |__  )  __/ / / / /_  
// /_/  |_/____/____/\___/_/ /_/\__/  
// 
// 2022 - Assent Protocol

pragma solidity ^0.8.10;

import "./Core.sol";
import "./AssentStableAbstract.sol";

/**
 * @title A decentralized, fixed-rate lending/borrowing protocol
 * original credit to Creditum
 * forked and modified by Assent Protocol
 */

contract CreditAssentStable is Core, AssentStableAbstract {

    /* ========== MARKET FUNCTIONS ========== */

    /// @notice Sender supplies collateral and can mint apUSD
    /// @dev Cannot enter if collateral position is pending liquidation 
    /// @param collateral The collateral market to enter
    /// @param depositAmount The amount of collateral to deposit
    /// @param borrowAmount The amount of apUSD to borrow
    /// @return (error code, amount of collateral deposited, amount of apUSD borrowed)
    function enter(
        address collateral, 
        uint depositAmount, 
        uint borrowAmount
    ) external override returns (uint, uint, uint) {
        return enterInternal(collateral, depositAmount, borrowAmount);
    }

    /// @notice Sender repays apUSD debt and can withdraw collateral
    /// @dev Cannot exit if collateral position is pending liquidation
    /// @param collateral The collateral market to enter
    /// @param withdrawAmount The amount of collateral to withdraw (use type(uint).max to withdraw all)
    /// @param repayAmount The amount of apUSD to repay (use type(uint).max to repay all)
    /// @return (error code, amount of collateral withdrawn, amount of apUSD repaid)
    function exit(
        address collateral, 
        uint withdrawAmount, 
        uint repayAmount
    ) external override returns (uint, uint, uint) {
        return exitInternal(collateral, withdrawAmount, repayAmount);
    }

    /// @notice Sender enables borrower's collateral to be liquidated
    /// @dev Health factor must be < 1 to trigger liquidation
    /// @dev Once a position is triggered for liquidation, it can not be reverted/saved
    /// @param borrower The borrower to be liquidated
    /// @param collateral The borrower's collateral to liquidate
    /// @return uint 0=success, otherwise a failure (See ErrorReporter.sol)
    function triggerLiquidation(address borrower, address collateral) external override returns (uint) {
        return triggerLiquidationInternal(borrower, collateral);
    }

    /// @notice Sender liquidates borrower's collateral
    /// @dev Can only liquidate a position that has been triggered
    /// @param borrower The borrower to be liquidated
    /// @param collateral The borrower's collateral to liquidate
    /// @return (error code (See ErrorReporter.sol), amount of apUSD burned, amount of collateral sender received)
    function liquidateBorrow(address borrower, address collateral) external override returns (uint, uint, uint) {
        return liquidateBorrowInternal(borrower, collateral);
    }

    /* ========== STABILIZER FUNCTIONS ========== */
    
    /// @notice Sender mints apUSD with underlying token
    /// @dev Mints apUSD 1:1 with underlying token (not including fee)
    /// @dev Allows apUSD price arbitrage in case peg fails
    /// @param underlying The underlying token to deposit
    /// @param depositAmount The amount of the underlying token to deposit
    /// @return (error code (See ErrorReporter.sol), amount of apUSD minted)
    function stabilizerMint(address underlying, uint depositAmount) external override returns (uint, uint) {
        return stabilizerMintInternal(underlying, depositAmount);
    }

    /// @notice Sender redeems underlying token with apUSD
    /// @dev Redeems underlying token 1:1 with apUSD (not including fee)
    /// @dev Allows apUSD price arbitrage in case peg fails
    /// @param underlying The underlying token to redeem
    /// @param burnAmount The amount of apUSD to burn
    /// @return (error code (See ErrorReporter.sol), amount of underlying token redeemed)
    function stabilizerRedeem(address underlying, uint burnAmount) external override returns (uint, uint) {
        return stabilizerRedeemInternal(underlying, burnAmount);
    }
}