/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "./implement/MatchingEngineCore.sol";
import "./implement/AutoMarketMakerCore.sol";
import "./interfaces/IMatchingEngineAMM.sol";
import "./libraries/extensions/Fee.sol";
import "./libraries/helper/Errors.sol";
import "./libraries/helper/Require.sol";

contract MatchingEngineAMM is
    IMatchingEngineAMM,
    Fee,
    AutoMarketMakerCore,
    MatchingEngineCore
{
    using Math for uint128;
    bool isInitialized;
    mapping(address => bool) public counterParties;
    uint128 public rangeFindingWordsAmm = 200;

    /// @notice initialize the contract right after deploy
    /// @notice only call once time
    /// @dev initialize the sub contract, approve contract
    function initialize(InitParams memory params) external {
        Require._require(!isInitialized, Errors.ME_INITIALIZED);
        isInitialized = true;

        counterParties[params.positionLiquidity] = true;
        counterParties[params.spotHouse] = true;
        counterParties[params.router] = true;

        _initializeAMM(
            params.pipRange,
            params.tickSpace,
            params.initialPip,
            params.feeShareAmm
        );
        _initializeCore(
            params.basisPoint,
            params.maxFindingWordsIndex,
            params.initialPip
        );
        _initFee(params.quoteAsset, params.baseAsset);

        if (params.basisPoint == 100) {
            rangeFindingWordsAmm = 10;
        } else if (params.basisPoint == 10_000) {
            rangeFindingWordsAmm = 100;
        }

        _approveCounterParty(params.quoteAsset, params.positionLiquidity);
        _approveCounterParty(params.baseAsset, params.positionLiquidity);

        _approveCounterParty(params.quoteAsset, params.spotHouse);
        _approveCounterParty(params.baseAsset, params.spotHouse);

        _approveCounterParty(params.baseAsset, params.router);
        _approveCounterParty(params.quoteAsset, params.router);
    }

    /// @notice implement hook function
    /// @notice require only counter party can call
    function _onlyCounterParty()
        internal
        view
        override(MatchingEngineCore, AutoMarketMakerCore)
    {
        Require._require(
            counterParties[msg.sender],
            Errors.ME_ONLY_COUNTERPARTY
        );
    }

    function _emitLimitOrderUpdatedHook(
        address spotManager,
        uint64 orderId,
        uint128 pip,
        uint256 size
    ) internal override {}

    /// @notice implement hook function
    /// @notice call to amm contract
    function _onCrossPipHook(
        CrossPipParams memory params,
        SwapState.AmmState memory ammState
    )
        internal
        view
        override(MatchingEngineCore)
        returns (CrossPipResult.Result memory crossPipResult)
    {
        if (params.pipNext == params.currentPip) {
            return crossPipResult;
        }

        int256 indexPip = int256(
            LiquidityMath.calculateIndexPipRange(
                params.currentPip,
                params.pipRange
            )
        );
        if (ammState.lastPipRangeLiquidityIndex != indexPip) {
            //                        if (ammState.lastPipRangeLiquidityIndex != -1) ammState.index++;
            ammState.lastPipRangeLiquidityIndex = indexPip;
        }
        /// Modify ammState.ammReserves here will update to `state.ammState.ammReserves` in MatchingEngineCore
        /// Eg. given `state.ammState.ammReserves` in MatchingEngineCore is [A, B, C, D, E]
        /// if you change ammStates[0] = 1
        /// then the `state.ammState.ammReserves` in MatchingEngineCore will be [1, B, C, D, E]
        /// because ammStates is passed by an underlying pointer
        /// let's try it in Remix
        crossPipResult = _onCrossPipAMMTargetPrice(
            OnCrossPipParams(
                params.pipNext,
                params.isBuy,
                params.isBase,
                params.amount,
                params.basisPoint,
                params.currentPip,
                params.pipRange
            ),
            ammState
        );
    }

    /// @notice implement update amm state
    function _updateAMMState(
        SwapState.AmmState memory ammState,
        uint128 currentPip,
        bool isBuy,
        uint16 feePercent
    )
        internal
        override(MatchingEngineCore)
        returns (
            uint128 totalFeeAmm,
            uint128 feeProtocolAmm,
            uint128 totalFilledAmm
        )
    {
        currentIndexedPipRange = LiquidityMath.calculateIndexPipRange(
            currentPip,
            pipRange
        );

        (
            totalFeeAmm,
            feeProtocolAmm,
            totalFilledAmm
        ) = _updateAMMStateAfterTrade(ammState, isBuy, feePercent);
    }

    /// @notice implement calculate fee
    function _calculateFee(
        SwapState.AmmState memory ammState,
        uint128 currentPip,
        bool isBuy,
        bool isBase,
        uint256 mainSideOut,
        uint256 flipSideOut,
        uint16 feePercent
    ) internal override(MatchingEngineCore) returns (uint256) {
        (
            uint128 totalFeeAmm,
            uint128 feeProtocolAmm,
            uint128 totalFilledAmm
        ) = _updateAMMState(ammState, currentPip, isBuy, feePercent);

        uint128 amount;

        if (
            ((isBuy && isBase) || (!isBuy && !isBase)) &&
            uint128(mainSideOut) >= totalFilledAmm
        ) {
            amount = uint128(mainSideOut) - totalFilledAmm;
        } else if (
            ((isBuy && !isBase) || (!isBuy && isBase)) &&
            uint128(flipSideOut) >= totalFilledAmm
        ) {
            amount = uint128(flipSideOut) - totalFilledAmm;
        }

        uint128 feeLimitOrder = (amount * feePercent) /
            FixedPoint128.BASIC_POINT_FEE;
        uint128 feeProtocol = feeProtocolAmm + feeLimitOrder;

        if ((isBuy && isBase) || (isBuy && !isBase)) {
            _increaseBaseFeeFunding(feeProtocol);
        } else if ((!isBuy && !isBase) || (!isBuy && isBase)) {
            _increaseQuoteFeeFunding(feeProtocol);
        }

        return totalFeeAmm + feeLimitOrder;
    }

    /// @notice implement need set pip next
    function _isNeedSetPipNext()
        internal
        pure
        override(MatchingEngineCore)
        returns (bool)
    {
        return true;
    }

    /// @notice approve counter party
    function _approveCounterParty(IERC20 asset, address spender) internal {
        asset.approve(spender, type(uint256).max);
    }

    /// @inheritdoc IFee
    function increaseQuoteFeeFunding(uint256 quoteFee)
        public
        override(Fee, IFee)
    {
        _onlyCounterParty();
        super.increaseQuoteFeeFunding(quoteFee);
    }

    /// @inheritdoc IFee
    function increaseBaseFeeFunding(uint256 baseFee)
        public
        override(Fee, IFee)
    {
        _onlyCounterParty();
        super.increaseBaseFeeFunding(baseFee);
    }

    /// @inheritdoc IFee
    function decreaseBaseFeeFunding(uint256 quoteFee)
        public
        override(Fee, IFee)
    {
        _onlyCounterParty();
        super.decreaseBaseFeeFunding(quoteFee);
    }

    /// @inheritdoc IFee
    function decreaseQuoteFeeFunding(uint256 baseFee)
        public
        override(Fee, IFee)
    {
        _onlyCounterParty();
        super.decreaseQuoteFeeFunding(baseFee);
    }

    /// @inheritdoc IMatchingEngineAMM
    function accumulateClaimableAmount(
        uint128 _pip,
        uint64 _orderId,
        ExchangedData memory exData,
        uint256 basisPoint,
        uint16 fee,
        uint128 feeBasis
    ) external view override returns (ExchangedData memory) {
        (
            bool isFilled,
            bool isBuy,
            uint256 baseSize,
            uint256 partialFilled
        ) = getPendingOrderDetail(_pip, _orderId);
        uint256 filledSize = isFilled ? baseSize : partialFilled;
        {
            if (isBuy) {
                //BUY => can claim base asset
                exData.baseAmount += filledSize;
            } else {
                // SELL => can claim quote asset
                exData.quoteAmount += TradeConvert.baseToQuote(
                    filledSize,
                    _pip,
                    basisPoint
                );
            }
        }
        return exData;
    }

    /// @notice get the address of context transactions
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    /// @notice get basis point
    /// @return basis point of pair
    function _basisPoint()
        internal
        view
        override(AutoMarketMakerCore)
        returns (uint256)
    {
        return basisPoint;
    }

    /// @notice get current pip
    /// @return The current pip of pair
    function getCurrentPip()
        public
        view
        override(MatchingEngineCore, AutoMarketMakerCore, IMatchingEngineCore)
        returns (uint128)
    {
        return singleSlot.pip;
    }

    /// @notice get pip range of pair
    /// @return the start of pip range
    function _getPipRange()
        internal
        view
        override(MatchingEngineCore)
        returns (uint128)
    {
        return pipRange;
    }

    /// @notice get range finding word of pair
    /// @return the storage of funding words amm
    function _getRangeFindingWordsAmm()
        internal
        view
        override(MatchingEngineCore)
        returns (uint128)
    {
        return rangeFindingWordsAmm;
    }

    /// @notice calculate the pip limit with range finding words when use amm
    /// @param pip the current pip step in market
    /// @param isBuy the side of the order
    /// @param rangeWords the range words amm of pair
    function _calculatePipLimitWhenFindPipNext(
        uint128 pip,
        bool isBuy,
        uint128 rangeWords
    ) internal pure override(MatchingEngineCore) returns (uint128 limitPip) {
        if (!isBuy) {
            if (pip <= rangeWords * 256) {
                return 1;
            }
            return pip - rangeWords * 256;
        }

        return pip + rangeWords * 256;
    }

    /// @notice implement emit event swap
    function emitEventSwap(
        bool isBuy,
        uint256 _baseAmount,
        uint256 _quoteAmount,
        address _trader
    ) internal override(MatchingEngineCore) {
        uint256 amount0In;
        uint256 amount1In;
        uint256 amount0Out;
        uint256 amount1Out;

        if (isBuy) {
            amount1In = _quoteAmount;
            amount0Out = _baseAmount;
        } else {
            amount0In = _baseAmount;
            amount1Out = _quoteAmount;
        }
        emit Swap(
            msg.sender,
            amount0In,
            amount1In,
            amount0Out,
            amount1Out,
            _trader
        );
    }

    /// @notice implement calculate quote amount
    /// @param quantity the size of base amount
    /// @param pip the pip want to calculate
    function calculatingQuoteAmount(uint256 quantity, uint128 pip)
        external
        view
        override(MatchingEngineCore, IMatchingEngineCore)
        returns (uint256)
    {
        return TradeConvert.baseToQuote(quantity, pip, basisPoint);
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;
import "../libraries/exchange/LimitOrder.sol";
import "../libraries/types/MatchingEngineCoreStorage.sol";
import "../libraries/helper/TradeConvert.sol";
import "../libraries/exchange/TickPosition.sol";
import "../libraries/helper/Convert.sol";
import "../interfaces/IMatchingEngineCore.sol";
import "../libraries/exchange/SwapState.sol";
import "../libraries/amm/CrossPipResult.sol";
import "../libraries/helper/Errors.sol";
import "../libraries/helper/Require.sol";
import "../libraries/amm/LiquidityMath.sol";

abstract contract MatchingEngineCore is MatchingEngineCoreStorage {
    // Define using library
    using TickPosition for TickPosition.Data;
    using LiquidityBitmap for mapping(uint128 => uint256);
    using Convert for uint256;
    using Convert for int256;
    using SwapState for SwapState.State;

    // Init storage of pai
    // called only once time
    function _initializeCore(
        uint256 _basisPoint,
        uint128 _maxFindingWordsIndex,
        uint128 _initialPip
    ) internal {
        singleSlot.pip = _initialPip;
        basisPoint = _basisPoint;
        //        maxFindingWordsIndex = _maxFindingWordsIndex;
        maxWordRangeForLimitOrder = _maxFindingWordsIndex;
        maxWordRangeForMarketOrder = _maxFindingWordsIndex;
    }

    //*
    //*** Virtual functions called from counter party
    //*

    /// @inheritdoc IMatchingEngineCore
    function updatePartialFilledOrder(uint128 _pip, uint64 _orderId)
        public
        virtual
    {
        _onlyCounterParty();
        uint256 newSize = tickPosition[_pip].updateOrderWhenClose(_orderId);
        _emitLimitOrderUpdatedHook(address(this), _orderId, _pip, newSize);
    }

    /// @inheritdoc IMatchingEngineCore
    function cancelLimitOrder(uint128 _pip, uint64 _orderId)
        public
        virtual
        returns (uint256 remainingSize, uint256 partialFilled)
    {
        _onlyCounterParty();
        TickPosition.Data storage _tickPosition = tickPosition[_pip];

        Require._require(
            hasLiquidity(_pip) && _orderId >= _tickPosition.filledIndex,
            Errors.ME_ONLY_PENDING_ORDER
        );
        return _internalCancelLimitOrder(_tickPosition, _pip, _orderId);
    }

    /// @inheritdoc IMatchingEngineCore
    function openLimit(
        uint128 pip,
        uint128 baseAmountIn,
        bool isBuy,
        address trader,
        uint256 quoteAmountIn,
        uint16 feePercent
    )
        public
        virtual
        returns (
            uint64 orderId,
            uint256 baseAmountFilled,
            uint256 quoteAmountFilled,
            uint256 fee
        )
    {
        _onlyCounterParty();
        (
            orderId,
            baseAmountFilled,
            quoteAmountFilled,
            fee
        ) = _internalOpenLimit(
            ParamsInternalOpenLimit({
                pip: pip,
                size: baseAmountIn,
                isBuy: isBuy,
                trader: trader,
                quoteDeposited: quoteAmountIn,
                feePercent: feePercent
            })
        );
    }

    /// @inheritdoc IMatchingEngineCore
    function openMarket(
        uint256 size,
        bool isBuy,
        address trader,
        uint16 feePercent
    )
        public
        virtual
        returns (
            uint256 mainSideOut,
            uint256 flipSideOut,
            uint256 fee
        )
    {
        _onlyCounterParty();
        return
            _internalOpenMarketOrder(
                size,
                isBuy,
                0,
                trader,
                true,
                maxWordRangeForLimitOrder,
                feePercent
            );
    }

    /// @inheritdoc IMatchingEngineCore
    function openMarketWithQuoteAsset(
        uint256 quoteAmount,
        bool isBuy,
        address trader,
        uint16 feePercent
    )
        public
        virtual
        returns (
            uint256 mainSideOut,
            uint256 flipSideOut,
            uint256 fee
        )
    {
        _onlyCounterParty();
        (mainSideOut, flipSideOut, fee) = _internalOpenMarketOrder(
            quoteAmount,
            isBuy,
            0,
            trader,
            false,
            maxWordRangeForLimitOrder,
            feePercent
        );
    }

    //*
    // Public view functions
    //*

    /// @inheritdoc IMatchingEngineCore
    function hasLiquidity(uint128 _pip) public view returns (bool) {
        return liquidityBitmap.hasLiquidity(_pip);
    }

    /// @inheritdoc IMatchingEngineCore
    function getPendingOrderDetail(uint128 pip, uint64 orderId)
        public
        view
        virtual
        returns (
            bool isFilled,
            bool isBuy,
            uint256 size,
            uint256 partialFilled
        )
    {
        (isFilled, isBuy, size, partialFilled) = tickPosition[pip]
            .getQueueOrder(orderId);

        if (!liquidityBitmap.hasLiquidity(pip)) {
            isFilled = true;
        }
        if (size != 0 && size == partialFilled) {
            isFilled = true;
        }
    }

    /// @inheritdoc IMatchingEngineCore
    function getLiquidityInCurrentPip() public view returns (uint128) {
        return
            liquidityBitmap.hasLiquidity(singleSlot.pip)
                ? tickPosition[singleSlot.pip].liquidity
                : 0;
    }

    /// @notice hook function get liquidity in pip range
    function getLiquidityInPipRange(
        uint128 fromPip,
        uint256 dataLength,
        bool toHigher
    ) external view virtual returns (LiquidityOfEachPip[] memory, uint128) {
        uint128[] memory allInitializedPip = new uint128[](uint128(dataLength));
        allInitializedPip = liquidityBitmap.findAllLiquidityInMultipleWords(
            fromPip,
            dataLength,
            toHigher
        );
        LiquidityOfEachPip[] memory allLiquidity = new LiquidityOfEachPip[](
            dataLength
        );
        for (uint256 i = 0; i < dataLength; i++) {
            allLiquidity[i] = LiquidityOfEachPip({
                pip: allInitializedPip[i],
                liquidity: tickPosition[allInitializedPip[i]].liquidity
            });
        }
        return (allLiquidity, allInitializedPip[dataLength - 1]);
    }

    //*
    // Private functions
    //*

    /// @notice cancel limit order
    function _internalCancelLimitOrder(
        TickPosition.Data storage _tickPosition,
        uint128 _pip,
        uint64 _orderId
    ) private returns (uint256 remainingSize, uint256 partialFilled) {
        bool isBuy;
        (remainingSize, partialFilled, isBuy) = _tickPosition.cancelLimitOrder(
            _orderId
        );
        // if that pip doesn't have liquidity after closed order, toggle pip to uninitialized
        if (_tickPosition.liquidity == 0) {
            liquidityBitmap.toggleSingleBit(_pip, false);
            // only unset isFullBuy when cancel order pip == current pip
            if (_pip == singleSlot.pip) {
                singleSlot.isFullBuy = 0;
            }
        }
        emit LimitOrderCancelled(isBuy, _orderId, _pip, remainingSize);
    }

    struct ParamsInternalOpenLimit {
        uint128 pip;
        uint128 size;
        bool isBuy;
        address trader;
        uint256 quoteDeposited;
        uint16 feePercent;
    }

    /// @notice open limit order
    function _internalOpenLimit(ParamsInternalOpenLimit memory _params)
        private
        returns (
            uint64 orderId,
            uint256 baseAmountFilled,
            uint256 quoteAmountFilled,
            uint256 fee
        )
    {
        Require._require(_params.size != 0, Errors.ME_INVALID_SIZE);
        SingleSlot memory _singleSlot = singleSlot;
        uint256 underlyingPip = uint256(getUnderlyingPriceInPip());
        {
            if (_params.isBuy && _singleSlot.pip != 0) {
                int256 maxPip = int256(underlyingPip) -
                    int128(maxWordRangeForLimitOrder * 250);

                if (maxPip > 0) {
                    Require._require(
                        int128(_params.pip) >= maxPip,
                        Errors.ME_MUST_CLOSE_TO_INDEX_PRICE_BUY
                    );
                } else {
                    Require._require(
                        _params.pip >= 1,
                        Errors.ME_MUST_CLOSE_TO_INDEX_PRICE_BUY
                    );
                }
            } else {
                Require._require(
                    _params.pip <=
                        (underlyingPip + maxWordRangeForLimitOrder * 250),
                    Errors.ME_MUST_CLOSE_TO_INDEX_PRICE_BUY
                );
            }
        }
        bool _hasLiquidity = liquidityBitmap.hasLiquidity(_params.pip);
        //save gas
        {
            bool canOpenMarketWithMaxPip = (_params.isBuy &&
                _params.pip >= _singleSlot.pip) ||
                (!_params.isBuy && _params.pip <= _singleSlot.pip);
            if (canOpenMarketWithMaxPip) {
                // open market
                if (_params.isBuy) {
                    // higher pip when long must lower than max word range for market order short
                    Require._require(
                        _params.pip <=
                            underlyingPip + maxWordRangeForMarketOrder * 250,
                        Errors.ME_MARKET_ORDER_MUST_CLOSE_TO_INDEX_PRICE
                    );
                } else {
                    // lower pip when short must higher than max word range for market order long
                    Require._require(
                        int128(_params.pip) >=
                            (int256(underlyingPip) -
                                int128(maxWordRangeForMarketOrder * 250)),
                        Errors.ME_MARKET_ORDER_MUST_CLOSE_TO_INDEX_PRICE
                    );
                }
                (
                    baseAmountFilled,
                    quoteAmountFilled,
                    fee
                ) = _openMarketWithMaxPip(
                    _params.size,
                    _params.isBuy,
                    _params.pip,
                    _params.trader,
                    _params.feePercent
                );
                _hasLiquidity = liquidityBitmap.hasLiquidity(_params.pip);
                // reassign _singleSlot after _openMarketPositionWithMaxPip
                _singleSlot = singleSlot;
            }
        }
        {
            if (
                (_params.size > baseAmountFilled) ||
                (_params.size == baseAmountFilled &&
                    _params.quoteDeposited > quoteAmountFilled &&
                    _params.quoteDeposited > 0)
            ) {
                uint128 remainingSize;

                if (
                    _params.quoteDeposited > 0 &&
                    _params.isBuy &&
                    _params.quoteDeposited > quoteAmountFilled
                ) {
                    remainingSize = uint128(
                        TradeConvert.quoteToBase(
                            _params.quoteDeposited - quoteAmountFilled,
                            _params.pip,
                            basisPoint
                        )
                    );
                } else {
                    remainingSize = _params.size - uint128(baseAmountFilled);
                }

                if (
                    _params.pip == _singleSlot.pip &&
                    _singleSlot.isFullBuy != (_params.isBuy ? 1 : 2)
                ) {
                    singleSlot.isFullBuy = _params.isBuy ? 1 : 2;
                }

                orderId = tickPosition[_params.pip].insertLimitOrder(
                    remainingSize,
                    _hasLiquidity,
                    _params.isBuy
                );
                if (!_hasLiquidity) {
                    //set the bit to mark it has liquidity
                    liquidityBitmap.toggleSingleBit(_params.pip, true);
                }
                emit LimitOrderCreated(
                    orderId,
                    _params.pip,
                    remainingSize,
                    _params.isBuy
                );
            }
        }
    }

    /// @notice open market order with max pip
    /// @notice  open limit can call this function if limit order is part of market order
    function _openMarketWithMaxPip(
        uint256 size,
        bool isBuy,
        uint128 maxPip,
        address _trader,
        uint16 feePercent
    )
        internal
        returns (
            uint256 baseOut,
            uint256 quoteOut,
            uint256 fee
        )
    {
        // plus 1 avoid  (singleSlot.pip - maxPip)/250 = 0
        uint128 _maxFindingWordsIndex = ((
            isBuy ? maxPip - singleSlot.pip : singleSlot.pip - maxPip
        ) / 250) + 1;
        return
            _internalOpenMarketOrder(
                size,
                isBuy,
                maxPip,
                address(0),
                true,
                _maxFindingWordsIndex,
                feePercent
            );
    }

    /// @notice open market order
    /// @notice this function fill market with limit order and amm

    function _internalOpenMarketOrder(
        uint256 _size,
        bool _isBuy,
        uint128 _maxPip,
        address _trader,
        bool _isBase,
        uint128 _maxFindingWordsIndex,
        uint16 feePercent
    )
        internal
        virtual
        returns (
            uint256 mainSideOut,
            uint256 flipSideOut,
            uint256 fee
        )
    {
        Require._require(_size != 0, Errors.ME_INVALID_SIZE);
        // get current tick liquidity
        SingleSlot memory _initialSingleSlot = singleSlot;

        //save gas
        SwapState.State memory state = SwapState.State({
            remainingSize: _size,
            pip: _initialSingleSlot.pip,
            basisPoint: basisPoint.Uint256ToUint32(),
            startPip: 0,
            remainingLiquidity: 0,
            isFullBuy: _initialSingleSlot.isFullBuy,
            isSkipFirstPip: false,
            lastMatchedPip: _initialSingleSlot.pip,
            isBuy: _isBuy,
            isBase: _isBase,
            flipSideOut: 0,
            pipRange: _getPipRange(),
            rangeFindingWordsAmm: _getRangeFindingWordsAmm(),
            ammState: SwapState.newAMMState()
        });
        state.beforeExecute();

        CrossPipParams memory crossPipParams = CrossPipParams({
            pipNext: 0,
            isBuy: state.isBuy,
            isBase: _isBase,
            amount: 0,
            basisPoint: state.basisPoint,
            currentPip: 0,
            pipRange: state.pipRange
        });

        while (state.remainingSize != 0) {
            StepComputations memory step;
            if (_isNeedSetPipNext()) {
                (step.pipNext) = liquidityBitmap
                    .findHasLiquidityInMultipleWordsWithLimitPip(
                        state.pip,
                        _maxFindingWordsIndex,
                        !state.isBuy,
                        _calculatePipLimitWhenFindPipNext(
                            state.pip,
                            state.isBuy,
                            state.rangeFindingWordsAmm
                        )
                    );

                if (
                    ((_maxPip != 0 && step.pipNext == 0) &&
                        ((!state.isBuy && state.pip >= _maxPip) ||
                            (state.isBuy && state.pip <= _maxPip))) ||
                    ((_maxPip != 0 && step.pipNext > 0) &&
                        ((!state.isBuy &&
                            step.pipNext <= _maxPip &&
                            state.pip >= _maxPip) ||
                            (state.isBuy &&
                                step.pipNext >= _maxPip &&
                                state.pip <= _maxPip)))
                ) {
                    step.pipNext = _maxPip;
                }

                crossPipParams.pipNext = step.pipNext;
                crossPipParams.amount = uint128(state.remainingSize);
                crossPipParams.currentPip = state.pip;
            } else
                (step.pipNext) = liquidityBitmap
                    .findHasLiquidityInMultipleWordsWithLimitPip(
                        state.pip,
                        _maxFindingWordsIndex,
                        !state.isBuy,
                        0
                    );

            // updated findHasLiquidityInMultipleWords, save more gas
            // if order is buy and step.pipNext (pip has liquidity) > maxPip then break cause this is limited to maxPip and vice versa
            if (state.isReachedMaxPip(step.pipNext, _maxPip)) {
                break;
            }

            CrossPipResult.Result memory crossPipResult = _onCrossPipHook(
                crossPipParams,
                state.ammState
            );
            if (
                state.ammState.index >= 4 ||
                state.ammState.lastPipRangeLiquidityIndex == -2 ||
                state.pip == 0
            ) {
                break;
            }
            if (crossPipResult.baseCrossPipOut > 0 && step.pipNext == 0) {
                step.pipNext = crossPipResult.toPip;
            }
            /// In this line, step.pipNext still is 0, that means no liquidity for this order

            if (step.pipNext == 0) {
                // no more next pip
                // state pip back 1 pip
                state.moveBack1Pip();
                break;
            } else {
                if (
                    crossPipResult.baseCrossPipOut > 0 &&
                    crossPipResult.quoteCrossPipOut > 0
                ) {
                    if (
                        (crossPipResult.baseCrossPipOut >=
                            state.remainingSize &&
                            state.isBase) ||
                        (crossPipResult.quoteCrossPipOut >=
                            state.remainingSize &&
                            !state.isBase)
                    ) {
                        if (
                            (state.isBuy && crossPipResult.toPip > state.pip) ||
                            (!state.isBuy && crossPipResult.toPip < state.pip)
                        ) {
                            state.pip = crossPipResult.toPip;
                        }
                        if (_maxPip != 0) {
                            state.lastMatchedPip = crossPipResult.toPip;
                        }
                        state.ammFillAll(
                            crossPipResult.baseCrossPipOut,
                            crossPipResult.quoteCrossPipOut
                        );
                        break;
                    } else {
                        state.updateAMMTradedSize(
                            crossPipResult.baseCrossPipOut,
                            crossPipResult.quoteCrossPipOut
                        );
                        state.isSkipFirstPip = false;
                    }
                }

                if (!state.isSkipFirstPip) {
                    if (state.startPip == 0) state.startPip = step.pipNext;

                    // get liquidity at a tick index
                    uint128 liquidity = tickPosition[step.pipNext].liquidity;
                    if (_maxPip != 0) {
                        state.lastMatchedPip = step.pipNext;
                    }
                    uint256 remainingQuantity = state.isBase
                        ? state.remainingSize
                        : TradeConvert.quoteToBase(
                            state.remainingSize,
                            step.pipNext,
                            state.basisPoint
                        );
                    if (liquidity > remainingQuantity) {
                        // pip position will partially filled and stop here
                        tickPosition[step.pipNext].partiallyFill(
                            remainingQuantity.Uint256ToUint128()
                        );
                        state.updateTradedSize(
                            state.remainingSize,
                            step.pipNext
                        );
                        // remaining liquidity at current pip
                        state.remainingLiquidity =
                            liquidity -
                            remainingQuantity.Uint256ToUint128();
                        state.pip = step.pipNext;
                        state.reverseIsFullBuy();
                    } else if (remainingQuantity > liquidity) {
                        // order in that pip will be fulfilled
                        state.updateTradedSize(liquidity, step.pipNext);
                        state.moveForward1Pip(step.pipNext);
                    } else {
                        // remaining size = liquidity
                        // only 1 pip should be toggled, so we call it directly here
                        liquidityBitmap.toggleSingleBit(step.pipNext, false);
                        state.updateTradedSize(liquidity, step.pipNext);
                        state.pip = step.pipNext;
                        state.isFullBuy = 0;
                        tickPosition[step.pipNext].fullFillLiquidity();
                    }
                } else {
                    state.isSkipFirstPip = false;
                    state.moveForward1Pip(step.pipNext);
                }
            }

            if (state.pip == 0) break;
        }

        {
            /// put code in new block memory avoid stack to deep
            if (
                _initialSingleSlot.pip != state.pip &&
                state.remainingSize != _size
            ) {
                // all ticks in shifted range must be marked as filled
                if (
                    !(state.remainingLiquidity > 0 &&
                        state.startPip == state.pip) && state.startPip != 0
                ) {
                    if (_maxPip != 0) {
                        state.pip = state.lastMatchedPip;
                    }

                    liquidityBitmap.unsetBitsRange(
                        state.startPip,
                        state.remainingLiquidity > 0
                            ? (state.isBuy ? state.pip - 1 : state.pip + 1)
                            : state.pip
                    );
                }
                // TODO write a checkpoint that we shift a range of ticks
            } else if (
                _maxPip != 0 &&
                _initialSingleSlot.pip == state.pip &&
                state.remainingSize < _size &&
                state.remainingSize != 0
            ) {
                // if limit order with max pip filled current pip, toggle current pip to initialized
                // after that when create new limit order will initialize pip again in `OpenLimitPosition`
                liquidityBitmap.toggleSingleBit(state.pip, false);
            }

            if (state.remainingSize != _size) {
                // if limit order with max pip filled other order, update isFullBuy
                singleSlot.isFullBuy = state.isFullBuy;
            }
            if (_maxPip != 0) {
                // if limit order still have remainingSize, change current price to limit price
                // else change current price to last matched pip
                singleSlot.pip = state.remainingSize != 0
                    ? _maxPip
                    : state.lastMatchedPip;
            } else {
                singleSlot.pip = state.pip;
            }
        }

        mainSideOut = _size - state.remainingSize;
        flipSideOut = state.flipSideOut;
        _addReserveSnapshot();

        fee = _calculateFee(
            state.ammState,
            singleSlot.pip,
            state.isBuy,
            state.isBase,
            mainSideOut,
            flipSideOut,
            feePercent
        );

        if (mainSideOut != 0) {
            emit MarketFilled(
                state.isBuy,
                _isBase ? mainSideOut : flipSideOut,
                singleSlot.pip,
                state.startPip,
                state.remainingLiquidity,
                0
            );
            emitEventSwap(state.isBuy, mainSideOut, flipSideOut, _trader);
        }
    }

    function _calculatePipLimitWhenFindPipNext(
        uint128 pip,
        bool isBuy,
        uint128 rangeWords
    ) internal pure virtual returns (uint128 limitPip) {}

    //*
    // HOOK HERE *
    //*

    /// @notice hook function check need set next pip
    /// @notice need set if the inheri contract is amm
    function _isNeedSetPipNext() internal pure virtual returns (bool) {
        return false;
    }

    /// @notice hook function emit event order book updated
    function _emitLimitOrderUpdatedHook(
        address spotManager,
        uint64 orderId,
        uint128 pip,
        uint256 size
    ) internal virtual {}

    struct CrossPipParams {
        uint128 pipNext;
        bool isBuy;
        bool isBase;
        uint128 amount;
        uint32 basisPoint;
        uint128 currentPip;
        uint128 pipRange;
    }

    /// @notice hook function call out side thi matching core and inherit contract call to amm contract
    function _onCrossPipHook(
        CrossPipParams memory params,
        SwapState.AmmState memory ammState
    ) internal virtual returns (CrossPipResult.Result memory crossPipResult) {}

    /// @notice hook function update amm state after swap
    /// @notice the inherit contract will call to amm contract and update
    function _updateAMMState(
        SwapState.AmmState memory ammState,
        uint128 currentPip,
        bool isBuy,
        uint16 feePercent
    )
        internal
        virtual
        returns (
            uint128 totalFeeAmm,
            uint128 feeProtocolAmm,
            uint128 totalFilledAmm
        )
    {}

    /// @notice hook function calculate fee for amm
    function _calculateFee(
        SwapState.AmmState memory ammState,
        uint128 currentPip,
        bool isBuy,
        bool isBase,
        uint256 mainSideOut,
        uint256 flipSideOut,
        uint16 feePercent
    ) internal virtual returns (uint256) {}

    /// @notice hook function emit event swap
    function emitEventSwap(
        bool isBuy,
        uint256 _baseAmount,
        uint256 _quoteAmount,
        address _trader
    ) internal virtual {}

    // TODO Must implement this function
    /// @notice hook function get amount estmate
    function getAmountEstimate(
        uint256 size,
        bool isBuy,
        bool isBase
    ) external view returns (uint256 mainSideOut, uint256 flipSideOut) {}

    /// @notice hook function calculate quote amount
    function calculatingQuoteAmount(uint256 quantity, uint128 pip)
        external
        view
        virtual
        returns (uint256)
    {}

    /// @notice hook function get currnet pip
    function getCurrentPip() external view virtual returns (uint128) {}

    // @notice hook function calculate quote to base
    function quoteToBase(uint256 quoteAmount, uint128 pip)
        external
        view
        returns (uint256)
    {}

    /// @notice hook function get pip
    function getUnderlyingPriceInPip() internal view virtual returns (uint256) {
        return uint256(singleSlot.pip);
    }

    /// @notice hook function snap shot reserve
    function _addReserveSnapshot() internal virtual {}

    /// @notice hook function require only counter party
    function _onlyCounterParty() internal virtual {}

    function _getPipRange() internal view virtual returns (uint128) {}

    function _getRangeFindingWordsAmm()
        internal
        view
        virtual
        returns (uint128)
    {
        return 0;
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../libraries/types/AMMCoreStorage.sol";
import "../libraries/helper/Math.sol";
import "../libraries/amm/LiquidityMath.sol";
import "../interfaces/IAutoMarketMakerCore.sol";
import "../libraries/exchange/SwapState.sol";
import "../libraries/amm/CrossPipResult.sol";
import "../libraries/helper/Convert.sol";
import "../libraries/helper/FixedPoint128.sol";

abstract contract AutoMarketMakerCore is AMMCoreStorage {
    using Liquidity for Liquidity.Info;
    using Math for uint128;
    using Math for uint256;
    using Convert for uint256;
    using CrossPipResult for CrossPipResult.Result;

    /// @notice init the amm when deploy contract
    /// @notice can call only one time
    function _initializeAMM(
        uint128 _pipRange,
        uint32 _tickSpace,
        uint128 _initPip,
        uint32 _feeShareAmm
    ) internal {
        pipRange = _pipRange;
        tickSpace = _tickSpace;
        feeShareAmm = _feeShareAmm;

        currentIndexedPipRange = LiquidityMath.calculateIndexPipRange(
            _initPip,
            _pipRange
        );
    }

    /// @notice the struct of when add liquidity avoid deep stack
    struct AddLiquidityState {
        uint128 currentPrice;
        uint128 quoteReal;
        uint128 baseReal;
        uint128 cacheSqrtK;
    }

    /// @inheritdoc IAutoMarketMakerCore
    function addLiquidity(AddLiquidity calldata params)
        public
        virtual
        returns (
            uint128 baseAmountAdded,
            uint128 quoteAmountAdded,
            uint256 liquidity,
            uint256 feeGrowthBase,
            uint256 feeGrowthQuote
        )
    {
        _onlyCounterParty();

        AddLiquidityState memory state;
        Liquidity.Info memory _liquidityInfo = liquidityInfo[
            params.indexedPipRange
        ];

        state.currentPrice = _calculateSqrtPrice(
            getCurrentPip(),
            FixedPoint128.BUFFER
        );
        state.cacheSqrtK = _liquidityInfo.sqrtK;

        if (_liquidityInfo.sqrtK == 0) {
            (uint128 pipMin, uint128 pipMax) = LiquidityMath.calculatePipRange(
                params.indexedPipRange,
                pipRange
            );

            _liquidityInfo.sqrtMaxPip = _calculateSqrtPrice(
                pipMax,
                FixedPoint128.BUFFER
            );
            _liquidityInfo.sqrtMinPip = _calculateSqrtPrice(
                pipMin,
                FixedPoint128.BUFFER
            );
            _liquidityInfo.indexedPipRange = params.indexedPipRange;
        }

        if (params.indexedPipRange < currentIndexedPipRange) {
            state.currentPrice = _liquidityInfo.sqrtMaxPip;
        } else if (params.indexedPipRange > currentIndexedPipRange) {
            state.currentPrice = _liquidityInfo.sqrtMinPip;
        }
        state.quoteReal = LiquidityMath.calculateQuoteReal(
            _liquidityInfo.sqrtMinPip,
            params.quoteAmount,
            state.currentPrice
        );
        state.baseReal = LiquidityMath.calculateBaseReal(
            _liquidityInfo.sqrtMaxPip,
            params.baseAmount,
            state.currentPrice
        );

        _liquidityInfo.baseReal += state.baseReal;
        _liquidityInfo.quoteReal += state.quoteReal;

        if (
            (params.indexedPipRange < currentIndexedPipRange) ||
            ((params.indexedPipRange == currentIndexedPipRange) &&
                (state.currentPrice == _liquidityInfo.sqrtMaxPip))
        ) {
            _liquidityInfo.sqrtK = (LiquidityMath.calculateKWithQuote(
                _liquidityInfo.quoteReal,
                state.currentPrice
            ) * _basisPoint()).sqrt().Uint256ToUint128();
            _liquidityInfo.baseReal = uint128(
                (uint256(_liquidityInfo.sqrtK)**2) /
                    uint256(_liquidityInfo.quoteReal)
            );
        } else if (
            (params.indexedPipRange > currentIndexedPipRange) ||
            ((params.indexedPipRange == currentIndexedPipRange) &&
                (state.currentPrice == _liquidityInfo.sqrtMinPip))
        ) {
            _liquidityInfo.sqrtK = (LiquidityMath.calculateKWithBase(
                _liquidityInfo.baseReal,
                state.currentPrice
            ) / _basisPoint()).sqrt().Uint256ToUint128();
            _liquidityInfo.quoteReal = uint128(
                (uint256(_liquidityInfo.sqrtK)**2) /
                    uint256(_liquidityInfo.baseReal)
            );
        } else if (params.indexedPipRange == currentIndexedPipRange) {
            _liquidityInfo.sqrtK = LiquidityMath
                .calculateKWithBaseAndQuote(
                    _liquidityInfo.baseReal,
                    _liquidityInfo.quoteReal
                )
                .sqrt()
                .Uint256ToUint128();
        }
        liquidityInfo[params.indexedPipRange].updateAddLiquidity(
            _liquidityInfo
        );
        return (
            params.baseAmount,
            params.quoteAmount,
            _liquidityInfo.sqrtK - state.cacheSqrtK,
            _liquidityInfo.feeGrowthBase,
            _liquidityInfo.feeGrowthQuote
        );
    }

    /// @inheritdoc IAutoMarketMakerCore
    function removeLiquidity(RemoveLiquidity calldata params)
        public
        virtual
        returns (uint128 baseAmount, uint128 quoteAmount)
    {
        _onlyCounterParty();
        Liquidity.Info memory _liquidityInfo;

        (baseAmount, quoteAmount, _liquidityInfo) = estimateRemoveLiquidity(
            params
        );
        liquidityInfo[params.indexedPipRange].updateAddLiquidity(
            _liquidityInfo
        );
    }

    /// @inheritdoc IAutoMarketMakerCore
    function estimateRemoveLiquidity(RemoveLiquidity calldata params)
        public
        view
        returns (
            uint128 baseAmount,
            uint128 quoteAmount,
            Liquidity.Info memory _liquidityInfo
        )
    {
        _liquidityInfo = liquidityInfo[params.indexedPipRange];
        uint128 quoteRealRemove = LiquidityMath.calculateQuoteRealByLiquidity(
            params.liquidity,
            _liquidityInfo.sqrtK,
            _liquidityInfo.quoteReal
        );
        _liquidityInfo.quoteReal = _liquidityInfo.quoteReal > quoteRealRemove
            ? _liquidityInfo.quoteReal - quoteRealRemove
            : 0;
        uint128 baseRealRemove = LiquidityMath.calculateBaseRealByLiquidity(
            params.liquidity,
            _liquidityInfo.sqrtK,
            _liquidityInfo.baseReal
        );
        _liquidityInfo.baseReal = _liquidityInfo.baseReal > baseRealRemove
            ? _liquidityInfo.baseReal - baseRealRemove
            : 0;

        uint128 sqrtBasicPoint = uint256(_basisPoint())
            .sqrt()
            .Uint256ToUint128();

        uint128 _currentPrice = _calculateSqrtPrice(
            getCurrentPip(),
            FixedPoint128.BUFFER
        );

        if (
            (params.indexedPipRange < currentIndexedPipRange) ||
            (params.indexedPipRange == currentIndexedPipRange &&
                _currentPrice == _liquidityInfo.sqrtMaxPip)
        ) {
            quoteAmount =
                LiquidityMath.calculateQuoteByLiquidity(
                    params.liquidity,
                    _liquidityInfo.sqrtMinPip,
                    _liquidityInfo.sqrtMaxPip
                ) /
                sqrtBasicPoint;

            _liquidityInfo.sqrtK =
                LiquidityMath
                    .calculateKWithQuote(
                        _liquidityInfo.quoteReal,
                        _liquidityInfo.sqrtMaxPip
                    )
                    .sqrt()
                    .Uint256ToUint128() *
                sqrtBasicPoint;
        } else if (
            (params.indexedPipRange > currentIndexedPipRange) ||
            (params.indexedPipRange == currentIndexedPipRange &&
                _currentPrice == _liquidityInfo.sqrtMinPip)
        ) {
            baseAmount =
                LiquidityMath.calculateBaseByLiquidity(
                    params.liquidity,
                    _liquidityInfo.sqrtMaxPip,
                    _liquidityInfo.sqrtMinPip
                ) *
                sqrtBasicPoint;

            _liquidityInfo.sqrtK =
                LiquidityMath
                    .calculateKWithBase(
                        _liquidityInfo.baseReal,
                        _liquidityInfo.sqrtMinPip
                    )
                    .sqrt()
                    .Uint256ToUint128() /
                sqrtBasicPoint;
        } else {
            baseAmount =
                LiquidityMath.calculateBaseByLiquidity(
                    params.liquidity,
                    _liquidityInfo.sqrtMaxPip,
                    _currentPrice
                ) *
                sqrtBasicPoint;
            quoteAmount =
                LiquidityMath.calculateQuoteByLiquidity(
                    params.liquidity,
                    _liquidityInfo.sqrtMinPip,
                    _currentPrice
                ) /
                sqrtBasicPoint;

            _liquidityInfo.sqrtK = LiquidityMath
                .calculateKWithBaseAndQuote(
                    _liquidityInfo.baseReal,
                    _liquidityInfo.quoteReal
                )
                .sqrt()
                .Uint256ToUint128();
        }
    }

    struct OnCrossPipParams {
        uint128 pipNext;
        bool isBuy;
        bool isBase;
        uint128 amount;
        uint32 basisPoint;
        uint128 currentPip;
        uint128 pipRange;
    }

    struct CrossPipState {
        int256 indexedPipRange;
        uint128 pipTargetStep;
        uint128 sqrtTargetPip;
        bool startIntoIndex;
        bool skipIndex;
    }

    /// @notice calculate amount fill amm when have target pip need reach to
    /// @param params the struct OnCrossPipParams
    /// @param ammState the state of amm, alive when market fill
    /// @return result the  struct result after fill
    function _onCrossPipAMMTargetPrice(
        OnCrossPipParams memory params,
        SwapState.AmmState memory ammState
    ) internal view returns (CrossPipResult.Result memory result) {
        CrossPipState memory crossPipState;
        // Have target price
        crossPipState.sqrtTargetPip = _calculateSqrtPrice(
            params.pipNext,
            FixedPoint128.BUFFER
        );
        crossPipState.indexedPipRange = int256(
            LiquidityMath.calculateIndexPipRange(
                params.pipNext,
                params.pipRange
            )
        );
        params.currentPip = _calculateSqrtPrice(
            params.currentPip,
            FixedPoint128.BUFFER
        );
        for (int256 i = ammState.lastPipRangeLiquidityIndex; ; ) {
            SwapState.AmmReserves memory _ammReserves = ammState.ammReserves[
                ammState.index
            ];
            // Init amm state
            if (
                _ammReserves.baseReserve == 0 && _ammReserves.baseReserve == 0
            ) {
                Liquidity.Info memory _liquidity = liquidityInfo[uint256(i)];

                if (_liquidity.sqrtK != 0) {
                    _ammReserves = _initCrossAmmReserves(_liquidity, ammState); // ammState.ammReserves[ammState.index];
                    if (crossPipState.skipIndex) {
                        crossPipState.skipIndex = false;
                    }
                } else {
                    crossPipState.skipIndex = true;
                }
            }

            if (!crossPipState.skipIndex) {
                if (i != crossPipState.indexedPipRange) {
                    crossPipState.pipTargetStep = params.isBuy
                        ? _ammReserves.sqrtMaxPip
                        : _ammReserves.sqrtMinPip;
                } else {
                    crossPipState.pipTargetStep = crossPipState.sqrtTargetPip;
                }

                if (crossPipState.startIntoIndex) {
                    params.currentPip = params.isBuy
                        ? _ammReserves.sqrtMinPip
                        : _ammReserves.sqrtMaxPip;
                    crossPipState.startIntoIndex = false;
                }

                (uint128 baseOut, uint128 quoteOut) = _calculateAmountOut(
                    _ammReserves,
                    params.isBuy,
                    crossPipState.pipTargetStep,
                    params.currentPip,
                    params.basisPoint
                );

                /// This case for amount no reach pip
                /// Need find price stop
                if (
                    _notReachPip(
                        params,
                        _ammReserves,
                        ammState,
                        baseOut,
                        quoteOut,
                        result
                    )
                ) {
                    break;
                }

                result.updateAmountResult(baseOut, quoteOut);

                _updateAmmState(
                    params,
                    ammState.ammReserves[ammState.index],
                    baseOut,
                    quoteOut
                );
                params.currentPip = crossPipState.pipTargetStep;

                params.amount = params.isBase
                    ? params.amount - baseOut
                    : params.amount - quoteOut;
            }
            i = params.isBuy ? i + 1 : i - 1;
            if (
                (params.isBuy && i > crossPipState.indexedPipRange) ||
                (!params.isBuy && i < crossPipState.indexedPipRange) ||
                ammState.index == 4
            ) {
                result.updatePipResult(params.pipNext);
                break;
            }

            ammState.lastPipRangeLiquidityIndex = i;
            crossPipState.startIntoIndex = true;
            ammState.index++;
        }
    }

    /// @notice check amount traded reach the pip or not
    /// @param params the struct OnCrossPipParams
    /// @param _ammReserves the struct SwapState.AmmReserves
    /// @param ammState the state of amm, alive when market fill
    /// @param baseOut the amount base if reach pip
    /// @param quoteOut the amount quote if reach the pip
    /// @return the flag reach pip or not
    function _notReachPip(
        OnCrossPipParams memory params,
        SwapState.AmmReserves memory _ammReserves,
        SwapState.AmmState memory ammState,
        uint128 baseOut,
        uint128 quoteOut,
        CrossPipResult.Result memory result
    ) internal pure returns (bool) {
        if (
            (params.isBase && params.amount <= baseOut) ||
            (!params.isBase && params.amount <= quoteOut)
        ) {
            (uint128 quoteAmount, uint128 baseAmount) = _calculateAmountFilled(
                params,
                _ammReserves
            );
            result.updateAmountResult(baseAmount, quoteAmount);
            result.updatePipResult(
                _updateAmmState(
                    params,
                    ammState.ammReserves[ammState.index],
                    baseAmount,
                    quoteAmount
                )
            );
            return true;
        }
        return false;
    }

    /// @notice calculate the amount filled if can reach to the tart pip we want
    /// @param isBuy the flag buy or sell
    /// @param sqrtPriceTarget the sqrt of target price
    /// @param sqrtCurrentPrice the sqrt of current price
    /// @param basisPoint the basis point of the pip
    /// @return baseOut the amount base if reach pip
    /// @return quoteOut the amount quote if reach the pip
    function _calculateAmountOut(
        SwapState.AmmReserves memory ammReserves,
        bool isBuy,
        uint128 sqrtPriceTarget,
        uint128 sqrtCurrentPrice,
        uint32 basisPoint
    ) internal pure returns (uint128 baseOut, uint128 quoteOut) {
        if (isBuy) {
            baseOut = LiquidityMath.calculateBaseWithPriceWhenBuy(
                sqrtPriceTarget,
                ammReserves.baseReserve,
                sqrtCurrentPrice
            );
            quoteOut =
                LiquidityMath.calculateQuoteWithPriceWhenBuy(
                    sqrtPriceTarget,
                    ammReserves.baseReserve,
                    sqrtCurrentPrice
                ) /
                uint128(basisPoint);
        } else {
            baseOut =
                LiquidityMath.calculateBaseWithPriceWhenSell(
                    sqrtPriceTarget,
                    ammReserves.quoteReserve,
                    sqrtCurrentPrice
                ) *
                uint128(basisPoint);
            quoteOut = LiquidityMath.calculateQuoteWithPriceWhenSell(
                sqrtPriceTarget,
                ammReserves.quoteReserve,
                sqrtCurrentPrice
            );
        }
    }

    /// @notice calculate the amount if not reach pip target
    /// @param params the struct OnCrossPipParams
    /// @param ammReserves the struct SwapState.AmmReserves
    /// @return quoteAmount if not reached pip target
    /// @return baseAmount if not reached pip target
    function _calculateAmountFilled(
        OnCrossPipParams memory params,
        SwapState.AmmReserves memory ammReserves
    ) internal pure returns (uint128 quoteAmount, uint128 baseAmount) {
        if (params.isBuy) {
            if (params.isBase) {
                quoteAmount = LiquidityMath
                    .calculateQuoteBuyAndBaseSellWithoutTargetPrice(
                        ammReserves.sqrtK,
                        ammReserves.baseReserve,
                        params.amount
                    );
                baseAmount = params.amount;
            } else {
                baseAmount = LiquidityMath
                    .calculateBaseBuyAndQuoteSellWithoutTargetPrice(
                        ammReserves.sqrtK,
                        ammReserves.baseReserve,
                        params.amount
                    );
                quoteAmount = params.amount;
            }
        } else if (!params.isBuy) {
            if (params.isBase) {
                quoteAmount = LiquidityMath
                    .calculateBaseBuyAndQuoteSellWithoutTargetPrice(
                        ammReserves.sqrtK,
                        ammReserves.quoteReserve,
                        params.amount
                    );
                baseAmount = params.amount;
            } else {
                baseAmount = LiquidityMath
                    .calculateQuoteBuyAndBaseSellWithoutTargetPrice(
                        ammReserves.sqrtK,
                        ammReserves.quoteReserve,
                        params.amount
                    );
                quoteAmount = params.amount;
            }
        }
    }

    /// @notice amm state when the step amm fill to the pip target
    /// @param params the struct OnCrossPipParams
    /// @param ammReserves the struct SwapState.AmmReserves
    /// @param baseAmount the amount base filled
    /// @param quoteAmount the amount quote filled
    /// @return price the pip reach to
    function _updateAmmState(
        OnCrossPipParams memory params,
        SwapState.AmmReserves memory ammReserves,
        uint128 baseAmount,
        uint128 quoteAmount
    ) internal pure returns (uint128 price) {
        /// In case both baseReal !=0 and quoteReal !=0
        /// We can choose many ways to update ammStates
        /// By quote or by base
        /// In this function, we choose to update by quote
        if (params.isBuy) {
            ammReserves.baseReserve -= baseAmount;
            ammReserves.quoteReserve = uint128(
                (uint256(ammReserves.sqrtK)**2) /
                    uint256(ammReserves.baseReserve)
            );
        } else {
            ammReserves.baseReserve += baseAmount;
            ammReserves.quoteReserve = uint128(
                (uint256(ammReserves.sqrtK)**2) /
                    uint256(ammReserves.baseReserve)
            );
        }

        ammReserves.amountFilled = params.isBuy
            ? ammReserves.amountFilled + baseAmount
            : ammReserves.amountFilled + quoteAmount;

        return
            (ammReserves.quoteReserve * params.basisPoint) /
            ammReserves.baseReserve;
    }

    /// @notice update the amm and save to storage
    /// @param ammState the struct AmmState
    /// @param isBuy the side of order
    /// @param feePercent the fee percent of fee of order
    /// @return totalFeeAmm the total fee of amm
    /// @return feeProtocolAmm the fee of protocol of amm
    /// @return totalFilledAmm the total filled of order
    function _updateAMMStateAfterTrade(
        SwapState.AmmState memory ammState,
        bool isBuy,
        uint16 feePercent
    )
        internal
        returns (
            uint128 totalFeeAmm,
            uint128 feeProtocolAmm,
            uint128 totalFilledAmm
        )
    {
        uint32 _feeShareAmm = feeShareAmm;
        uint128 feeEachIndex;
        uint256 indexedPipRange;
        SwapState.AmmReserves memory ammReserves;
        for (uint8 i = 0; i <= ammState.index; i++) {
            if (ammState.ammReserves[uint256(i)].sqrtK != 0) {
                indexedPipRange = ammState.pipRangesIndex[uint256(i)];
                ammReserves = ammState.ammReserves[uint256(i)];
                totalFilledAmm += ammReserves.amountFilled;

                feeEachIndex =
                    (ammReserves.amountFilled * feePercent) /
                    FixedPoint128.BASIC_POINT_FEE;
                totalFeeAmm += feeEachIndex;

                liquidityInfo[indexedPipRange].updateAMMReserve(
                    ammReserves.quoteReserve,
                    ammReserves.baseReserve,
                    Math.mulDiv(
                        ((feeEachIndex * _feeShareAmm) /
                            FixedPoint128.BASIC_POINT_FEE),
                        FixedPoint128.Q_POW18,
                        ammReserves.sqrtK
                    ),
                    isBuy
                );
            }
        }

        feeProtocolAmm =
            (totalFeeAmm * (FixedPoint128.BASIC_POINT_FEE - _feeShareAmm)) /
            FixedPoint128.BASIC_POINT_FEE;
    }

    /// @notice init amm state when the order is first time
    /// @param _liquidity the information of liquidity
    /// @param ammState the struct SwapState.AmmState, and store memory
    /// @return the amm reserve after init
    function _initCrossAmmReserves(
        Liquidity.Info memory _liquidity,
        SwapState.AmmState memory ammState
    ) internal pure returns (SwapState.AmmReserves memory) {
        ammState.ammReserves[ammState.index] = SwapState.AmmReserves({
            baseReserve: _liquidity.baseReal,
            quoteReserve: _liquidity.quoteReal,
            sqrtK: _liquidity.sqrtK,
            sqrtMaxPip: _liquidity.sqrtMaxPip,
            sqrtMinPip: _liquidity.sqrtMinPip,
            amountFilled: 0
        });

        ammState.pipRangesIndex[ammState.index] = uint256(
            ammState.lastPipRangeLiquidityIndex
        );
        return ammState.ammReserves[ammState.index];
    }

    /// @notice calculate the sqrt of price
    /// @param pip the pip need to sqrt
    /// @param curve the buffer to sqrt
    function _calculateSqrtPrice(uint128 pip, uint256 curve)
        internal
        pure
        returns (uint128)
    {
        return (uint256(pip) * curve).sqrt().Uint256ToUint128();
    }

    /// @notice hook function to get basis point of pair
    function _basisPoint() internal view virtual returns (uint256) {}

    /// @notice hook function to get current pip
    function getCurrentPip() public view virtual returns (uint128) {}

    /// @notice hook function to require only counter can call
    function _onlyCounterParty() internal virtual {}
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IAutoMarketMakerCore.sol";
import "./IMatchingEngineCore.sol";
import "./IFee.sol";

interface IMatchingEngineAMM is
    IFee,
    IAutoMarketMakerCore,
    IMatchingEngineCore
{
    struct InitParams {
        IERC20 quoteAsset;
        IERC20 baseAsset;
        uint256 basisPoint;
        uint128 maxFindingWordsIndex;
        uint128 initialPip;
        uint128 pipRange;
        uint32 tickSpace;
        address owner;
        address positionLiquidity;
        address spotHouse;
        address router;
        uint32 feeShareAmm;
    }

    struct ExchangedData {
        uint256 baseAmount;
        uint256 quoteAmount;
        uint256 feeQuoteAmount;
        uint256 feeBaseAmount;
    }

    /// @notice init the pair right after cloned
    /// @param params the init params with struct InitParams
    /// @dev save storage the init data
    function initialize(InitParams memory params) external;

    /// @notice get the base and quote amount can claim
    /// @param pip the pip of the order
    /// @param orderId id of order in pip
    /// @param exData the base amount
    /// @param basisPoint the basis point of price
    /// @param fee the fee percent
    /// @param feeBasis the basis fee froe calculate
    /// @return the Exchanged data
    /// @dev calculate the base and quote from order and pip
    function accumulateClaimableAmount(
        uint128 pip,
        uint64 orderId,
        ExchangedData memory exData,
        uint256 basisPoint,
        uint16 fee,
        uint128 feeBasis
    ) external view returns (ExchangedData memory);
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../interfaces/IFee.sol";

abstract contract Fee is IFee {
    // quote asset token address
    IERC20 public quoteAsset;

    // base asset token address
    IERC20 public baseAsset;

    // base fee for base asset
    uint256 internal baseFeeFunding;

    // base fee for quote asset
    uint256 internal quoteFeeFunding;

    function _initFee(IERC20 _quoteAsset, IERC20 _baseAsset) internal {
        quoteAsset = _quoteAsset;
        baseAsset = _baseAsset;
    }

    /// @inheritdoc IFee
    function decreaseBaseFeeFunding(uint256 baseFee) public virtual {
        if (baseFee > 0) {
            baseFeeFunding -= baseFee;
        }
    }

    /// @inheritdoc IFee
    function decreaseQuoteFeeFunding(uint256 quoteFee) public virtual {
        if (quoteFee > 0) {
            quoteFeeFunding -= quoteFee;
        }
    }

    /// @inheritdoc IFee
    function increaseBaseFeeFunding(uint256 baseFee) public virtual {
        _increaseBaseFeeFunding(baseFee);
    }

    /// @inheritdoc IFee
    function increaseQuoteFeeFunding(uint256 quoteFee) public virtual {
        _increaseQuoteFeeFunding(quoteFee);
    }

    /// @notice increase the fee base with internal when fill amm and share fee
    function _increaseBaseFeeFunding(uint256 baseFee) internal virtual {
        if (baseFee > 0) {
            baseFeeFunding += baseFee;
        }
    }

    /// @notice increase the fee base with internal when fill amm and share fee
    function _increaseQuoteFeeFunding(uint256 quoteFee) internal virtual {
        if (quoteFee > 0) {
            quoteFeeFunding += quoteFee;
        }
    }

    function resetFee(uint256 baseFee, uint256 quoteFee) external virtual {
        baseFeeFunding -= baseFee;
        quoteFeeFunding -= quoteFee;
    }

    function getFee() external view returns (uint256, uint256) {
        return (baseFeeFunding, quoteFeeFunding);
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

/// @notice this library is used to reduce size contract when require condition
library Require {
    function _require(bool condition, string memory reason) internal pure {
        require(condition, reason);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

/// @notice Mapping error code to error message
library Errors {
    string public constant ME_INITIALIZED = "ME_01";
    string public constant ME_ONLY_COUNTERPARTY = "ME_02";
    string public constant ME_INVALID_SIZE = "ME_03";
    string public constant ME_NOT_ENOUGH_LIQUIDITY = "ME_04";
    string public constant ME_INVALID_INPUT = "ME_05";
    string public constant ME_ONLY_PENDING_ORDER = "ME_06";
    string public constant ME_NOT_PASS_MARKET_MARKER = "ME_07";
    string public constant ME_MUST_CLOSE_TO_INDEX_PRICE_BUY = "ME_08";
    string public constant ME_MUST_CLOSE_TO_INDEX_PRICE_SELL = "ME_09";
    string public constant ME_MARKET_ORDER_MUST_CLOSE_TO_INDEX_PRICE = "ME_10";
    string public constant ME_SETTLE_FUNDING_TOO_EARLY = "ME_11";
    string public constant ME_INVALID_LEVERAGE = "ME_12";
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

interface IMatchingEngineCore {
    struct LiquidityOfEachPip {
        uint128 pip;
        uint256 liquidity;
    }

    /// @notice Emitted when market order filled
    /// @param isBuy side of order
    /// @param amount amount filled
    /// @param toPip fill to pip
    /// @param startPip fill start pip
    /// @param remainingLiquidity remaining liquidity in pip
    /// @param filledIndex number of index filled
    event MarketFilled(
        bool isBuy,
        uint256 indexed amount,
        uint128 toPip,
        uint256 startPip,
        uint128 remainingLiquidity,
        uint64 filledIndex
    );

    /// @notice Emitted when market order filled
    /// @param orderId side of order
    /// @param pip amount filled
    /// @param size fill to pip
    /// @param isBuy fill start pip
    event LimitOrderCreated(
        uint64 orderId,
        uint128 pip,
        uint128 size,
        bool isBuy
    );

    /// @notice Emitted limit order cancel
    /// @param size size of order
    /// @param pip of order
    /// @param orderId id of order cancel
    /// @param isBuy fill start pip
    event LimitOrderCancelled(
        bool isBuy,
        uint64 orderId,
        uint128 pip,
        uint256 size
    );

    /// @notice Emitted when update max finding word
    /// @param pairManager address of pair
    /// @param newMaxFindingWordsIndex new value
    event UpdateMaxFindingWordsIndex(
        address pairManager,
        uint128 newMaxFindingWordsIndex
    );

    /// @notice Emitted when update max finding word for limit order
    /// @param newMaxWordRangeForLimitOrder new value
    event MaxWordRangeForLimitOrderUpdated(
        uint128 newMaxWordRangeForLimitOrder
    );

    /// @notice Emitted when update max finding word for market order
    /// @param newMaxWordRangeForMarketOrder new value
    event MaxWordRangeForMarketOrderUpdated(
        uint128 newMaxWordRangeForMarketOrder
    );

    /// @notice Emitted when snap shot reserve
    /// @param pip pip snap shot
    /// @param timestamp time snap shot
    event ReserveSnapshotted(uint128 pip, uint256 timestamp);

    /// @notice Emitted when limit order updated
    /// @param pairManager address of pair
    /// @param orderId id of order
    /// @param pip at order
    /// @param size of order
    event LimitOrderUpdated(
        address pairManager,
        uint64 orderId,
        uint128 pip,
        uint256 size
    );

    /// @notice Emitted when order fill for swap
    /// @param sender address of trader
    /// @param amount0In amount 0 int
    /// @param amount1In amount 1 in
    /// @param amount0Out amount 0 out
    /// @param amount1Out amount 1 out
    /// @param to swap for address
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );

    /// @notice Update the order when partial fill
    /// @param pip the price of order
    /// @param orderId id of order in pip
    function updatePartialFilledOrder(uint128 pip, uint64 orderId) external;

    /// @notice Cancel the limit order
    /// @param pip the price of order
    /// @param orderId id of order in pip
    function cancelLimitOrder(uint128 pip, uint64 orderId)
        external
        returns (uint256 remainingSize, uint256 partialFilled);

    /// @notice Open limit order with size and price
    /// @param pip the price of order
    /// @param baseAmountIn amount of base asset
    /// @param isBuy side of the limit order
    /// @param trader the owner of the limit order
    /// @param quoteAmountIn amount of quote asset
    /// @param feePercent fee of the order
    /// @dev Calculate the order in insert to queue
    /// @return orderId id of order in pip
    /// @return baseAmountFilled when can fill market amount has filled
    /// @return quoteAmountFilled when can fill market amount has filled
    /// @return fee when can fill market amount has filled
    function openLimit(
        uint128 pip,
        uint128 baseAmountIn,
        bool isBuy,
        address trader,
        uint256 quoteAmountIn,
        uint16 feePercent
    )
        external
        returns (
            uint64 orderId,
            uint256 baseAmountFilled,
            uint256 quoteAmountFilled,
            uint256 fee
        );

    /// @notice Open market order with size is base and price
    /// @param size the amount want to open market order
    /// @param isBuy the side of market order
    /// @param trader the owner of the market order
    /// @param feePercent fee of the order
    /// @dev Calculate full the market order with limit order in queue
    /// @return mainSideOut the amount fill of main asset
    /// @return flipSideOut the amount fill of main asset convert to flip asset
    /// @return fee the amount of fee
    function openMarket(
        uint256 size,
        bool isBuy,
        address trader,
        uint16 feePercent
    )
        external
        returns (
            uint256 mainSideOut,
            uint256 flipSideOut,
            uint256 fee
        );

    /// @notice Open market order with size is base and price
    /// @param quoteAmount the quote amount want to open market order
    /// @param isBuy the side of market order
    /// @param trader the owner of the market order
    /// @param feePercent fee of the order
    /// @dev Calculate full the market order with limit order in queue
    /// @return mainSideOut the amount fill of main asset
    /// @return flipSideOut the amount fill of main asset convert to flip asset
    /// @return fee the amount of fee
    function openMarketWithQuoteAsset(
        uint256 quoteAmount,
        bool isBuy,
        address trader,
        uint16 feePercent
    )
        external
        returns (
            uint256 mainSideOut,
            uint256 flipSideOut,
            uint256 fee
        );

    /// @notice check at this pip has liquidity
    /// @param pip the price of order
    /// @dev load and check flag of liquidity
    /// @return the bool of has liquidity
    function hasLiquidity(uint128 pip) external view returns (bool);

    /// @notice Get detail pending order
    /// @param pip the price of order
    /// @param orderId id of order in pip
    /// @dev Load pending order and calculate the amount of base and quote asset
    /// @return isFilled the order is filled
    /// @return isBuy the side of the order
    /// @return size the size of order
    /// @return partialFilled the amount partial order is filled
    function getPendingOrderDetail(uint128 pip, uint64 orderId)
        external
        view
        returns (
            bool isFilled,
            bool isBuy,
            uint256 size,
            uint256 partialFilled
        );

    /// @notice Get amount liquidity pending at current price
    /// @return the amount liquidity pending
    function getLiquidityInCurrentPip() external view returns (uint128);

    function getLiquidityInPipRange(
        uint128 fromPip,
        uint256 dataLength,
        bool toHigher
    ) external view returns (LiquidityOfEachPip[] memory, uint128);

    function getAmountEstimate(
        uint256 size,
        bool isBuy,
        bool isBase
    ) external view returns (uint256 mainSideOut, uint256 flipSideOut);

    function calculatingQuoteAmount(uint256 quantity, uint128 pip)
        external
        view
        returns (uint256);

    /// @notice Get basis point of pair
    /// @return the basis point of pair
    function basisPoint() external view returns (uint256);

    /// @notice Get current price
    /// @return return the current price
    function getCurrentPip() external view returns (uint128);

    /// @notice Calculate the amount of quote asset
    /// @param quoteAmount the quote amount
    /// @param pip the price
    /// @return the base converted
    function quoteToBase(uint256 quoteAmount, uint128 pip)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

library LimitOrder {
    struct Data {
        // Type order LONG or SHORT
        uint8 isBuy;
        uint120 size;
        // NOTICE need to add leverage
        uint120 partialFilled;
    }

    /// @notice get data or order in queue
    /// @return isBuy the side of order
    /// @return size the size of order
    /// @return partialFilled the partial filled of order
    function getData(LimitOrder.Data storage self)
        internal
        view
        returns (
            bool isBuy,
            uint256 size,
            uint256 partialFilled
        )
    {
        isBuy = self.isBuy == 1;
        size = uint256(self.size);
        partialFilled = uint256(self.partialFilled);
    }

    /// @notice update the order when pill
    /// @param isBuy the side of order
    /// @param size the size of order
    function update(
        LimitOrder.Data storage self,
        bool isBuy,
        uint256 size
    ) internal {
        self.isBuy = isBuy ? 1 : 2;
        self.size = uint120(size);
    }

    /// @notice update the order when to partial pill
    /// @param _remainSize remain size of order
    function updatePartialFill(
        LimitOrder.Data storage _self,
        uint120 _remainSize
    ) internal {
        // remainingSize should be negative
        _self.partialFilled += (_self.size - _self.partialFilled - _remainSize);
    }

    /// @notice reset the order to empty when cancel order
    /// @return the remain size of order
    function updateWhenClose(LimitOrder.Data storage self)
        internal
        returns (uint256)
    {
        self.size -= self.partialFilled;
        self.partialFilled = 0;
        return (uint256(self.size));
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

library TradeConvert {
    /// @notice convert from base amount to quote amount by pip
    /// @param quantity the base amount
    /// @param pip the pip
    /// @param basisPoint the basis point to calculate amount
    /// @return quote amount
    function baseToQuote(
        uint256 quantity,
        uint128 pip,
        uint256 basisPoint
    ) internal pure returns (uint256) {
        // quantity * pip / baseBasisPoint / basisPoint / baseBasisPoint;
        // shorten => quantity * pip / basisPoint ;
        return (quantity * pip) / basisPoint;
    }

    /// @notice convert from quote amount to base amount by pip
    /// @param quoteAmount the base amount
    /// @param pip the pip
    /// @param basisPoint the basis point to calculate amount
    /// @return base amount
    function quoteToBase(
        uint256 quoteAmount,
        uint128 pip,
        uint256 basisPoint
    ) internal pure returns (uint256) {
        return (quoteAmount * basisPoint) / pip;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../exchange/TickPosition.sol";
import "../exchange/LiquidityBitmap.sol";
import "../../interfaces/IMatchingEngineCore.sol";

abstract contract MatchingEngineCoreStorage is IMatchingEngineCore {
    using TickPosition for TickPosition.Data;
    using LiquidityBitmap for mapping(uint128 => uint256);

    /// @inheritdoc IMatchingEngineCore
    // the smallest number of the price. Eg. 100 for 0.01
    uint256 public override basisPoint;

    // Max finding word can be 3500
    //    uint128 public maxFindingWordsIndex;

    uint128 public maxWordRangeForLimitOrder;

    uint128 public maxWordRangeForMarketOrder;

    // The unit of measurement to express the change in value between two currencies
    struct SingleSlot {
        uint128 pip;
        //0: not set
        //1: buy
        //2: sell
        uint8 isFullBuy;
    }

    struct StepComputations {
        uint128 pipNext;
    }

    SingleSlot public singleSlot;
    mapping(uint128 => TickPosition.Data) public tickPosition;
    mapping(uint128 => uint256) public tickStore;
    // a packed array of bit, where liquidity is filled or not
    mapping(uint128 => uint256) public liquidityBitmap;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./LimitOrder.sol";

/*
 * A library storing data and logic at a pip
 */

library TickPosition {
    using SafeMath for uint128;
    using SafeMath for uint64;
    using LimitOrder for LimitOrder.Data;
    struct Data {
        uint128 liquidity;
        uint64 filledIndex;
        uint64 currentIndex;
        // position at a certain tick
        // index => order data
        mapping(uint64 => LimitOrder.Data) orderQueue;
    }

    /// @notice insert the limit order to queue in the pip
    /// @param _size the size of order
    /// @param _isBuy the side of order
    /// @param _hasLiquidity the flag check pip have liquidity before insert
    /// @return _orderId the id of order
    function insertLimitOrder(
        TickPosition.Data storage _self,
        uint128 _size,
        bool _hasLiquidity,
        bool _isBuy
    ) internal returns (uint64) {
        _self.currentIndex++;
        if (
            !_hasLiquidity &&
            _self.filledIndex != _self.currentIndex &&
            _self.liquidity != 0
        ) {
            // means it has liquidity but is not set currentIndex yet
            // reset the filledIndex to fill all
            _self.filledIndex = _self.currentIndex;
            _self.liquidity = _size;
        } else {
            _self.liquidity = _self.liquidity + _size;
        }
        _self.orderQueue[_self.currentIndex].update(_isBuy, _size);
        return _self.currentIndex;
    }

    /// @notice update the order when claim asset of partial order
    /// @param _orderId the id of order
    /// @return the remaining size of order
    function updateOrderWhenClose(
        TickPosition.Data storage _self,
        uint64 _orderId
    ) internal returns (uint256) {
        return _self.orderQueue[_orderId].updateWhenClose();
    }

    /// @notice Get the order by order id
    /// @param _orderId the id of order
    /// @return _isFilled the flag show order is filled
    /// @return _isBuy the side of order
    /// @return _size the _size of order
    /// @return _partialFilled the _size of order filled
    function getQueueOrder(TickPosition.Data storage _self, uint64 _orderId)
        internal
        view
        returns (
            bool _isFilled,
            bool _isBuy,
            uint256 _size,
            uint256 _partialFilled
        )
    {
        (_isBuy, _size, _partialFilled) = _self.orderQueue[_orderId].getData();
        if (_self.filledIndex > _orderId && _size != 0) {
            _isFilled = true;
        } else if (_self.filledIndex < _orderId) {
            _isFilled = false;
        } else {
            _isFilled = _partialFilled >= _size && _size != 0 ? true : false;
        }
    }

    /// @notice update the order to partial fill when market trade
    /// @param _amount the amount fill
    function partiallyFill(TickPosition.Data storage _self, uint128 _amount)
        internal
    {
        _self.liquidity -= _amount;
        unchecked {
            uint64 index = _self.filledIndex;
            uint128 totalSize = 0;
            if (
                _self.orderQueue[index].size ==
                _self.orderQueue[index].partialFilled
            ) {
                index++;
            }
            if (_self.orderQueue[index].partialFilled != 0) {
                totalSize += (_self.orderQueue[index].size -
                    _self.orderQueue[index].partialFilled);
                index++;
            }
            while (totalSize < _amount) {
                totalSize += _self.orderQueue[index].size;
                index++;
            }
            index--;
            _self.filledIndex = index;
            _self.orderQueue[index].updatePartialFill(
                uint120(totalSize - _amount)
            );
        }
    }

    /// @notice update the order to full fill when market trade
    function fullFillLiquidity(TickPosition.Data storage _self) internal {
        uint64 _currentIndex = _self.currentIndex;
        _self.liquidity = 0;
        _self.filledIndex = _currentIndex;
        _self.orderQueue[_currentIndex].partialFilled = _self
            .orderQueue[_currentIndex]
            .size;
    }

    /// @notice update the order when cancel limit order
    /// @param _orderId the id of order
    function cancelLimitOrder(TickPosition.Data storage _self, uint64 _orderId)
        internal
        returns (
            uint256,
            uint256,
            bool
        )
    {
        (bool _isBuy, uint256 _size, uint256 _partialFilled) = _self
            .orderQueue[_orderId]
            .getData();
        if (_self.liquidity >= uint128(_size - _partialFilled)) {
            _self.liquidity = _self.liquidity - uint128(_size - _partialFilled);
        }
        _self.orderQueue[_orderId].update(_isBuy, _partialFilled);

        return (_size - _partialFilled, _partialFilled, _isBuy);
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

library Convert {
    function Uint256ToUint128(uint256 x) internal pure returns (uint128) {
        return uint128(x);
    }

    function Uint256ToUint64(uint256 x) internal pure returns (uint64) {
        return uint64(x);
    }

    function Uint256ToUint32(uint256 x) internal pure returns (uint32) {
        return uint32(x);
    }

    function toI256(uint256 x) internal pure returns (int256) {
        return int256(x);
    }

    function toI128(uint256 x) internal pure returns (int128) {
        return int128(int256(x));
    }

    function abs(int256 x) internal pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
    }

    function abs256(int128 x) internal pure returns (uint256) {
        return uint256(uint128(x >= 0 ? x : -x));
    }

    function toU128(uint256 x) internal pure returns (uint128) {
        return uint128(x);
    }

    function Uint256ToUint40(uint256 x) internal pure returns (uint40) {
        return uint40(x);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../helper/TradeConvert.sol";

library SwapState {
    enum CurrentLiquiditySide {
        NotSet,
        Buy,
        Sell
    }

    struct AmmReserves {
        uint128 baseReserve;
        uint128 quoteReserve;
        uint128 sqrtK;
        uint128 sqrtMaxPip;
        uint128 sqrtMinPip;
        uint128 amountFilled;
    }

    struct AmmState {
        int256 lastPipRangeLiquidityIndex;
        uint8 index;
        uint256[5] pipRangesIndex;
        AmmReserves[5] ammReserves;
    }

    struct State {
        uint256 remainingSize;
        // the tick associated with the current price
        uint128 pip;
        uint32 basisPoint;
        uint128 startPip;
        uint128 remainingLiquidity;
        uint8 isFullBuy;
        bool isSkipFirstPip;
        uint128 lastMatchedPip;
        bool isBuy;
        bool isBase;
        uint256 flipSideOut;
        uint128 pipRange;
        uint128 rangeFindingWordsAmm;
        // For AMM
        AmmState ammState;
    }

    /// @notice init amm stare when start market fill
    /// @return amm state after init value
    function newAMMState() internal pure returns (AmmState memory) {
        AmmReserves[5] memory _ammReserves;
        uint256[5] memory _pipRangesIndex;
        return
            AmmState({
                lastPipRangeLiquidityIndex: -1,
                index: 0,
                pipRangesIndex: _pipRangesIndex,
                ammReserves: _ammReserves
            });
    }

    /// @notice check condition to skip first pip before market fill
    /// @param state the state of market fill
    function beforeExecute(State memory state) internal pure {
        // Check need to skip first pip
        CurrentLiquiditySide currentLiquiditySide = CurrentLiquiditySide(
            state.isFullBuy
        );
        if (currentLiquiditySide != CurrentLiquiditySide.NotSet) {
            if (state.isBuy)
                // if buy and latest liquidity is buy. skip current pip
                state.isSkipFirstPip =
                    currentLiquiditySide == CurrentLiquiditySide.Buy;
                // if sell and latest liquidity is sell. skip current pip
            else
                state.isSkipFirstPip =
                    currentLiquiditySide == CurrentLiquiditySide.Sell;
        }
    }

    /// @notice check is reach max pip when have limit fill market
    /// @param state the state of market fill
    /// @param _pipNext the next pip
    /// @param _maxPip the max pip can reach
    /// @return true if reach max pip
    function isReachedMaxPip(
        State memory state,
        uint128 _pipNext,
        uint128 _maxPip
    ) internal pure returns (bool) {
        return
            (state.isBuy && _pipNext > _maxPip && _maxPip != 0) ||
            (!state.isBuy && _pipNext < _maxPip && _maxPip != 0) ||
            (_maxPip != 0 && _pipNext == 0);
    }

    /// @notice increase or decrease pip back 1 pip depends on buy or sell
    /// @param state the state of market fill
    function moveBack1Pip(State memory state) internal pure {
        if (state.isBuy) {
            state.pip--;
        } else {
            state.pip++;
        }
    }

    /// @notice increase or decrease pip foward 1 pip depends on buy or sell
    /// @param state the state of market fill
    /// @param pipNext the next pip
    function moveForward1Pip(State memory state, uint128 pipNext)
        internal
        pure
    {
        if (state.isBuy) {
            state.pip = pipNext + 1;
        } else {
            state.pip = pipNext - 1;
        }
    }

    /// @notice update the main size out and flip side out when market fill
    /// @param state the state of market fill
    /// @param tradedQuantity then quan of trade
    /// @param pipNext the next pip reach to
    function updateTradedSize(
        State memory state,
        uint256 tradedQuantity,
        uint128 pipNext
    ) internal pure {
        if (state.remainingSize == tradedQuantity) {
            state.remainingSize = 0;
        } else {
            state.remainingSize -= state.isBase
                ? tradedQuantity
                : TradeConvert.baseToQuote(
                    tradedQuantity,
                    pipNext,
                    state.basisPoint
                );
        }

        state.flipSideOut += state.isBase
            ? TradeConvert.baseToQuote(
                tradedQuantity,
                pipNext,
                state.basisPoint
            )
            : tradedQuantity;
    }

    /// @notice update the state with flag buy or sell
    function reverseIsFullBuy(State memory state) internal pure {
        if (!state.isBuy) {
            state.isFullBuy = uint8(1);
        } else {
            state.isFullBuy = uint8(2);
        }
    }

    /// @notice udpate the amm traded when fill amm
    /// @param state the state of market fill
    /// @param baseAmount fill with amm
    /// @param quoteAmount fill with amm
    function updateAMMTradedSize(
        State memory state,
        uint128 baseAmount,
        uint128 quoteAmount
    ) internal pure {
        if (state.isBase) {
            state.flipSideOut += quoteAmount;
            state.remainingSize -= baseAmount;
        } else {
            state.flipSideOut += baseAmount;
            state.remainingSize -= quoteAmount;
        }
    }

    /// @notice update the amm will full fill active range
    /// @param state the state of market fill
    /// @param baseAmount fill with amm
    /// @param quoteAmount fill with amm
    function ammFillAll(
        State memory state,
        uint128 baseAmount,
        uint128 quoteAmount
    ) internal pure {
        state.remainingSize = 0;
        state.flipSideOut += state.isBase ? quoteAmount : baseAmount;
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

library CrossPipResult {
    struct Result {
        uint128 baseCrossPipOut;
        uint128 quoteCrossPipOut;
        uint128 toPip;
    }

    /// @notice update amount quote and base when fill amm
    /// @param self the result of cross pip
    /// @param baseCrossPipOut amount base cross pip out
    /// @param quoteCrossPipOut amount quote cross pip out
    function updateAmountResult(
        Result memory self,
        uint128 baseCrossPipOut,
        uint128 quoteCrossPipOut
    ) internal pure {
        self.baseCrossPipOut += baseCrossPipOut;
        self.quoteCrossPipOut += quoteCrossPipOut;
    }

    /// @notice update the pip when fill amm
    /// @param self the result of cross pip
    /// @param toPip the pip reach to
    function updatePipResult(Result memory self, uint128 toPip) internal pure {
        self.toPip = toPip;
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../helper/FixedPoint128.sol";

/// @title All formulas used in the AMM
library LiquidityMath {
    /// @notice calculate base real from virtual
    /// @param sqrtMaxPip sqrt the max price
    /// @param xVirtual the base virtual
    /// @param sqrtCurrentPrice sqrt the current price
    /// @return the base real
    function calculateBaseReal(
        uint128 sqrtMaxPip,
        uint128 xVirtual,
        uint128 sqrtCurrentPrice
    ) internal pure returns (uint128) {
        if (sqrtCurrentPrice == sqrtMaxPip) {
            return 0;
        }
        return
            uint128(
                (uint256(sqrtMaxPip) * uint256(xVirtual)) /
                    (uint256(sqrtMaxPip) - uint256(sqrtCurrentPrice))
            );
    }

    /// @notice calculate quote real from virtual
    /// @param sqrtMinPip sqrt the max price
    /// @param yVirtual the quote virtual
    /// @param sqrtCurrentPrice sqrt the current price
    /// @return the quote real
    function calculateQuoteReal(
        uint128 sqrtMinPip,
        uint128 yVirtual,
        uint128 sqrtCurrentPrice
    ) internal pure returns (uint128) {
        if (sqrtCurrentPrice == sqrtMinPip) {
            return 0;
        }
        return
            uint128(
                (uint256(sqrtCurrentPrice) * uint256(yVirtual)) /
                    (uint256(sqrtCurrentPrice) - uint256(sqrtMinPip))
            );
    }

    /// @title These functions below are used to calculate the amount asset when SELL

    /// @notice calculate base amount with target price when sell
    /// @param sqrtPriceTarget sqrt the target price
    /// @param quoteReal the quote real
    /// @param sqrtCurrentPrice sqrt the current price
    /// @return the base amount
    function calculateBaseWithPriceWhenSell(
        uint128 sqrtPriceTarget,
        uint128 quoteReal,
        uint128 sqrtCurrentPrice
    ) internal pure returns (uint128) {
        return
            uint128(
                (FixedPoint128.BUFFER *
                    (uint256(quoteReal) *
                        (uint256(sqrtCurrentPrice) -
                            uint256(sqrtPriceTarget)))) /
                    (uint256(sqrtPriceTarget) * uint256(sqrtCurrentPrice)**2)
            );
    }

    /// @notice calculate quote amount with target price when sell
    /// @param sqrtPriceTarget sqrt the target price
    /// @param quoteReal the quote real
    /// @param sqrtCurrentPrice sqrt the current price
    /// @return the quote amount
    function calculateQuoteWithPriceWhenSell(
        uint128 sqrtPriceTarget,
        uint128 quoteReal,
        uint128 sqrtCurrentPrice
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(quoteReal) *
                    (uint256(sqrtCurrentPrice) - uint256(sqrtPriceTarget))) /
                    uint256(sqrtCurrentPrice)
            );
    }

    /// @notice calculate base amount with target price when buy
    /// @param sqrtPriceTarget sqrt the target price
    /// @param baseReal the quote real
    /// @param sqrtCurrentPrice sqrt the current price
    /// @return the base amount
    function calculateBaseWithPriceWhenBuy(
        uint128 sqrtPriceTarget,
        uint128 baseReal,
        uint128 sqrtCurrentPrice
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(baseReal) *
                    (uint256(sqrtPriceTarget) - uint256(sqrtCurrentPrice))) /
                    uint256(sqrtPriceTarget)
            );
    }

    /// @notice calculate quote amount with target price when buy
    /// @param sqrtPriceTarget sqrt the target price
    /// @param baseReal the quote real
    /// @param sqrtCurrentPrice sqrt the current price
    /// @return the quote amount
    function calculateQuoteWithPriceWhenBuy(
        uint128 sqrtPriceTarget,
        uint128 baseReal,
        uint128 sqrtCurrentPrice
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(baseReal) *
                    uint256(sqrtCurrentPrice) *
                    (uint256(sqrtPriceTarget) - uint256(sqrtCurrentPrice))) /
                    FixedPoint128.BUFFER
            );
    }

    /// @notice calculate index pip range
    /// @param pip the pip want to calculate
    /// @param pipRange the range of pair
    /// @return the index pip range
    function calculateIndexPipRange(uint128 pip, uint128 pipRange)
        internal
        pure
        returns (uint256)
    {
        return uint256(pip / pipRange);
    }

    /// @notice calculate max in min pip in index
    /// @param indexedPipRange the index pip range
    /// @param pipRange the range of pair
    /// @return pipMin the min pip in index
    /// @return pipMax the max pip in index
    function calculatePipRange(uint32 indexedPipRange, uint128 pipRange)
        internal
        pure
        returns (uint128 pipMin, uint128 pipMax)
    {
        pipMin = indexedPipRange == 0 ? 1 : indexedPipRange * pipRange;
        pipMax = pipMin + pipRange - 1;
    }

    /// @notice calculate quote and quote amount with no target price when sell
    /// @param sqrtK the sqrt k- mean liquidity
    /// @param amountReal amount real
    /// @param amount amount
    /// @return the amount base or quote
    function calculateBaseBuyAndQuoteSellWithoutTargetPrice(
        uint128 sqrtK,
        uint128 amountReal,
        uint128 amount
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(amount) * uint256(amountReal)**2) /
                    (uint256(sqrtK)**2 + amount * uint256(amountReal))
            );
    }

    /// @notice calculate quote and quote amount with no target price when buy
    /// @param sqrtK the sqrt k- mean liquidity
    /// @param amountReal amount real
    /// @param amount amount
    /// @return the amount base or quote
    function calculateQuoteBuyAndBaseSellWithoutTargetPrice(
        uint128 sqrtK,
        uint128 amountReal,
        uint128 amount
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(amount) * uint256(sqrtK)**2) /
                    (uint256(amountReal) *
                        (uint256(amountReal) - uint256(amount)))
            );
    }

    /// @notice calculate K ( liquidity) with quote real
    /// @param quoteReal the quote real
    /// @param sqrtPriceMax sqrt of price max
    function calculateKWithQuote(uint128 quoteReal, uint128 sqrtPriceMax)
        internal
        pure
        returns (uint256)
    {
        return
            (uint256(quoteReal)**2 / uint256(sqrtPriceMax)) *
            (FixedPoint128.BUFFER / uint256(sqrtPriceMax));
    }

    /// @notice calculate K ( liquidity) with base real
    /// @param baseReal the quote real
    /// @param sqrtPriceMin sqrt of price max
    function calculateKWithBase(uint128 baseReal, uint128 sqrtPriceMin)
        internal
        pure
        returns (uint256)
    {
        return
            (uint256(baseReal)**2 / FixedPoint128.HALF_BUFFER) *
            (uint256(sqrtPriceMin)**2 / FixedPoint128.HALF_BUFFER);
    }

    /// @notice calculate K ( liquidity) with base real and quote ral
    /// @param baseReal the quote real
    /// @param baseReal the base real
    function calculateKWithBaseAndQuote(uint128 quoteReal, uint128 baseReal)
        internal
        pure
        returns (uint256)
    {
        return uint256(quoteReal) * uint256(baseReal);
    }

    /// @notice calculate the liquidity
    /// @param amountReal the amount real
    /// @param sqrtPrice sqrt of price
    /// @param isBase true if base, false if quote
    /// @return the liquidity
    function calculateLiquidity(
        uint128 amountReal,
        uint128 sqrtPrice,
        bool isBase
    ) internal pure returns (uint256) {
        if (isBase) {
            return uint256(amountReal) * uint256(sqrtPrice);
        } else {
            return uint256(amountReal) / uint256(sqrtPrice);
        }
    }

    /// @notice calculate base by the liquidity
    /// @param liquidity the liquidity
    /// @param sqrtPriceMax sqrt of price max
    /// @param sqrtPrice  sqrt of current price
    /// @return the base amount
    function calculateBaseByLiquidity(
        uint128 liquidity,
        uint128 sqrtPriceMax,
        uint128 sqrtPrice
    ) internal pure returns (uint128) {
        return
            uint128(
                (FixedPoint128.HALF_BUFFER *
                    uint256(liquidity) *
                    (uint256(sqrtPriceMax) - uint256(sqrtPrice))) /
                    (uint256(sqrtPrice) * uint256(sqrtPriceMax))
            );
    }

    /// @notice calculate quote by the liquidity
    /// @param liquidity the liquidity
    /// @param sqrtPriceMin sqrt of price min
    /// @param sqrtPrice  sqrt of current price
    /// @return the quote amount
    function calculateQuoteByLiquidity(
        uint128 liquidity,
        uint128 sqrtPriceMin,
        uint128 sqrtPrice
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(liquidity) *
                    (uint256(sqrtPrice) - uint256(sqrtPriceMin))) /
                    FixedPoint128.HALF_BUFFER
            );
    }

    /// @notice calculate base real by the liquidity
    /// @param liquidity the liquidity
    /// @param totalLiquidity the total liquidity of liquidity info
    /// @param totalBaseReal total base real of liquidity
    /// @return the base real
    function calculateBaseRealByLiquidity(
        uint128 liquidity,
        uint128 totalLiquidity,
        uint128 totalBaseReal
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(liquidity) * totalBaseReal) / uint256(totalLiquidity)
            );
    }

    /// @notice calculate quote real by the liquidity
    /// @param liquidity the liquidity
    /// @param totalLiquidity the total liquidity of liquidity info
    /// @param totalQuoteReal total quote real of liquidity
    /// @return the quote real
    function calculateQuoteRealByLiquidity(
        uint128 liquidity,
        uint128 totalLiquidity,
        uint128 totalQuoteReal
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(liquidity) * totalQuoteReal) / uint256(totalLiquidity)
            );
    }

    /// @notice calculate quote virtual from base virtual
    /// @param baseVirtualAmount the base virtual amount
    /// @param sqrtCurrentPrice the sqrt of current price
    /// @param sqrtMaxPip sqrt of max pip
    /// @param sqrtMinPip sqrt of min pip
    /// @return quoteVirtualAmount the quote virtual amount
    function calculateQuoteVirtualAmountFromBaseVirtualAmount(
        uint128 baseVirtualAmount,
        uint128 sqrtCurrentPrice,
        uint128 sqrtMaxPip,
        uint128 sqrtMinPip
    ) internal pure returns (uint128 quoteVirtualAmount) {
        return
            (baseVirtualAmount *
                sqrtCurrentPrice *
                (sqrtCurrentPrice - sqrtMinPip)) /
            (sqrtMaxPip * sqrtCurrentPrice);
    }

    /// @notice calculate base virtual from quote virtual
    /// @param quoteVirtualAmount the quote virtual amount
    /// @param sqrtCurrentPrice the sqrt of current price
    /// @param sqrtMaxPip sqrt of max pip
    /// @param sqrtMinPip sqrt of min pip
    /// @return  baseVirtualAmount the base virtual amount
    function calculateBaseVirtualAmountFromQuoteVirtualAmount(
        uint128 quoteVirtualAmount,
        uint128 sqrtCurrentPrice,
        uint128 sqrtMaxPip,
        uint128 sqrtMinPip
    ) internal pure returns (uint128 baseVirtualAmount) {
        return
            (quoteVirtualAmount *
                sqrtCurrentPrice *
                (sqrtCurrentPrice - sqrtMinPip)) /
            ((sqrtCurrentPrice - sqrtMinPip) * sqrtCurrentPrice * sqrtMaxPip);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "./BitMath.sol";

library LiquidityBitmap {
    uint256 public constant MAX_UINT256 =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    /// @notice Get the position in the mapping
    /// @param pip The bip index for computing the position
    /// @return mapIndex the index in the map
    /// @return bitPos the position in the bitmap
    function position(uint128 pip)
        private
        pure
        returns (uint128 mapIndex, uint8 bitPos)
    {
        mapIndex = pip >> 8;
        bitPos = uint8((pip) & 0xff);
        // % 256
    }

    /// @notice find the next pip has liquidity
    /// @param pip The current pip index
    /// @param lte  Whether to search for the next initialized tick to the left (less than or equal to the starting tick)
    /// @return next The next bit position has liquidity, 0 means no liquidity found
    function findHasLiquidityInOneWords(
        mapping(uint128 => uint256) storage self,
        uint128 pip,
        bool lte
    ) internal view returns (uint128 next) {
        if (lte) {
            // main is find the next pip has liquidity
            (uint128 wordPos, uint8 bitPos) = position(pip);
            // all the 1s at or to the right of the current bitPos
            uint256 mask = (1 << bitPos) - 1 + (1 << bitPos);
            uint256 masked = self[wordPos] & mask;
            //            bool hasLiquidity = (self[wordPos] & 1 << bitPos) != 0;

            // if there are no initialized ticks to the right of or at the current tick, return rightmost in the word
            bool initialized = masked != 0;
            // overflow/underflow is possible, but prevented externally by limiting both tickSpacing and tick
            next = initialized
                ? (pip - (bitPos - BitMath.mostSignificantBit(masked)))
                : 0;
        } else {
            // start from the word of the next tick, since the current tick state doesn't matter
            (uint128 wordPos, uint8 bitPos) = position(pip);
            // all the 1s at or to the left of the bitPos
            uint256 mask = ~((1 << bitPos) - 1);
            uint256 masked = self[wordPos] & mask;
            // if there are no initialized ticks to the left of the current tick, return leftmost in the word
            bool initialized = masked != 0;
            // overflow/underflow is possible, but prevented externally by limiting both tickSpacing and tick
            next = initialized
                ? (pip + (BitMath.leastSignificantBit(masked) - bitPos)) // +1
                : 0;
        }
    }

    // find nearest pip has liquidity in multiple word
    function findHasLiquidityInMultipleWords(
        mapping(uint128 => uint256) storage self,
        uint128 pip,
        uint128 maxWords,
        bool lte
    ) internal view returns (uint128 next) {
        uint128 startWord = pip >> 8;
        if (lte) {
            if (startWord != 0) {
                uint128 i = startWord;
                for (
                    i;
                    i > (startWord < maxWords ? 0 : startWord - maxWords);
                    i--
                ) {
                    if (self[i] != 0) {
                        next = findHasLiquidityInOneWords(
                            self,
                            i < startWord ? 256 * i + 255 : pip,
                            true
                        );
                        if (next != 0) {
                            return next;
                        }
                    }
                }
                if (i == 0 && self[0] != 0) {
                    next = findHasLiquidityInOneWords(self, 255, true);
                    if (next != 0) {
                        return next;
                    }
                }
            } else {
                if (self[startWord] != 0) {
                    next = findHasLiquidityInOneWords(self, pip, true);
                    if (next != 0) {
                        return next;
                    }
                }
            }
        } else {
            for (uint128 i = startWord; i < startWord + maxWords; i++) {
                if (self[i] != 0) {
                    next = findHasLiquidityInOneWords(
                        self,
                        i > startWord ? 256 * i : pip,
                        false
                    );
                    if (next != 0) {
                        return next;
                    }
                }
            }
        }
    }

    // find nearest pip has liquidity in multiple word
    function findHasLiquidityInMultipleWordsWithLimitPip(
        mapping(uint128 => uint256) storage self,
        uint128 pip,
        uint128 maxWords,
        bool lte,
        uint128 limitPip
    ) internal view returns (uint128 next) {
        uint128 startWord = pip >> 8;
        if (lte) {
            if (startWord != 0) {
                uint128 i = startWord;
                for (
                    i;
                    i > (startWord < maxWords ? 0 : startWord - maxWords);
                    i--
                ) {
                    if (self[i] != 0) {
                        next = findHasLiquidityInOneWords(
                            self,
                            i < startWord ? 256 * i + 255 : pip,
                            true
                        );
                        if (next != 0) {
                            return next;
                        }
                    } else if (self[i] == 0 && 256 * i + 255 < limitPip)
                        return limitPip;
                }
                if (i == 0 && self[0] != 0) {
                    next = findHasLiquidityInOneWords(self, 255, true);
                    if (next != 0) {
                        return next;
                    } else return 1;
                } else if (i == 0 && self[0] == 0) return 1;
            } else {
                next = 1;
                if (self[startWord] != 0) {
                    next = findHasLiquidityInOneWords(self, pip, true);
                    if (next != 0) {
                        return next;
                    }
                }
            }
        } else {
            for (uint128 i = startWord; i < startWord + maxWords; i++) {
                if (self[i] != 0) {
                    next = findHasLiquidityInOneWords(
                        self,
                        i > startWord ? 256 * i : pip,
                        false
                    );
                    if (next != 0) {
                        return next;
                    }
                } else if (self[i] == 0 && 256 * i > limitPip) return limitPip;
            }
        }
    }

    // find all pip has liquidity in multiple word
    function findAllLiquidityInMultipleWords(
        mapping(uint128 => uint256) storage self,
        uint128 startPip,
        uint256 dataLength,
        bool toHigher
    ) internal view returns (uint128[] memory) {
        uint128 startWord = startPip >> 8;
        uint128 index = 0;
        uint128[] memory allPip = new uint128[](uint128(dataLength));
        if (!toHigher) {
            for (
                uint128 i = startWord;
                i >= (startWord == 0 ? 0 : startWord - 100);
                i--
            ) {
                if (self[i] != 0) {
                    uint128 next;
                    next = findHasLiquidityInOneWords(
                        self,
                        i < startWord ? 256 * i + 255 : startPip,
                        true
                    );
                    if (next != 0) {
                        allPip[index] = next;
                        index++;
                        while (true) {
                            next = findHasLiquidityInOneWords(
                                self,
                                next - 1,
                                true
                            );
                            if (next != 0 && index <= dataLength) {
                                allPip[index] = next;
                                index++;
                            } else {
                                break;
                            }
                        }
                    }
                }
                if (index == dataLength) return allPip;
                if (i == 0) break;
            }
        } else {
            for (uint128 i = startWord; i <= startWord + 100; i++) {
                if (self[i] != 0) {
                    uint128 next;
                    next = findHasLiquidityInOneWords(
                        self,
                        i > startWord ? 256 * i : startPip,
                        false
                    );
                    if (next != 0) {
                        allPip[index] = next;
                        index++;
                    }
                    while (true) {
                        next = findHasLiquidityInOneWords(
                            self,
                            next + 1,
                            false
                        );
                        if (next != 0 && index <= dataLength) {
                            allPip[index] = next;
                            index++;
                        } else {
                            break;
                        }
                    }
                }
            }
            if (index == dataLength) return allPip;
        }

        return allPip;
    }

    /// @notice check at this pip has liquidity
    /// @param pip The current pip index
    function hasLiquidity(mapping(uint128 => uint256) storage self, uint128 pip)
        internal
        view
        returns (bool)
    {
        (uint128 mapIndex, uint8 bitPos) = position(pip);
        return (self[mapIndex] & (1 << bitPos)) != 0;
    }

    /// @notice Set all bits in a given range
    /// @dev WARNING THIS FUNCTION IS NOT READY FOR PRODUCTION
    /// only use for generating test data purpose
    /// @param fromPip the pip to set from
    /// @param toPip the pip to set to
    function setBitsInRange(
        mapping(uint128 => uint256) storage self,
        uint128 fromPip,
        uint128 toPip
    ) internal {
        (uint128 fromMapIndex, uint8 fromBitPos) = position(fromPip);
        (uint128 toMapIndex, uint8 toBitPos) = position(toPip);
        if (toMapIndex == fromMapIndex) {
            // in the same storage
            // Set all the bits in given range of a number
            self[toMapIndex] |= (((1 << (fromBitPos - 1)) - 1) ^
                ((1 << toBitPos) - 1));
        } else {
            // need to shift the map index
            // TODO fromMapIndex needs set separately
            self[fromMapIndex] |= (((1 << (fromBitPos - 1)) - 1) ^
                ((1 << 255) - 1));
            for (uint128 i = fromMapIndex + 1; i < toMapIndex; i++) {
                // pass uint256.MAX to avoid gas for computing
                self[i] = MAX_UINT256;
            }
            // set bits for the last index
            self[toMapIndex] = MAX_UINT256 >> (256 - toBitPos);
        }
    }

    /// @notice Set all bits to false in a given range
    /// @param _fromPip the pip to set from
    /// @param _toPip the pip to set to
    function unsetBitsRange(
        mapping(uint128 => uint256) storage _self,
        uint128 _fromPip,
        uint128 _toPip
    ) internal {
        if (_fromPip == _toPip) return toggleSingleBit(_self, _fromPip, false);
        _fromPip++;
        _toPip++;
        if (_toPip < _fromPip) {
            uint128 n = _fromPip;
            _fromPip = _toPip;
            _toPip = n;
        }
        (uint128 fromMapIndex, uint8 fromBitPos) = position(_fromPip);
        // toggle pip % 256 = 255 cause when we do _fromPip++, it moved to another word
        if (fromBitPos == 0) {
            toggleSingleBit(_self, _fromPip - 1, false);
        }
        (uint128 toMapIndex, uint8 toBitPos) = position(_toPip);
        if (toMapIndex == fromMapIndex) {
            _self[toMapIndex] &= unsetBitsFromLToR(
                MAX_UINT256,
                fromBitPos,
                toBitPos
            );
        } else {
            // check overflow
            if (fromBitPos > 0) fromBitPos--;
            _self[fromMapIndex] &= ~toggleLastMBits(MAX_UINT256, fromBitPos);
            for (uint128 i = fromMapIndex + 1; i < toMapIndex; i++) {
                _self[i] = 0;
            }
            _self[toMapIndex] &= toggleLastMBits(MAX_UINT256, toBitPos);
        }
    }

    /// @notice toggle a single bit to true or false
    /// @param pip the pip to toggle
    /// @param isSet true to set, false to unset
    function toggleSingleBit(
        mapping(uint128 => uint256) storage self,
        uint128 pip,
        bool isSet
    ) internal {
        (uint128 mapIndex, uint8 bitPos) = position(pip);
        if (isSet) {
            self[mapIndex] |= 1 << bitPos;
        } else {
            self[mapIndex] &= ~(1 << bitPos);
        }
    }

    /// @notice unset bit from left to right
    /// @param _n the number to unset bits
    /// @param _l the bit to unset from left
    /// @param _r the bit to unset to right
    function unsetBitsFromLToR(
        uint256 _n,
        uint8 _l,
        uint8 _r
    ) private pure returns (uint256) {
        if (_l == 0) {
            // NOTE this code support unset at index 0 only
            // avoid overflow in the next line (_l - 1)
            _n |= 1;
            _l++;
        }
        // calculating a number 'num'
        // having 'r' number of bits
        // and bits in the range l
        // to r are the only set bits
        // Important NOTE this code could toggle 0 -> 1
        uint256 num = ((1 << _r) - 1) ^ ((1 << (_l - 1)) - 1);

        // toggle the bits in the
        // range l to r in 'n'
        // and return the number
        return (_n ^ num);
    }

    /// @notice Function to toggle the last m bits
    /// @param n the number to toggle bits
    /// @param m the number of bits to toggle
    function toggleLastMBits(uint256 n, uint8 m)
        private
        pure
        returns (uint256)
    {
        // Calculating a number 'num' having
        // 'm' bits and all are set
        uint256 num = (1 << m) - 1;

        // Toggle the last m bits and
        // return the number
        return (n ^ num);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

/// @title BitMath
/// @dev This libraries provides functionality for computing bit properties of an unsigned integer
library BitMath {
    /// @notice Returns the index of the most significant bit of the number,
    ///     where the least significant bit is at index 0 and the most significant bit is at index 255
    /// @dev The function satisfies the property:
    ///     x >= 2**mostSignificantBit(x) and x < 2**(mostSignificantBit(x)+1)
    /// @param x the value for which to compute the most significant bit, must be greater than 0
    /// @return r the index of the most significant bit
    function mostSignificantBit(uint256 x) internal pure returns (uint8 r) {
        require(x > 0);

        if (x >= 0x100000000000000000000000000000000) {
            x >>= 128;
            r += 128;
        }
        if (x >= 0x10000000000000000) {
            x >>= 64;
            r += 64;
        }
        if (x >= 0x100000000) {
            x >>= 32;
            r += 32;
        }
        if (x >= 0x10000) {
            x >>= 16;
            r += 16;
        }
        if (x >= 0x100) {
            x >>= 8;
            r += 8;
        }
        if (x >= 0x10) {
            x >>= 4;
            r += 4;
        }
        if (x >= 0x4) {
            x >>= 2;
            r += 2;
        }
        if (x >= 0x2) r += 1;
    }

    /// @notice Returns the index of the least significant bit of the number,
    ///     where the least significant bit is at index 0 and the most significant bit is at index 255
    /// @dev The function satisfies the property:
    ///     (x & 2**leastSignificantBit(x)) != 0 and (x & (2**(leastSignificantBit(x)) - 1)) == 0)
    /// @param x the value for which to compute the least significant bit, must be greater than 0
    /// @return r the index of the least significant bit
    function leastSignificantBit(uint256 x) internal pure returns (uint8 r) {
        require(x > 0);

        r = 255;
        if (x & type(uint128).max > 0) {
            r -= 128;
        } else {
            x >>= 128;
        }
        if (x & type(uint64).max > 0) {
            r -= 64;
        } else {
            x >>= 64;
        }
        if (x & type(uint32).max > 0) {
            r -= 32;
        } else {
            x >>= 32;
        }
        if (x & type(uint16).max > 0) {
            r -= 16;
        } else {
            x >>= 16;
        }
        if (x & type(uint8).max > 0) {
            r -= 8;
        } else {
            x >>= 8;
        }
        if (x & 0xf > 0) {
            r -= 4;
        } else {
            x >>= 4;
        }
        if (x & 0x3 > 0) {
            r -= 2;
        } else {
            x >>= 2;
        }
        if (x & 0x1 > 0) r -= 1;
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

/// @title FixedPoint128
/// @notice A library for handling binary fixed point numbers, see https://en.wikipedia.org/wiki/Q_(number_format)
library FixedPoint128 {
    uint256 internal constant Q128 = 0x100000000000000000000000000000000;
    uint256 internal constant BUFFER = 10**24;
    uint256 internal constant Q_POW18 = 10**18;
    uint256 internal constant HALF_BUFFER = 10**12;
    uint32 internal constant BASIC_POINT_FEE = 10_000;
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../libraries/amm/Liquidity.sol";

interface IAutoMarketMakerCore {
    struct AddLiquidity {
        uint128 baseAmount;
        uint128 quoteAmount;
        uint32 indexedPipRange;
    }

    /// @notice Add liquidity and mint the NFT
    /// @param params Struct AddLiquidity
    /// @dev Depends on data struct with base amount, quote amount and index pip
    /// calculate the liquidity and increase liquidity at index pip
    /// @return baseAmountAdded the base amount will be added
    /// @return quoteAmountAdded the quote amount will be added
    /// @return liquidity calculate from quote and base amount
    /// @return feeGrowthBase tracking growth base
    /// @return feeGrowthQuote tracking growth quote
    function addLiquidity(AddLiquidity calldata params)
        external
        returns (
            uint128 baseAmountAdded,
            uint128 quoteAmountAdded,
            uint256 liquidity,
            uint256 feeGrowthBase,
            uint256 feeGrowthQuote
        );

    /// @notice the struct for remove liquidity avoid deep stack
    struct RemoveLiquidity {
        uint128 liquidity;
        uint32 indexedPipRange;
        uint256 feeGrowthBase;
        uint256 feeGrowthQuote;
    }

    /// @notice Remove liquidity in index pip of nft
    /// @param params Struct Remove liquidity
    /// @dev remove liquidity at index pip and decrease the data of liquidity info
    /// @return baseAmount base amount receive
    /// @return quoteAmount quote amount receive
    function removeLiquidity(RemoveLiquidity calldata params)
        external
        returns (uint128 baseAmount, uint128 quoteAmount);

    /// @notice estimate amount receive when remove liquidity in index pip
    /// @param params struct Remove liquidity
    /// @dev calculate amount of quote and base
    /// @return baseAmount base amount receive
    /// @return quoteAmount quote amount receive
    /// @return liquidityInfo newest of liquidity info
    function estimateRemoveLiquidity(RemoveLiquidity calldata params)
        external
        view
        returns (
            uint128 baseAmount,
            uint128 quoteAmount,
            Liquidity.Info memory liquidityInfo
        );

    /// @notice get liquidity info of any index pip range
    /// @param index want to get info
    /// @dev load data from storage and return
    /// @return sqrtMaxPip sqrt of max pip
    /// @return sqrtMinPip sqrt of min pip
    /// @return quoteReal quote real of liquidity of index
    /// @return baseReal base real of liquidity of index
    /// @return indexedPipRange index of liquidity info
    /// @return feeGrowthBase the growth of base
    /// @return feeGrowthQuote the growth of base
    /// @return sqrtK sqrt of k=quoteReal*baseReal,
    function liquidityInfo(uint256 index)
        external
        view
        returns (
            uint128 sqrtMaxPip,
            uint128 sqrtMinPip,
            uint128 quoteReal,
            uint128 baseReal,
            uint32 indexedPipRange,
            uint256 feeGrowthBase,
            uint256 feeGrowthQuote,
            uint128 sqrtK
        );

    /// @notice get current index pip range
    /// @dev load current index pip range from storage
    /// @return The current pip range
    function pipRange() external view returns (uint128);

    /// @notice get the tick space for external generate orderbook
    /// @dev load current tick space from storage
    /// @return the config tick space
    function tickSpace() external view returns (uint32);

    /// @notice get current index pip range
    /// @dev load current current index pip range from storage
    /// @return the current index pip range
    function currentIndexedPipRange() external view returns (uint256);

    /// @notice get percent fee will be share when market order fill
    /// @dev load config fee from storage
    /// @return the config fee
    function feeShareAmm() external view returns (uint32);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../../interfaces/IAutoMarketMakerCore.sol";

abstract contract AMMCoreStorage is IAutoMarketMakerCore {
    /// @inheritdoc IAutoMarketMakerCore
    /// @notice the range of liquidity
    uint128 public override pipRange;

    /// @inheritdoc IAutoMarketMakerCore
    /// @notice the tick space of external bulid order book
    uint32 public override tickSpace;

    /// @inheritdoc IAutoMarketMakerCore
    /// @notice the current index pip active
    uint256 public override currentIndexedPipRange;

    /// @inheritdoc IAutoMarketMakerCore
    /// @notice the mapping with index and the liquidity of index
    mapping(uint256 => Liquidity.Info) public override liquidityInfo;

    /// @inheritdoc IAutoMarketMakerCore
    /// @notice the percent fee share when fill amm
    uint32 public override feeShareAmm;
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

library Math {
    /// @notice Calculates the square root of x, rounding down.
    /// @dev Uses the Babylonian method https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
    /// @param x The uint256 number for which to calculate the square root.
    /// @return result The result as an uint256.
    function sqrt(uint256 x) internal pure returns (uint256 result) {
        if (x == 0) {
            return 0;
        }

        // Calculate the square root of the perfect square of a power of two that is the closest to x.
        uint256 xAux = uint256(x);
        result = 1;
        if (xAux >= 0x100000000000000000000000000000000) {
            xAux >>= 128;
            result <<= 64;
        }
        if (xAux >= 0x10000000000000000) {
            xAux >>= 64;
            result <<= 32;
        }
        if (xAux >= 0x100000000) {
            xAux >>= 32;
            result <<= 16;
        }
        if (xAux >= 0x10000) {
            xAux >>= 16;
            result <<= 8;
        }
        if (xAux >= 0x100) {
            xAux >>= 8;
            result <<= 4;
        }
        if (xAux >= 0x10) {
            xAux >>= 4;
            result <<= 2;
        }
        if (xAux >= 0x8) {
            result <<= 1;
        }

        // The operations can never overflow because the result is max 2^127 when it enters this block.
        {
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1; // Seven iterations should be enough
            uint256 roundedDownResult = x / result;
            return result >= roundedDownResult ? roundedDownResult : result;
        }
    }

    /// @notice Get minimum of two numbers.
    /// @return z the number with the minimum value.
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param x The multiplicand
    /// @param y The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

library Liquidity {
    struct Info {
        uint128 sqrtMaxPip;
        uint128 sqrtMinPip;
        uint128 quoteReal;
        uint128 baseReal;
        uint32 indexedPipRange;
        uint256 feeGrowthBase;
        uint256 feeGrowthQuote;
        uint128 sqrtK;
    }

    /// @notice Define the new pip range when the first time add liquidity
    /// @param self the liquidity info
    /// @param sqrtMaxPip the max pip
    /// @param sqrtMinPip the min pip
    /// @param indexedPipRange the index of liquidity info
    function initNewPipRange(
        Liquidity.Info storage self,
        uint128 sqrtMaxPip,
        uint128 sqrtMinPip,
        uint32 indexedPipRange
    ) internal {
        self.sqrtMaxPip = sqrtMaxPip;
        self.sqrtMinPip = sqrtMinPip;
        self.indexedPipRange = indexedPipRange;
    }

    /// @notice update the liquidity info when add liquidity
    /// @param self the liquidity info
    /// @param updater of struct Liquidity.Info, this is new value of liquidity info
    function updateAddLiquidity(
        Liquidity.Info storage self,
        Liquidity.Info memory updater
    ) internal {
        if (self.sqrtK == 0) {
            self.sqrtMaxPip = updater.sqrtMaxPip;
            self.sqrtMinPip = updater.sqrtMinPip;
            self.indexedPipRange = updater.indexedPipRange;
        }
        self.quoteReal = updater.quoteReal;
        self.baseReal = updater.baseReal;
        self.sqrtK = updater.sqrtK;
    }

    /// @notice growth fee base and quote
    /// @param self the liquidity info
    /// @param feeGrowthBase the growth of base
    /// @param feeGrowthQuote the growth of base
    function updateFeeGrowth(
        Liquidity.Info storage self,
        uint256 feeGrowthBase,
        uint256 feeGrowthQuote
    ) internal {
        self.feeGrowthBase = feeGrowthBase;
        self.feeGrowthQuote = feeGrowthQuote;
    }

    /// @notice update the liquidity info when after trade and save to storage
    /// @param self the liquidity info
    /// @param baseReserve the new value of baseReserve
    /// @param quoteReserve the new value of quoteReserve
    /// @param feeGrowth new growth value increase
    /// @param isBuy the side of trade
    function updateAMMReserve(
        Liquidity.Info storage self,
        uint128 quoteReserve,
        uint128 baseReserve,
        uint256 feeGrowth,
        bool isBuy
    ) internal {
        self.quoteReal = quoteReserve;
        self.baseReal = baseReserve;

        if (isBuy) {
            self.feeGrowthBase += feeGrowth;
        } else {
            self.feeGrowthQuote += feeGrowth;
        }
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

interface IFee {
    /// @notice decrease the fee base
    /// @param baseFee will be decreased
    /// @dev minus the fee base funding
    function decreaseBaseFeeFunding(uint256 baseFee) external;

    /// @notice decrease the fee quote
    /// @param quoteFee will be decreased
    /// @dev minus the fee quote funding
    function decreaseQuoteFeeFunding(uint256 quoteFee) external;

    /// @notice increase the fee base
    /// @param baseFee will be decreased
    /// @dev plus the fee base funding
    function increaseBaseFeeFunding(uint256 baseFee) external;

    /// @notice increase the fee quote`
    /// @param quoteFee will be decreased
    /// @dev plus the fee quote funding
    function increaseQuoteFeeFunding(uint256 quoteFee) external;

    /// @notice reset the fee funding to zero when Position claim fee
    /// @param baseFee will be decreased
    /// @param quoteFee will be decreased
    /// @dev reset baseFee and quoteFee to zero
    function resetFee(uint256 baseFee, uint256 quoteFee) external;

    /// @notice get the fee base funding and fee quote funding
    /// @dev load amount quote and base
    /// @return baseFeeFunding and quoteFeeFunding
    function getFee()
        external
        view
        returns (uint256 baseFeeFunding, uint256 quoteFeeFunding);
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