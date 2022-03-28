// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../interfaces/IPositionManager.sol";
import "./libraries/position/Position.sol";
import "hardhat/console.sol";
import "./PositionManager.sol";
import "./libraries/helpers/Quantity.sol";
import "./libraries/position/PositionLimitOrder.sol";
import "../interfaces/IInsuranceFund.sol";
import "./libraries/types/PositionHouseStorage.sol";
import {PositionHouseFunction} from "./libraries/position/PositionHouseFunction.sol";
import {PositionHouseMath} from "./libraries/position/PositionHouseMath.sol";
import {Errors} from "./libraries/helpers/Errors.sol";
import {Int256Math} from "./libraries/helpers/Int256Math.sol";

contract PositionHouse is
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable,
    PositionHouseStorage,
    PausableUpgradeable
{
    using PositionLimitOrder for mapping(address => mapping(address => PositionLimitOrder.Data[]));
    using Quantity for int256;
    using Int256Math for int256;
    using Quantity for int128;

    using Position for Position.Data;
    using Position for Position.LiquidatedData;
    using PositionHouseFunction for PositionHouse;

    event OpenMarket(
        address trader,
        int256 quantity,
        uint256 leverage,
        uint256 entryPrice,
        IPositionManager positionManager
    );
    event OpenLimit(
        uint64 orderId,
        address trader,
        int256 quantity,
        uint256 leverage,
        uint128 pip,
        IPositionManager positionManager
    );

    event MarginAdded(
        address trader,
        uint256 marginAdded,
        IPositionManager positionManager
    );

    event MarginRemoved(
        address trader,
        uint256 marginRemoved,
        IPositionManager positionManager
    );

    event CancelLimitOrder(
        address trader,
        address _positionManager,
        uint128 pip,
        uint64 orderId
    );

    event Liquidated(address pmAddress, address trader);

    event WhitelistPositionManagerAdded(address pmAddress);

    event WhitelistPositionManagerRemoved(address pmAddress);

    function initialize(
        uint256 _maintenanceMarginRatio,
        uint256 _partialLiquidationRatio,
        uint256 _liquidationFeeRatio,
        uint256 _liquidationPenaltyRatio,
        address _insuranceFund
    ) public initializer {
        __ReentrancyGuard_init();
        __Ownable_init();
        maintenanceMarginRatio = _maintenanceMarginRatio;
        partialLiquidationRatio = _partialLiquidationRatio;
        liquidationFeeRatio = _liquidationFeeRatio;
        liquidationPenaltyRatio = _liquidationPenaltyRatio;
        insuranceFund = IInsuranceFund(_insuranceFund);
    }

    /**
     * @notice open position with price market
     * @param _positionManager IPositionManager address
     * @param _side Side of position LONG or SHORT
     * @param _quantity quantity of size after mul with leverage
     * @param _leverage leverage of position
     */
    function openMarketPosition(
        IPositionManager _positionManager,
        Position.Side _side,
        uint256 _quantity,
        uint256 _leverage
    ) public whenNotPaused nonReentrant {
        address _trader = _msgSender();
        address _pmAddress = address(_positionManager);
        int256 pQuantity = _side == Position.Side.LONG
            ? int256(_quantity)
            : -int256(_quantity);
        Position.Data memory oldPosition = getPosition(
            _pmAddress,
            _trader
        );
        if (oldPosition.quantity == 0) {
            oldPosition.leverage = 1;
        }
        //leverage must be greater than old position and in range of allowed leverage
        require(
            _leverage >= oldPosition.leverage &&
                _leverage <= 125 &&
                _leverage > 0,
            Errors.VL_INVALID_LEVERAGE
        );
        PositionResp memory pResp;
        // check if old position quantity is the same side with the new one
        if (oldPosition.quantity == 0 || oldPosition.side() == _side) {
            pResp = PositionHouseFunction.increasePosition(
                _pmAddress,
                _side,
                int256(_quantity),
                _leverage,
                _trader,
                oldPosition,
                positionMap[_pmAddress][_trader],
                cumulativePremiumFractions[_pmAddress]
            );
        } else {
            pResp = openReversePosition(
                _positionManager,
                _side,
                pQuantity,
                _leverage,
                _trader,
                oldPosition
            );
        }
        // update position state
        positionMap[_pmAddress][_trader].update(pResp.position);

        if (pResp.marginToVault > 0) {
            //transfer from trader to vault
            uint256 fee = _positionManager.calcFee(pResp.position.openNotional);
            deposit(_positionManager, _trader, pResp.marginToVault.abs(), fee);
        } else if (pResp.marginToVault < 0) {
            // withdraw from vault to user
            withdraw(_positionManager, _trader, pResp.marginToVault.abs());
        }
        emit OpenMarket(
            _trader,
            pQuantity,
            _leverage,
            (pResp.exchangedQuoteAssetAmount * _positionManager.getBasisPoint()) / _quantity,
            _positionManager
        );
    }

    function openLimitOrder(
        IPositionManager _positionManager,
        Position.Side _side,
        uint256 _uQuantity,
        uint128 _pip,
        uint256 _leverage
    ) public whenNotPaused nonReentrant {
        address _trader = _msgSender();
        OpenLimitResp memory openLimitResp;
        int256 _quantity = _side == Position.Side.LONG
            ? int256(_uQuantity)
            : -int256(_uQuantity);
        (
            openLimitResp.orderId,
            openLimitResp.sizeOut
        ) = _internalOpenLimitOrder(
            _positionManager,
            _trader,
            _pip,
            _quantity,
            _leverage
        );
        if (openLimitResp.sizeOut < _uQuantity) {
            PositionLimitOrder.Data memory _newOrder = PositionLimitOrder.Data({
                pip: _pip,
                orderId: openLimitResp.orderId,
                leverage: uint16(_leverage),
                isBuy: _side == Position.Side.LONG ? 1 : 2,
                entryPrice: 0,
                reduceLimitOrderId: 0,
                reduceQuantity: 0,
                blockNumber: block.number
            });
            _storeLimitOrder(
                _newOrder,
                _positionManager,
                _trader,
                _quantity,
                openLimitResp.sizeOut
            );
        }
        (, uint256 marginToVault, uint256 fee) = _positionManager
            .getNotionalMarginAndFee(_uQuantity, _pip, _leverage);
        deposit(_positionManager, _trader, marginToVault, fee);
        canClaimAmountMap[address(_positionManager)][_trader] += marginToVault;
        emit OpenLimit(
            openLimitResp.orderId,
            _trader,
            _quantity,
            _leverage,
            _pip,
            _positionManager
        );
    }

    function _internalOpenLimitOrder(
        IPositionManager _positionManager,
        address _trader,
        uint128 _pip,
        int256 _rawQuantity,
        uint256 _leverage
    ) internal returns (uint64 orderId, uint256 sizeOut) {
        {
            address _pmAddress = address(_positionManager);
            Position.Data memory oldPosition = getPosition(_pmAddress, _trader);
            require(
                _leverage >= oldPosition.leverage &&
                    _leverage <= 125 &&
                    _leverage > 0,
                Errors.VL_INVALID_LEVERAGE
            );
            uint256 openNotional;
            uint128 _quantity = _rawQuantity.abs128();
            if (
                oldPosition.quantity != 0 &&
                !oldPosition.quantity.isSameSide(_rawQuantity) &&
                _positionManager.needClosePositionBeforeOpeningLimitOrder(
                    _rawQuantity.u8Side(),
                    _pip,
                    _quantity,
                    oldPosition.quantity.u8Side(),
                    oldPosition.quantity.abs()
                )
            ) {
                PositionResp memory closePositionResp = internalClosePosition(
                    _positionManager,
                    _trader,
                    PnlCalcOption.SPOT_PRICE,
                    true,
                    oldPosition
                );
                if (
                    _rawQuantity - closePositionResp.exchangedPositionSize == 0
                ) {
                    // TODO deposit margin to vault of position resp
                    //                            positionResp = closePositionResp;
                    //                            deposit(_positionManager, _trader, positionResp.marginToVault.abs(), 0);
                } else {
                    _quantity -= (closePositionResp.exchangedPositionSize)
                        .abs128();
                }
            }
            (orderId, sizeOut, openNotional) = _positionManager
                .openLimitPosition(_pip, _quantity, _rawQuantity > 0);
            if (sizeOut != 0) {
                // case: open a limit order at the last price
                // the order must be partially executed
                // then update the current position
                Position.Data memory newData;
                newData = PositionHouseFunction.handleMarketPart(
                    oldPosition,
                    positionMap[_pmAddress][_trader],
                    openNotional,
                    _rawQuantity > 0 ? int256(sizeOut) : -int256(sizeOut),
                    _leverage,
                    cumulativePremiumFractions[_pmAddress]
                );
                positionMap[_pmAddress][_trader].update(newData);
            }
        }
    }

    // check the new limit order is fully reduce, increase or both reduce and increase
    function _storeLimitOrder(
        PositionLimitOrder.Data memory _newOrder,
        IPositionManager _positionManager,
        address _trader,
        int256 _quantity,
        uint256 _sizeOut
    ) internal {
        address _pmAddress = address(_positionManager);
        Position.Data memory oldPosition = getPosition(
            _pmAddress,
            _trader
        );
        if (
            oldPosition.quantity == 0 ||
            _quantity.isSameSide(oldPosition.quantity)
        ) {
            limitOrders[_pmAddress][_trader].push(_newOrder);
        } else {
            // limit order reducing position
            uint256 baseBasisPoint = _positionManager.getBaseBasisPoint();
            // if new limit order is smaller than old position then just reduce old position
            if (oldPosition.quantity.abs() > _quantity.abs()) {
                _newOrder.reduceQuantity = _quantity.abs() - _sizeOut;
            }
            // else new limit order is larger than old position then close old position and open new opposite position
            else {
                _newOrder.reduceQuantity = oldPosition.quantity.abs();
                _newOrder.reduceLimitOrderId =
                    reduceLimitOrders[_pmAddress][_trader].length +
                    1;
                limitOrders[_pmAddress][_trader].push(_newOrder);
            }
            _newOrder.entryPrice = PositionHouseMath.entryPriceFromNotional(
                oldPosition.openNotional,
                oldPosition.quantity.abs(),
                baseBasisPoint
            );
            reduceLimitOrders[_pmAddress][_trader].push(_newOrder);
        }
    }

    /**
     * @dev cancel a limit order
     * @param _positionManager position manager
     * @param _orderIdx order index in the limit orders (increase or reduce) list
     * @param _isReduce is that a reduce limit order?
     * The external service must determine that by a variable in getListOrderPending
     */
    function cancelLimitOrder(
        IPositionManager _positionManager,
        uint64 _orderIdx,
        uint8 _isReduce
    ) external whenNotPaused nonReentrant {
        address _trader = _msgSender();
        address _pmAddress = address(_positionManager);
        // declare a pointer to reduceLimitOrders or limitOrders
        PositionLimitOrder.Data[] storage _orders = _isReduce == 1
            ? reduceLimitOrders[_pmAddress][_trader]
            : limitOrders[_pmAddress][_trader];
        require(_orderIdx < _orders.length, Errors.VL_INVALID_ORDER);
        // save gas
        PositionLimitOrder.Data memory _order = _orders[_orderIdx];
        // blank limit order data
        // we set the deleted order to a blank data
        // because we don't want to mess with order index (orderIdx)
        PositionLimitOrder.Data memory blankLimitOrderData;

        (uint256 refundQuantity, uint256 partialFilled) = _positionManager
            .cancelLimitOrder(_order.pip, _order.orderId);
        if (partialFilled == 0) {
            _orders[_orderIdx] = blankLimitOrderData;
            if (_order.reduceLimitOrderId != 0) {
                reduceLimitOrders[_pmAddress][_trader][
                    _order.reduceLimitOrderId - 1
                ] = blankLimitOrderData;
            }
        }

        (, uint256 _refundMargin, ) = _positionManager.getNotionalMarginAndFee(
            refundQuantity,
            _order.pip,
            _order.leverage
        );
        withdraw(_positionManager, _trader, _refundMargin);
        canClaimAmountMap[_pmAddress][_trader] -= _refundMargin;
        emit CancelLimitOrder(_trader, _pmAddress, _order.pip, _order.orderId);
    }

    /**
     * @notice close position with close market
     * @param _positionManager IPositionManager address
     * @param _quantity want to close
     */
    function closePosition(IPositionManager _positionManager, uint256 _quantity)
        public
    {
        address _trader = _msgSender();
        Position.Data memory positionData = getPosition(
            address(_positionManager),
            _trader
        );
        require(
            _quantity > 0 && _quantity <= positionData.quantity.abs(),
            Errors.VL_INVALID_CLOSE_QUANTITY
        );
        openMarketPosition(
            _positionManager,
            positionData.quantity > 0
                ? Position.Side.SHORT
                : Position.Side.LONG,
            _quantity,
            positionData.leverage
        );
    }

    /**
     * @notice close position with close market
     * @param _positionManager IPositionManager address
     * @param _pip limit price want to close
     * @param _quantity want to close
     */
    function closeLimitPosition(
        IPositionManager _positionManager,
        uint128 _pip,
        uint256 _quantity
    ) public {
        address _trader = _msgSender();
        Position.Data memory positionData = getPosition(
            address(_positionManager),
            _trader
        );
        require(
            _quantity > 0 && _quantity <= positionData.quantity.abs(),
            Errors.VL_INVALID_CLOSE_QUANTITY
        );
        openLimitOrder(
            _positionManager,
            positionData.quantity > 0
                ? Position.Side.SHORT
                : Position.Side.LONG,
            _quantity,
            _pip,
            positionData.leverage
        );
    }

    function getClaimAmount(address _pmAddress, address _trader)
        public
        view
        returns (int256 totalClaimableAmount)
    {
        Position.Data memory positionData = getPosition(
            _pmAddress,
            _trader
        );
        return
            PositionHouseFunction.getClaimAmount(
                _pmAddress,
                _trader,
                positionData,
                positionMap[_pmAddress][_trader],
                limitOrders[_pmAddress][_trader],
                reduceLimitOrders[_pmAddress][_trader],
                canClaimAmountMap[_pmAddress][_trader],
                manualMargin[_pmAddress][_trader]
            );
    }

    function claimFund(IPositionManager _positionManager)
        external
        whenNotPaused
        nonReentrant
    {
        address _trader = _msgSender();
        address _pmAddress = address(_positionManager);
        int256 totalRealizedPnl = getClaimAmount(
            _pmAddress,
            _trader
        );
        require(
            getPosition(_pmAddress, _trader).quantity == 0,
            Errors.VL_INVALID_CLAIM_FUND
        );
        clearPosition(_pmAddress, _trader);
        if (totalRealizedPnl > 0) {
            withdraw(_positionManager, _trader, totalRealizedPnl.abs());
        }
    }

    /**
     * @notice liquidate trader's underwater position. Require trader's margin ratio more than partial liquidation ratio
     * @dev liquidator can NOT open any positions in the same block to prevent from price manipulation.
     * @param _positionManager positionManager address
     * @param _trader trader address
     */
    function liquidate(IPositionManager _positionManager, address _trader)
        external
        whenNotPaused
        nonReentrant
    {
        address _caller = _msgSender();
        (, , uint256 marginRatio) = getMaintenanceDetail(
            _positionManager,
            _trader
        );

        require(
            marginRatio >= partialLiquidationRatio,
            Errors.VL_NOT_ENOUGH_MARGIN_RATIO
        );
        address _pmAddress = address(_positionManager);
        PositionResp memory positionResp;
        uint256 liquidationPenalty;
        {
            uint256 feeToLiquidator;
            uint256 feeToInsuranceFund;
            Position.Data memory positionData = getPosition(
                _pmAddress,
                _trader
            );
            // partially liquidate position
            if (marginRatio >= partialLiquidationRatio && marginRatio < 100) {
                // calculate amount quantity of position to reduce
                int256 partiallyLiquidateQuantity = positionData
                    .quantity
                    .getPartiallyLiquidate(liquidationPenaltyRatio);
                // partially liquidate position by reduce position's quantity
                positionResp = partialLiquidate(
                    _positionManager,
                    positionData.quantity > 0
                        ? Position.Side.SHORT
                        : Position.Side.LONG,
                    -partiallyLiquidateQuantity,
                    positionData,
                    _trader
                );

                // half of the liquidationFee goes to liquidator & another half goes to insurance fund
                liquidationPenalty = uint256(positionResp.marginToVault);
                feeToLiquidator = liquidationPenalty / 2;
                feeToInsuranceFund = liquidationPenalty - feeToLiquidator;
            } else {
                // fully liquidate trader's position
                liquidationPenalty =
                    positionData.margin +
                    uint256(manualMargin[_pmAddress][_trader]);
                withdraw(
                    _positionManager,
                    _trader,
                    (uint256(getClaimAmount(_pmAddress, _trader)) +
                        positionData.margin)
                );
                clearPosition(_pmAddress, _trader);
                feeToLiquidator =
                    (liquidationPenalty * liquidationFeeRatio) /
                    2 /
                    100;
            }
            withdraw(_positionManager, _caller, feeToLiquidator);
            // count as bad debt, transfer money to insurance fund and liquidator
        }
        emit Liquidated(_pmAddress, _trader);
    }

    /**
     * @notice add margin to decrease margin ratio
     * @param _positionManager IPositionManager address
     * @param _amount amount of margin to add
     */
    function addMargin(IPositionManager _positionManager, uint256 _amount)
        external
        whenNotPaused
        nonReentrant
    {
        address _trader = _msgSender();
        address _pmAddress = address(_positionManager);
        require(
            getPosition(_pmAddress, _trader).quantity != 0,
            Errors.VL_NO_POSITION_TO_ADD
        );
        manualMargin[_pmAddress][_trader] += int256(
            _amount
        );

        deposit(_positionManager, _trader, _amount, 0);

        emit MarginAdded(_trader, _amount, _positionManager);
    }

    function getAddedMargin(IPositionManager _positionManager, address _trader)
        external
        view
        returns (int256)
    {
        return manualMargin[address(_positionManager)][_trader];
    }

    /**
     * @notice add margin to increase margin ratio
     * @param _positionManager IPositionManager address
     * @param _amount amount of margin to remove
     */
    function removeMargin(IPositionManager _positionManager, uint256 _amount)
        external
        whenNotPaused
        nonReentrant
    {
        address _trader = _msgSender();

        uint256 removableMargin = getRemovableMargin(_positionManager, _trader);
        require(_amount <= removableMargin, Errors.VL_INVALID_REMOVE_MARGIN);

        manualMargin[address(_positionManager)][_trader] -= int256(_amount);

        withdraw(_positionManager, _trader, _amount);

        emit MarginRemoved(_trader, _amount, _positionManager);
    }

    function getRemovableMargin(
        IPositionManager _positionManager,
        address _trader
    ) public view returns (uint256) {
        int256 _marginAdded = manualMargin[address(_positionManager)][_trader];
        (
            uint256 maintenanceMargin,
            int256 marginBalance,

        ) = getMaintenanceDetail(_positionManager, _trader);
        int256 _remainingMargin = marginBalance - int256(maintenanceMargin);
        return
            uint256(
                _marginAdded <= _remainingMargin
                    ? _marginAdded
                    : _remainingMargin.kPositive()
            );
    }

    function clearPosition(address _pmAddress, address _trader)
        internal
    {
        positionMap[_pmAddress][_trader].clear();
        debtPosition[_pmAddress][_trader].clearDebt();
        manualMargin[_pmAddress][_trader] = 0;
        canClaimAmountMap[_pmAddress][_trader] = 0;
        (
            PositionLimitOrder.Data[] memory subListLimitOrders,
            PositionLimitOrder.Data[] memory subReduceLimitOrders
        ) = PositionHouseFunction.clearAllFilledOrder(
                IPositionManager(_pmAddress),
                limitOrders[_pmAddress][_trader],
                reduceLimitOrders[_pmAddress][_trader]
            );
        if (limitOrders[_pmAddress][_trader].length > 0) {
            delete limitOrders[_pmAddress][_trader];
        }
        for (uint256 i = 0; i < subListLimitOrders.length; i++) {
            if (subListLimitOrders[i].pip == 0) {
                break;
            }
            limitOrders[_pmAddress][_trader].push(
                subListLimitOrders[i]
            );
        }
        if (reduceLimitOrders[_pmAddress][_trader].length > 0) {
            delete reduceLimitOrders[_pmAddress][_trader];
        }
        for (uint256 i = 0; i < subReduceLimitOrders.length; i++) {
            if (subReduceLimitOrders[i].pip == 0) {
                break;
            }
            reduceLimitOrders[_pmAddress][_trader].push(
                subReduceLimitOrders[i]
            );
        }
    }

    function openReversePosition(
        IPositionManager _positionManager,
        Position.Side _side,
        int256 _quantity,
        uint256 _leverage,
        address _trader,
        Position.Data memory _oldPosition
    ) internal returns (PositionResp memory positionResp) {
        address _pmAddress = address(_positionManager);
        if (_quantity.abs() < _oldPosition.quantity.abs()) {
            {
                positionResp = PositionHouseFunction.openReversePosition(
                    _pmAddress,
                    _side,
                    _quantity,
                    _leverage,
                    _trader,
                    _oldPosition,
                    positionMap[_pmAddress][_trader],
                    cumulativePremiumFractions[_pmAddress]
                );
                return positionResp;
            }
        }
        // if new position is larger then close old and open new
        return
            closeAndOpenReversePosition(
                _positionManager,
                _side,
                _quantity,
                _leverage,
                _oldPosition
            );
    }

    function closeAndOpenReversePosition(
        IPositionManager _positionManager,
        Position.Side _side,
        int256 _quantity,
        uint256 _leverage,
        Position.Data memory _oldPosition
    ) internal returns (PositionResp memory positionResp) {
        address _trader = _msgSender();
        address _pmAddress = address(_positionManager);
        PositionResp memory closePositionResp = internalClosePosition(
            _positionManager,
            _trader,
            PnlCalcOption.SPOT_PRICE,
            false,
            _oldPosition
        );
        if (_quantity - closePositionResp.exchangedPositionSize == 0) {
            positionResp = closePositionResp;
        } else {
            _oldPosition = getPosition(_pmAddress, _trader);
            PositionResp memory increasePositionResp = PositionHouseFunction
                .increasePosition(
                    address(_positionManager),
                    _side,
                    _quantity - closePositionResp.exchangedPositionSize,
                    _leverage,
                    _trader,
                    _oldPosition,
                    positionMap[_pmAddress][_trader],
                    cumulativePremiumFractions[_pmAddress]
                );
            positionResp = PositionResp({
                position: increasePositionResp.position,
                exchangedQuoteAssetAmount: closePositionResp
                    .exchangedQuoteAssetAmount +
                    increasePositionResp.exchangedQuoteAssetAmount,
                fundingPayment: 0,
                exchangedPositionSize: closePositionResp.exchangedPositionSize +
                    increasePositionResp.exchangedPositionSize,
                realizedPnl: closePositionResp.realizedPnl +
                    increasePositionResp.realizedPnl,
                unrealizedPnl: 0,
                marginToVault: closePositionResp.marginToVault +
                    increasePositionResp.marginToVault
            });
        }
        return positionResp;
    }

    function internalClosePosition(
        IPositionManager _positionManager,
        address _trader,
        PnlCalcOption _pnlCalcOption,
        bool _isInOpenLimit,
        Position.Data memory _oldPosition
    ) internal returns (PositionResp memory positionResp) {
        address _pmAddress = address(_positionManager);
        (, int256 unrealizedPnl) = getPositionNotionalAndUnrealizedPnl(
            _positionManager,
            _trader,
            _pnlCalcOption,
            _oldPosition
        );
        uint256 openMarketQuantity = _oldPosition.quantity.abs();
        require(
            openMarketQuantity != 0,
            Errors.VL_INVALID_QUANTITY_INTERNAL_CLOSE
        );
        if (_isInOpenLimit) {
            uint256 liquidityInCurrentPip = uint256(
                _positionManager.getLiquidityInCurrentPip()
            );
            openMarketQuantity = liquidityInCurrentPip >
                _oldPosition.quantity.abs()
                ? _oldPosition.quantity.abs()
                : liquidityInCurrentPip;
        }

        (
            positionResp.exchangedPositionSize,
            positionResp.exchangedQuoteAssetAmount
        ) = PositionHouseFunction.openMarketOrder(
            _pmAddress,
            openMarketQuantity,
            _oldPosition.quantity > 0 ? Position.Side.SHORT : Position.Side.LONG,
            _trader
        );

        (
            uint256 remainMargin,
            uint256 badDebt,
            int256 fundingPayment,
        ) = calcRemainMarginWithFundingPayment(
                _positionManager,
                _oldPosition,
                _oldPosition.margin
            );

        positionResp.realizedPnl = unrealizedPnl;
        positionResp.marginToVault = -int256(remainMargin)
            .add(positionResp.realizedPnl)
            .add(manualMargin[_pmAddress][_trader])
            .kPositive();
        positionResp.unrealizedPnl = 0;
        canClaimAmountMap[_pmAddress][_trader] = 0;
        clearPosition(_pmAddress, _trader);
    }

    function getListOrderPending(
        IPositionManager _positionManager,
        address _trader
    ) public view returns (LimitOrderPending[] memory) {
        address _pmAddress = address(_positionManager);
        return
            PositionHouseFunction.getListOrderPending(
                _pmAddress,
                _trader,
                limitOrders[_pmAddress][_trader],
                reduceLimitOrders[_pmAddress][_trader]
            );
    }

    function getPosition(address _pmAddress, address _trader)
        public
        view
        returns (Position.Data memory positionData)
    {
        positionData = positionMap[_pmAddress][_trader];
        PositionLimitOrder.Data[] memory _limitOrders = limitOrders[
            _pmAddress
        ][_trader];
        PositionLimitOrder.Data[] memory _reduceOrders = reduceLimitOrders[
            _pmAddress
        ][_trader];
        positionData = PositionHouseFunction.calculateLimitOrder(
            _pmAddress,
            _limitOrders,
            _reduceOrders,
            positionData
        );
        positionData.margin += uint256(manualMargin[_pmAddress][_trader]);
        Position.LiquidatedData memory _debtPosition = debtPosition[
            _pmAddress
        ][_trader];
        if (_debtPosition.margin != 0) {
            positionData.quantity -= _debtPosition.quantity;
            positionData.margin -= _debtPosition.margin;
            positionData.openNotional -= _debtPosition.notional;
        }
    }

    function getPositionNotionalAndUnrealizedPnl(
        IPositionManager _positionManager,
        address _trader,
        PnlCalcOption _pnlCalcOption,
        Position.Data memory _oldPosition
    ) public view returns (uint256 positionNotional, int256 unrealizedPnl) {
        (positionNotional, unrealizedPnl) = PositionHouseFunction
            .getPositionNotionalAndUnrealizedPnl(
                address(_positionManager),
                _trader,
                _pnlCalcOption,
                _oldPosition
            );
    }

    //    function getLiquidationPrice(
    //        IPositionManager positionManager,
    //        address _trader,
    //        PnlCalcOption _pnlCalcOption
    //    ) public view returns (uint256 liquidationPrice){
    //        Position.Data memory positionData = getPosition(address(positionManager), _trader);
    //        (uint256 maintenanceMargin,,) = getMaintenanceDetail(positionManager, _trader);
    //        if (positionData.side() == Position.Side.LONG) {
    //            liquidationPrice = (maintenanceMargin - positionData.margin + positionData.openNotional) / positionData.quantity.abs();
    //        } else {
    //            liquidationPrice = (positionData.openNotional - maintenanceMargin + positionData.margin) / positionData.quantity.abs();
    //        }
    //    }

    function getMaintenanceDetail(
        IPositionManager _positionManager,
        address _trader
    )
        public
        view
        returns (
            uint256 maintenanceMargin,
            int256 marginBalance,
            uint256 marginRatio
        )
    {
        address _pmAddress = address(_positionManager);
        Position.Data memory positionData = getPosition(
            _pmAddress,
            _trader
        );
        (, int256 unrealizedPnl) = getPositionNotionalAndUnrealizedPnl(
            _positionManager,
            _trader,
            PnlCalcOption.SPOT_PRICE,
            positionData
        );
        (
            uint256 remainMarginWithFundingPayment,
            ,
            ,

        ) = calcRemainMarginWithFundingPayment(
                _positionManager,
                positionData,
                positionData.margin
            );
        maintenanceMargin =
            ((remainMarginWithFundingPayment -
                uint256(manualMargin[_pmAddress][_trader])) *
                maintenanceMarginRatio) /
            100;
        marginBalance = int256(remainMarginWithFundingPayment) + unrealizedPnl;
        marginRatio = marginBalance <= 0
            ? 100
            : (maintenanceMargin * 100) / uint256(marginBalance);
    }

    function getLatestCumulativePremiumFraction(
        IPositionManager _positionManager
    ) public view returns (int256) {
        uint256 len = cumulativePremiumFractions[address(_positionManager)]
            .length;
        if (len > 0) {
            return
                cumulativePremiumFractions[address(_positionManager)][len - 1];
        }
        return 0;
    }

    function payFunding(IPositionManager _positionManager) external onlyOwner {
        int256 premiumFraction = _positionManager.settleFunding();
        cumulativePremiumFractions[address(_positionManager)].push(
            premiumFraction +
                getLatestCumulativePremiumFraction(_positionManager)
        );
    }

    function withdraw(
        IPositionManager _positionManager,
        address _trader,
        uint256 _amount
    ) internal onlyWhitelistManager(address(_positionManager)) {
        insuranceFund.withdraw(
            address(_positionManager.getQuoteAsset()),
            _trader,
            _amount
        );
    }

    function deposit(
        IPositionManager _positionManager,
        address _trader,
        uint256 _amount,
        uint256 _fee
    ) internal onlyWhitelistManager(address(_positionManager)) {
        insuranceFund.deposit(
            address(_positionManager.getQuoteAsset()),
            _trader,
            _amount + _fee
        );
        insuranceFund.updateTotalFee(_fee);
    }

    //
    // INTERNAL FUNCTION OF POSITION HOUSE
    //

    function calcRemainMarginWithFundingPayment(
        IPositionManager _positionManager,
        Position.Data memory _oldPosition,
        uint256 _pMargin
    )
        internal
        view
        returns (
            uint256 remainMargin,
            uint256 badDebt,
            int256 fundingPayment,
            int256 latestCumulativePremiumFraction
        )
    {
        // calculate fundingPayment
        latestCumulativePremiumFraction = getLatestCumulativePremiumFraction(
            _positionManager
        );
        if (_oldPosition.quantity != 0) {
            fundingPayment =
                (latestCumulativePremiumFraction -
                    _oldPosition.lastUpdatedCumulativePremiumFraction) *
                _oldPosition.quantity;
        }

        // calculate remain margin, if remain margin is negative, set to zero and leave the rest to bad debt
        if (int256(_pMargin) + fundingPayment >= 0) {
            remainMargin = uint256(int256(_pMargin) + fundingPayment);
        } else {
            badDebt = uint256(-fundingPayment - int256(_pMargin));
        }
    }

    function partialLiquidate(
        IPositionManager _positionManager,
        Position.Side _side,
        int256 _quantity,
        Position.Data memory _oldPosition,
        address _trader
    ) internal returns (PositionResp memory positionResp) {
        address _pmAddress = address(_positionManager);
        (positionResp.exchangedPositionSize, ) = PositionHouseFunction
            .openMarketOrder(
                _pmAddress,
                _quantity.abs(),
                _side,
                _trader
            );
        positionResp.exchangedQuoteAssetAmount = _quantity
            .getExchangedQuoteAssetAmount(
                _oldPosition.openNotional,
                _oldPosition.quantity.abs()
            );
        (, int256 unrealizedPnl) = getPositionNotionalAndUnrealizedPnl(
            _positionManager,
            _trader,
            PnlCalcOption.SPOT_PRICE,
            _oldPosition
        );
        // TODO need to calculate remain margin with funding payment
        uint256 remainMargin = (_oldPosition.margin *
            (100 - liquidationFeeRatio)) / 100;
        // unchecked
        positionResp.marginToVault =
            int256(_oldPosition.margin) -
            int256(remainMargin);
        positionResp.unrealizedPnl = unrealizedPnl;
        debtPosition[_pmAddress][_trader].updateDebt(
            -_quantity,
            _oldPosition.margin - remainMargin,
            positionResp.exchangedQuoteAssetAmount
        );
        return positionResp;
    }

    // UPDATE VARIABLE STORAGE

    function updatePartialLiquidationRatio(uint256 _partialLiquidationRatio)
        public
        onlyOwner
    {
        partialLiquidationRatio = _partialLiquidationRatio;
    }

    function updateLiquidationPenaltyRatio(uint256 _liquidationPenaltyRatio)
        public
        onlyOwner
    {
        liquidationPenaltyRatio = _liquidationPenaltyRatio;
    }

    function isWhitelistManager(address _positionManager) public view returns (bool) {
        return whitelistManager[_positionManager];
    }

    function setWhitelistManager(address _positionManager) public onlyOwner {
        whitelistManager[_positionManager] = true;
        emit WhitelistPositionManagerAdded(_positionManager);
    }

    function removeWhitelistManager(address _positionManager) public onlyOwner {
        whitelistManager[_positionManager] = false;
        emit WhitelistPositionManagerRemoved(_positionManager);
    }

    modifier onlyWhitelistManager(address _positionManager) {
        require(isWhitelistManager(_positionManager), Errors.VL_NOT_WHITELIST_MANAGER);
        _;
    }

    function setPauseStatus(bool _isPause) public onlyOwner {
        if(_isPause) {
            _pause();
        }else{
            _unpause();
        }
    }

    // NEW REQUIRE: restriction mode
    // In restriction mode, no one can do multi open/close/liquidate position in the same block.
    // If any underwater position being closed (having a bad debt and make insuranceFund loss),
    // or any liquidation happened,
    // restriction mode is ON in that block and OFF(default) in the next block.
    // This design is to prevent the attacker being benefited from the multiple action in one block
    //    function requireNotRestrictionMode(IAmm _amm) private view {
    //        uint256 currentBlock = _blockNumber();
    //        if (currentBlock == positionManagerMap[address].lastRestrictionBlock) {
    //            // only one action allowed
    //
    //        }
    //    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPositionManager {
    function getCurrentPip() external view returns (uint128);

    function getBaseBasisPoint() external view returns (uint256);

    function getBasisPoint() external view returns (uint256);

    function getCurrentSingleSlot() external view returns (uint128, uint8);

    function getLiquidityInCurrentPip() external view returns (uint128);

    function updatePartialFilledOrder(uint128 pip, uint64 orderId) external;

    function getPendingOrderDetail(uint128 pip, uint64 orderId)
        external
        view
        returns (
            bool isFilled,
            bool isBuy,
            uint256 size,
            uint256 partialFilled
        );

    function needClosePositionBeforeOpeningLimitOrder(
        uint8 _side,
        uint256 _pip,
        uint128 _quantity,
        uint8 _pSide,
        uint256 _pQuantity
    ) external view returns (bool);

    function getNotionalMarginAndFee(
        uint256 _pQuantity,
        uint128 _pip,
        uint256 _leverage
    )
        external
        view
        returns (
            uint256 notional,
            uint256 margin,
            uint256 fee
        );

    function openLimitPosition(
        uint128 pip,
        uint128 size,
        bool isBuy
    )
        external
        returns (
            uint64 orderId,
            uint256 sizeOut,
            uint256 openNotional
        );

    function openMarketPosition(uint256 size, bool isBuy)
        external
        returns (uint256 sizeOut, uint256 openNotional);

    function getPrice() external view returns (uint256);

    function pipToPrice(uint128 pip) external view returns (uint256);

    function getQuoteAsset() external view returns (IERC20);

    function calcAdjustMargin(uint256 adjustMargin)
        external
        view
        returns (uint256);

    function calcFee(uint256 _positionNotional) external view returns (uint256);

    function cancelLimitOrder(uint128 pip, uint64 orderId)
        external
        returns (uint256 refundSize, uint256 partialFilled);

    function settleFunding() external returns (int256 premiumFraction);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../helpers/Quantity.sol";
import "hardhat/console.sol";
import "../../../interfaces/IPositionManager.sol";

library Position {
    using Quantity for int256;
    enum Side {
        LONG,
        SHORT
    }
    struct Data {
        // TODO restruct data
        int256 quantity;
        uint256 margin;
        uint256 openNotional;
        int256 lastUpdatedCumulativePremiumFraction;
        uint256 blockNumber;
        uint256 leverage;
    }

    struct LiquidatedData {
        int256 quantity;
        uint256 margin;
        uint256 notional;
    }

    function updateDebt(
        Position.LiquidatedData storage _self,
        int256 _quantity,
        uint256 _margin,
        uint256 _notional
    ) internal {
        _self.quantity += _quantity;
        _self.margin += _margin;
        _self.notional += _notional;
    }

    function update(
        Position.Data storage _self,
        Position.Data memory _newPosition
    ) internal {
        _self.quantity = _newPosition.quantity;
        _self.margin = _newPosition.margin;
        _self.openNotional = _newPosition.openNotional;
        _self.lastUpdatedCumulativePremiumFraction = _newPosition
            .lastUpdatedCumulativePremiumFraction;
        _self.blockNumber = _newPosition.blockNumber;
        _self.leverage = _newPosition.leverage;
    }

    function updateMargin(Position.Data storage _self, uint256 _newMargin)
        internal
    {
        _self.margin = _newMargin;
    }

    function updatePartialLiquidate(
        Position.Data storage _self,
        Position.Data memory _newPosition
    ) internal {
        _self.quantity += _newPosition.quantity;
        _self.margin -= _newPosition.margin;
        _self.openNotional -= _newPosition.openNotional;
        _self.lastUpdatedCumulativePremiumFraction += _newPosition
            .lastUpdatedCumulativePremiumFraction;
        _self.blockNumber += _newPosition.blockNumber;
        _self.leverage = _self.leverage;
    }

    function clearDebt(Position.LiquidatedData storage _self) internal {
        _self.quantity = 0;
        _self.margin = 0;
        _self.notional = 0;
    }

    function clear(Position.Data storage _self) internal {
        _self.quantity = 0;
        _self.margin = 0;
        _self.openNotional = 0;
        _self.lastUpdatedCumulativePremiumFraction = 0;
        _self.blockNumber = block.number;
        _self.leverage = 0;
    }

    function side(Position.Data memory _self)
        internal
        view
        returns (Position.Side)
    {
        return _self.quantity > 0 ? Position.Side.LONG : Position.Side.SHORT;
    }

    function getEntryPrice(
        Position.Data memory _self,
        address _addressPositionManager
    ) internal view returns (uint256) {
        IPositionManager _positionManager = IPositionManager(
            _addressPositionManager
        );
        return
            (_self.openNotional * _positionManager.getBaseBasisPoint()) /
            _self.quantity.abs();
    }

    function accumulateLimitOrder(
        Position.Data memory _self,
        int256 _quantity,
        uint256 _orderMargin,
        uint256 _orderNotional
    ) internal view returns (Position.Data memory positionData) {
        // same side
        if (_self.quantity * _quantity > 0) {
            positionData.margin = _self.margin + _orderMargin;
            positionData.openNotional = _self.openNotional + _orderNotional;
        } else {
            positionData.margin = _self.margin > _orderMargin
                ? _self.margin - _orderMargin
                : _orderMargin - _self.margin;
            positionData.openNotional = _self.openNotional > _orderNotional
                ? _self.openNotional - _orderNotional
                : _orderNotional - _self.openNotional;
        }
        positionData.quantity = _self.quantity + _quantity;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./libraries/position/TickPosition.sol";
import "./libraries/position/LimitOrder.sol";
import "./libraries/position/LiquidityBitmap.sol";
import "./libraries/types/PositionManagerStorage.sol";
import {IChainLinkPriceFeed} from "../interfaces/IChainLinkPriceFeed.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {Errors} from "./libraries/helpers/Errors.sol";

import "hardhat/console.sol";

contract PositionManager is
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    OwnableUpgradeable,
    PositionManagerStorage
{
    using TickPosition for TickPosition.Data;
    using LiquidityBitmap for mapping(uint128 => uint256);

    // Events that supports building order book
    event MarketFilled(
        bool isBuy,
        uint256 indexed amount,
        uint128 toPip,
        uint256 passedPipCount,
        uint128 remainingLiquidity
    );
    event LimitOrderCreated(
        uint64 orderId,
        uint128 pip,
        uint128 size,
        bool isBuy
    );
    event LimitOrderCancelled(
        uint64 orderId,
        uint128 pip,
        uint256 remainingSize
    );

    event UpdateMaxFindingWordsIndex(uint128 newMaxFindingWordsIndex);
    event UpdateBasisPoint(uint256 newBasicPoint);
    event UpdateBaseBasicPoint(uint256 newBaseBasisPoint);
    event UpdateTollRatio(uint256 newTollRatio);
    event UpdateSpotPriceTwapInterval(uint256 newSpotPriceTwapInterval);
    event ReserveSnapshotted(uint128 pip, uint256 timestamp);
    event FundingRateUpdated(int256 fundingRate, uint256 underlyingPrice);
    event LimitOrderUpdated(uint64 orderId, uint128 pip, uint256 size);

    modifier onlyCounterParty() {
        require(counterParty == _msgSender(), Errors.VL_NOT_COUNTERPARTY);
        _;
    }

    function initialize(
        uint128 _initialPip,
        address _quoteAsset,
        bytes32 _priceFeedKey,
        uint256 _basisPoint,
        uint256 _BASE_BASIC_POINT,
        uint256 _tollRatio,
        uint128 _maxFindingWordsIndex,
        uint256 _fundingPeriod,
        address _priceFeed,
        address _counterParty
    ) public initializer {
        require(
            _fundingPeriod != 0 &&
                _quoteAsset != address(0) &&
                _priceFeed != address(0) &&
                _counterParty != address(0),
            Errors.VL_INVALID_INPUT
        );

        __ReentrancyGuard_init();
        __Ownable_init();
        __Pausable_init();

        priceFeedKey = _priceFeedKey;
        singleSlot.pip = _initialPip;
        reserveSnapshots.push(
            ReserveSnapshot(_initialPip, block.timestamp, block.number)
        );
        quoteAsset = IERC20(_quoteAsset);
        basisPoint = _basisPoint;
        BASE_BASIC_POINT = _BASE_BASIC_POINT;
        tollRatio = _tollRatio;
        spotPriceTwapInterval = 1 hours;
        fundingPeriod = _fundingPeriod;
        fundingBufferPeriod = _fundingPeriod / 2;
        maxFindingWordsIndex = _maxFindingWordsIndex;
        priceFeed = IChainLinkPriceFeed(_priceFeed);
        counterParty = _counterParty;
        emit ReserveSnapshotted(_initialPip, block.timestamp);
    }

    function updatePartialFilledOrder(uint128 _pip, uint64 _orderId)
        public
        whenNotPaused
        onlyCounterParty
    {
        uint256 newSize = tickPosition[_pip].updateOrderWhenClose(_orderId);
        emit LimitOrderUpdated(_orderId, _pip, newSize);
    }

    function cancelLimitOrder(uint128 _pip, uint64 _orderId)
        external
        whenNotPaused
        onlyCounterParty
        returns (uint256 remainingSize, uint256 partialFilled)
    {
        require(
            hasLiquidity(_pip) && _orderId >= tickPosition[_pip].filledIndex,
            Errors.VL_ONLY_PENDING_ORDER
        );
        (remainingSize, partialFilled) = tickPosition[_pip].cancelLimitOrder(
            _orderId
        );
        if (tickPosition[_pip].liquidity == 0) {
            liquidityBitmap.toggleSingleBit(_pip, false);
            singleSlot.isFullBuy = 0;
        }
        emit LimitOrderCancelled(_orderId, _pip, remainingSize);
    }

    function openLimitPosition(
        uint128 _pip,
        uint128 _size,
        bool _isBuy
    )
        external
        whenNotPaused
        onlyCounterParty
        returns (
            uint64 orderId,
            uint256 sizeOut,
            uint256 openNotional
        )
    {
        if (_isBuy && singleSlot.pip != 0) {
            require(
                _pip <= singleSlot.pip &&
                    int128(_pip) >=
                    (int128(singleSlot.pip) -
                        int128(maxFindingWordsIndex * 250)),
                Errors.VL_LONG_PRICE_THAN_CURRENT_PRICE
            );
        } else {
            require(
                _pip >= singleSlot.pip &&
                    _pip <= (singleSlot.pip + maxFindingWordsIndex * 250),
                Errors.VL_SHORT_PRICE_LESS_CURRENT_PRICE
            );
        }
        SingleSlot memory _singleSlot = singleSlot;
        bool hasLiquidity = liquidityBitmap.hasLiquidity(_pip);
        //save gas
        if (
            _pip == _singleSlot.pip &&
            hasLiquidity &&
            _singleSlot.isFullBuy != (_isBuy ? 1 : 2)
        ) {
            // open market
            (sizeOut, openNotional) = openMarketPositionWithMaxPip(
                _size,
                _isBuy,
                _pip
            );
            hasLiquidity = liquidityBitmap.hasLiquidity(_pip);
        }
        uint128 remainingSize = _size - uint128(sizeOut);
        if (_size > sizeOut) {
            if (
                _pip == _singleSlot.pip &&
                _singleSlot.isFullBuy != (_isBuy ? 1 : 2)
            ) {
                singleSlot.isFullBuy = _isBuy ? 1 : 2;
            }
            // save at that pip has how many liquidity
            orderId = tickPosition[_pip].insertLimitOrder(
                remainingSize,
                hasLiquidity,
                _isBuy
            );
            if (!hasLiquidity) {
                // set the bit to mark it has liquidity
                liquidityBitmap.toggleSingleBit(_pip, true);
            }
        }
        emit LimitOrderCreated(orderId, _pip, remainingSize, _isBuy);
    }

    function openMarketPositionWithMaxPip(
        uint256 _size,
        bool _isBuy,
        uint128 _maxPip
    )
        public
        whenNotPaused
        onlyCounterParty
        returns (uint256 sizeOut, uint256 openNotional)
    {
        return _internalOpenMarketOrder(_size, _isBuy, _maxPip);
    }

    function openMarketPosition(uint256 _size, bool _isBuy)
        external
        whenNotPaused
        onlyCounterParty
        returns (uint256 sizeOut, uint256 openNotional)
    {
        return _internalOpenMarketOrder(_size, _isBuy, 0);
    }

    /**
     * @notice update funding rate
     * @dev only allow to update while reaching `nextFundingTime`
     * @return premiumFraction of this period in 18 digits
     */
    function settleFunding()
        external
        whenNotPaused
        onlyCounterParty
        returns (int256 premiumFraction)
    {
        require(
            block.timestamp >= nextFundingTime,
            Errors.VL_SETTLE_FUNDING_TOO_EARLY
        );

        // premium = twapMarketPrice - twapIndexPrice
        // timeFraction = fundingPeriod(1 hour) / 1 day
        // premiumFraction = premium * timeFraction
        uint256 underlyingPrice = getUnderlyingTwapPrice(spotPriceTwapInterval);
        int256 premium = int256(getTwapPrice(spotPriceTwapInterval)) -
            int256(underlyingPrice);
        premiumFraction = (premium * int256(fundingPeriod)) / int256(1 days);

        // update funding rate = premiumFraction / twapIndexPrice
        _updateFundingRate(premiumFraction, underlyingPrice);

        // in order to prevent multiple funding settlement during very short time after network congestion
        uint256 minNextValidFundingTime = block.timestamp + fundingBufferPeriod;

        // floor((nextFundingTime + fundingPeriod) / 3600) * 3600
        uint256 nextFundingTimeOnHourStart = ((nextFundingTime +
            fundingPeriod) / (1 hours)) * (1 hours);

        // max(nextFundingTimeOnHourStart, minNextValidFundingTime)
        nextFundingTime = nextFundingTimeOnHourStart > minNextValidFundingTime
            ? nextFundingTimeOnHourStart
            : minNextValidFundingTime;

        return premiumFraction;
    }

    //******************************************************************************************************************
    // VIEW FUNCTIONS
    //******************************************************************************************************************

    function getBaseBasisPoint() public view returns (uint256) {
        return BASE_BASIC_POINT;
    }

    function getBasisPoint() public view returns (uint256) {
        return basisPoint;
    }

    function getCurrentPip() public view returns (uint128) {
        return singleSlot.pip;
    }

    function getCurrentSingleSlot() public view returns (uint128, uint8) {
        return (singleSlot.pip, singleSlot.isFullBuy);
    }

    function getPrice() public view returns (uint256) {
        return (uint256(singleSlot.pip) * BASE_BASIC_POINT) / basisPoint;
    }

    function pipToPrice(uint128 _pip) public view returns (uint256) {
        return (uint256(_pip) * BASE_BASIC_POINT) / basisPoint;
    }

    function getLiquidityInCurrentPip() public view returns (uint128) {
        return
            liquidityBitmap.hasLiquidity(singleSlot.pip)
                ? tickPosition[singleSlot.pip].liquidity
                : 0;
    }

    function calcAdjustMargin(uint256 _adjustMargin)
        public
        view
        returns (uint256)
    {
        return _adjustMargin;
    }

    function hasLiquidity(uint128 _pip) public view returns (bool) {
        return liquidityBitmap.hasLiquidity(_pip);
    }

    function getPendingOrderDetail(uint128 _pip, uint64 _orderId)
        public
        view
        returns (
            bool isFilled,
            bool isBuy,
            uint256 size,
            uint256 partialFilled
        )
    {
        (isFilled, isBuy, size, partialFilled) = tickPosition[_pip]
            .getQueueOrder(_orderId);

        if (!liquidityBitmap.hasLiquidity(_pip)) {
            isFilled = true;
        }
        if (size != 0 && size == partialFilled) {
            isFilled = true;
        }
    }

    function needClosePositionBeforeOpeningLimitOrder(
        uint8 _side,
        uint256 _pip,
        uint128 _quantity,
        uint8 _pSide,
        uint256 _pQuantity
    ) public view returns (bool) {
        //save gas
        SingleSlot memory _singleSlot = singleSlot;
        return
            _pip == _singleSlot.pip &&
            _singleSlot.isFullBuy != _side &&
            _pQuantity <= _quantity &&
            _pQuantity <= getLiquidityInCurrentPip();
    }

    function getNotionalMarginAndFee(
        uint256 _pQuantity,
        uint128 _pip,
        uint256 _leverage
    )
        public
        view
        returns (
            uint256 notional,
            uint256 margin,
            uint256 fee
        )
    {
        notional = (_pQuantity * pipToPrice(_pip)) / getBaseBasisPoint();
        margin = notional / _leverage;
        fee = calcFee(notional);
    }

    /**
     * @notice calculate total fee (including toll and spread) by input quote asset amount
     * @param _positionNotional quote asset amount
     * @return total tx fee
     */
    function calcFee(uint256 _positionNotional) public view returns (uint256) {
        if (tollRatio != 0) {
            return _positionNotional / tollRatio;
        }
        return 0;
    }

    struct LiquidityOfEachPip {
        uint128 pip;
        uint256 liquidity;
    }

    function getLiquidityInPipRange(
        uint128 _fromPip,
        uint256 _dataLength,
        bool _toHigher
    ) public view returns (LiquidityOfEachPip[] memory, uint128) {
        uint128[] memory allInitializedPips = new uint128[](
            uint128(_dataLength)
        );
        allInitializedPips = liquidityBitmap.findAllLiquidityInMultipleWords(
            _fromPip,
            _dataLength,
            _toHigher
        );
        LiquidityOfEachPip[] memory allLiquidity = new LiquidityOfEachPip[](
            _dataLength
        );

        for (uint256 i = 0; i < _dataLength; i++) {
            allLiquidity[i] = LiquidityOfEachPip({
                pip: allInitializedPips[i],
                liquidity: tickPosition[allInitializedPips[i]].liquidity
            });
        }
        return (allLiquidity, allInitializedPips[_dataLength - 1]);
    }

    function getQuoteAsset() public view returns (IERC20) {
        return quoteAsset;
    }

    /**
     * @notice get underlying price provided by oracle
     * @return underlying price
     */
    function getUnderlyingPrice() public view returns (uint256) {
        return priceFeed.getPrice(priceFeedKey) * BASE_BASIC_POINT;
    }

    /**
     * @notice get underlying twap price provided by oracle
     * @return underlying price
     */
    function getUnderlyingTwapPrice(uint256 _intervalInSeconds)
        public
        view
        returns (uint256)
    {
        return
            priceFeed.getTwapPrice(priceFeedKey, _intervalInSeconds) *
            BASE_BASIC_POINT;
    }

    /**
     * @notice get twap price
     */
    function getTwapPrice(uint256 _intervalInSeconds)
        public
        view
        returns (uint256)
    {
        return implGetReserveTwapPrice(_intervalInSeconds);
    }

    function implGetReserveTwapPrice(uint256 _intervalInSeconds)
        public
        view
        returns (uint256)
    {
        TwapPriceCalcParams memory params;
        // Can remove this line
        params.opt = TwapCalcOption.RESERVE_ASSET;
        params.snapshotIndex = reserveSnapshots.length - 1;
        return calcTwap(params, _intervalInSeconds);
    }

    function calcTwap(
        TwapPriceCalcParams memory _params,
        uint256 _intervalInSeconds
    ) public view returns (uint256) {
        uint256 currentPrice = _getPriceWithSpecificSnapshot(_params);
        if (_intervalInSeconds == 0) {
            return currentPrice;
        }

        uint256 baseTimestamp = block.timestamp - _intervalInSeconds;
        ReserveSnapshot memory currentSnapshot = reserveSnapshots[
            _params.snapshotIndex
        ];
        // return the latest snapshot price directly
        // if only one snapshot or the timestamp of latest snapshot is earlier than asking for
        if (
            reserveSnapshots.length == 1 ||
            currentSnapshot.timestamp <= baseTimestamp
        ) {
            return currentPrice;
        }

        uint256 previousTimestamp = currentSnapshot.timestamp;
        // period same as cumulativeTime
        uint256 period = block.timestamp - previousTimestamp;
        uint256 weightedPrice = currentPrice * period;
        while (true) {
            // if snapshot history is too short
            if (_params.snapshotIndex == 0) {
                return weightedPrice / period;
            }

            _params.snapshotIndex = _params.snapshotIndex - 1;
            currentSnapshot = reserveSnapshots[_params.snapshotIndex];
            currentPrice = _getPriceWithSpecificSnapshot(_params);

            // check if current snapshot timestamp is earlier than target timestamp
            if (currentSnapshot.timestamp <= baseTimestamp) {
                // weighted time period will be (target timestamp - previous timestamp). For example,
                // now is 1000, _intervalInSeconds is 100, then target timestamp is 900. If timestamp of current snapshot is 970,
                // and timestamp of NEXT snapshot is 880, then the weighted time period will be (970 - 900) = 70,
                // instead of (970 - 880)
                weightedPrice =
                    weightedPrice +
                    (currentPrice * (previousTimestamp - baseTimestamp));
                break;
            }

            uint256 timeFraction = previousTimestamp -
                currentSnapshot.timestamp;
            weightedPrice = weightedPrice + (currentPrice * timeFraction);
            period = period + timeFraction;
            previousTimestamp = currentSnapshot.timestamp;
        }
        return weightedPrice / _intervalInSeconds;
    }

    //******************************************************************************************************************
    // ONLY OWNER FUNCTIONS
    //******************************************************************************************************************

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function updateMaxFindingWordsIndex(uint128 _newMaxFindingWordsIndex)
        public
        onlyOwner
    {
        maxFindingWordsIndex = _newMaxFindingWordsIndex;
        emit UpdateMaxFindingWordsIndex(_newMaxFindingWordsIndex);
    }

    function updateBasisPoint(uint256 _newBasisPoint) public onlyOwner {
        basisPoint = _newBasisPoint;
        emit UpdateBasisPoint(_newBasisPoint);
    }

    function updateBaseBasicPoint(uint256 _newBaseBasisPoint) public onlyOwner {
        BASE_BASIC_POINT = _newBaseBasisPoint;
        emit UpdateBaseBasicPoint(_newBaseBasisPoint);
    }

    function updateTollRatio(uint256 _newTollRatio) public onlyOwner {
        tollRatio = _newTollRatio;
        emit UpdateTollRatio(_newTollRatio);
    }

    function setCounterParty(address _counterParty) public onlyOwner {
        require(_counterParty != address(0), Errors.VL_EMPTY_ADDRESS);
        counterParty = _counterParty;
    }

    function updateSpotPriceTwapInterval(uint256 _spotPriceTwapInterval)
        public
        onlyOwner
    {
        spotPriceTwapInterval = _spotPriceTwapInterval;
        emit UpdateSpotPriceTwapInterval(_spotPriceTwapInterval);
    }

    //******************************************************************************************************************
    // INTERNAL FUNCTIONS
    //******************************************************************************************************************

    function _msgSender()
        internal
        view
        override(ContextUpgradeable)
        returns (address)
    {
        return msg.sender;
    }

    function _msgData()
        internal
        view
        override(ContextUpgradeable)
        returns (bytes calldata)
    {
        return msg.data;
    }

    function _internalOpenMarketOrder(
        uint256 _size,
        bool _isBuy,
        uint128 _maxPip
    ) internal returns (uint256 sizeOut, uint256 openNotional) {
        require(_size != 0, Errors.VL_INVALID_SIZE);
        // TODO lock
        // get current tick liquidity
        SingleSlot memory _initialSingleSlot = singleSlot;
        //save gas
        SwapState memory state = SwapState({
            remainingSize: _size,
            pip: _initialSingleSlot.pip
        });
        uint128 startPip;
        uint128 remainingLiquidity;
        uint8 isFullBuy = 0;
        bool isSkipFirstPip;
        uint256 passedPipCount = 0;
        CurrentLiquiditySide currentLiquiditySide = CurrentLiquiditySide(
            _initialSingleSlot.isFullBuy
        );
        if (currentLiquiditySide != CurrentLiquiditySide.NotSet) {
            if (_isBuy)
                // if buy and latest liquidity is buy. skip current pip
                isSkipFirstPip =
                    currentLiquiditySide == CurrentLiquiditySide.Buy;
                // if sell and latest liquidity is sell. skip current pip
            else
                isSkipFirstPip =
                    currentLiquiditySide == CurrentLiquiditySide.Sell;
        }
        while (state.remainingSize != 0) {
            StepComputations memory step;
            // updated findHasLiquidityInMultipleWords, save more gas
            (step.pipNext) = liquidityBitmap.findHasLiquidityInMultipleWords(
                state.pip,
                maxFindingWordsIndex,
                !_isBuy
            );
            if (_maxPip != 0 && step.pipNext != _maxPip) break;
            if (step.pipNext == 0) {
                // no more next pip
                // state pip back 1 pip
                if (_isBuy) {
                    state.pip--;
                } else {
                    state.pip++;
                }
                break;
            } else {
                if (!isSkipFirstPip) {
                    if (startPip == 0) startPip = step.pipNext;

                    // get liquidity at a tick index
                    uint128 liquidity = tickPosition[step.pipNext].liquidity;
                    if (liquidity > state.remainingSize) {
                        // pip position will partially filled and stop here
                        tickPosition[step.pipNext].partiallyFill(
                            uint128(state.remainingSize)
                        );
                        openNotional += ((state.remainingSize *
                            pipToPrice(step.pipNext)) / BASE_BASIC_POINT);
                        // remaining liquidity at current pip
                        remainingLiquidity =
                            liquidity -
                            uint128(state.remainingSize);
                        state.remainingSize = 0;
                        state.pip = step.pipNext;
                        isFullBuy = uint8(
                            !_isBuy
                                ? CurrentLiquiditySide.Buy
                                : CurrentLiquiditySide.Sell
                        );
                    } else if (state.remainingSize > liquidity) {
                        // order in that pip will be fulfilled
                        state.remainingSize = state.remainingSize - liquidity;
                        openNotional += ((liquidity *
                            pipToPrice(step.pipNext)) / BASE_BASIC_POINT);
                        state.pip = state.remainingSize > 0
                            ? (_isBuy ? step.pipNext + 1 : step.pipNext - 1)
                            : step.pipNext;
                        passedPipCount++;
                    } else {
                        // remaining size = liquidity
                        // only 1 pip should be toggled, so we call it directly here
                        liquidityBitmap.toggleSingleBit(step.pipNext, false);
                        openNotional += ((state.remainingSize *
                            pipToPrice(step.pipNext)) / BASE_BASIC_POINT);
                        state.remainingSize = 0;
                        state.pip = step.pipNext;
                        isFullBuy = 0;
                    }
                } else {
                    isSkipFirstPip = false;
                    state.pip = _isBuy ? step.pipNext + 1 : step.pipNext - 1;
                }
            }
        }
        if (_initialSingleSlot.pip != state.pip) {
            // all ticks in shifted range must be marked as filled
            if (!(remainingLiquidity > 0 && startPip == state.pip)) {
                liquidityBitmap.unsetBitsRange(
                    startPip,
                    remainingLiquidity > 0
                        ? (_isBuy ? state.pip - 1 : state.pip + 1)
                        : state.pip
                );
            }
            // TODO write a checkpoint that we shift a range of ticks
        }
        singleSlot.pip = _maxPip != 0 ? _maxPip : state.pip;
        passedPipCount = _maxPip != 0 ? 0 : passedPipCount;
        singleSlot.isFullBuy = isFullBuy;
        sizeOut = _size - state.remainingSize;
        _addReserveSnapshot();
        emit MarketFilled(
            _isBuy,
            sizeOut,
            _maxPip != 0 ? _maxPip : state.pip,
            passedPipCount,
            remainingLiquidity
        );
    }

    function _getPriceWithSpecificSnapshot(TwapPriceCalcParams memory _params)
        internal
        view
        virtual
        returns (uint256)
    {
        return pipToPrice(reserveSnapshots[_params.snapshotIndex].pip);
    }

    // update funding rate = premiumFraction / twapIndexPrice
    function _updateFundingRate(
        int256 _premiumFraction,
        uint256 _underlyingPrice
    ) internal {
        fundingRate = _premiumFraction / int256(_underlyingPrice);
        emit FundingRateUpdated(fundingRate, _underlyingPrice);
    }

    function _addReserveSnapshot() internal {
        uint256 currentBlock = block.number;
        ReserveSnapshot memory latestSnapshot = reserveSnapshots[
            reserveSnapshots.length - 1
        ];
        if (currentBlock == latestSnapshot.blockNumber) {
            reserveSnapshots[reserveSnapshots.length - 1].pip = singleSlot.pip;
        } else {
            reserveSnapshots.push(
                ReserveSnapshot(singleSlot.pip, block.timestamp, currentBlock)
            );
        }
        emit ReserveSnapshotted(singleSlot.pip, block.timestamp);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

library Quantity {
    function getExchangedQuoteAssetAmount(
        int256 _quantity,
        uint256 _openNotional,
        uint256 _oldPQuantity
    ) internal pure returns (uint256) {
        return (abs(_quantity) * _openNotional) / _oldPQuantity;
    }

    function getPartiallyLiquidate(
        int256 _quantity,
        uint256 _liquidationPenaltyRatio
    ) internal pure returns (int256) {
        return (_quantity * int256(_liquidationPenaltyRatio)) / 100;
    }

    function isSameSide(int256 qA, int256 qB) internal pure returns (bool) {
        return qA * qB > 0;
    }

    function u8Side(int256 _quantity) internal pure returns (uint8) {
        return _quantity > 0 ? 1 : 2;
    }

    function abs(int256 _quantity) internal pure returns (uint256) {
        return uint256(_quantity >= 0 ? _quantity : -_quantity);
    }

    function abs128(int256 _quantity) internal pure returns (uint128) {
        return uint128(abs(_quantity));
    }

    function sumWithUint256(int256 a, uint256 b)
        internal
        pure
        returns (int256)
    {
        return a >= 0 ? a + int256(b) : a - int256(b);
    }

    function minusWithUint256(int256 a, uint256 b)
        internal
        pure
        returns (int256)
    {
        return a >= 0 ? a - int256(b) : a + int256(b);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./Position.sol";
import "hardhat/console.sol";
import "../../../interfaces/IPositionManager.sol";

library PositionLimitOrder {
    enum OrderType {
        OPEN_LIMIT,
        CLOSE_LIMIT
    }
    struct Data {
        uint128 pip;
        uint64 orderId;
        uint16 leverage;
        //        OrderType typeLimitOrder;
        uint8 isBuy;
        uint256 entryPrice;
        uint256 reduceLimitOrderId;
        uint256 reduceQuantity;
        uint256 blockNumber;
    }

    //    struct ReduceData {
    //        int128 pip;
    //        uint64 orderId;
    //        uint16 leverage;
    ////        OrderType typeLimitOrder;
    //        uint8 isBuy;
    //    }
    //
    //    function clearLimitOrder(
    //        PositionLimitOrder.Data self
    //    ) internal {
    //        self.pip = 0;
    //        self.orderId = 0;
    //        self.leverage = 0;
    //    }

    //    function checkFilledToSelfOrders(
    //        mapping(address => mapping(address => PositionLimitOrder.Data[])) storage limitOrderMap,
    //        IPositionManager _positionManager,
    //        address _trader,
    //        int128 startPip,
    //        int128 endPip,
    //        Position.Side side
    //    ) internal view returns (uint256 selfFilledQuantity) {
    //        uint256 gasBefore = gasleft();
    //        // check if fill to self limit orders
    //        PositionLimitOrder.Data[] memory listLimitOrder = limitOrderMap[address(_positionManager)][_trader];
    //        for(uint256 i; i<listLimitOrder.length; i++){
    //            PositionLimitOrder.Data memory limitOrder = listLimitOrder[i];
    //            if(limitOrder.isBuy == 1 && side == Position.Side.SHORT){
    //                if(endPip <= limitOrder.pip && startPip >= limitOrder.pip){
    //                    (,,uint256 size, uint256 partialFilledSize) = _positionManager.getPendingOrderDetail(limitOrder.pip, limitOrder.orderId);
    //                    selfFilledQuantity += (size > partialFilledSize ? size - partialFilledSize : size);
    //                }
    //            }
    //            if(limitOrder.isBuy == 2 && side == Position.Side.LONG){
    //                if(endPip >= limitOrder.pip){
    //                    (,,uint256 size, uint256 partialFilledSize) = _positionManager.getPendingOrderDetail(limitOrder.pip, limitOrder.orderId);
    //                    selfFilledQuantity += (size > partialFilledSize ? size - partialFilledSize : size);
    //                }
    //            }
    //        }
    //    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IInsuranceFund {
    function deposit(
        address token,
        address trader,
        uint256 amount
    ) external;

    function withdraw(
        address token,
        address trader,
        uint256 amount
    ) external;

    function buyBackAndBurn(address token, uint256 amount) external;

    function transferFeeFromTrader(
        address token,
        address trader,
        uint256 amountFee
    ) external;

    function updateTotalFee(uint256 fee) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import "../position/PositionLimitOrder.sol";
import "../../../interfaces/IInsuranceFund.sol";

contract PositionHouseStorage {
    using PositionLimitOrder for mapping(address => mapping(address => PositionLimitOrder.Data[]));
    using Quantity for int256;
    using Quantity for int128;

    using Position for Position.Data;
    using Position for Position.LiquidatedData;
    type PositionManager is address;

    enum PnlCalcOption {
        TWAP,
        SPOT_PRICE,
        ORACLE
    }

    struct PositionResp {
        Position.Data position;
        int256 marginToVault;
        int256 realizedPnl;
        int256 unrealizedPnl;
        int256 exchangedPositionSize;
        uint256 exchangedQuoteAssetAmount;
        uint256 fundingPayment;
    }

    struct LimitOrderPending {
        bool isBuy;
        uint256 quantity;
        uint256 partialFilled;
        uint128 pip;
        // can change leverage to uint16 to save gas
        uint16 leverage;
        uint8 isReduce;
        uint256 blockNumber;
        uint256 orderIdx;
        uint256 orderId;
    }

    struct OpenLimitResp {
        uint64 orderId;
        uint256 sizeOut;
    }

    //    struct PositionManagerData {
    //        uint24 blockNumber;
    //        int256[] cumulativePremiumFraction;
    //        // Position data of each trader
    //        mapping(address => Position.Data) positionMap;
    //        mapping(address => PositionLimitOrder.Data[]) limitOrders;
    //        mapping(address => PositionLimitOrder.Data[]) reduceLimitOrders;
    //        // Amount that trader can claim from exchange
    //        mapping(address => int256) canClaimAmount;
    //        mapping(address => int256) manualMargin;
    //    }
    //    // TODO change separate mapping to positionManagerMap
    //    mapping(address => PositionManagerData) public positionManagerMap;

    // Can join positionMap and cumulativePremiumFractionsMap into a map of struct with key is PositionManager's address
    // Mapping from position manager address of each pair to position data of each trader
    mapping(address => mapping(address => Position.Data)) public positionMap;
    //    mapping(address => int256[]) public cumulativePremiumFractionsMap;

    mapping(address => mapping(address => Position.LiquidatedData))
        public debtPosition;
    mapping(address => mapping(address => uint256)) public canClaimAmountMap;

    // update added margin type from int256 to uint256
    mapping(address => mapping(address => int256)) public manualMargin;
    //can update with index => no need delete array when close all
    mapping(address => mapping(address => PositionLimitOrder.Data[]))
        public limitOrders;
    mapping(address => mapping(address => PositionLimitOrder.Data[]))
        public reduceLimitOrders;

    // Cumulative premium fraction
    mapping(address => int256[]) public cumulativePremiumFractions;

    // Whitelist for position manager address
    mapping(address => bool) internal whitelistManager;

    uint256 maintenanceMarginRatio;
    uint256 partialLiquidationRatio;
    uint256 liquidationFeeRatio;
    uint256 liquidationPenaltyRatio;

    IInsuranceFund public insuranceFund;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import "./Position.sol";
import "../../../interfaces/IPositionManager.sol";
import "./PositionLimitOrder.sol";
import "../../libraries/helpers/Quantity.sol";
import "../../PositionHouse.sol";
import "../types/PositionHouseStorage.sol";
import {Errors} from "../helpers/Errors.sol";

library PositionHouseFunction {
    using PositionLimitOrder for mapping(address => mapping(address => PositionLimitOrder.Data[]));
    using Position for Position.Data;
    using Position for Position.LiquidatedData;
    using Quantity for int256;
    using Quantity for int128;

    function handleMarketPart(
        Position.Data memory _positionData,
        Position.Data memory _positionDataWithoutLimit,
        uint256 _newNotional,
        int256 _newQuantity,
        uint256 _leverage,
        int256[] memory _cumulativePremiumFractions
    ) public view returns (Position.Data memory newData) {
        if (_newQuantity * _positionData.quantity >= 0) {
            newData = Position.Data(
                _positionDataWithoutLimit.quantity + _newQuantity,
                handleMarginInIncrease(
                    _newNotional / _leverage,
                    _positionData,
                    _positionDataWithoutLimit,
                    _cumulativePremiumFractions
                ),
                handleNotionalInIncrease(
                    _newNotional,
                    _positionData,
                    _positionDataWithoutLimit
                ),
                // TODO update latest cumulative premium fraction
                0,
                block.number,
                _leverage
            );
        } else {
            newData = Position.Data(
                _positionDataWithoutLimit.quantity + _newQuantity,
                handleMarginInOpenReverse(
                    (_positionData.margin * _newQuantity.abs()) /
                        _positionData.quantity.abs(),
                    _positionData,
                    _positionDataWithoutLimit,
                    _cumulativePremiumFractions
                ),
                handleNotionalInOpenReverse(
                    _newNotional,
                    _positionData,
                    _positionDataWithoutLimit
                ),
                // TODO update latest cumulative premium fraction
                0,
                block.number,
                _leverage
            );
        }
    }

    // There are 4 cases could happen:
    //      1. oldPosition created by limitOrder, new marketOrder reversed it => ON = positionResp.exchangedQuoteAssetAmount
    //      2. oldPosition created by marketOrder, new marketOrder reversed it => ON = oldPosition.openNotional - positionResp.exchangedQuoteAssetAmount
    //      3. oldPosition created by both marketOrder and limitOrder, new marketOrder reversed it => ON = oldPosition.openNotional (of _positionDataWithoutLimit only) - positionResp.exchangedQuoteAssetAmount
    //      4. oldPosition increased by limitOrder and reversed by marketOrder, new MarketOrder reversed it => ON = oldPosition.openNotional (of _positionDataWithoutLimit only) + positionResp.exchangedQuoteAssetAmount
    function handleNotionalInOpenReverse(
        uint256 _exchangedQuoteAmount,
        Position.Data memory _positionData,
        Position.Data memory _positionDataWithoutLimit
    ) public view returns (uint256 openNotional) {
        if (_positionDataWithoutLimit.quantity * _positionData.quantity < 0) {
            openNotional =
                _positionDataWithoutLimit.openNotional +
                _exchangedQuoteAmount;
        } else {
            if (_positionDataWithoutLimit.openNotional > _exchangedQuoteAmount) {
                openNotional =
                    _positionDataWithoutLimit.openNotional -
                    _exchangedQuoteAmount;
            } else {
                openNotional =
                    _exchangedQuoteAmount -
                    _positionDataWithoutLimit.openNotional;
            }
        }
    }

    // There are 5 cases could happen:
    //      1. Old position created by long limit and short market, reverse position is short => margin = oldMarketMargin + reduceMarginRequirement
    //      2. Old position created by long limit and long market, reverse position is short and < old long market => margin = oldMarketMargin - reduceMarginRequirement
    //      3. Old position created by long limit and long market, reverse position is short and > old long market => margin = reduceMarginRequirement - oldMarketMargin
    //      4. Old position created by long limit and no market, reverse position is short => margin = reduceMarginRequirement - oldMarketMargin
    //      5. Old position created by short limit and long market, reverse position is short => margin = oldMarketMargin - reduceMarginRequirement
    function handleMarginInOpenReverse(
        uint256 _reduceMarginRequirement,
        Position.Data memory _positionData,
        Position.Data memory _positionDataWithoutLimit,
        int256[] memory _cumulativePremiumFractions
    ) public view returns (uint256 margin) {
        int256 newPositionSide = _positionData.quantity < 0
            ? int256(1)
            : int256(-1);
        if (_positionDataWithoutLimit.quantity * _positionData.quantity < 0) {
            margin = _positionDataWithoutLimit.margin + _reduceMarginRequirement;
        } else {
            if (_positionDataWithoutLimit.margin > _reduceMarginRequirement) {
                margin = _positionDataWithoutLimit.margin - _reduceMarginRequirement;
            } else {
                margin = _reduceMarginRequirement - _positionDataWithoutLimit.margin;
            }
        }
        margin = calcRemainMarginWithFundingPayment(
            _positionData,
            margin,
            _cumulativePremiumFractions
        );
    }

    // There are 5 cases could happen:
    //      1. Old position created by long limit and long market, increase position is long => notional = oldNotional + exchangedQuoteAssetAmount
    //      2. Old position created by long limit and short market, increase position is long and < old short market => notional = oldNotional - exchangedQuoteAssetAmount
    //      3. Old position created by long limit and short market, increase position is long and > old short market => notional = exchangedQuoteAssetAmount - oldNotional
    //      4. Old position created by long limit and no market, increase position is long => notional = oldNotional + exchangedQuoteAssetAmount
    //      5. Old position created by short limit and long market, increase position is long => notional = oldNotional + exchangedQuoteAssetAmount
    function handleNotionalInIncrease(
        uint256 _exchangedQuoteAmount,
        Position.Data memory _positionData,
        Position.Data memory _positionDataWithoutLimit
    ) public view returns (uint256 openNotional) {
        if (_positionDataWithoutLimit.quantity * _positionData.quantity < 0) {
            if (_positionDataWithoutLimit.openNotional > _exchangedQuoteAmount) {
                openNotional =
                    _positionDataWithoutLimit.openNotional -
                    _exchangedQuoteAmount;
            } else {
                openNotional =
                    _exchangedQuoteAmount -
                    _positionDataWithoutLimit.openNotional;
            }
        } else {
            openNotional =
                _positionDataWithoutLimit.openNotional +
                _exchangedQuoteAmount;
        }
    }

    // There are 6 cases could happen:
    //      1. Old position created by long limit and long market, increase position is long market => margin = oldMarketMargin + increaseMarginRequirement
    //      2. Old position created by long limit and short market, increase position is long market and < old short market => margin = oldMarketMargin - increaseMarginRequirement
    //      3. Old position created by long limit and short market, increase position is long market and > old short market => margin = increaseMarginRequirement - oldMarketMargin
    //      4. Old position created by long limit and no market, increase position is long market => margin = increaseMarginRequirement - oldMarketMargin
    //      5. Old position created by short limit and long market, increase position is long market => margin = oldMarketMargin + increaseMarginRequirement
    //      6. Old position created by no limit and long market, increase position is long market => margin = oldMarketMargin + increaseMarginRequirement
    function handleMarginInIncrease(
        uint256 _increaseMarginRequirement,
        Position.Data memory _positionData,
        Position.Data memory _positionDataWithoutLimit,
        int256[] memory _cumulativePremiumFractions
    ) public view returns (uint256 margin) {
        if (_positionDataWithoutLimit.quantity * _positionData.quantity < 0) {
            if (_positionDataWithoutLimit.margin > _increaseMarginRequirement) {
                margin = _positionDataWithoutLimit.margin - _increaseMarginRequirement;
            } else {
                margin = _increaseMarginRequirement - _positionDataWithoutLimit.margin;
            }
        } else {
            margin = _positionDataWithoutLimit.margin + _increaseMarginRequirement;
        }
        margin = calcRemainMarginWithFundingPayment(
            _positionData,
            margin,
            _cumulativePremiumFractions
        );
    }

    function handleQuantity(int256 _oldMarketQuantity, int256 _newQuantity)
        public
        view
        returns (int256 quantity)
    {
        if (_oldMarketQuantity * _newQuantity >= 0) {
            return _oldMarketQuantity + _newQuantity;
        }
        return _oldMarketQuantity - _newQuantity;
    }

    function clearAllFilledOrder(
        IPositionManager _positionManager,
        PositionLimitOrder.Data[] memory _limitOrders,
        PositionLimitOrder.Data[] memory _reduceLimitOrders
    )
        internal
        returns (
            PositionLimitOrder.Data[] memory,
            PositionLimitOrder.Data[] memory
        )
    {
        PositionLimitOrder.Data[]
            memory subLimitOrders = new PositionLimitOrder.Data[](
                _limitOrders.length
            );
        PositionLimitOrder.Data[]
            memory subReduceLimitOrders = new PositionLimitOrder.Data[](
                _reduceLimitOrders.length
            );
        if (_limitOrders.length > 0) {
            uint256 index = 0;
            for (uint256 i = 0; i < _limitOrders.length; i++) {
                (bool isFilled, , , ) = _positionManager.getPendingOrderDetail(
                    _limitOrders[i].pip,
                    _limitOrders[i].orderId
                );
                if (isFilled != true) {
                    subLimitOrders[index] = _limitOrders[i];
                    _positionManager.updatePartialFilledOrder(
                        _limitOrders[i].pip,
                        _limitOrders[i].orderId
                    );
                    index++;
                }
            }
        }
        if (_reduceLimitOrders.length > 0) {
            uint256 index = 0;
            for (uint256 i = 0; i < _reduceLimitOrders.length; i++) {
                (bool isFilled, , , ) = _positionManager.getPendingOrderDetail(
                    _reduceLimitOrders[i].pip,
                    _reduceLimitOrders[i].orderId
                );
                if (isFilled != true) {
                    subReduceLimitOrders[index] = _reduceLimitOrders[i];
                    _positionManager.updatePartialFilledOrder(
                        _reduceLimitOrders[i].pip,
                        _reduceLimitOrders[i].orderId
                    );
                    index++;
                }
            }
        }
        return (subLimitOrders, subReduceLimitOrders);
    }

    function calculateLimitOrder(
        address _positionManager,
        PositionLimitOrder.Data[] memory _limitOrders,
        PositionLimitOrder.Data[] memory _reduceLimitOrders,
        Position.Data memory _positionData
    ) public view returns (Position.Data memory positionData) {
        for (uint256 i = 0; i < _limitOrders.length; i++) {
            if (_limitOrders[i].pip != 0) {
                _positionData = accumulateLimitOrderToPositionData(
                    _positionManager,
                    _limitOrders[i],
                    _positionData,
                    _limitOrders[i].entryPrice,
                    _limitOrders[i].reduceQuantity
                );
            }
        }
        for (uint256 i = 0; i < _reduceLimitOrders.length; i++) {
            if (_reduceLimitOrders[i].pip != 0) {
                _positionData = accumulateLimitOrderToPositionData(
                    _positionManager,
                    _reduceLimitOrders[i],
                    _positionData,
                    _reduceLimitOrders[i].entryPrice,
                    _reduceLimitOrders[i].reduceQuantity
                );
            }
        }
        positionData = _positionData;
    }

    function accumulateLimitOrderToPositionData(
        address _pmAddress,
        PositionLimitOrder.Data memory _limitOrder,
        Position.Data memory _positionData,
        uint256 _entryPrice,
        uint256 _reduceQuantity
    ) public view returns (Position.Data memory) {
        IPositionManager _positionManager = IPositionManager(
            _pmAddress
        );

        (
            bool isFilled,
            bool isBuy,
            uint256 quantity,
            uint256 partialFilled
        ) = _positionManager.getPendingOrderDetail(
                _limitOrder.pip,
                _limitOrder.orderId
            );
        if (isFilled) {
            int256 _orderQuantity;
            if (_reduceQuantity == 0 && _entryPrice == 0) {
                _orderQuantity = isBuy ? int256(quantity) : -int256(quantity);
            } else if (_reduceQuantity != 0 && _entryPrice == 0) {
                _orderQuantity = isBuy
                    ? int256(quantity - _reduceQuantity)
                    : -int256(quantity - _reduceQuantity);
            } else {
                _orderQuantity = isBuy
                    ? int256(_reduceQuantity)
                    : -int256(_reduceQuantity);
            }
            uint256 _orderNotional = _entryPrice == 0
                ? ((_orderQuantity.abs() *
                    _positionManager.pipToPrice(_limitOrder.pip)) /
                    _positionManager.getBaseBasisPoint())
                : ((_orderQuantity.abs() * _entryPrice) /
                    _positionManager.getBaseBasisPoint());
            // IMPORTANT UPDATE FORMULA WITH LEVERAGE
            // TODO RECHECK THIS
            uint256 _orderMargin = _orderNotional / _limitOrder.leverage;
            _positionData = _positionData.accumulateLimitOrder(
                _orderQuantity,
                _orderMargin,
                _orderNotional
            );
        } else if (!isFilled && partialFilled != 0) {
            // partial filled
            int256 _partialQuantity;
            if (_reduceQuantity == 0 && _entryPrice == 0) {
                _partialQuantity = isBuy
                    ? int256(partialFilled)
                    : -int256(partialFilled);
            } else if (_reduceQuantity != 0 && _entryPrice == 0) {
                int256 _partialQuantityTemp = partialFilled > _reduceQuantity
                    ? int256(partialFilled - _reduceQuantity)
                    : int256(0);
                _partialQuantity = isBuy
                    ? _partialQuantityTemp
                    : -_partialQuantityTemp;
            } else {
                int256 _partialQuantityTemp = partialFilled > _reduceQuantity
                    ? int256(_reduceQuantity)
                    : int256(partialFilled);
                _partialQuantity = isBuy
                    ? _partialQuantityTemp
                    : -_partialQuantityTemp;
            }
            uint256 _partialOpenNotional = _entryPrice == 0
                ? ((_partialQuantity.abs() *
                    _positionManager.pipToPrice(_limitOrder.pip)) /
                    _positionManager.getBaseBasisPoint())
                : ((_partialQuantity.abs() * _entryPrice) /
                    _positionManager.getBaseBasisPoint());
            // IMPORTANT UPDATE FORMULA WITH LEVERAGE
            // TODO RECHECK THIS
            uint256 _partialMargin = _partialOpenNotional / _limitOrder.leverage;
            _positionData = _positionData.accumulateLimitOrder(
                _partialQuantity,
                _partialMargin,
                _partialOpenNotional
            );
        }
        _positionData.leverage = _positionData.leverage >= _limitOrder.leverage
            ? _positionData.leverage
            : _limitOrder.leverage;
        return _positionData;
    }

    function getListOrderPending(
        address _pmAddress,
        address _trader,
        PositionLimitOrder.Data[] memory _limitOrders,
        PositionLimitOrder.Data[] memory _reduceLimitOrders
    ) public view returns (PositionHouseStorage.LimitOrderPending[] memory) {
        IPositionManager _positionManager = IPositionManager(
            _pmAddress
        );
        if (_limitOrders.length + _reduceLimitOrders.length > 0) {
            PositionHouseStorage.LimitOrderPending[]
                memory listPendingOrders = new PositionHouseStorage.LimitOrderPending[](
                    _limitOrders.length + _reduceLimitOrders.length + 1
                );
            uint256 index = 0;
            for (uint256 i = 0; i < _limitOrders.length; i++) {
                (
                    bool isFilled,
                    bool isBuy,
                    uint256 quantity,
                    uint256 partialFilled
                ) = _positionManager.getPendingOrderDetail(
                        _limitOrders[i].pip,
                        _limitOrders[i].orderId
                    );
                if (!isFilled) {
                    listPendingOrders[index] = PositionHouseStorage
                        .LimitOrderPending({
                            isBuy: isBuy,
                            quantity: quantity,
                            partialFilled: partialFilled,
                            pip: _limitOrders[i].pip,
                            leverage: _limitOrders[i].leverage,
                            blockNumber: _limitOrders[i].blockNumber,
                            isReduce: 0,
                            orderIdx: i,
                            orderId: _limitOrders[i].orderId
                        });
                    index++;
                }
            }
            for (uint256 i = 0; i < _reduceLimitOrders.length; i++) {
                (
                    bool isFilled,
                    bool isBuy,
                    uint256 quantity,
                    uint256 partialFilled
                ) = _positionManager.getPendingOrderDetail(
                        _reduceLimitOrders[i].pip,
                        _reduceLimitOrders[i].orderId
                    );
                if (!isFilled && _reduceLimitOrders[i].reduceLimitOrderId == 0) {
                    listPendingOrders[index] = PositionHouseStorage
                        .LimitOrderPending({
                            isBuy: isBuy,
                            quantity: quantity,
                            partialFilled: partialFilled,
                            pip: _reduceLimitOrders[i].pip,
                            leverage: _reduceLimitOrders[i].leverage,
                            blockNumber: _reduceLimitOrders[i].blockNumber,
                            isReduce: 1,
                            orderIdx: i,
                            orderId: _reduceLimitOrders[i].orderId
                        });
                    index++;
                }
            }
            for (uint256 i = 0; i < listPendingOrders.length; i++) {
                if (listPendingOrders[i].quantity != 0) {
                    return listPendingOrders;
                }
            }
        }
        PositionHouseStorage.LimitOrderPending[]
            memory blankListPendingOrders;
        return blankListPendingOrders;
    }

    function getPositionNotionalAndUnrealizedPnl(
        address _pmAddress,
        address _trader,
        PositionHouseStorage.PnlCalcOption _pnlCalcOption,
        Position.Data memory _position
    ) public view returns (uint256 positionNotional, int256 unrealizedPnl) {
        IPositionManager positionManager = IPositionManager(
            _pmAddress
        );

        uint256 oldPositionNotional = _position.openNotional;
        if (_pnlCalcOption == PositionHouseStorage.PnlCalcOption.SPOT_PRICE) {
            positionNotional =
                (positionManager.getPrice() * _position.quantity.abs()) /
                positionManager.getBaseBasisPoint();
        } else if (_pnlCalcOption == PositionHouseStorage.PnlCalcOption.TWAP) {
            // TODO get twap price
        } else {
            // TODO get oracle price
        }

        if (_position.side() == Position.Side.LONG) {
            unrealizedPnl =
                int256(positionNotional) -
                int256(oldPositionNotional);
        } else {
            unrealizedPnl =
                int256(oldPositionNotional) -
                int256(positionNotional);
        }
    }

    function calcMaintenanceDetail(
        Position.Data memory _positionData,
        uint256 _maintenanceMarginRatio,
        int256 _unrealizedPnl
    )
        public
        view
        returns (
            uint256 maintenanceMargin,
            int256 marginBalance,
            uint256 marginRatio
        )
    {
        maintenanceMargin =
            (_positionData.margin * _maintenanceMarginRatio) /
            100;
        marginBalance = int256(_positionData.margin) + _unrealizedPnl;
        if (marginBalance <= 0) {
            marginRatio = 100;
        } else {
            marginRatio = (maintenanceMargin * 100) / uint256(marginBalance);
        }
    }

    function getClaimAmount(
        address _pmAddress,
        address _trader,
        Position.Data memory _positionData,
        Position.Data memory _positionDataWithoutLimit,
        PositionLimitOrder.Data[] memory _limitOrders,
        PositionLimitOrder.Data[] memory _reduceLimitOrders,
        uint256 _canClaimAmountInMap,
        int256 _manualMarginInMap
    ) public view returns (int256 totalClaimableAmount) {
        IPositionManager _positionManager = IPositionManager(
            _pmAddress
        );
        uint256 indexReduce;
        uint256 indexLimit;

        for (indexLimit; indexLimit < _limitOrders.length; indexLimit++) {
            {
                if (
                    _limitOrders[indexLimit].pip == 0 &&
                    _limitOrders[indexLimit].orderId == 0
                ) continue;
                if (
                    _limitOrders[indexLimit].reduceQuantity != 0 ||
                    indexLimit == _limitOrders.length - 1
                ) {
                    {
                        (
                            indexReduce,
                            totalClaimableAmount,
                            _positionData
                        ) = calculatePnlFromReduceOrder(
                            _positionManager,
                            indexReduce,
                            totalClaimableAmount,
                            _positionData,
                            _positionDataWithoutLimit,
                            _reduceLimitOrders
                        );
                    }
                    _positionData = accumulateLimitOrderToPositionData(
                        _pmAddress,
                        _limitOrders[indexLimit],
                        _positionData,
                        _limitOrders[indexLimit].entryPrice,
                        _limitOrders[indexLimit].reduceQuantity
                    );
                } else {
                    _positionData = accumulateLimitOrderToPositionData(
                        _pmAddress,
                        _limitOrders[indexLimit],
                        _positionData,
                        _limitOrders[indexLimit].entryPrice,
                        _limitOrders[indexLimit].reduceQuantity
                    );
                }
            }

            (
                bool isFilled,
                ,
                uint256 quantity,
                uint256 partialFilled
            ) = _positionManager.getPendingOrderDetail(
                    _limitOrders[indexLimit].pip,
                    _limitOrders[indexLimit].orderId
                );
            if (!isFilled) {
                totalClaimableAmount -= int256(
                    ((quantity - partialFilled) *
                        _positionManager.pipToPrice(
                            _limitOrders[indexLimit].pip
                        )) /
                        _positionManager.getBaseBasisPoint() /
                        _limitOrders[indexLimit].leverage
                );
            }
        }

        totalClaimableAmount =
            totalClaimableAmount +
            int256(_canClaimAmountInMap) +
            _manualMarginInMap +
            int256(_positionDataWithoutLimit.margin);
        if (totalClaimableAmount <= 0) {
            totalClaimableAmount = 0;
        }
    }

    function calculatePnlFromReduceOrder(
        IPositionManager _positionManager,
        uint256 _indexReduce,
        int256 _totalClaimableAmount,
        Position.Data memory _positionData,
        Position.Data memory _positionDataWithoutLimit,
        PositionLimitOrder.Data[] memory _reduceLimitOrders
    )
        public
        view
        returns (
            uint256 indexReduce,
            int256 totalClaimableAmount,
            Position.Data memory positionData
        )
    {
        for (
            _indexReduce;
            _indexReduce < _reduceLimitOrders.length;
            _indexReduce++
        ) {
            (bool isFilled, , , uint256 partialFilled) = _positionManager
                .getPendingOrderDetail(
                    _reduceLimitOrders[_indexReduce].pip,
                    _reduceLimitOrders[_indexReduce].orderId
                );
            {
                int256 realizedPnl = int256(
                    ((
                        (partialFilled <
                            _reduceLimitOrders[_indexReduce].reduceQuantity &&
                            !isFilled)
                            ? partialFilled
                            : _reduceLimitOrders[_indexReduce].reduceQuantity
                    ) *
                        _positionManager.pipToPrice(
                            _reduceLimitOrders[_indexReduce].pip
                        )) / _positionManager.getBaseBasisPoint()
                ) -
                    int256(
                        ((
                            _positionData.openNotional != 0
                                ? _positionData.openNotional
                                : _positionDataWithoutLimit.openNotional
                        ) *
                            (
                                (partialFilled <
                                    _reduceLimitOrders[_indexReduce]
                                        .reduceQuantity &&
                                    !isFilled)
                                    ? partialFilled
                                    : _reduceLimitOrders[_indexReduce].reduceQuantity
                            )) /
                            (
                                _positionData.quantity.abs() != 0
                                    ? _positionData.quantity.abs()
                                    : _positionDataWithoutLimit.quantity.abs()
                            )
                    );
                _totalClaimableAmount += _reduceLimitOrders[_indexReduce].isBuy == 2
                    ? realizedPnl
                    : (-realizedPnl);
            }
            {
                positionData = accumulateLimitOrderToPositionData(
                    address(_positionManager),
                    _reduceLimitOrders[_indexReduce],
                    _positionData,
                    _reduceLimitOrders[_indexReduce].entryPrice,
                    _reduceLimitOrders[_indexReduce].reduceQuantity
                );
            }
            if (_reduceLimitOrders[_indexReduce].reduceLimitOrderId != 0) {
                _indexReduce++;
                break;
            }
        }
        indexReduce = _indexReduce;
        totalClaimableAmount = _totalClaimableAmount;
    }

    function openMarketOrder(
        address _pmAddress,
        uint256 _quantity,
        Position.Side _side,
        address _trader
    ) internal returns (int256 exchangedQuantity, uint256 openNotional) {
        IPositionManager _positionManager = IPositionManager(
            _pmAddress
        );

        uint256 exchangedSize;
        (exchangedSize, openNotional) = _positionManager.openMarketPosition(
            _quantity,
            _side == Position.Side.LONG
        );
        require(exchangedSize == _quantity, Errors.VL_NOT_ENOUGH_LIQUIDITY);
        exchangedQuantity = _side == Position.Side.LONG
            ? int256(exchangedSize)
            : -int256(exchangedSize);
    }

    function increasePosition(
        address _pmAddress,
        Position.Side _side,
        int256 _quantity,
        uint256 _leverage,
        address _trader,
        Position.Data memory _positionData,
        Position.Data memory _positionDataWithoutLimit,
        int256[] memory _cumulativePremiumFractions
    ) public returns (PositionHouseStorage.PositionResp memory positionResp) {
        (
            positionResp.exchangedPositionSize,
            positionResp.exchangedQuoteAssetAmount
        ) = openMarketOrder(
            _pmAddress,
            _quantity.abs(),
            _side,
            _trader
        );
        if (positionResp.exchangedPositionSize != 0) {
            int256 _newSize = _positionDataWithoutLimit.quantity +
                positionResp.exchangedPositionSize;
            uint256 increaseMarginRequirement = positionResp
                .exchangedQuoteAssetAmount / _leverage;
            // TODO update function latestCumulativePremiumFraction

            (, int256 unrealizedPnl) = getPositionNotionalAndUnrealizedPnl(
                _pmAddress,
                _trader,
                PositionHouseStorage.PnlCalcOption.SPOT_PRICE,
                _positionData
            );

            positionResp.unrealizedPnl = unrealizedPnl;
            positionResp.realizedPnl = 0;
            // checked margin to vault
            positionResp.marginToVault = int256(increaseMarginRequirement);
            positionResp.position = Position.Data(
                _newSize,
                handleMarginInIncrease(
                    increaseMarginRequirement,
                    _positionData,
                    _positionDataWithoutLimit,
                    _cumulativePremiumFractions
                ),
                handleNotionalInIncrease(
                    positionResp.exchangedQuoteAssetAmount,
                    _positionData,
                    _positionDataWithoutLimit
                ),
                // TODO update cumulative fraction
                0,
                block.number,
                _leverage
            );
        }
    }

    function openReversePosition(
        address _pmAddress,
        Position.Side _side,
        int256 _quantity,
        uint256 _leverage,
        address _trader,
        Position.Data memory _positionData,
        Position.Data memory _positionDataWithoutLimit,
        int256[] memory _cumulativePremiumFractions
    ) public returns (PositionHouseStorage.PositionResp memory positionResp) {
        IPositionManager _positionManager = IPositionManager(
            _pmAddress
        );
        uint256 reduceMarginRequirement = (_positionData.margin *
            _quantity.abs()) / _positionData.quantity.abs();
        int256 totalQuantity = _positionDataWithoutLimit.quantity + _quantity;
        (positionResp.exchangedPositionSize, ) = openMarketOrder(
            _pmAddress,
            _quantity.abs(),
            _side,
            _trader
        );

        (, int256 unrealizedPnl) = getPositionNotionalAndUnrealizedPnl(
            _pmAddress,
            _trader,
            PositionHouseStorage.PnlCalcOption.SPOT_PRICE,
            _positionData
        );
        positionResp.realizedPnl =
            (unrealizedPnl * int256(positionResp.exchangedPositionSize)) /
            _positionData.quantity;
        positionResp.exchangedQuoteAssetAmount =
            (_quantity.abs() *
                _positionData.getEntryPrice(_pmAddress)) /
            _positionManager.getBaseBasisPoint();
        // NOTICE margin to vault can be negative
        positionResp.marginToVault = -(int256(reduceMarginRequirement) +
            positionResp.realizedPnl);
        // NOTICE calc unrealizedPnl after open reverse
        positionResp.unrealizedPnl = unrealizedPnl - positionResp.realizedPnl;
        {
            positionResp.position = Position.Data(
                totalQuantity,
                handleMarginInOpenReverse(
                    reduceMarginRequirement,
                    _positionData,
                    _positionDataWithoutLimit,
                    _cumulativePremiumFractions
                ),
                handleNotionalInOpenReverse(
                    positionResp.exchangedQuoteAssetAmount,
                    _positionData,
                    _positionDataWithoutLimit
                ),
                // TODO update cumulative fraction
                0,
                block.number,
                _leverage
            );
        }
        return positionResp;
    }

    function calcRemainMarginWithFundingPayment(
        Position.Data memory _oldPosition,
        uint256 _pMargin,
        int256[] memory _cumulativePremiumFractions
    ) internal view returns (uint256 remainMargin) {
        int256 fundingPayment;
        int256 latestCumulativePremiumFraction = getLatestCumulativePremiumFraction(
                _cumulativePremiumFractions
            );
        if (_oldPosition.quantity != 0) {
            fundingPayment =
                (latestCumulativePremiumFraction -
                    _oldPosition.lastUpdatedCumulativePremiumFraction) *
                _oldPosition.quantity;
        }

        // calculate remain margin, if remain margin is negative, set to zero and leave the rest to bad debt
        if (int256(_pMargin) + fundingPayment >= 0) {
            remainMargin = uint256(int256(_pMargin) + fundingPayment);
        }
    }

    function getLatestCumulativePremiumFraction(
        int256[] memory _cumulativePremiumFractions
    ) public view returns (int256) {
        uint256 len = _cumulativePremiumFractions.length;
        if (len > 0) {
            return _cumulativePremiumFractions[len - 1];
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library PositionHouseMath {
    function entryPriceFromNotional(
        uint256 _notional,
        uint256 _quantity,
        uint256 _baseBasicPoint
    ) public pure returns (uint256) {
        return (_notional * _baseBasicPoint) / _quantity;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

/**
 * @title Errors libraries
 * @author Position Exchange
 * @notice Defines the error messages emitted by the different contracts of the Position Exchange protocol
 * @dev Error messages prefix glossary:
 *  - VL = ValidationLogic
 *  - MATH = Math libraries
 *  - CT = Common errors between tokens (AToken, VariableDebtToken and StableDebtToken)
 *  - P = Pausable
 *  - A = Amm
 */
library Errors {
    //common errors

    //contract specific errors
    //    string public constant VL_INVALID_AMOUNT = '1'; // 'Amount must be greater than 0'
    string public constant VL_EMPTY_ADDRESS = "2";
    //    string public constant VL_INVALID_QUANTITY = '3'; // 'IQ'
    string public constant VL_INVALID_LEVERAGE = "4"; // 'IL'
    string public constant VL_INVALID_CLOSE_QUANTITY = "5"; // 'ICQ'
    string public constant VL_INVALID_CLAIM_FUND = "6"; // 'ICF'
    string public constant VL_NOT_ENOUGH_MARGIN_RATIO = "7"; // 'NEMR'
    string public constant VL_NO_POSITION_TO_REMOVE = "8"; // 'NPTR'
    string public constant VL_NO_POSITION_TO_ADD = "9"; // 'NPTA'
    string public constant VL_INVALID_QUANTITY_INTERNAL_CLOSE = "10"; // 'IQIC'
    string public constant VL_NOT_ENOUGH_LIQUIDITY = "11"; // 'NELQ'
    string public constant VL_INVALID_REMOVE_MARGIN = "12"; // 'IRM'
    string public constant VL_NOT_COUNTERPARTY = "13"; // 'IRM'
    string public constant VL_INVALID_INPUT = "14"; // 'IP'
    string public constant VL_SETTLE_FUNDING_TOO_EARLY = "15"; // 'SFTE'
    string public constant VL_LONG_PRICE_THAN_CURRENT_PRICE = "16"; // '!B'
    string public constant VL_SHORT_PRICE_LESS_CURRENT_PRICE = "17"; // '!S'
    string public constant VL_INVALID_SIZE = "18"; // ''
    string public constant VL_NOT_WHITELIST_MANAGER = "19"; // ''
    string public constant VL_INVALID_ORDER = "20"; // ''
    string public constant VL_ONLY_PENDING_ORDER = "21"; // ''

    enum CollateralManagerErrors {
        NO_ERROR
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

library Int256Math {

    /**
     * @dev Keeps positive side else return 0
     */
    function kPositive(int256 self) internal pure returns (int256) {
        return self > 0 ? self : int256(0);
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        unchecked {
            // don't worry about overflow here
            return a + b;
        }
    }
}

// SPDX-License-Identifier: MIT

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./LimitOrder.sol";
import "hardhat/console.sol";

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

    function updateOrderWhenClose(
        TickPosition.Data storage _self,
        uint64 _orderId
    ) internal returns (uint256) {
        return _self.orderQueue[_orderId].updateWhenClose();
    }

    function getQueueOrder(TickPosition.Data storage _self, uint64 _orderId)
        internal
        view
        returns (
            bool isFilled,
            bool isBuy,
            uint256 size,
            uint256 partialFilled
        )
    {
        (isBuy, size, partialFilled) = _self.orderQueue[_orderId].getData();
        if (_self.filledIndex > _orderId && size != 0) {
            isFilled = true;
        } else if (_self.filledIndex < _orderId) {
            isFilled = false;
        } else {
            isFilled = partialFilled >= size && size != 0 ? true : false;
        }
    }

    function partiallyFill(TickPosition.Data storage _self, uint128 _amount)
        internal
    {
        _self.liquidity -= _amount;
        unchecked {
            uint64 index = _self.filledIndex;
            uint128 totalSize = 0;
            if (_self.orderQueue[index].size == _self.orderQueue[index].partialFilled) {
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

    function cancelLimitOrder(TickPosition.Data storage _self, uint64 _orderId)
        internal
        returns (uint256, uint256)
    {
        (bool isBuy, uint256 size, uint256 partialFilled) = _self
            .orderQueue[_orderId]
            .getData();
        if (_self.liquidity >= uint128(size - partialFilled)) {
            _self.liquidity = _self.liquidity - uint128(size - partialFilled);
        }
        _self.orderQueue[_orderId].update(isBuy, partialFilled);
        return (size - partialFilled, partialFilled);
    }

    function closeLimitOrder(
        TickPosition.Data storage _self,
        uint64 _orderId,
        uint256 _amountClose
    ) internal returns (uint256 remainAmountClose) {
        (bool isBuy, uint256 size, uint256 partialFilled) = _self
            .orderQueue[_orderId]
            .getData();

        uint256 amount = _amountClose > partialFilled ? 0 : _amountClose;
        if (_amountClose > partialFilled) {
            uint256 amount = size - partialFilled;
            _self.orderQueue[_orderId].update(isBuy, amount);
            remainAmountClose = _amountClose - partialFilled;
        } else {
            uint256 amount = partialFilled - _amountClose;
            _self.orderQueue[_orderId].update(isBuy, amount);
            remainAmountClose = 0;
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "hardhat/console.sol";

library LimitOrder {
    struct Data {
        // Type order LONG or SHORT
        uint8 isBuy;
        uint120 size;
        // NOTICE need to add leverage
        uint120 partialFilled;
    }

    function getData(LimitOrder.Data storage _self)
        internal
        view
        returns (
            bool isBuy,
            uint256 size,
            uint256 partialFilled
        )
    {
        isBuy = _self.isBuy == 1;
        size = uint256(_self.size);
        partialFilled = uint256(_self.partialFilled);
    }

    function update(
        LimitOrder.Data storage _self,
        bool _isBuy,
        uint256 _size
    ) internal {
        _self.isBuy = _isBuy ? 1 : 2;
        _self.size = uint120(_size);
    }

    function updatePartialFill(LimitOrder.Data storage _self, uint120 _remainSize)
        internal
    {
        // remainingSize should be negative
        _self.partialFilled += _self.size - _remainSize;
    }

    function updateWhenClose(LimitOrder.Data storage _self)
        internal
        returns (uint256)
    {
        _self.size -= _self.partialFilled;
        _self.partialFilled = 0;
        return (uint256(_self.size));
    }

    function getPartialFilled(LimitOrder.Data storage _self)
        internal
        view
        returns (bool isPartial, uint256 remainingSize)
    {
        remainingSize = _self.size - _self.partialFilled;
        isPartial = remainingSize > 0;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./BitMath.sol";

library LiquidityBitmap {
    uint256 public constant MAX_UINT256 =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    /// @notice Get the position in the mapping
    /// @param _pip The bip index for computing the position
    /// @return mapIndex the index in the map
    /// @return bitPos the position in the bitmap
    function position(uint128 _pip)
        private
        pure
        returns (uint128 mapIndex, uint8 bitPos)
    {
        mapIndex = _pip >> 8;
        bitPos = uint8((_pip) & 0xff);
        // % 256
    }

    /// @notice find the next pip has liquidity
    /// @param _pip The current pip index
    /// @param _lte  Whether to search for the next initialized tick to the left (less than or equal to the starting tick)
    /// @return next The next bit position has liquidity, 0 means no liquidity found
    function findHasLiquidityInOneWords(
        mapping(uint128 => uint256) storage _self,
        uint128 _pip,
        bool _lte
    ) internal view returns (uint128 next) {
        if (_lte) {
            // main is find the next pip has liquidity
            (uint128 wordPos, uint8 bitPos) = position(_pip);
            // all the 1s at or to the right of the current bitPos
            uint256 mask = (1 << bitPos) - 1 + (1 << bitPos);
            uint256 masked = _self[wordPos] & mask;
            //            bool hasLiquidity = (_self[wordPos] & 1 << bitPos) != 0;

            // if there are no initialized ticks to the right of or at the current tick, return rightmost in the word
            bool initialized = masked != 0;
            // overflow/underflow is possible, but prevented externally by limiting both tickSpacing and tick
            next = initialized
                ? (_pip - (bitPos - BitMath.mostSignificantBit(masked)))
                : 0;

            //            if (!hasLiquidity && next != 0) {
            //                next = next + 1;
            //            }
        } else {
            // start from the word of the next tick, since the current tick state doesn't matter
            (uint128 wordPos, uint8 bitPos) = position(_pip);
            // all the 1s at or to the left of the bitPos
            uint256 mask = ~((1 << bitPos) - 1);
            uint256 masked = _self[wordPos] & mask;
            // if there are no initialized ticks to the left of the current tick, return leftmost in the word
            bool initialized = masked != 0;
            // overflow/underflow is possible, but prevented externally by limiting both tickSpacing and tick
            next = initialized
                ? (_pip + (BitMath.leastSignificantBit(masked) - bitPos)) // +1
                : 0;

            //            if (!hasLiquidity && next != 0) {
            //                next = next + 1;
            //            }
        }
    }

    // find nearest pip has liquidity in multiple word
    function findHasLiquidityInMultipleWords(
        mapping(uint128 => uint256) storage _self,
        uint128 _pip,
        uint128 _maxWords,
        bool _lte
    ) internal view returns (uint128 next) {
        uint128 startWord = _pip >> 8;
        if (_lte) {
            if (startWord != 0) {
                for (
                    uint128 i = startWord;
                    i > (startWord < _maxWords ? 0 : startWord - _maxWords);
                    i--
                ) {
                    if (_self[i] != 0) {
                        next = findHasLiquidityInOneWords(
                            _self,
                            i < startWord ? 256 * i + 255 : _pip,
                            true
                        );
                        if (next != 0) {
                            return next;
                        }
                    }
                }
            } else {
                if (_self[startWord] != 0) {
                    next = findHasLiquidityInOneWords(
                        _self,
                        _pip,
                        true
                    );
                    if (next != 0) {
                        return next;
                    }
                }
            }
        } else {
            for (uint128 i = startWord; i < startWord + _maxWords; i++) {
                if (_self[i] != 0) {
                    next = findHasLiquidityInOneWords(
                        _self,
                        i > startWord ? 256 * i : _pip,
                        false
                    );
                    if (next != 0) {
                        return next;
                    }
                }
            }
        }
    }

    // find all pip has liquidity in multiple word
    function findAllLiquidityInMultipleWords(
        mapping(uint128 => uint256) storage _self,
        uint128 _startPip,
        uint256 _dataLength,
        bool _toHigher
    ) internal view returns (uint128[] memory) {
        uint128 startWord = _startPip >> 8;
        uint128 index = 0;
        uint128[] memory allPip = new uint128[](uint128(_dataLength));
        if (!_toHigher) {
            for (uint128 i = startWord; i >= startWord - 1000; i--) {
                if (_self[i] != 0) {
                    uint128 next;
                    next = findHasLiquidityInOneWords(
                        _self,
                        i < startWord ? 256 * i + 255 : _startPip,
                        true
                    );
                    if (next != 0) {
                        allPip[index] = next;
                        index++;
                    }
                    while (true) {
                        next = findHasLiquidityInOneWords(_self, next - 1, true);
                        if (next != 0 && index <= _dataLength) {
                            allPip[index] = next;
                            index++;
                        } else {
                            break;
                        }
                    }
                }
                if (index == _dataLength) return allPip;
            }
        } else {
            for (uint128 i = startWord; i <= startWord + 1000; i++) {
                if (_self[i] != 0) {
                    uint128 next;
                    next = findHasLiquidityInOneWords(
                        _self,
                        i > startWord ? 256 * i : _startPip,
                        false
                    );
                    if (next != 0) {
                        allPip[index] = next;
                        index++;
                    }
                    while (true) {
                        next = findHasLiquidityInOneWords(
                            _self,
                            next + 1,
                            false
                        );
                        if (next != 0 && index <= _dataLength) {
                            allPip[index] = next;
                            index++;
                        } else {
                            break;
                        }
                    }
                }
            }
            if (index == _dataLength) return allPip;
        }

        return allPip;
    }

    function hasLiquidity(mapping(uint128 => uint256) storage _self, uint128 _pip)
        internal
        view
        returns (bool)
    {
        (uint128 mapIndex, uint8 bitPos) = position(_pip);
        return (_self[mapIndex] & (1 << bitPos)) != 0;
    }

    /// @notice Set all bits in a given range
    /// @dev WARNING THIS FUNCTION IS NOT READY FOR PRODUCTION
    /// only use for generating test data purpose
    /// @param _fromPip the pip to set from
    /// @param _toPip the pip to set to
    function setBitsInRange(
        mapping(uint128 => uint256) storage _self,
        uint128 _fromPip,
        uint128 _toPip
    ) internal {
        (uint128 fromMapIndex, uint8 fromBitPos) = position(_fromPip);
        (uint128 toMapIndex, uint8 toBitPos) = position(_toPip);
        if (toMapIndex == fromMapIndex) {
            // in the same storage
            // Set all the bits in given range of a number
            _self[toMapIndex] |= (((1 << (fromBitPos - 1)) - 1) ^
                ((1 << toBitPos) - 1));
        } else {
            // need to shift the map index
            // TODO fromMapIndex needs set separately
            _self[fromMapIndex] |= (((1 << (fromBitPos - 1)) - 1) ^
                ((1 << 255) - 1));
            for (uint128 i = fromMapIndex + 1; i < toMapIndex; i++) {
                // pass uint256.MAX to avoid gas for computing
                _self[i] = MAX_UINT256;
            }
            // set bits for the last index
            _self[toMapIndex] = MAX_UINT256 >> (256 - toBitPos);
        }
    }

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
        (uint128 toMapIndex, uint8 toBitPos) = position(_toPip);
        if (toMapIndex == fromMapIndex) {
            //            if(fromBitPos > toBitPos){
            //                uint8 n = fromBitPos;
            //                fromBitPos = toBitPos;
            //                toBitPos = n;
            //            }
            _self[toMapIndex] &= toggleBitsFromLToR(
                MAX_UINT256,
                fromBitPos,
                toBitPos
            );
        } else {
            //TODO check overflow here
            fromBitPos--;
            _self[fromMapIndex] &= ~toggleLastMBits(MAX_UINT256, fromBitPos);
            for (uint128 i = fromMapIndex + 1; i < toMapIndex; i++) {
                _self[i] = 0;
            }
            _self[toMapIndex] &= toggleLastMBits(MAX_UINT256, toBitPos);
        }
    }

    function toggleSingleBit(
        mapping(uint128 => uint256) storage _self,
        uint128 _pip,
        bool _isSet
    ) internal {
        (uint128 mapIndex, uint8 bitPos) = position(_pip);
        if (_isSet) {
            _self[mapIndex] |= 1 << bitPos;
        } else {
            _self[mapIndex] &= ~(1 << bitPos);
        }
    }

    function toggleBitsFromLToR(
        uint256 _n,
        uint8 _l,
        uint8 _r
    ) private returns (uint256) {
        // calculating a number 'num'
        // having 'r' number of bits
        // and bits in the range l
        // to r are the only set bits
        uint256 num = ((1 << _r) - 1) ^ ((1 << (_l - 1)) - 1);

        // toggle the bits in the
        // range l to r in 'n'
        // and return the number
        return (_n ^ num);
    }

    // Function to toggle the last m bits
    function toggleLastMBits(uint256 _n, uint8 _m) private returns (uint256) {
        // Calculating a number 'num' having
        // 'm' bits and all are set
        uint256 num = (1 << _m) - 1;

        // Toggle the last m bits and
        // return the number
        return (_n ^ num);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../../interfaces/IChainLinkPriceFeed.sol";
import "../position/TickPosition.sol";
import "../position/LiquidityBitmap.sol";

contract PositionManagerStorage {
    using TickPosition for TickPosition.Data;
    using LiquidityBitmap for mapping(uint128 => uint256);

    uint256 public basisPoint; //0.01
    uint256 public BASE_BASIC_POINT;
    // fee = quoteAssetAmount / tollRatio (means if fee = 0.001% then tollRatio = 100000)
    uint256 tollRatio;

    int256 public fundingRate;

    uint256 public spotPriceTwapInterval;
    uint256 public fundingPeriod;
    uint256 public fundingBufferPeriod;
    uint256 public nextFundingTime;
    bytes32 public priceFeedKey;
    // Max finding word can be 3500
    uint128 public maxFindingWordsIndex;

    address counterParty;

    bool public isOpen;

//    bool public paused;

    IChainLinkPriceFeed public priceFeed;

    struct SingleSlot {
        uint128 pip;
        //0: not set
        //1: buy
        //2: sell
        uint8 isFullBuy;
    }

    IERC20 quoteAsset;

    struct ReserveSnapshot {
        uint128 pip;
        uint256 timestamp;
        uint256 blockNumber;
    }

    enum TwapCalcOption {
        RESERVE_ASSET,
        INPUT_ASSET
    }

    struct TwapPriceCalcParams {
        TwapCalcOption opt;
        uint256 snapshotIndex;
    }

    struct SwapState {
        uint256 remainingSize;
        // the tick associated with the current price
        uint128 pip;
    }

    struct StepComputations {
        uint128 pipNext;
    }

    enum CurrentLiquiditySide {
        NotSet,
        Buy,
        Sell
    }

    // array of reserveSnapshots
    ReserveSnapshot[] public reserveSnapshots;

    SingleSlot public singleSlot;
    mapping(uint128 => TickPosition.Data) public tickPosition;
    mapping(uint128 => uint256) public tickStore;
    // a packed array of bit, where liquidity is filled or not
    mapping(uint128 => uint256) public liquidityBitmap;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IChainLinkPriceFeed {
    // get latest price
    function getPrice(bytes32 _priceFeedKey) external view returns (uint256);

    // get latest timestamp
    function getLatestTimestamp(bytes32 _priceFeedKey)
        external
        view
        returns (uint256);

    // get previous price with _back rounds
    function getPreviousPrice(bytes32 _priceFeedKey, uint256 _numOfRoundBack)
        external
        view
        returns (uint256);

    // get previous timestamp with _back rounds
    function getPreviousTimestamp(
        bytes32 _priceFeedKey,
        uint256 _numOfRoundBack
    ) external view returns (uint256);

    // get twap price depending on _period
    function getTwapPrice(bytes32 _priceFeedKey, uint256 _interval)
        external
        view
        returns (uint256);

    //    function setLatestData(
    //        bytes32 _priceFeedKey,
    //        uint256 _price,
    //        uint256 _timestamp,
    //        uint256 _roundId
    //    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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
pragma solidity ^0.8.0;

/// @title BitMath
/// @dev This libraries provides functionality for computing bit properties of an unsigned integer
library BitMath {
    /// @notice Returns the index of the most significant bit of the number,
    ///     where the least significant bit is at index 0 and the most significant bit is at index 255
    /// @dev The function satisfies the property:
    ///     x >= 2**mostSignificantBit(x) and x < 2**(mostSignificantBit(x)+1)
    /// @param x the value for which to compute the most significant bit, must be greater than 0
    /// @return r the index of the most significant bit// SPDX-License-Identifier: GPL-2.0-or-later
    //pragma solidity >=0.5.0;
    //
    ///// @title BitMath
    ///// @dev This libraries provides functionality for computing bit properties of an unsigned integer
    //libraries BitMath {
    //    /// @notice Returns the index of the most significant bit of the number,
    //    ///     where the least significant bit is at index 0 and the most significant bit is at index 255
    //    /// @dev The function satisfies the property:
    //    ///     x >= 2**mostSignificantBit(x) and x < 2**(mostSignificantBit(x)+1)
    //    /// @param x the value for which to compute the most significant bit, must be greater than 0
    //    /// @return r the index of the most significant bit
    //    function mostSignificantBit(uint256 x) internal pure returns (uint8 r) {
    //        require(x > 0);
    //
    //        if (x >= 0x100000000000000000000000000000000) {
    //            x >>= 128;
    //            r += 128;
    //        }
    //        if (x >= 0x10000000000000000) {
    //            x >>= 64;
    //            r += 64;
    //        }
    //        if (x >= 0x100000000) {
    //            x >>= 32;
    //            r += 32;
    //        }
    //        if (x >= 0x10000) {
    //            x >>= 16;
    //            r += 16;
    //        }
    //        if (x >= 0x100) {
    //            x >>= 8;
    //            r += 8;
    //        }
    //        if (x >= 0x10) {
    //            x >>= 4;
    //            r += 4;
    //        }
    //        if (x >= 0x4) {
    //            x >>= 2;
    //            r += 2;
    //        }
    //        if (x >= 0x2) r += 1;
    //    }
    //
    //    /// @notice Returns the index of the least significant bit of the number,
    //    ///     where the least significant bit is at index 0 and the most significant bit is at index 255
    //    /// @dev The function satisfies the property:
    //    ///     (x & 2**leastSignificantBit(x)) != 0 and (x & (2**(leastSignificantBit(x)) - 1)) == 0)
    //    /// @param x the value for which to compute the least significant bit, must be greater than 0
    //    /// @return r the index of the least significant bit
    //    function leastSignificantBit(uint256 x) internal pure returns (uint8 r) {
    //        require(x > 0);
    //
    //        r = 255;
    //        if (x & type(uint128).max > 0) {
    //            r -= 128;
    //        } else {
    //            x >>= 128;
    //        }
    //        if (x & type(uint64).max > 0) {
    //            r -= 64;
    //        } else {
    //            x >>= 64;
    //        }
    //        if (x & type(uint32).max > 0) {
    //            r -= 32;
    //        } else {
    //            x >>= 32;
    //        }
    //        if (x & type(uint16).max > 0) {
    //            r -= 16;
    //        } else {
    //            x >>= 16;
    //        }
    //        if (x & type(uint8).max > 0) {
    //            r -= 8;
    //        } else {
    //            x >>= 8;
    //        }
    //        if (x & 0xf > 0) {
    //            r -= 4;
    //        } else {
    //            x >>= 4;
    //        }
    //        if (x & 0x3 > 0) {
    //            r -= 2;
    //        } else {
    //            x >>= 2;
    //        }
    //        if (x & 0x1 > 0) r -= 1;
    //    }
    //}
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