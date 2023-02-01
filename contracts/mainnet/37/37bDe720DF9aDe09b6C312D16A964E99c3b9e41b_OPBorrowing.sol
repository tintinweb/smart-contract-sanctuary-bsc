// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.17;

import "./common/DelegateInterface.sol";
import "./common/Adminable.sol";
import "./common/ReentrancyGuard.sol";
import "./IOPBorrowing.sol";
import "./libraries/TransferHelper.sol";
import "./libraries/DexData.sol";
import "./libraries/Utils.sol";

import "./OPBorrowingLib.sol";

contract OPBorrowing is DelegateInterface, Adminable, ReentrancyGuard, IOPBorrowing, OPBorrowingStorage {
    using TransferHelper for IERC20;
    using DexData for bytes;

    constructor(
        OpenLevInterface _openLev,
        ControllerInterface _controller,
        DexAggregatorInterface _dexAgg,
        XOLEInterface _xOLE,
        address _wETH
    ) OPBorrowingStorage(_openLev, _controller, _dexAgg, _xOLE, _wETH) {}

    /// @notice Initialize contract only by admin
    /// @dev This function is supposed to call multiple times
    /// @param _marketDefConf The market default config after the new market was created
    /// @param _liquidationConf The liquidation config
    function initialize(MarketConf memory _marketDefConf, LiquidationConf memory _liquidationConf) external override onlyAdmin {
        marketDefConf = _marketDefConf;
        liquidationConf = _liquidationConf;
    }

    /// @notice Create new market only by controller contract
    /// @param marketId The new market id
    /// @param pool0 The pool0 address
    /// @param pool1 The pool1 address
    /// @param dexData The dex data (0x03 means PANCAKE)
    function addMarket(uint16 marketId, LPoolInterface pool0, LPoolInterface pool1, bytes memory dexData) external override {
        require(msg.sender == address(controller), "NCN");
        addMarketInternal(marketId, pool0, pool1, pool0.underlying(), pool1.underlying(), dexData);
    }

    struct BorrowVars {
        address collateralToken; // the collateral token address
        address borrowToken; // the borrow token address
        LPoolInterface borrowPool; // the borrow pool address
        uint collateralTotalReserve; // the collateral token balance of this contract
        uint collateralTotalShare; // the collateral token total share
        uint borrowTotalReserve; // the borrow token balance of this contract
        uint borrowTotalShare; // the borrow token total share
    }

    /// @notice Sender collateralize token to borrow this market another token
    /// @dev This function will collect borrow fees and check the borrowing amount is healthy
    /// @param marketId The market id
    /// @param collateralIndex The collateral index (false means token0)
    /// @param collateral The collateral token amount
    /// @param borrowing The borrow token amount to borrow
    function borrow(uint16 marketId, bool collateralIndex, uint collateral, uint borrowing) external payable override nonReentrant {
        address borrower = msg.sender;
        controller.collBorrowAllowed(marketId, borrower, collateralIndex);

        BorrowVars memory borrowVars = toBorrowVars(marketId, collateralIndex);

        MarketConf storage marketConf = marketsConf[marketId];
        collateral = OPBorrowingLib.transferIn(borrower, IERC20(borrowVars.collateralToken), wETH, collateral);

        if (collateral > 0) {
            // amount to share
            collateral = OPBorrowingLib.amountToShare(collateral, borrowVars.collateralTotalShare, borrowVars.collateralTotalReserve);
            increaseCollateralShare(borrower, marketId, collateralIndex, borrowVars.collateralToken, collateral);
        }
        require(collateral > 0 || borrowing > 0, "CB0");
        uint fees;
        if (borrowing > 0) {
            // check minimal borrowing > absolute value 0.0001
            {
                uint decimals = OPBorrowingLib.decimals(borrowVars.borrowToken);
                uint minimalBorrows = decimals > 4 ? 10 ** (decimals - 4) : 1;
                require(borrowing > minimalBorrows, "BTS");
            }

            uint borrowed = OPBorrowingLib.borrowBehalf(borrowVars.borrowPool, borrowVars.borrowToken, borrower, borrowing);
            // check pool's liquidity * maxLiquidityRatio >= totalBorrow
            {
                uint borrowTWALiquidity = collateralIndex ? twaLiquidity[marketId].token0Liq : twaLiquidity[marketId].token1Liq;
                bytes memory dexData = OPBorrowingLib.uint32ToBytes(markets[marketId].dex);
                uint borrowLiquidity = dexAgg.getToken0Liquidity(borrowVars.borrowToken, borrowVars.collateralToken, dexData);
                uint minLiquidity = Utils.minOf(borrowTWALiquidity, borrowLiquidity);
                require((minLiquidity * marketConf.maxLiquidityRatio) / RATIO_DENOMINATOR >= borrowVars.borrowPool.totalBorrows(), "BGL");
                // check healthy
                uint totalCollateral = activeCollaterals[borrower][marketId][collateralIndex];
                uint accountTotalBorrowed = OPBorrowingLib.borrowStored(borrowVars.borrowPool, borrower);
                require(
                    checkHealthy(
                        marketId,
                        OPBorrowingLib.shareToAmount(
                            totalCollateral,
                            totalShares[borrowVars.collateralToken],
                            OPBorrowingLib.balanceOf(IERC20(borrowVars.collateralToken))
                        ),
                        accountTotalBorrowed,
                        borrowVars.collateralToken,
                        borrowVars.borrowToken
                    ),
                    "BNH"
                );
            }
            // collect borrow fees
            fees = collectBorrowFee(
                marketId,
                collateralIndex,
                borrowing,
                borrowVars.borrowToken,
                borrowVars.borrowPool,
                borrowVars.borrowTotalReserve,
                borrowVars.borrowTotalShare
            );
            // transfer out borrowed - fees
            OPBorrowingLib.doTransferOut(borrower, IERC20(borrowVars.borrowToken), wETH, borrowed - fees);
        }

        emit Borrow(borrower, marketId, collateralIndex, collateral, borrowing, fees);
    }

    /// @notice Sender repay borrowings and redeem collateral token
    /// @dev This function will redeem all collateral token if borrowing is 0
    ///  and redeem partial collateral token if the isRedeem=true and borrowing is healthy
    /// @param marketId The market id
    /// @param collateralIndex The collateral index (false means token0)
    /// @param repayAmount The amount to repay
    /// @param isRedeem If equal true, will redeem (repayAmount/totalBorrowing)*collateralAmount token
    function repay(uint16 marketId, bool collateralIndex, uint repayAmount, bool isRedeem) external payable override nonReentrant returns (uint redeemShare) {
        address borrower = msg.sender;
        controller.collRepayAllowed(marketId);
        // check collateral
        uint collateral = activeCollaterals[borrower][marketId][collateralIndex];
        checkCollateral(collateral);

        BorrowVars memory borrowVars = toBorrowVars(marketId, collateralIndex);

        uint borrowPrior = OPBorrowingLib.borrowCurrent(borrowVars.borrowPool, borrower);
        require(borrowPrior > 0, "BL0");
        if (repayAmount == type(uint256).max) {
            repayAmount = borrowPrior;
        }
        repayAmount = OPBorrowingLib.transferIn(borrower, IERC20(borrowVars.borrowToken), wETH, repayAmount);
        require(repayAmount > 0, "RL0");
        // repay
        OPBorrowingLib.repay(borrowVars.borrowPool, borrower, repayAmount);
        uint borrowAfterRepay = OPBorrowingLib.borrowStored(borrowVars.borrowPool, borrower);
        // in the tax token case, should get actual repayment amount
        repayAmount = borrowPrior - borrowAfterRepay;
        // borrowing is 0, so return all collateral
        if (borrowAfterRepay == 0) {
            redeemShare = collateral;
            decreaseCollateralShare(borrower, marketId, collateralIndex, borrowVars.collateralToken, redeemShare);
            OPBorrowingLib.doTransferOut(
                borrower,
                IERC20(borrowVars.collateralToken),
                wETH,
                OPBorrowingLib.shareToAmount(redeemShare, borrowVars.collateralTotalShare, borrowVars.collateralTotalReserve)
            );
        }
        // redeem collateral= borrower.collateral * repayRatio
        else if (isRedeem) {
            uint repayRatio = (repayAmount * RATIO_DENOMINATOR) / borrowPrior;
            redeemShare = (collateral * repayRatio) / RATIO_DENOMINATOR;
            if (redeemShare > 0) {
                redeemInternal(borrower, marketId, collateralIndex, redeemShare, borrowAfterRepay, borrowVars);
            }
        }
        emit Repay(borrower, marketId, collateralIndex, repayAmount, redeemShare);
    }

    /// @notice Sender redeem collateral token
    /// @dev This function will check borrowing is healthy after collateral redeemed
    /// @param marketId The market id
    /// @param collateral The collateral index (false means token0)
    /// @param collateral The collateral share to redeem
    function redeem(uint16 marketId, bool collateralIndex, uint collateral) external override nonReentrant {
        address borrower = msg.sender;
        controller.collRedeemAllowed(marketId);

        BorrowVars memory borrowVars = toBorrowVars(marketId, collateralIndex);

        uint borrowPrior = OPBorrowingLib.borrowCurrent(borrowVars.borrowPool, borrower);

        redeemInternal(borrower, marketId, collateralIndex, collateral, borrowPrior, borrowVars);

        emit Redeem(borrower, marketId, collateralIndex, collateral);
    }

    struct LiquidateVars {
        uint collateralAmount; // the amount of collateral token
        uint borrowing; // the borrowing amount
        uint liquidationAmount; // the amount of collateral token to liquidate
        uint liquidationShare; // the share of collateral token to liquidate
        uint liquidationFees; // the liquidation fees
        bool isPartialLiquidate; // liquidate partial or fully
        bytes dexData; // the dex data
        bool buySuccess; // Whether or not buy enough borrowing token to repay
        uint repayAmount; // the repay amount
        uint buyAmount; // buy borrowing token amount
        uint price0; // the price of token0/token1
        uint collateralToBorrower; // the collateral amount back to the borrower
        uint outstandingAmount; // the outstanding amount
    }

    /// @notice Liquidate borrower collateral
    /// @dev This function will call by any users and bots.
    /// will trigger in the borrower collateral * ratio < borrowing
    /// @param marketId The market id
    /// @param collateralIndex The collateral index (false means token0)
    /// @param borrower The borrower address
    function liquidate(uint16 marketId, bool collateralIndex, address borrower) external override nonReentrant {
        controller.collLiquidateAllowed(marketId);
        // check collateral
        uint collateral = activeCollaterals[borrower][marketId][collateralIndex];
        checkCollateral(collateral);

        BorrowVars memory borrowVars = toBorrowVars(marketId, collateralIndex);
        LiquidateVars memory liquidateVars;
        liquidateVars.borrowing = OPBorrowingLib.borrowCurrent(borrowVars.borrowPool, borrower);
        liquidateVars.collateralAmount = OPBorrowingLib.shareToAmount(collateral, borrowVars.collateralTotalShare, borrowVars.collateralTotalReserve);

        // check liquidable
        require(checkLiquidable(marketId, liquidateVars.collateralAmount, liquidateVars.borrowing, borrowVars.collateralToken, borrowVars.borrowToken), "BIH");
        // check msg.sender xOLE
        require(xOLE.balanceOf(msg.sender) >= liquidationConf.liquidatorXOLEHeld, "XNE");
        // compute liquidation collateral
        MarketConf storage marketConf = marketsConf[marketId];
        liquidateVars.liquidationAmount = liquidateVars.collateralAmount;
        liquidateVars.liquidationShare = collateral;
        liquidateVars.dexData = OPBorrowingLib.uint32ToBytes(markets[marketId].dex);
        // liquidationAmount = collateralAmount/2 when the collateralAmount >= liquidity * liquidateMaxLiquidityRatio
        {
            uint collateralLiquidity = dexAgg.getToken0Liquidity(borrowVars.collateralToken, borrowVars.borrowToken, liquidateVars.dexData);
            uint maxLiquidity = (collateralLiquidity * marketConf.liquidateMaxLiquidityRatio) / RATIO_DENOMINATOR;
            if (liquidateVars.liquidationAmount >= maxLiquidity) {
                liquidateVars.liquidationShare = liquidateVars.liquidationShare / 2;
                liquidateVars.liquidationAmount = OPBorrowingLib.shareToAmount(
                    liquidateVars.liquidationShare,
                    borrowVars.collateralTotalShare,
                    borrowVars.collateralTotalReserve
                );
                liquidateVars.isPartialLiquidate = true;
            }
        }
        (liquidateVars.price0, ) = dexAgg.getPrice(markets[marketId].token0, markets[marketId].token1, liquidateVars.dexData);
        // compute sell collateral amount, borrowings + liquidationFees + tax
        {
            uint24 borrowTokenTransTax = openLev.taxes(marketId, borrowVars.borrowToken, 0);
            uint24 borrowTokenBuyTax = openLev.taxes(marketId, borrowVars.borrowToken, 2);
            uint24 collateralSellTax = openLev.taxes(marketId, borrowVars.collateralToken, 1);

            liquidateVars.repayAmount = Utils.toAmountBeforeTax(liquidateVars.borrowing, borrowTokenTransTax);
            liquidateVars.liquidationFees = (liquidateVars.borrowing * marketConf.liquidateFeesRatio) / RATIO_DENOMINATOR;
            OPBorrowingLib.safeApprove(IERC20(borrowVars.collateralToken), address(dexAgg), liquidateVars.liquidationAmount);
            (liquidateVars.buySuccess, ) = address(dexAgg).call(
                abi.encodeWithSelector(
                    dexAgg.buy.selector,
                    borrowVars.borrowToken,
                    borrowVars.collateralToken,
                    borrowTokenBuyTax,
                    collateralSellTax,
                    liquidateVars.repayAmount + liquidateVars.liquidationFees,
                    liquidateVars.liquidationAmount,
                    liquidateVars.dexData
                )
            );
        }
        /*
         * if buySuccess==true, repay all debts and returns collateral
         */
        if (liquidateVars.buySuccess) {
            uint sellAmount = borrowVars.collateralTotalReserve - OPBorrowingLib.balanceOf(IERC20(borrowVars.collateralToken));
            liquidateVars.collateralToBorrower = liquidateVars.collateralAmount - sellAmount;
            liquidateVars.buyAmount = OPBorrowingLib.balanceOf(IERC20(borrowVars.borrowToken)) - borrowVars.borrowTotalReserve;
            require(liquidateVars.buyAmount >= liquidateVars.repayAmount, "BLR");
            OPBorrowingLib.repay(borrowVars.borrowPool, borrower, liquidateVars.repayAmount);
            // check borrowing is 0
            require(OPBorrowingLib.borrowStored(borrowVars.borrowPool, borrower) == 0, "BG0");
            unchecked {
                liquidateVars.liquidationFees = liquidateVars.buyAmount - liquidateVars.repayAmount;
            }
            liquidateVars.liquidationShare = collateral;
        }
        /*
         * if buySuccess==false and isPartialLiquidate==true, sell liquidation amount and repay with buyAmount
         * if buySuccess==false and isPartialLiquidate==false, sell liquidation amount and repay with buyAmount + insurance
         */
        else {
            liquidateVars.buyAmount = dexAgg.sell(
                borrowVars.borrowToken,
                borrowVars.collateralToken,
                liquidateVars.liquidationAmount,
                0,
                liquidateVars.dexData
            );
            liquidateVars.liquidationFees = (liquidateVars.buyAmount * marketConf.liquidateFeesRatio) / RATIO_DENOMINATOR;
            if (liquidateVars.isPartialLiquidate) {
                liquidateVars.repayAmount = liquidateVars.buyAmount - liquidateVars.liquidationFees;
                OPBorrowingLib.repay(borrowVars.borrowPool, borrower, liquidateVars.repayAmount);
                require(OPBorrowingLib.borrowStored(borrowVars.borrowPool, borrower) != 0, "BE0");
            } else {
                uint insuranceShare = collateralIndex ? insurances[marketId].insurance0 : insurances[marketId].insurance1;
                uint insuranceAmount = OPBorrowingLib.shareToAmount(insuranceShare, borrowVars.borrowTotalShare, borrowVars.borrowTotalReserve);
                uint diffRepayAmount = liquidateVars.repayAmount + liquidateVars.liquidationFees - liquidateVars.buyAmount;
                uint insuranceDecrease;
                if (insuranceAmount >= diffRepayAmount) {
                    OPBorrowingLib.repay(borrowVars.borrowPool, borrower, liquidateVars.repayAmount);
                    insuranceDecrease = OPBorrowingLib.amountToShare(diffRepayAmount, borrowVars.borrowTotalShare, borrowVars.borrowTotalReserve);
                } else {
                    liquidateVars.repayAmount = liquidateVars.buyAmount + insuranceAmount - liquidateVars.liquidationFees;
                    borrowVars.borrowPool.repayBorrowEndByOpenLev(borrower, liquidateVars.repayAmount);
                    liquidateVars.outstandingAmount = diffRepayAmount - insuranceAmount;
                    insuranceDecrease = insuranceShare;
                }
                decreaseInsuranceShare(insurances[marketId], !collateralIndex, borrowVars.borrowToken, insuranceDecrease);
            }
        }
        // collect liquidation fees
        collectLiquidationFee(
            marketId,
            collateralIndex,
            liquidateVars.liquidationFees,
            borrowVars.borrowToken,
            borrowVars.borrowPool,
            borrowVars.borrowTotalReserve,
            borrowVars.borrowTotalShare
        );
        decreaseCollateralShare(borrower, marketId, collateralIndex, borrowVars.collateralToken, liquidateVars.liquidationShare);
        // transfer remaining collateral to borrower
        if (liquidateVars.collateralToBorrower > 0) {
            OPBorrowingLib.doTransferOut(borrower, IERC20(borrowVars.collateralToken), wETH, liquidateVars.collateralToBorrower);
        }
        emit Liquidate(
            borrower,
            marketId,
            collateralIndex,
            msg.sender,
            liquidateVars.liquidationShare,
            liquidateVars.repayAmount,
            liquidateVars.outstandingAmount,
            liquidateVars.liquidationFees,
            liquidateVars.price0
        );
    }

    /// @notice Borrower collateral ratio
    /// @dev This function will compute borrower collateral ratio=collateral * ratio / borrowing (10000 means 100%).
    /// If the collateral ratio is less than 10000, it can be liquidated
    /// @param marketId The market id
    /// @param collateralIndex The collateral index (false means token0)
    /// @param borrower The borrower address
    /// @return scaled by RATIO_DENOMINATOR
    function collateralRatio(uint16 marketId, bool collateralIndex, address borrower) external view override returns (uint) {
        BorrowVars memory borrowVars = toBorrowVars(marketId, collateralIndex);
        uint borrowed = borrowVars.borrowPool.borrowBalanceCurrent(borrower);
        uint collateral = activeCollaterals[borrower][marketId][collateralIndex];
        if (borrowed == 0 || collateral == 0) {
            return 100 * RATIO_DENOMINATOR;
        }
        uint collateralAmount = OPBorrowingLib.shareToAmount(collateral, borrowVars.collateralTotalShare, borrowVars.collateralTotalReserve);
        MarketConf storage marketConf = marketsConf[marketId];
        bytes memory dexData = OPBorrowingLib.uint32ToBytes(markets[marketId].dex);
        (uint price, uint8 decimals) = dexAgg.getPrice(borrowVars.collateralToken, borrowVars.borrowToken, dexData);
        return (((collateralAmount * price) / (10 ** uint(decimals))) * marketConf.collateralRatio) / borrowed;
    }

    /*** Admin Functions ***/

    /// @notice Admin migrate markets from openLev contract
    /// @param from The from market id
    /// @param to The to market id
    function migrateOpenLevMarkets(uint16 from, uint16 to) external override onlyAdmin {
        for (uint16 i = from; i <= to; i++) {
            OpenLevInterface.Market memory market = openLev.markets(i);
            addMarketInternal(
                i,
                LPoolInterface(market.pool0),
                LPoolInterface(market.pool1),
                market.token0,
                market.token1,
                OPBorrowingLib.uint32ToBytes(openLev.getMarketSupportDexs(i)[0])
            );
        }
    }

    function setTwaLiquidity(uint16[] calldata marketIds, OPBorrowingStorage.Liquidity[] calldata liquidity) external override onlyAdminOrDeveloper {
        require(marketIds.length == liquidity.length, "IIL");
        for (uint i = 0; i < marketIds.length; i++) {
            uint16 marketId = marketIds[i];
            setTwaLiquidityInternal(marketId, liquidity[i].token0Liq, liquidity[i].token1Liq);
        }
    }

    function setMarketConf(uint16 marketId, OPBorrowingStorage.MarketConf calldata _marketConf) external override onlyAdmin {
        marketsConf[marketId] = _marketConf;
        emit NewMarketConf(
            marketId,
            _marketConf.collateralRatio,
            _marketConf.maxLiquidityRatio,
            _marketConf.borrowFeesRatio,
            _marketConf.insuranceRatio,
            _marketConf.poolReturnsRatio,
            _marketConf.liquidateFeesRatio,
            _marketConf.liquidatorReturnsRatio,
            _marketConf.liquidateInsuranceRatio,
            _marketConf.liquidatePoolReturnsRatio,
            _marketConf.liquidateMaxLiquidityRatio,
            _marketConf.twapDuration
        );
    }

    function setMarketDex(uint16 marketId, uint32 dex) external override onlyAdmin {
        markets[marketId].dex = dex;
    }

    /// @notice Admin move insurance to other address
    /// @param marketId The market id
    /// @param tokenIndex The token index (false means token0)
    /// @param to The address of insurance to transfer
    /// @param moveShare The insurance share to move
    function moveInsurance(uint16 marketId, bool tokenIndex, address to, uint moveShare) external override onlyAdmin {
        address token = !tokenIndex ? markets[marketId].token0 : markets[marketId].token1;
        uint256 totalShare = totalShares[token];
        decreaseInsuranceShare(insurances[marketId], tokenIndex, token, moveShare);
        OPBorrowingLib.safeTransfer(IERC20(token), to, OPBorrowingLib.shareToAmount(moveShare, totalShare, OPBorrowingLib.balanceOf(IERC20(token))));
    }

    function redeemInternal(address borrower, uint16 marketId, bool collateralIndex, uint redeemShare, uint borrowing, BorrowVars memory borrowVars) internal {
        uint collateral = activeCollaterals[borrower][marketId][collateralIndex];
        require(collateral >= redeemShare, "RGC");
        decreaseCollateralShare(borrower, marketId, collateralIndex, borrowVars.collateralToken, redeemShare);
        // redeem
        OPBorrowingLib.doTransferOut(
            borrower,
            IERC20(borrowVars.collateralToken),
            wETH,
            OPBorrowingLib.shareToAmount(redeemShare, borrowVars.collateralTotalShare, borrowVars.collateralTotalReserve)
        );
        // check healthy
        require(
            checkHealthy(
                marketId,
                OPBorrowingLib.shareToAmount(
                    activeCollaterals[borrower][marketId][collateralIndex],
                    totalShares[borrowVars.collateralToken],
                    OPBorrowingLib.balanceOf(IERC20(borrowVars.collateralToken))
                ),
                borrowing,
                borrowVars.collateralToken,
                borrowVars.borrowToken
            ),
            "BNH"
        );
    }

    function increaseCollateralShare(address borrower, uint16 marketId, bool collateralIndex, address token, uint increaseShare) internal {
        activeCollaterals[borrower][marketId][collateralIndex] += increaseShare;
        totalShares[token] += increaseShare;
    }

    function decreaseCollateralShare(address borrower, uint16 marketId, bool collateralIndex, address token, uint decreaseShare) internal {
        activeCollaterals[borrower][marketId][collateralIndex] -= decreaseShare;
        totalShares[token] -= decreaseShare;
    }

    function increaseInsuranceShare(Insurance storage insurance, bool index, address token, uint increaseShare) internal {
        if (!index) {
            insurance.insurance0 += increaseShare;
        } else {
            insurance.insurance1 += increaseShare;
        }
        totalShares[token] += increaseShare;
    }

    function decreaseInsuranceShare(Insurance storage insurance, bool index, address token, uint decreaseShare) internal {
        if (!index) {
            insurance.insurance0 -= decreaseShare;
        } else {
            insurance.insurance1 -= decreaseShare;
        }
        totalShares[token] -= decreaseShare;
    }

    function checkCollateral(uint collateral) internal pure {
        require(collateral > 0, "CE0");
    }

    function collectBorrowFee(
        uint16 marketId,
        bool collateralIndex,
        uint borrowed,
        address borrowToken,
        LPoolInterface borrowPool,
        uint borrowTotalReserve,
        uint borrowTotalShare
    ) internal returns (uint) {
        MarketConf storage marketConf = marketsConf[marketId];
        uint fees = (borrowed * marketConf.borrowFeesRatio) / RATIO_DENOMINATOR;
        if (fees > 0) {
            uint poolReturns = (fees * marketConf.poolReturnsRatio) / RATIO_DENOMINATOR;
            if (poolReturns > 0) {
                OPBorrowingLib.safeTransfer(IERC20(borrowToken), address(borrowPool), poolReturns);
            }
            uint insurance = (fees * marketConf.insuranceRatio) / RATIO_DENOMINATOR;
            if (insurance > 0) {
                uint increaseInsurance = OPBorrowingLib.amountToShare(insurance, borrowTotalShare, borrowTotalReserve);
                increaseInsuranceShare(insurances[marketId], !collateralIndex, borrowToken, increaseInsurance);
            }
            uint xoleAmount = fees - poolReturns - insurance;
            if (xoleAmount > 0) {
                OPBorrowingLib.safeTransfer(IERC20(borrowToken), address(xOLE), xoleAmount);
            }
        }
        return fees;
    }

    function collectLiquidationFee(
        uint16 marketId,
        bool collateralIndex,
        uint liquidationFees,
        address borrowToken,
        LPoolInterface borrowPool,
        uint borrowTotalReserve,
        uint borrowTotalShare
    ) internal returns (bool buyBackSuccess) {
        if (liquidationFees > 0) {
            MarketConf storage marketConf = marketsConf[marketId];
            uint poolReturns = (liquidationFees * marketConf.liquidatePoolReturnsRatio) / RATIO_DENOMINATOR;
            if (poolReturns > 0) {
                OPBorrowingLib.safeTransfer(IERC20(borrowToken), address(borrowPool), poolReturns);
            }
            uint insurance = (liquidationFees * marketConf.liquidateInsuranceRatio) / RATIO_DENOMINATOR;
            if (insurance > 0) {
                uint increaseInsurance = OPBorrowingLib.amountToShare(insurance, borrowTotalShare, borrowTotalReserve);
                increaseInsuranceShare(insurances[marketId], !collateralIndex, borrowToken, increaseInsurance);
            }
            uint liquidatorReturns = (liquidationFees * marketConf.liquidatorReturnsRatio) / RATIO_DENOMINATOR;
            if (liquidatorReturns > 0) {
                OPBorrowingLib.safeTransfer(IERC20(borrowToken), msg.sender, liquidatorReturns);
            }
            uint buyBackAmount = liquidationFees - poolReturns - insurance - liquidatorReturns;
            if (buyBackAmount > 0) {
                OPBorrowingLib.safeApprove(IERC20(borrowToken), address(liquidationConf.buyBack), buyBackAmount);
                (buyBackSuccess, ) = address(liquidationConf.buyBack).call(
                    abi.encodeWithSelector(liquidationConf.buyBack.transferIn.selector, borrowToken, buyBackAmount)
                );
            }
        }
    }

    /// @notice Check collateral * ratio >= borrowed
    function checkHealthy(uint16 marketId, uint collateral, uint borrowed, address collateralToken, address borrowToken) internal returns (bool) {
        if (borrowed == 0) {
            return true;
        }
        MarketConf storage marketConf = marketsConf[marketId];
        // update price
        uint32 dex = markets[marketId].dex;
        uint collateralPrice;
        uint denominator;
        {
            (uint price, uint cAvgPrice, uint hAvgPrice, uint8 decimals, ) = updatePrices(collateralToken, borrowToken, marketConf.twapDuration, dex);
            collateralPrice = Utils.minOf(Utils.minOf(price, cAvgPrice), hAvgPrice);
            denominator = (10 ** uint(decimals));
        }
        return (((collateral * collateralPrice) / denominator) * marketConf.collateralRatio) / RATIO_DENOMINATOR >= borrowed;
    }

    /// @notice Check collateral * ratio < borrowed
    function checkLiquidable(uint16 marketId, uint collateral, uint borrowed, address collateralToken, address borrowToken) internal returns (bool) {
        if (borrowed == 0) {
            return false;
        }
        MarketConf storage marketConf = marketsConf[marketId];
        // update price
        uint32 dex = markets[marketId].dex;
        uint collateralPrice;
        uint denominator;
        {
            (uint price, uint cAvgPrice, uint hAvgPrice, uint8 decimals, ) = updatePrices(collateralToken, borrowToken, marketConf.twapDuration, dex);
            // avoids flash loan
            if (price < cAvgPrice && price != 0) {
                uint diffPriceRatio = (cAvgPrice * 100) / price;
                require(diffPriceRatio - 100 <= liquidationConf.priceDiffRatio, "MPT");
            }
            collateralPrice = Utils.maxOf(Utils.maxOf(price, cAvgPrice), hAvgPrice);
            denominator = (10 ** uint(decimals));
        }
        return (((collateral * collateralPrice) / denominator) * marketConf.collateralRatio) / RATIO_DENOMINATOR < borrowed;
    }

    function updatePrices(
        address collateralToken,
        address borrowToken,
        uint16 twapDuration,
        uint32 dex
    ) internal returns (uint price, uint cAvgPrice, uint hAvgPrice, uint8 decimals, uint timestamp) {
        bytes memory dexData = OPBorrowingLib.uint32ToBytes(dex);
        if (dexData.isUniV2Class()) {
            dexAgg.updatePriceOracle(collateralToken, borrowToken, twapDuration, dexData);
        }
        (price, cAvgPrice, hAvgPrice, decimals, timestamp) = dexAgg.getPriceCAvgPriceHAvgPrice(collateralToken, borrowToken, twapDuration, dexData);
    }

    function addMarketInternal(uint16 marketId, LPoolInterface pool0, LPoolInterface pool1, address token0, address token1, bytes memory dexData) internal {
        // init market info
        markets[marketId] = Market(pool0, pool1, token0, token1, dexData.toDexDetail());
        // init default config
        marketsConf[marketId] = marketDefConf;
        // init liquidity
        (uint token0Liq, uint token1Liq) = dexAgg.getPairLiquidity(token0, token1, dexData);
        setTwaLiquidityInternal(marketId, token0Liq, token1Liq);
        // approve the max number for pools
        OPBorrowingLib.safeApprove(IERC20(token0), address(pool0), type(uint256).max);
        OPBorrowingLib.safeApprove(IERC20(token1), address(pool1), type(uint256).max);
        emit NewMarket(marketId, pool0, pool1, token0, token1, dexData.toDexDetail(), token0Liq, token1Liq);
    }

    function setTwaLiquidityInternal(uint16 marketId, uint token0Liq, uint token1Liq) internal {
        uint oldToken0Liq = twaLiquidity[marketId].token0Liq;
        uint oldToken1Liq = twaLiquidity[marketId].token1Liq;
        twaLiquidity[marketId] = Liquidity(token0Liq, token1Liq);
        emit NewLiquidity(marketId, oldToken0Liq, oldToken1Liq, token0Liq, token1Liq);
    }

    function toBorrowVars(uint16 marketId, bool collateralIndex) internal view returns (BorrowVars memory) {
        BorrowVars memory borrowVars;
        borrowVars.collateralToken = collateralIndex ? markets[marketId].token1 : markets[marketId].token0;
        borrowVars.borrowToken = collateralIndex ? markets[marketId].token0 : markets[marketId].token1;
        borrowVars.borrowPool = collateralIndex ? markets[marketId].pool0 : markets[marketId].pool1;
        borrowVars.collateralTotalReserve = OPBorrowingLib.balanceOf(IERC20(borrowVars.collateralToken));
        borrowVars.collateralTotalShare = totalShares[borrowVars.collateralToken];
        borrowVars.borrowTotalReserve = OPBorrowingLib.balanceOf(IERC20(borrowVars.borrowToken));
        borrowVars.borrowTotalShare = totalShares[borrowVars.borrowToken];
        return borrowVars;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;

library Utils {
    uint private constant FEE_RATE_PRECISION = 10 ** 6;

    function toAmountBeforeTax(uint256 amount, uint24 feeRate) internal pure returns (uint) {
        uint denominator = FEE_RATE_PRECISION - feeRate;
        uint numerator = amount * FEE_RATE_PRECISION + denominator - 1;
        return numerator / denominator;
    }

    function toAmountAfterTax(uint256 amount, uint24 feeRate) internal pure returns (uint) {
        return (amount * (FEE_RATE_PRECISION - feeRate)) / FEE_RATE_PRECISION;
    }

    function minOf(uint a, uint b) internal pure returns (uint) {
        return a < b ? a : b;
    }

    function maxOf(uint a, uint b) internal pure returns (uint) {
        return a > b ? a : b;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title TransferHelper
 * @dev Wrappers around ERC20 operations that returns the value received by recipent and the actual allowance of approval.
 * To use this library you can add a `using TransferHelper for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library TransferHelper {
    function safeTransfer(IERC20 _token, address _to, uint256 _amount) internal {
        if (_amount > 0) {
            bool success;
            (success, ) = address(_token).call(abi.encodeWithSelector(_token.transfer.selector, _to, _amount));
            require(success, "TF");
        }
    }

    function safeTransferFrom(IERC20 _token, address _from, address _to, uint256 _amount) internal returns (uint256 amountReceived) {
        if (_amount > 0) {
            bool success;
            uint256 balanceBefore = _token.balanceOf(_to);
            (success, ) = address(_token).call(abi.encodeWithSelector(_token.transferFrom.selector, _from, _to, _amount));
            require(success, "TFF");
            uint256 balanceAfter = _token.balanceOf(_to);
            amountReceived = balanceAfter - balanceBefore;
        }
    }

    function safeApprove(IERC20 _token, address _spender, uint256 _amount) internal {
        bool success;
        if (_token.allowance(address(this), _spender) != 0) {
            (success, ) = address(_token).call(abi.encodeWithSelector(_token.approve.selector, _spender, 0));
            require(success, "AF");
        }
        (success, ) = address(_token).call(abi.encodeWithSelector(_token.approve.selector, _spender, _amount));
        require(success, "AF");
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;

/// @dev DexDataFormat addPair = byte(dexID) + bytes3(feeRate) + bytes(arrayLength) + byte3[arrayLength](trasferFeeRate Lpool <-> openlev)
/// + byte3[arrayLength](transferFeeRate openLev -> Dex) + byte3[arrayLength](Dex -> transferFeeRate openLev)
/// exp: 0x0100000002011170000000011170000000011170000000
/// DexDataFormat dexdata = byte(dexID）+ bytes3(feeRate) + byte(arrayLength) + path
/// uniV2Path = bytes20[arraylength](address)
/// uniV3Path = bytes20(address)+ bytes20[arraylength-1](address + fee)
library DexData {
    // in byte
    uint constant DEX_INDEX = 0;
    uint constant FEE_INDEX = 1;
    uint constant ARRYLENTH_INDEX = 4;
    uint constant TRANSFERFEE_INDEX = 5;
    uint constant PATH_INDEX = 5;
    uint constant FEE_SIZE = 3;
    uint constant ADDRESS_SIZE = 20;
    uint constant NEXT_OFFSET = ADDRESS_SIZE + FEE_SIZE;

    uint8 constant DEX_UNIV2 = 1;
    uint8 constant DEX_UNIV3 = 2;
    uint8 constant DEX_PANCAKE = 3;
    uint8 constant DEX_SUSHI = 4;
    uint8 constant DEX_MDEX = 5;
    uint8 constant DEX_TRADERJOE = 6;
    uint8 constant DEX_SPOOKY = 7;
    uint8 constant DEX_QUICK = 8;
    uint8 constant DEX_SHIBA = 9;
    uint8 constant DEX_APE = 10;
    uint8 constant DEX_PANCAKEV1 = 11;
    uint8 constant DEX_BABY = 12;
    uint8 constant DEX_MOJITO = 13;
    uint8 constant DEX_KU = 14;
    uint8 constant DEX_BISWAP = 15;
    uint8 constant DEX_VVS = 20;

    function toDex(bytes memory data) internal pure returns (uint8) {
        require(data.length >= FEE_INDEX, "DexData: toDex wrong data format");
        uint8 temp;
        assembly {
            temp := byte(0, mload(add(data, add(0x20, DEX_INDEX))))
        }
        return temp;
    }

    function toFee(bytes memory data) internal pure returns (uint24) {
        require(data.length >= ARRYLENTH_INDEX, "DexData: toFee wrong data format");
        uint temp;
        assembly {
            temp := mload(add(data, add(0x20, FEE_INDEX)))
        }
        return uint24(temp >> (256 - (ARRYLENTH_INDEX - FEE_INDEX) * 8));
    }

    function toDexDetail(bytes memory data) internal pure returns (uint32) {
        require(data.length >= FEE_INDEX, "DexData: toDexDetail wrong data format");
        if (isUniV2Class(data)) {
            uint8 temp;
            assembly {
                temp := byte(0, mload(add(data, add(0x20, DEX_INDEX))))
            }
            return uint32(temp);
        } else {
            uint temp;
            assembly {
                temp := mload(add(data, add(0x20, DEX_INDEX)))
            }
            return uint32(temp >> (256 - ((FEE_SIZE + FEE_INDEX) * 8)));
        }
    }

    function isUniV2Class(bytes memory data) internal pure returns (bool) {
        return toDex(data) != DEX_UNIV3;
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.17;

interface XOLEInterface {
    function balanceOf(address account) external view returns (uint256);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.17;

interface OpenLevInterface {
    struct Market {
        // Market info
        address pool0; // Lending Pool 0
        address pool1; // Lending Pool 1
        address token0; // Lending Token 0
        address token1; // Lending Token 1
        uint16 marginLimit; // Margin ratio limit for specific trading pair. Two decimal in percentage, ex. 15.32% => 1532
        uint16 feesRate; // feesRate 30=>0.3%
        uint16 priceDiffientRatio;
        address priceUpdater;
        uint256 pool0Insurance; // Insurance balance for token 0
        uint256 pool1Insurance; // Insurance balance for token 1
    }

    function markets(uint16 marketId) external view returns (Market memory market);

    function taxes(uint16 marketId, address token, uint index) external view returns (uint24);

    function getMarketSupportDexs(uint16 marketId) external view returns (uint32[] memory);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.17;

interface OPBuyBackInterface {
    function transferIn(address token, uint amount) external;
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.17;

interface LPoolInterface {
    function underlying() external view returns (address);

    function totalBorrows() external view returns (uint);

    function borrowBalanceCurrent(address account) external view returns (uint);

    function borrowBalanceStored(address account) external view returns (uint);

    function borrowBehalf(address borrower, uint borrowAmount) external;

    function repayBorrowBehalf(address borrower, uint repayAmount) external;

    function repayBorrowEndByOpenLev(address borrower, uint repayAmount) external;
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.17;

interface DexAggregatorInterface {
    function getPrice(address desToken, address quoteToken, bytes memory data) external view returns (uint256 price, uint8 decimals);

    function getPriceCAvgPriceHAvgPrice(
        address desToken,
        address quoteToken,
        uint32 secondsAgo,
        bytes memory dexData
    ) external view returns (uint256 price, uint256 cAvgPrice, uint256 hAvgPrice, uint8 decimals, uint256 timestamp);

    function updatePriceOracle(address desToken, address quoteToken, uint32 timeWindow, bytes memory data) external returns (bool);

    function getToken0Liquidity(address token0, address token1, bytes memory dexData) external view returns (uint);

    function getPairLiquidity(address token0, address token1, bytes memory dexData) external view returns (uint token0Liq, uint token1Liq);

    function buy(
        address buyToken,
        address sellToken,
        uint24 buyTax,
        uint24 sellTax,
        uint buyAmount,
        uint maxSellAmount,
        bytes memory data
    ) external returns (uint sellAmount);

    function sell(address buyToken, address sellToken, uint sellAmount, uint minBuyAmount, bytes memory data) external returns (uint buyAmount);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.17;

interface ControllerInterface {
    function collBorrowAllowed(uint marketId, address borrower, bool collateralIndex) external view returns (bool);

    function collRepayAllowed(uint marketId) external view returns (bool);

    function collRedeemAllowed(uint marketId) external view returns (bool);

    function collLiquidateAllowed(uint marketId) external view returns (bool);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.17;

contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        check();
        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

    function check() private view {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;

contract DelegateInterface {
    /**
     * Implementation address for this contract
     */
    address public implementation;
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.17;

abstract contract Adminable {
    address payable public admin;
    address payable public pendingAdmin;
    address payable public developer;

    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    event NewAdmin(address oldAdmin, address newAdmin);

    constructor() {
        developer = payable(msg.sender);
    }

    modifier onlyAdmin() {
        checkAdmin();
        _;
    }
    modifier onlyAdminOrDeveloper() {
        require(msg.sender == admin || msg.sender == developer, "Only admin or dev");
        _;
    }

    function setPendingAdmin(address payable newPendingAdmin) external virtual onlyAdmin {
        // Save current value, if any, for inclusion in log
        address oldPendingAdmin = pendingAdmin;
        // Store pendingAdmin with value newPendingAdmin
        pendingAdmin = newPendingAdmin;
        // Emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin)
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
    }

    function acceptAdmin() external virtual {
        require(msg.sender == pendingAdmin, "Only pendingAdmin");
        // Save current values for inclusion in log
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;
        // Store admin with value pendingAdmin
        admin = pendingAdmin;
        // Clear the pending value
        pendingAdmin = payable(0);
        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
    }

    function checkAdmin() private view {
        require(msg.sender == admin, "caller must be admin");
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.17;

import "./interfaces/LPoolInterface.sol";
import "./libraries/TransferHelper.sol";
import "./common/IWETH.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

library OPBorrowingLib {
    using TransferHelper for IERC20;

    function transferIn(address from, IERC20 token, address weth, uint amount) internal returns (uint) {
        if (address(token) == weth) {
            IWETH(weth).deposit{ value: msg.value }();
            return msg.value;
        } else {
            return token.safeTransferFrom(from, address(this), amount);
        }
    }

    function doTransferOut(address to, IERC20 token, address weth, uint amount) internal {
        if (address(token) == weth) {
            IWETH(weth).withdraw(amount);
            (bool success, ) = to.call{ value: amount }("");
            require(success, "Transfer failed");
        } else {
            token.safeTransfer(to, amount);
        }
    }

    function borrowBehalf(LPoolInterface pool, address token, address account, uint amount) internal returns (uint) {
        uint balance = balanceOf(IERC20(token));
        pool.borrowBehalf(account, amount);
        return balanceOf(IERC20(token)) - (balance);
    }

    function borrowCurrent(LPoolInterface pool, address account) internal view returns (uint256) {
        return pool.borrowBalanceCurrent(account);
    }

    function borrowStored(LPoolInterface pool, address account) internal view returns (uint256) {
        return pool.borrowBalanceStored(account);
    }

    function repay(LPoolInterface pool, address account, uint amount) internal {
        pool.repayBorrowBehalf(account, amount);
    }

    function balanceOf(IERC20 token) internal view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function decimals(address token) internal view returns (uint256) {
        return ERC20(token).decimals();
    }

    function safeApprove(IERC20 token, address spender, uint256 amount) internal {
        token.safeApprove(spender, amount);
    }

    function safeTransfer(IERC20 token, address to, uint256 amount) internal {
        token.safeTransfer(to, amount);
    }

    function amountToShare(uint amount, uint totalShare, uint reserve) internal pure returns (uint share) {
        share = totalShare > 0 && reserve > 0 ? (totalShare * amount) / reserve : amount;
    }

    function shareToAmount(uint share, uint totalShare, uint reserve) internal pure returns (uint amount) {
        if (totalShare > 0 && reserve > 0) {
            amount = (reserve * share) / totalShare;
        }
    }

    function uint32ToBytes(uint32 u) internal pure returns (bytes memory) {
        if (u < 256) {
            return abi.encodePacked(uint8(u));
        }
        return abi.encodePacked(u);
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.17;

import "./interfaces/LPoolInterface.sol";
import "./interfaces/OpenLevInterface.sol";
import "./interfaces/ControllerInterface.sol";
import "./interfaces/DexAggregatorInterface.sol";
import "./interfaces/XOLEInterface.sol";
import "./interfaces/OPBuyBackInterface.sol";

contract OPBorrowingStorage {
    event NewMarket(uint16 marketId, LPoolInterface pool0, LPoolInterface pool1, address token0, address token1, uint32 dex, uint token0Liq, uint token1Liq);

    event Borrow(address indexed borrower, uint16 marketId, bool collateralIndex, uint collateral, uint borrow, uint borrowFees);

    event Repay(address indexed borrower, uint16 marketId, bool collateralIndex, uint repayAmount, uint collateral);

    event Redeem(address indexed borrower, uint16 marketId, bool collateralIndex, uint collateral);

    event Liquidate(
        address indexed borrower,
        uint16 marketId,
        bool collateralIndex,
        address liquidator,
        uint collateralDecrease,
        uint repayAmount,
        uint outstandingAmount,
        uint liquidateFees,
        uint token0Price
    );

    event NewLiquidity(uint16 marketId, uint oldToken0Liq, uint oldToken1Liq, uint newToken0Liq, uint newToken1Liq);

    event NewMarketConf(
        uint16 marketId,
        uint16 collateralRatio,
        uint16 maxLiquidityRatio,
        uint16 borrowFeesRatio,
        uint16 insuranceRatio,
        uint16 poolReturnsRatio,
        uint16 liquidateFeesRatio,
        uint16 liquidatorReturnsRatio,
        uint16 liquidateInsuranceRatio,
        uint16 liquidatePoolReturnsRatio,
        uint16 liquidateMaxLiquidityRatio,
        uint16 twapDuration
    );

    struct Market {
        LPoolInterface pool0; // pool0 address
        LPoolInterface pool1; // pool1 address
        address token0; // token0 address
        address token1; // token1 address
        uint32 dex; // decentralized exchange
    }

    struct MarketConf {
        uint16 collateralRatio; //  the collateral ratio, 6000 => 60%
        uint16 maxLiquidityRatio; // the maximum pool's total borrowed cannot be exceeded dex liquidity*ratio, 1000 => 10%
        uint16 borrowFeesRatio; // the borrowing fees ratio, 30 => 0.3%
        uint16 insuranceRatio; // the insurance percentage of the borrowing fees, 3000 => 30%
        uint16 poolReturnsRatio; // the pool's returns percentage of the borrowing fees, 3000 => 30%
        uint16 liquidateFeesRatio; // the liquidation fees ratio, 100 => 1%
        uint16 liquidatorReturnsRatio; // the liquidator returns percentage of the liquidation fees, 3000 => 30%
        uint16 liquidateInsuranceRatio; // the insurance percentage of the liquidation fees, 3000 => 30%
        uint16 liquidatePoolReturnsRatio; // the pool's returns percentage of the liquidation fees, 3000 => 30%
        uint16 liquidateMaxLiquidityRatio; // the maximum liquidation amount cannot be exceeded dex liquidity*ratio, 1000=> 10%
        uint16 twapDuration; // the TWAP duration, 60 => 60s
    }

    struct Liquidity {
        uint token0Liq; // the token0 liquidity
        uint token1Liq; // the token1 liquidity
    }

    struct Insurance {
        uint insurance0; // the token0 insurance
        uint insurance1; // the token1 insurance
    }

    struct LiquidationConf {
        uint128 liquidatorXOLEHeld; //  the minimum amount of xole held by liquidator
        uint8 priceDiffRatio; // the maximum ratio of real price diff TWAP, 10 => 10%
        OPBuyBackInterface buyBack; // the ole buyback contract address
    }

    uint internal constant RATIO_DENOMINATOR = 10000;

    address public immutable wETH;

    OpenLevInterface public immutable openLev;

    ControllerInterface public immutable controller;

    DexAggregatorInterface public immutable dexAgg;

    XOLEInterface public immutable xOLE;

    // mapping of marketId to market info
    mapping(uint16 => Market) public markets;

    // mapping of marketId to market config
    mapping(uint16 => MarketConf) public marketsConf;

    // mapping of borrower, marketId, collateralIndex to collateral shares
    mapping(address => mapping(uint16 => mapping(bool => uint))) public activeCollaterals;

    // mapping of marketId to insurances
    mapping(uint16 => Insurance) public insurances;

    // mapping of marketId to time weighted average liquidity
    mapping(uint16 => Liquidity) public twaLiquidity;

    // mapping of token address to total shares
    mapping(address => uint) public totalShares;

    MarketConf public marketDefConf;

    LiquidationConf public liquidationConf;

    constructor(OpenLevInterface _openLev, ControllerInterface _controller, DexAggregatorInterface _dexAgg, XOLEInterface _xOLE, address _wETH) {
        openLev = _openLev;
        controller = _controller;
        dexAgg = _dexAgg;
        xOLE = _xOLE;
        wETH = _wETH;
    }
}

interface IOPBorrowing {
    function initialize(OPBorrowingStorage.MarketConf memory _marketDefConf, OPBorrowingStorage.LiquidationConf memory _liquidationConf) external;

    // only controller
    function addMarket(uint16 marketId, LPoolInterface pool0, LPoolInterface pool1, bytes memory dexData) external;

    /*** Borrower Functions ***/
    function borrow(uint16 marketId, bool collateralIndex, uint collateral, uint borrowing) external payable;

    function repay(uint16 marketId, bool collateralIndex, uint repayAmount, bool isRedeem) external payable returns (uint redeemShare);

    function redeem(uint16 marketId, bool collateralIndex, uint collateral) external;

    function liquidate(uint16 marketId, bool collateralIndex, address borrower) external;

    function collateralRatio(uint16 marketId, bool collateralIndex, address borrower) external view returns (uint current);

    /*** Admin Functions ***/
    function migrateOpenLevMarkets(uint16 from, uint16 to) external;

    function setTwaLiquidity(uint16[] calldata marketIds, OPBorrowingStorage.Liquidity[] calldata liquidity) external;

    function setMarketConf(uint16 marketId, OPBorrowingStorage.MarketConf calldata _marketConf) external;

    function setMarketDex(uint16 marketId, uint32 dex) external;

    function moveInsurance(uint16 marketId, bool tokenIndex, address to, uint moveShare) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}