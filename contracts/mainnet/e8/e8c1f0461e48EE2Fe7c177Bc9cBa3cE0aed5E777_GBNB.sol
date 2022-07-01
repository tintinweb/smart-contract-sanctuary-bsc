//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "./GToken.sol";

contract GBNB is GToken {
    /**
     * @notice Construct a new CEther money market
     * @param addresses The address of the Gammatroller, InterestRateModel, PlanetDiscount, iGamma
     * @param initialExchangeRateMantissa_ The initial exchange rate, scaled by 1e18
     * @param name_ ERC-20 name of this token
     * @param symbol_ ERC-20 symbol of this token
     * @param decimals_ ERC-20 decimal precision of this token
     */
    constructor(address[] memory addresses,
                uint initialExchangeRateMantissa_,
                string memory name_,
                string memory symbol_,
                uint8 decimals_)
    GToken(addresses, initialExchangeRateMantissa_, name_, symbol_, decimals_) {}

    /*** User Interface ***/

    /**
     * @notice Sender supplies assets into the market and receives gTokens in exchange
     * @dev Reverts upon any failure
     */
    function mint() external payable {
        mintInternal(msg.value);
    }

    /**
     * @notice Sender redeems gTokens in exchange for the underlying asset
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param redeemTokens The number of gTokens to redeem into underlying
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function redeem(uint redeemTokens) external returns (uint) {
        redeemInternal(redeemTokens);
        return NO_ERROR;
    }

    /**
     * @notice Sender redeems gTokens in exchange for a specified amount of underlying asset
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param redeemAmount The amount of underlying to redeem
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function redeemUnderlying(uint redeemAmount) external returns (uint) {
        redeemUnderlyingInternal(redeemAmount);
        return NO_ERROR;
    }

    /**
      * @notice Sender borrows assets from the protocol to their own address
      * @param borrowAmount The amount of the underlying asset to borrow
      * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
      */
    function borrow(uint borrowAmount) external returns (uint) {
        borrowInternal(borrowAmount);
        return NO_ERROR;
    }

    /**
     * @notice Sender repays their own borrow
     * @dev Reverts upon any failure
     */
    function repayBorrow() external payable {
        repayBorrowInternal(msg.value);
    }

    /**
     * @notice Sender repays a borrow belonging to borrower
     * @dev Reverts upon any failure
     * @param borrower the account with the debt being payed off
     */
    function repayBorrowBehalf(address borrower) external payable {
        repayBorrowBehalfInternal(borrower, msg.value);
    }

    /**
     * @notice The sender liquidates the borrowers collateral.
     *  The collateral seized is transferred to the liquidator.
     * @dev Reverts upon any failure
     * @param borrower The borrower of this gToken to be liquidated
     * @param gTokenCollateral The market in which to seize collateral from the borrower
     */
    function liquidateBorrow(address borrower, GTokenInterface gTokenCollateral) external payable {
        liquidateBorrowInternal(borrower, msg.value, gTokenCollateral);
    }

    /**
     * @notice The sender is updating the discount contract address.
     * @param newDiscountLevel New DiscountLevel contract address
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function _setDiscountLevel(address newDiscountLevel) external returns (uint) {
        return _setDiscountLevelInternal(PlanetDiscount(newDiscountLevel));
    }
    
    /**
     * @notice The sender is updating user's discount in the market.
     */
    function updateUserDiscount(address user) external {
        changeUserBorrowDiscountInternal(user);
        changeLastBorrowBalanceAtBorrow(user);
        changeUserSupplyDiscountInternal(user);
    }
    
    /**
     * @notice The sender is updating discount for all the users in the market.
     */
    function updateDiscountForAll() external {
        
        address[] memory usersWhoHaveBorrow = PlanetDiscount(discountLevel).returnBorrowUserArr(address(this));
        address[] memory usersWhoHaveSupply = PlanetDiscount(discountLevel).returnSupplyUserArr(address(this));
        
        
        for(uint i = 0 ; i < usersWhoHaveBorrow.length ; ++i){
            (bool exist,,,,) = PlanetDiscount(discountLevel).borrowDiscountSnap(address(this),usersWhoHaveBorrow[i]);
            if(usersWhoHaveBorrow[i] != address(0) && exist){
                changeUserBorrowDiscountInternal(usersWhoHaveBorrow[i]);
                changeLastBorrowBalanceAtBorrow(usersWhoHaveBorrow[i]);
            }
        }
        for(uint i = 0 ; i < usersWhoHaveSupply.length ; ++i){
            (bool exist,,,) = PlanetDiscount(discountLevel).supplyDiscountSnap(address(this),usersWhoHaveSupply[i]);
            if(usersWhoHaveSupply[i] != address(0) && exist){
               changeUserSupplyDiscountInternal(usersWhoHaveSupply[i]);
            }
        }
    }

    /**
     * @notice Send Ether to CEther to mint
     */
    fallback () external payable {
        mintInternal(msg.value);
    }

    /*** Safe Token ***/

    /**
     * @notice Gets balance of this contract in terms of Ether, before this message
     * @dev This excludes the value of the current message, if any
     * @return startingBalance the quantity of Ether owned by this contract
     */
    function getCashPrior() override internal view returns (uint startingBalance) {
        startingBalance = sub_(address(this).balance, msg.value);
    }

    /**
     * @notice Checks whether the requested transfer matches the `msg`
     * @dev Does NOT do a transfer
     * @param from Address sending the Ether
     * @param amount Amount of Ether being sent
     * @return Whether or not the transfer checks out
     */
    function checkTransferIn(address from, uint amount) override internal view returns (uint) {
        // Sanity checks
        require(msg.sender == from, "sender mismatch");
        require(msg.value == amount, "value mismatch");
        return NO_ERROR;
    }

    /**
     * @notice Perform the actual transfer in, which is a no-op
     * @param from Address sending the Ether
     * @param amount Amount of Ether being sent
     * @return Success
     */
    function doTransferIn(address from, uint amount) override internal returns (uint) {
        // Sanity checks
        require(msg.sender == from, "sender mismatch");
        require(msg.value == amount, "value mismatch");
        return NO_ERROR;
    }

    function doTransferOut(address payable to, uint amount) override internal returns (uint){
        /* Send the Ether, with minimal gas and revert on failure */
        to.transfer(amount);
        return NO_ERROR;
    }

    function requireNoError(uint errCode, string memory message) internal pure {
        if (errCode == NO_ERROR) {
            return;
        }

        bytes memory fullMessage = new bytes(bytes(message).length + 5);
        uint i;

        for (i = 0; i < bytes(message).length; ++i) {
            fullMessage[i] = bytes(message)[i];
        }

        fullMessage[i+0] = bytes1(uint8(32));
        fullMessage[i+1] = bytes1(uint8(40));
        fullMessage[i+2] = bytes1(uint8(48 + ( errCode / 10 )));
        fullMessage[i+3] = bytes1(uint8(48 + ( errCode % 10 )));
        fullMessage[i+4] = bytes1(uint8(41));

        require(errCode == NO_ERROR, string(fullMessage));
    }
}