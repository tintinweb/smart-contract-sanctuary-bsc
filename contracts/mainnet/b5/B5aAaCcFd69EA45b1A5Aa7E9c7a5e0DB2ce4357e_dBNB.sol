// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.5.16;

// Copyright 2020 Venus Labs, Inc.

// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

// 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
// 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
// PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



import "./VToken.sol";


/**
 *
 *** MODIFICATIONS ***
 * redeem() removed (keep redeemUnderlying())
 *
 *** ADDITIONS ***
 * swapExactBNBForToken() to support selling BNB
 *
 */

contract dBNB is VToken {
    /**
     * @notice Construct a new VBNB money market
     * @param comptroller_ The address of the Comptroller
     * @param interestRateModel_ The address of the interest rate model
     * @param initialExchangeRateMantissa_ The initial exchange rate, scaled by 1e18
     * @param name_ BEP-20 name of this token
     * @param symbol_ BEP-20 symbol of this token
     * @param decimals_ BEP-20 decimal precision of this token
     * @param admin_ Address of the administrator of this token
     */
    constructor(ComptrollerInterface comptroller_,
                InterestRateModel interestRateModel_,
                ITradeModel tradeModel_,
                uint initialExchangeRateMantissa_,
                string memory name_,
                string memory symbol_,
                uint8 decimals_,
                address payable admin_) public {
        // Creator of the contract is admin during initialization
        admin = msg.sender;

        initialize(comptroller_, interestRateModel_, tradeModel_, initialExchangeRateMantissa_, name_, symbol_, decimals_);

        // Set the proper admin now that initialization is done
        admin = admin_;
    }


    /*** User Interface ***/

    /**
     * @notice Sender supplies assets into the market and receives vTokens in exchange
     * @dev Reverts upon any failure
     */
    function mint() external payable {
        (uint err,) = mintInternal(msg.value);
        requireNoError(err, "mint failed");
    }


    /**
     * @notice Sender redeems vTokens in exchange for a specified amount of underlying asset
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param redeemAmount The amount of underlying to redeem
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function redeemUnderlying(uint redeemAmount) external returns (uint success) {
        success = redeemUnderlyingInternal(redeemAmount);
        iUSDrateLimits();
    }

    /**
      * @notice Sender borrows assets from the protocol to their own address
      * @param borrowAmount The amount of the underlying asset to borrow
      * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
      */
    function borrow(uint borrowAmount) external returns (uint success) {
        success = borrowInternal(borrowAmount);
        iUSDrateLimits();
    }

    /**
     * @notice Sender repays their own borrow
     * @dev Reverts upon any failure
     */
    function repayBorrow() external payable {
        (uint err,) = repayBorrowInternal(msg.value);
        requireNoError(err, "repayBorrow failed");
    }

    /**
     * @notice Sender repays a borrow belonging to borrower
     * @dev Reverts upon any failure
     * @param borrower the account with the debt being payed off
     */
    function repayBorrowBehalf(address borrower) external payable {
        (uint err,) = repayBorrowBehalfInternal(borrower, msg.value);
        requireNoError(err, "repayBorrowBehalf failed");
    }

    /**
     * @notice The sender liquidates the borrowers collateral.
     *  The collateral seized is transferred to the liquidator.
     * @dev Reverts upon any failure
     * @param borrower The borrower of this vToken to be liquidated
     * @param vTokenCollateral The market in which to seize collateral from the borrower
     */
    function liquidateBorrow(address borrower, VToken vTokenCollateral) external payable {
        (uint err,) = liquidateBorrowInternal(borrower, msg.value, vTokenCollateral);
        requireNoError(err, "liquidateBorrow failed");
    }

    /**
     * @notice Send BNB to VBNB to mint
     */
    function () external payable {
        (uint err,) = mintInternal(msg.value);
        requireNoError(err, "mint failed");
    }

    /*** Safe Token ***/


    /**
     * @notice Gets balance of this contract in terms of BNB, before this message
     * @dev This excludes the value of the current message, if any
     * @return The quantity of BNB owned by this contract
     */
    function getCashPrior() internal view returns (uint) {
        (MathError err, uint startingBalance) = subUInt(address(this).balance, msg.value);
        require(err == MathError.NO_ERROR, "cash prior math error");
        return startingBalance;
    }


    /**
     * @notice Perform the actual transfer in, which is a no-op
     * @param from Address sending the BNB
     * @param amount Amount of BNB being sent
     * @return The actual amount of BNB transferred
     */
    function doTransferIn(address from, uint amount) internal returns (uint) {
        // Sanity checks
        require(msg.sender == from, "sender mismatch");
        require(msg.value == amount, "value mismatch");
        return amount;
    }

    function doTransferOut(address payable to, uint amount) internal {
        /* Send the BNB, with minimal gas and revert on failure */
        to.transfer(amount);
    }

    function requireNoError(uint errCode, string memory message) internal pure {
        if (errCode == uint(Error.NO_ERROR)) {
            return;
        }

        bytes memory fullMessage = new bytes(bytes(message).length + 5);
        uint i;

        for (i = 0; i < bytes(message).length; i++) {
            fullMessage[i] = bytes(message)[i];
        }

        fullMessage[i+0] = byte(uint8(32));
        fullMessage[i+1] = byte(uint8(40));
        fullMessage[i+2] = byte(uint8(48 + ( errCode / 10 )));
        fullMessage[i+3] = byte(uint8(48 + ( errCode % 10 )));
        fullMessage[i+4] = byte(uint8(41));

        require(errCode == uint(Error.NO_ERROR), string(fullMessage));
    }


    // ------------------ ADDITIONS FOR TRADING --------------- //


    function getCashCurrent() internal view returns (uint) {
        return address(this).balance;
    }

    /**
     * @notice Allows user to sell (deposit) BNB to get underlying from another dual pool
     * @dev Signal is sent (with valueUSD) to approved dTokens to send out its underlying token to _sendTo
     * @param _minOut The minimum amount of dTokenOut's underlying out or it fails
     * @param dTokenOut_referrer An array of format [dTokenOut, referrer], if no referrer then zero address 
     *        used because swapExactTokensForTokens method of this format is registered on Metamask
     * @param _sendTo The address to send this dTokens underlying
     * @param _deadline Trade must be completed before this deadline (in block.timestamp)
     */
    function swapExactETHForTokens(uint _minOut, address[] calldata dTokenOut_referrer, address payable _sendTo, uint _deadline) external nonReentrant payable {
        
        // requirements (BNB accepted first due to payable function)
        address dTokenOut = dTokenOut_referrer[0]; 
        address payable referrer = address(uint160(dTokenOut_referrer[1]));
        require(dTokenOut != address(this),"cannot buy and sell same token"); 
        require(dTokenOut_referrer.length == 2 && comptroller.dTokenApproved(dTokenOut),"!dTokenOut");

        // calculates valueOut and updates balances
        (uint256 mintiUSD, uint256 reserveTradeFee,) = amountsOut(address(this), address(0), msg.value, msg.sender, referrer); // amountOut USD
        iUSDbalance = subINT(iUSDbalance,int(mintiUSD)); // updates global variables

        VTokenInterface(dTokenOut).sendTokenOut(mintiUSD, _minOut, _sendTo, _deadline); 

        // sends fee to referrer (if one exists), otherwise add to totalReserves
        if (referrer != address(0)) {
            doTransferOut(referrer,reserveTradeFee);
        } else {
            totalReserves = addUINT(totalReserves,reserveTradeFee); // trading fee in underlying
        }

        require(iUSDrate() > int(-iUSDlimit),"sell would exceed iUSD limit.");

        emit SwapExactETHForTokens(dTokenOut, msg.value, mintiUSD);

    }


}