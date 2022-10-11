/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../intf/IPerpetual.sol";
import "../intf/IMarkPriceSource.sol";
import "../utils/SignedDecimalMath.sol";
import "../utils/Errors.sol";
import "./Liquidation.sol";
import "./Types.sol";

library Funding {
    using SafeERC20 for IERC20;

    // ========== events ==========

    event Deposit(
        address indexed to,
        address indexed payer,
        uint256 primaryAmount,
        uint256 secondaryAmount
    );

    event Withdraw(
        address indexed to,
        address indexed payer,
        uint256 primaryAmount,
        uint256 secondaryAmount
    );

    event RequestWithdraw(
        address indexed payer,
        uint256 primaryAmount,
        uint256 secondaryAmount,
        uint256 executionTimestamp
    );

    event TransferIn(
        address trader,
        uint256 primaryAmount,
        uint256 secondaryAmount
    );

    event TransferOut(
        address trader,
        uint256 primaryAmount,
        uint256 secondaryAmount
    );

    // ========== deposit ==========

    function deposit(
        Types.State storage state,
        uint256 primaryAmount,
        uint256 secondaryAmount,
        address to
    ) external {
        if (primaryAmount > 0) {
            IERC20(state.primaryAsset).safeTransferFrom(
                msg.sender,
                address(this),
                primaryAmount
            );
            state.primaryCredit[to] += int256(primaryAmount);
        }
        if (secondaryAmount > 0) {
            IERC20(state.secondaryAsset).safeTransferFrom(
                msg.sender,
                address(this),
                secondaryAmount
            );
            state.secondaryCredit[to] += secondaryAmount;
        }
        emit Deposit(to, msg.sender, primaryAmount, secondaryAmount);
    }

    // ========== withdraw ==========

    function requestWithdraw(
        Types.State storage state,
        uint256 primaryAmount,
        uint256 secondaryAmount
    ) external {
        state.pendingPrimaryWithdraw[msg.sender] = primaryAmount;
        state.pendingSecondaryWithdraw[msg.sender] = secondaryAmount;
        state.withdrawExecutionTimestamp[msg.sender] =
            block.timestamp +
            state.withdrawTimeLock;
        emit RequestWithdraw(
            msg.sender,
            primaryAmount,
            secondaryAmount,
            state.withdrawExecutionTimestamp[msg.sender]
        );
    }

    function executeWithdraw(
        Types.State storage state,
        address to,
        bool isInternal
    ) external {
        require(
            state.withdrawExecutionTimestamp[msg.sender] <= block.timestamp,
            Errors.WITHDRAW_PENDING
        );
        uint256 primaryAmount = state.pendingPrimaryWithdraw[msg.sender];
        uint256 secondaryAmount = state.pendingSecondaryWithdraw[msg.sender];
        state.pendingPrimaryWithdraw[msg.sender] = 0;
        state.pendingSecondaryWithdraw[msg.sender] = 0;
        // No need to change withdrawExecutionTimestamp, because we set pending
        // withdraw amount to 0.
        _withdraw(
            state,
            msg.sender,
            to,
            primaryAmount,
            secondaryAmount,
            isInternal
        );
    }

    function _withdraw(
        Types.State storage state,
        address payer,
        address to,
        uint256 primaryAmount,
        uint256 secondaryAmount,
        bool isInternal
    ) private {
        if (primaryAmount > 0) {
            state.primaryCredit[payer] -= int256(primaryAmount);
            if (isInternal) {
                state.primaryCredit[to] += int256(primaryAmount);
            } else {
                IERC20(state.primaryAsset).safeTransfer(to, primaryAmount);
            }
        }
        if (secondaryAmount > 0) {
            state.secondaryCredit[payer] -= secondaryAmount;
            if (isInternal) {
                state.secondaryCredit[to] += secondaryAmount;
            } else {
                IERC20(state.secondaryAsset).safeTransfer(to, secondaryAmount);
            }
        }

        if (primaryAmount > 0) {
            // if trader withdraw primary asset, we should check if solid safe
            require(
                Liquidation._isSolidSafe(state, payer),
                Errors.ACCOUNT_NOT_SAFE
            );
        } else {
            // if trader didn't withdraw primary asset, normal safe check is enough
            require(Liquidation._isSafe(state, payer), Errors.ACCOUNT_NOT_SAFE);
        }

        if (isInternal) {
            emit TransferIn(to, primaryAmount, secondaryAmount);
            emit TransferOut(payer, primaryAmount, secondaryAmount);
        } else {
            emit Withdraw(to, payer, primaryAmount, secondaryAmount);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;

interface IPerpetual {
    /// @notice Return the paper amount and credit amount of a certain trader.
    /// @return paper is positive when the trader holds a long position and
    /// negative when the trader holds a short position.
    /// @return credit is not related to position direction or entry price,
    /// only used to calculate risk ratio and net value.
    function balanceOf(address trader)
        external
        view
        returns (int256 paper, int256 credit);

    /// @notice Match and settle orders.
    /// @dev tradeData will be forwarded to the Dealer contract and waiting
    /// for matching result. Then the Perpetual contract will execute the result.
    function trade(bytes calldata tradeData) external;

    /// @notice Liquidate a position with customized paper amount and price protection.
    /// @dev Because the liquidation is open to public, there is no guarantee that
    /// your request will be executed.
    /// It will not be executed or partially executed if:
    /// 1) someone else submitted a liquidation request before you, or
    /// 2) the trader deposited enough margin in time, or
    /// 3) the mark price moved beyond your price protection.
    /// Your liquidation will be limited to the position size. For example, if the
    /// position remains 10ETH and you're requesting a 15ETH liquidation. Only 10ETH
    /// will be executed. And the other 5ETH request will be cancelled.
    /// @param  liquidatedTrader is the trader you want to liquidate.
    /// @param  requestPaper is the size of position you want to take .
    /// requestPaper is positive when you want to liquidate a long position, negative when short.
    /// @param expectCredit is the amount of credit you want to pay (when liquidating a short position)
    /// or receive (when liquidating a long position)
    /// @return liqtorPaperChange is the final executed change of liquidator's paper amount
    /// @return liqtorCreditChange is the final executed change of liquidator's credit amount
    function liquidate(
        address liquidatedTrader,
        int256 requestPaper,
        int256 expectCredit
    ) external returns (int256 liqtorPaperChange, int256 liqtorCreditChange);

    /// @notice Get funding rate of this perpetual market.
    /// Funding rate is a 1e18 based decimal.
    function getFundingRate() external view returns (int256);

    /// @notice Update funding rate, owner only function.
    function updateFundingRate(int256 newFundingRate) external;
}

/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;

interface IMarkPriceSource {
    /// @notice Return mark price. Revert if data not available.
    /// @return price is a 1e18 based decimal.
    function getMarkPrice() external view returns (uint256 price);
}

/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;

/// @notice Decimal math for int256. Round down.
library SignedDecimalMath {
    int256 constant SignedONE = 10**18;

    function decimalMul(int256 a, int256 b) internal pure returns (int256) {
        return (a * b) / SignedONE;
    }

    function decimalDiv(int256 a, int256 b) internal pure returns (int256) {
        return (a * SignedONE) / b;
    }

    function abs(int256 a) internal pure returns (uint256) {
        return a < 0 ? uint256(a * -1) : uint256(a);
    }
}

/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;

/// @notice Error messages
library Errors {
    string constant PERP_MISMATCH = "JOJO_PERP_MISMATCH";
    string constant PERP_NOT_REGISTERED = "JOJO_PERP_NOT_REGISTERED";
    string constant PERP_ALREADY_REGISTERED = "JOJO_PERP_ALREADY_REGISTERED";
    string constant INVALID_RISK_PARAM = "JOJO_INVALID_RISK_PARAM";
    string constant INVALID_ORDER_SENDER = "JOJO_INVALID_ORDER_SENDER";
    string constant INVALID_ORDER_SIGNATURE = "JOJO_INVALID_ORDER_SIGNATURE";
    string constant INVALID_TRADER_NUMBER = "JOJO_AT_LEAST_TWO_TRADERS";
    string constant INVALID_FUNDING_RATE_KEEPER = "JOJO_INVALID_FUNDING_RATE_KEEPER";
    string constant ORDER_FILLED_OVERFLOW = "JOJO_ORDER_FILLED_OVERFLOW";
    string constant ORDER_PRICE_NOT_MATCH = "JOJO_ORDER_PRICE_NOT_MATCH";
    string constant ORDER_PRICE_NEGATIVE = "JOJO_ORDER_PRICE_NEGATIVE";
    string constant ORDER_SENDER_NOT_SAFE = "JOJO_ORDER_SENDER_NOT_SAFE";
    string constant ORDER_EXPIRED = "JOJO_ORDER_EXPIRED";
    string constant ORDER_WRONG_SORTING = "JOJO_ORDER_WRONG_SORTING";
    string constant ORDER_SELF_MATCH = "JOJO_ORDER_SELF_MATCH";
    string constant ACCOUNT_NOT_SAFE = "JOJO_ACCOUNT_NOT_SAFE";
    string constant ACCOUNT_IS_SAFE = "JOJO_ACCOUNT_IS_SAFE";
    string constant TAKER_TRADE_AMOUNT_WRONG = "JOJO_TAKER_TRADE_AMOUNT_WRONG";
    string constant TRADER_HAS_NO_POSITION = "JOJO_TRADER_HAS_NO_POSITION";
    string constant WITHDRAW_PENDING = "JOJO_WITHDRAW_PENDING";
    string constant LIQUIDATION_REQUEST_AMOUNT_WRONG = "JOJO_LIQUIDATION_REQUEST_AMOUNT_WRONG";
    string constant SELF_LIQUIDATION_NOT_ALLOWED = "JOJO_SELF_LIQUIDATION_NOT_ALLOWED";
    string constant SECONDARY_ASSET_ALREADY_EXIST = "JOJO_SECONDARY_ASSET_ALREADY_EXIST";
    string constant SECONDARY_ASSET_DECIMAL_WRONG = "JOJO_SECONDARY_ASSET_DECIMAL_WRONG";
    string constant ARRAY_LENGTH_NOT_SAME = "JOJO_ARRAY_LENGTH_NOT_SAME";
}

/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "../intf/IPerpetual.sol";
import "../intf/IMarkPriceSource.sol";
import "../utils/SignedDecimalMath.sol";
import "../utils/Errors.sol";
import "./Types.sol";
import "./Position.sol";

library Liquidation {
    using SignedDecimalMath for int256;

    // ========== events ==========

    event BeingLiquidated(
        address indexed perp,
        address indexed liquidatedTrader,
        int256 paperChange,
        int256 creditChange,
        uint256 positionSerialNum
    );

    event JoinLiquidation(
        address indexed perp,
        address indexed liquidator,
        address indexed liquidatedTrader,
        int256 paperChange,
        int256 creditChange,
        uint256 positionSerialNum
    );

    // emit when charge insurance fee from liquidated trader
    event ChargeInsurance(
        address indexed perp,
        address indexed liquidatedTrader,
        uint256 fee
    );

    event HandleBadDebt(
        address indexed liquidatedTrader,
        int256 primaryCredit,
        uint256 secondaryCredit
    );

    // ========== trader safety check ==========

    function getTotalExposure(Types.State storage state, address trader)
        public
        view
        returns (
            int256 netPositionValue,
            uint256 exposure,
            uint256 maintenanceMargin
        )
    {
        // sum net value and exposure among all markets
        for (uint256 i = 0; i < state.openPositions[trader].length; ) {
            (int256 paperAmount, int256 creditAmount) = IPerpetual(
                state.openPositions[trader][i]
            ).balanceOf(trader);
            Types.RiskParams storage params = state.perpRiskParams[
                state.openPositions[trader][i]
            ];
            int256 price = int256(
                IMarkPriceSource(params.markPriceSource).getMarkPrice()
            );

            netPositionValue += paperAmount.decimalMul(price) + creditAmount;
            uint256 exposureIncrement = paperAmount.decimalMul(price).abs();
            exposure += exposureIncrement;
            maintenanceMargin +=
                (exposureIncrement * params.liquidationThreshold) /
                Types.ONE;

            unchecked {
                ++i;
            }
        }
    }

    function _isSafe(Types.State storage state, address trader)
        internal
        view
        returns (bool)
    {
        (
            int256 netPositionValue,
            ,
            uint256 maintenanceMargin
        ) = getTotalExposure(state, trader);

        // net value >= maintenanceMargin
        return
            netPositionValue +
                state.primaryCredit[trader] +
                int256(state.secondaryCredit[trader]) >=
            int256(maintenanceMargin);
    }

    /// @notice More strict than _isSafe.
    /// Additional requirement: netPositionValue + primaryCredit >= 0
    /// used when traders transfer out primary credit.
    function _isSolidSafe(Types.State storage state, address trader)
        internal
        view
        returns (bool)
    {
        (
            int256 netPositionValue,
            ,
            uint256 maintenanceMargin
        ) = getTotalExposure(state, trader);
        return
            netPositionValue + state.primaryCredit[trader] >= 0 &&
            netPositionValue +
                state.primaryCredit[trader] +
                int256(state.secondaryCredit[trader]) >=
            int256(maintenanceMargin);
    }

    /// @dev A gas saving way to check multi traders' safety status
    /// by caching mark prices
    function _isAllSafe(Types.State storage state, address[] calldata traderList)
        internal
        view
        returns (bool)
    {
        // cache mark price
        uint256 totalPerpNum = state.registeredPerp.length;
        address[] memory perpList = new address[](totalPerpNum);
        int256[] memory markPriceCache = new int256[](totalPerpNum);

        // check each trader's maintenance margin and net value
        for (uint256 i = 0; i < traderList.length; ) {
            address trader = traderList[i];
            uint256 maintenanceMargin;
            int256 netValue = state.primaryCredit[trader] +
                int256(state.secondaryCredit[trader]);

            // go through all open positions
            for (uint256 j = 0; j < state.openPositions[trader].length; ) {
                address perp = state.openPositions[trader][j];
                Types.RiskParams storage params = state.perpRiskParams[perp];
                int256 markPrice;
                // use cached price OR cache it
                for (uint256 k = 0; k < totalPerpNum; ) {
                    if (perpList[k] == perp) {
                        markPrice = markPriceCache[k];
                        break;
                    }
                    // if not, query mark price and cache it
                    if (perpList[k] == address(0)) {
                        markPrice = int256(
                            IMarkPriceSource(params.markPriceSource)
                                .getMarkPrice()
                        );
                        perpList[k] = perp;
                        markPriceCache[k] = markPrice;
                        break;
                    }
                    unchecked {
                        ++k;
                    }
                }
                (int256 paperAmount, int256 credit) = IPerpetual(perp)
                    .balanceOf(trader);
                maintenanceMargin +=
                    (paperAmount.decimalMul(markPrice).abs() *
                        params.liquidationThreshold) /
                    Types.ONE;
                netValue += paperAmount.decimalMul(markPrice) + credit;
                unchecked {
                    ++j;
                }
            }

            // return false if any one of traders is lack of collateral
            if (netValue < int256(maintenanceMargin)) {
                return false;
            }

            unchecked {
                ++i;
            }
        }
        return true;
    }

    /// @return liquidationPrice It should be considered as the position can never be
    /// liquidated (absolutely safe) or being liquidated at the present if return 0.
    function getLiquidationPrice(
        Types.State storage state,
        address trader,
        address perp
    ) external view returns (uint256 liquidationPrice) {
        if (!state.hasPosition[trader][perp]) {
            return 0;
        }

        /*
            To avoid liquidation, we need:
            netValue >= maintenanceMargin

            We first calculate the maintenanceMargin for all other markets' positions.
            Let's call it maintenanceMargin'

            Then we have netValue of the account.
            Let's call it netValue'

            So we have:
                netValue' + paperAmount * price + creditAmount >= maintenanceMargin' + abs(paperAmount) * price * liquidationThreshold
            
            if paperAmount > 0
                paperAmount * price * (1-liquidationThreshold) >= maintenanceMargin' - netValue' - creditAmount 
                price >= (maintenanceMargin' - netValue' - creditAmount)/paperAmount/(1-liquidationThreshold)
                liqPrice = (maintenanceMargin' - netValue' - creditAmount)/paperAmount/(1-liquidationThreshold)

            if paperAmount < 0
                paperAmount * price * (1+liquidationThreshold) >= maintenanceMargin' - netValue' - creditAmount 
                price <= (maintenanceMargin' - netValue' - creditAmount)/paperAmount/(1+liquidationThreshold)
                liqPrice = (maintenanceMargin' - netValue' - creditAmount)/paperAmount/(1+liquidationThreshold)
            
            Let's call 1±liquidationThreshold "multiplier"
            Then:
                liqPrice = (maintenanceMargin' - netValue' - creditAmount)/paperAmount/multiplier
            
            If liqPrice<0, it should be considered as the position can never be
            liquidated (absolutely safe) or being liquidated at the present if return 0.
        */
        int256 maintenanceMarginPrime;
        int256 netValuePrime = state.primaryCredit[trader] +
            int256(state.secondaryCredit[trader]);
        for (uint256 i = 0; i < state.openPositions[trader].length; i++) {
            address p = state.openPositions[trader][i];
            if (perp != p) {
                (
                    int256 paperAmountPrime,
                    int256 creditAmountPrime
                ) = IPerpetual(p).balanceOf(trader);
                Types.RiskParams storage params = state.perpRiskParams[p];
                int256 price = int256(
                    IMarkPriceSource(params.markPriceSource).getMarkPrice()
                );
                netValuePrime +=
                    paperAmountPrime.decimalMul(price) +
                    creditAmountPrime;
                maintenanceMarginPrime += int256(
                    (paperAmountPrime.decimalMul(price).abs() *
                        params.liquidationThreshold) / Types.ONE
                );
            }
        }
        (int256 paperAmount, int256 creditAmount) = IPerpetual(perp).balanceOf(
            trader
        );
        int256 multiplier = paperAmount > 0
            ? int256(Types.ONE - state.perpRiskParams[perp].liquidationThreshold)
            : int256(Types.ONE + state.perpRiskParams[perp].liquidationThreshold);
        int256 liqPrice = (maintenanceMarginPrime -
            netValuePrime -
            creditAmount).decimalDiv(paperAmount).decimalDiv(multiplier);
        return liqPrice < 0 ? 0 : uint256(liqPrice);
    }

    /// @notice Using a fixed discount price model.
    /// Charge fee from liquidated trader.
    /// Will limit you liquidation request to the position size.
    function getLiquidateCreditAmount(
        Types.State storage state,
        address perp,
        address liquidatedTrader,
        int256 requestPaperAmount
    )
        public
        view
        returns (
            int256 liqtorPaperChange,
            int256 liqtorCreditChange,
            uint256 insuranceFee
        )
    {
        // can not liquidate a safe trader
        require(!_isSafe(state, liquidatedTrader), Errors.ACCOUNT_IS_SAFE);

        // calculate and limit the paper change to the position size
        (int256 brokenPaperAmount, ) = IPerpetual(perp).balanceOf(
            liquidatedTrader
        );
        require(brokenPaperAmount != 0, Errors.TRADER_HAS_NO_POSITION);
        require(
            requestPaperAmount * brokenPaperAmount > 0,
            Errors.LIQUIDATION_REQUEST_AMOUNT_WRONG
        );
        liqtorPaperChange = requestPaperAmount.abs() > brokenPaperAmount.abs()
            ? brokenPaperAmount
            : requestPaperAmount;

        // get price
        Types.RiskParams storage params = state.perpRiskParams[perp];
        uint256 price = IMarkPriceSource(params.markPriceSource).getMarkPrice();
        uint256 priceOffset = (price * params.liquidationPriceOff) / Types.ONE;
        price = liqtorPaperChange > 0
            ? price - priceOffset
            : price + priceOffset;

        // calculate credit change
        liqtorCreditChange = -1 * liqtorPaperChange.decimalMul(int256(price));
        insuranceFee =
            (liqtorCreditChange.abs() * params.insuranceFeeRate) /
            Types.ONE;
    }

    /// @notice execute a liquidation request
    function requestLiquidation(
        Types.State storage state,
        address perp,
        address liquidator,
        address liquidatedTrader,
        int256 requestPaperAmount
    )
        external
        returns (
            int256 liqtorPaperChange,
            int256 liqtorCreditChange,
            int256 liqedPaperChange,
            int256 liqedCreditChange
        )
    {
        require(
            liquidatedTrader != liquidator,
            Errors.SELF_LIQUIDATION_NOT_ALLOWED
        );
        uint256 insuranceFee;
        (
            liqtorPaperChange,
            liqtorCreditChange,
            insuranceFee
        ) = getLiquidateCreditAmount(
            state,
            perp,
            liquidatedTrader,
            requestPaperAmount
        );
        state.primaryCredit[state.insurance] += int256(insuranceFee);

        // liquidated trader balance change
        liqedCreditChange = liqtorCreditChange * -1 - int256(insuranceFee);
        liqedPaperChange = liqtorPaperChange * -1;

        // events
        uint256 ltSN = state.positionSerialNum[liquidatedTrader][perp];
        uint256 liquidatorSN = state.positionSerialNum[liquidator][perp];
        emit BeingLiquidated(
            perp,
            liquidatedTrader,
            liqedPaperChange,
            liqedCreditChange,
            ltSN
        );
        emit JoinLiquidation(
            perp,
            liquidator,
            liquidatedTrader,
            liqtorPaperChange,
            liqtorCreditChange,
            liquidatorSN
        );
        emit ChargeInsurance(perp, liquidatedTrader, insuranceFee);
    }

    function getMarkPrice(Types.State storage state, address perp)
        external
        view
        returns (uint256 price)
    {
        price = IMarkPriceSource(state.perpRiskParams[perp].markPriceSource)
            .getMarkPrice();
    }

    function handleBadDebt(Types.State storage state, address liquidatedTrader)
        external
    {
        if (
            state.openPositions[liquidatedTrader].length == 0 &&
            !Liquidation._isSafe(state, liquidatedTrader)
        ) {
            int256 primaryCredit = state.primaryCredit[liquidatedTrader];
            uint256 secondaryCredit = state.secondaryCredit[liquidatedTrader];
            state.primaryCredit[state.insurance] += primaryCredit;
            state.secondaryCredit[state.insurance] += secondaryCredit;
            state.primaryCredit[liquidatedTrader] = 0;
            state.secondaryCredit[liquidatedTrader] = 0;
            emit HandleBadDebt(
                liquidatedTrader,
                primaryCredit,
                secondaryCredit
            );
        }
    }
}

/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

library Types {
    /// @notice data structure of dealer
    struct State {
        // primary asset, ERC20
        address primaryAsset;
        // secondary asset, ERC20
        address secondaryAsset;
        // credit, gained by deposit assets
        mapping(address => int256) primaryCredit;
        mapping(address => uint256) secondaryCredit;
        // withdrawal request time lock
        uint256 withdrawTimeLock;
        // pending primary asset withdrawal amount
        mapping(address => uint256) pendingPrimaryWithdraw;
        // pending secondary asset withdrawal amount
        mapping(address => uint256) pendingSecondaryWithdraw;
        // withdrawal request executable timestamp
        mapping(address => uint256) withdrawExecutionTimestamp;
        // perpetual contract risk parameters
        mapping(address => Types.RiskParams) perpRiskParams;
        // perpetual contract registry, for view
        address[] registeredPerp;
        // all open positions of a trader
        mapping(address => address[]) openPositions;
        // To quickly search if a trader has open position:
        // trader => perpetual contract address => hasPosition
        mapping(address => mapping(address => bool)) hasPosition;
        // For offchain pnl calculation, serial number +1 whenever 
        // position is fully closed.
        // trader => perpetual contract address => current serial Num
        mapping(address => mapping(address => uint256)) positionSerialNum;
        // filled amount of orders
        mapping(bytes32 => uint256) orderFilledPaperAmount;
        // valid order sender registry
        mapping(address => bool) validOrderSender;
        // operator registry
        // client => operator => isValid
        mapping(address => mapping(address => bool)) operatorRegistry;
        // insurance account
        address insurance;
        // funding rate keeper, normally an EOA account
        address fundingRateKeeper;
    }

    struct Order {
        // address of perpetual market
        address perp;
        /*
            Signer is trader, the identity of trading behavior,
            whose balance will be changed.
            Normally it should be an EOA account and the 
            order is valid only if the signer signed it.
            If the signer is a contract, it must implement
            isValidPerpetualOperator(address) returns(bool).
            The order is valid only if one of the valid operators
            is an EOA account and signed the order.
        */
        address signer;
        // positive(negative) if you want to open long(short) position
        int128 paperAmount;
        // negative(positive) if you want to open short(long) position
        int128 creditAmount;
        /*
            ╔═══════════════════╤═════════╗
            ║ info component    │ type    ║
            ╟───────────────────┼─────────╢
            ║ makerFeeRate      │ int64   ║
            ║ takerFeeRate      │ int64   ║
            ║ expiration        │ uint64  ║
            ║ nonce             │ uint64  ║
            ╚═══════════════════╧═════════╝
        */
        bytes32 info;
    }

    // EIP712 component
    bytes32 public constant ORDER_TYPEHASH =
        keccak256(
            "Order(address perp,address signer,int128 paperAmount,int128 creditAmount,bytes32 info)"
        );

    /// @notice risk params of a perpetual market
    struct RiskParams {
        /*
            Liquidation will happen when
            netValue < exposure * liquidationThreshold
            The lower liquidationThreshold, the higher leverage.
            1E18 based decimal.
        */
        uint256 liquidationThreshold;
        /*
            The discount rate for the liquidation.
            markPrice * (1 - liquidationPriceOff) when liquidate long position
            markPrice * (1 + liquidationPriceOff) when liquidate short position
            1e18 based decimal.
        */
        uint256 liquidationPriceOff;
        // The insurance fee rate charged from liquidation. 
        // 1E18 based decimal.
        uint256 insuranceFeeRate;
        // price source of mark price
        address markPriceSource;
        // perpetual market name
        string name;
        // if the market is activited
        bool isRegistered;
    }

    /// @notice Match result obtained by parsing and validating tradeData.
    /// Contains arrays of balance change.
    struct MatchResult {
        address[] traderList;
        int256[] paperChangeList;
        int256[] creditChangeList;
        int256 orderSenderFee;
    }

    uint256 constant ONE = 10**18;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "../utils/Errors.sol";
import "./Types.sol";

library Position {

    // ========== position register ==========

    /// @notice add position when trade or liquidation happen
    /// msg.sender is the perpetual contract
    function _openPosition(
        Types.State storage state,
        address trader
    ) internal {
        if (!state.hasPosition[trader][msg.sender]) {
            state.hasPosition[trader][msg.sender] = true;
            state.openPositions[trader].push(msg.sender);
        }
    }

    /// @notice realize pnl and remove position from the registry
    /// msg.sender is the perpetual contract
    function _realizePnl(
        Types.State storage state,
        address trader,
        int256 pnl
    ) internal {
        state.hasPosition[trader][msg.sender] = false;
        state.primaryCredit[trader] += pnl;
        state.positionSerialNum[trader][msg.sender] += 1;

        address[] storage positionList = state.openPositions[trader];
        for (uint256 i = 0; i < positionList.length; i++) {
            if (positionList[i] == msg.sender) {
                positionList[i] = positionList[positionList.length - 1];
                positionList.pop();
                break;
            }
        }
    }
}