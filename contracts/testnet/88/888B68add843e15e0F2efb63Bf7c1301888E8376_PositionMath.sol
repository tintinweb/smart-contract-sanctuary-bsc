// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {USDMargin} from "./math/USDMargin.sol";

library PositionMath {
    function calculateNotional(
        uint256 _price,
        uint256 _quantity,
        uint256 _baseBasisPoint
    ) public pure returns (uint256) {
        return USDMargin.calculateNotional(_price, _quantity, _baseBasisPoint);
    }

    function calculateEntryPrice(
        uint256 _notional,
        uint256 _quantity,
        uint256 _baseBasisPoint
    ) public pure returns (uint256) {
        return USDMargin.calculateEntryPrice(_notional, _quantity, _baseBasisPoint);
    }

    function calculatePnl(
        int256 _quantity,
        uint256 _openNotional,
        uint256 _closeNotional
    ) public pure returns (int256) {
        return USDMargin.calculatePnl(_quantity, _openNotional, _closeNotional);
    }

    function calculateFundingPayment(
        int256 _deltaPremiumFraction,
        int256 _margin,
        int256 _PREMIUM_FRACTION_DENOMINATOR
    ) public pure returns (int256) {
        return _margin * _deltaPremiumFraction / _PREMIUM_FRACTION_DENOMINATOR;
    }

    function calculateLiquidationPip(
        int256 _quantity,
        uint256 _margin,
        uint256 _positionNotional,
        uint256 _maintenanceMargin,
        uint256 _basisPoint
    ) public pure returns (uint256) {
        return USDMargin.calculateLiquidationPip(
            _quantity,
            _margin,
            _positionNotional,
            _maintenanceMargin,
            _basisPoint
        );
    }

    function calculatePartialLiquidateQuantity(
        int256 _quantity,
        uint256 _liquidationPenaltyRatio,
        uint256 _contractPrice
    ) public pure returns (int256) {
        int256 partialLiquidateQuantity = _quantity * int256(_liquidationPenaltyRatio) / 100;
        if (_contractPrice != 0) {
            return floorQuantity(partialLiquidateQuantity, _contractPrice);
        }
        return partialLiquidateQuantity;
    }

    function floorQuantity(
        int256 _quantity,
        uint256 _contractPrice
    ) public pure returns (int256) {
        int256 minimumContractSize = int256(10**18 * _contractPrice);
        return _quantity / minimumContractSize * minimumContractSize;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../../helpers/Quantity.sol";

library USDMargin {
    using Quantity for int256;

    function calculateNotional(
        uint256 _price,
        uint256 _quantity,
        uint256 _baseBasisPoint
    ) public pure returns (uint256) {
        return _quantity * _price / _baseBasisPoint;
    }

    function calculateEntryPrice(
        uint256 _notional,
        uint256 _quantity,
        uint256 _baseBasisPoint
    ) public pure returns (uint256) {
        if (_quantity != 0) {
            return _notional * _baseBasisPoint / _quantity;
        }
        return 0;
    }

    function calculatePnl(
        int256 _quantity,
        uint256 _openNotional,
        uint256 _closeNotional
    ) public pure returns (int256) {
        // LONG position
        if (_quantity > 0) {
            return (int256(_closeNotional) - int256(_openNotional));
        }
        // SHORT position
        return (int256(_openNotional) - int256(_closeNotional));
    }

    function calculateLiquidationPip(
        int256 _quantity,
        uint256 _margin,
        uint256 _positionNotional,
        uint256 _maintenanceMargin,
        uint256 _basisPoint
    ) public pure returns (uint256) {
        if (_quantity > 0) {
            if (_margin > _maintenanceMargin + _positionNotional) {
                return 0;
            }
            return (_maintenanceMargin + _positionNotional - _margin) * _basisPoint / _quantity.abs();
        }
        return (_margin + _positionNotional - _maintenanceMargin) * _basisPoint / _quantity.abs();
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

    // TODO write unit test
    /// @dev return the value of Quantity minus amount
    function subAmount(int256 _quantity, uint256 _amount) internal pure returns(int256){
        return _quantity < 0 ? _quantity + int256(_amount) : _quantity - int256(_amount);
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