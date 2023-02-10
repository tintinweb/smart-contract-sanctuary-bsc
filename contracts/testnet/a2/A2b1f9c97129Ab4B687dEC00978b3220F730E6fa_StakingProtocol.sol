// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./StakingParts/ClaimSender.sol";
import "../libs/utils/ERC721OnlySelfInitHolder.sol";
import "../libs/interfaces/IStakingProtocol.sol";

contract StakingProtocol is
    Initializable,
    OwnableUpgradeable,
    ClaimSender,
    ERC721OnlySelfInitHolder,
    IStakingProtocol
{
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.AddressToUintMap;

    function initialize(
        address _oracle,
        address _nftBondManager,
        address _nftSmart,
        uint256 _rewardDelayPeriod,
        uint256 _baseRewardInPercent,
        uint256 _timedRewardInPercent,
        uint256 _timedRewardPeriod,
        address _stablecoin
    )
        public
        initializer
    {
        __Ownable_init();

        __init_StakingStorage(
            _stablecoin,
            _oracle,
            _nftBondManager,
            _nftSmart
        );
        __init_PendingCalculator(
            _rewardDelayPeriod,
            _baseRewardInPercent,
            _timedRewardInPercent,
            _timedRewardPeriod
        );
    }

////////////////////////////////////////// modifiers

    modifier onlyOracle() {
        require(oracle == _msgSender(), "onlyOracle: caller is not the oracle");
        _;
    }

////////////////////////////////////////// AssetsManager

    function assetsManagerAddAsset(
        address _asset,
        uint256 _rewardCoefficientInPercent
    )
        public
        override
        onlyOracle
    {
        __AddAsset(_asset, _rewardCoefficientInPercent);
    }

    function assetsManagerEditAssetRewardCoefficient(
        address _asset,
        uint256 _rewardCoefficientInPercent
    )
        public
        override
        onlyOracle
    {
        __EditAssetRewardCoefficient(_asset, _rewardCoefficientInPercent);
    }

    function assetsManagerRemoveAsset(
        address _asset
    )
        public
        override
        onlyOracle
    {
        __RemoveAsset(_asset);
    }

////////////////////////////////////////// StakingStorage

    function deposit(
        address[] memory _assets,
        uint256[] memory _amounts,
        uint256[] memory _bondNFTs,
        bool _needDepositSmartNFT,
        uint256 _smartNFT
    )
        public
    {
        __deposit(
            _msgSender(),
            _assets,
            _amounts,
            _bondNFTs,
            _needDepositSmartNFT,
            _smartNFT
        );
    }

    function withdraw(
        address[] memory _assets,
        uint256[] memory _amounts,
        uint256[] memory _bondNFTs,
        bool _needWithdrawSmartNFT
    )
        public
    {
        __withdraw(
            _msgSender(),
            _assets,
            _amounts,
            _bondNFTs,
            _needWithdrawSmartNFT
        );
    }

////////////////////////////////////////// StakingStorage - AmountInBase view methods

    function getCurrentAmountInBaseWithAllBoostsAndCurrentTimeRewardPercent(
        address _account
    )
        public
        view
        returns (uint256 amountInBase, uint256 currentTimedRewardInPercent, uint256 _timeRewardPeriodBegin)
    {
        AccountPeriodInfo storage _accountPeriodInfo = accountPeriodDataByPeriodNumber[_account][accountLastPeriodNumber[_account]];
        amountInBase = __getAmountInBase(_accountPeriodInfo);


        _timeRewardPeriodBegin = __getCurrentTimeRewardPeriodBegin(_account);
        currentTimedRewardInPercent = 0;
        if (_timeRewardPeriodBegin != 0) {
            uint256 _currentTimeRewardPeriod = _calculateNonSuspensionPeriod(_timeRewardPeriodBegin, block.timestamp);

            if (_currentTimeRewardPeriod >= timedRewardPeriod) {
                currentTimedRewardInPercent = timedRewardInPercent * 100;
            } else {
                currentTimedRewardInPercent = timedRewardInPercent * 100 * _currentTimeRewardPeriod / timedRewardPeriod;
            }
        }
        // currentTimedRewardInPercent - percent * 100
        return (amountInBase, currentTimedRewardInPercent, _timeRewardPeriodBegin);
    }

    function __getCurrentTimeRewardPeriodBegin(address _account)
        private
        view
        returns (uint256)
    {
        uint256 _timeRewardPeriodBegin = 0;

        for (uint256 i = accountLastPeriodNumber[_account]; i > 0; --i)
        {
            AccountPeriodInfo storage _period = accountPeriodDataByPeriodNumber[_account][i];
            if (_period.timeBegin <= accountLastClaimTime[_account]) {
                return accountLastClaimTime[_account];
            }
            if (_period.isWithdraw) {
                return _period.timeBegin;
            }
            _timeRewardPeriodBegin = _period.timeBegin;
        }
        return _timeRewardPeriodBegin;
    }

    function getCurrentAmountInBase(
        address _account
    )
        public
        view
        returns (uint256 _amountInBase)
    {
        AccountPeriodInfo storage _accountPeriodInfo = accountPeriodDataByPeriodNumber[_account][accountLastPeriodNumber[_account]];

        if (_accountPeriodInfo.timeBegin == 0) {
            return 0;
        }

        uint256 timeEnd = block.timestamp;

        _amountInBase = 0;
        for (uint256 i = 0; i < _accountPeriodInfo.assetsAmounts.length(); ++i) {
            (address _asset, uint256 _amount) = _accountPeriodInfo.assetsAmounts.at(i);
            _amountInBase += getOracle().consultByHistory(_asset, _accountPeriodInfo.timeBegin, timeEnd)
            * _amount
            / 10 ** IERC20MetadataUpgradeable(_asset).decimals()
            ;
        }

        return _amountInBase;
    }

////////////////////////////////////////// oracle - helpers functions

    function consultNFTBond(uint256 tokenId)
        public
        view
        returns (uint256 _amountInBase)
    {
        (address[] memory _assetsFromNFTBond, uint256[] memory _amountsFromNFTBond) = getNFTBondManager().currencyBalancesList(tokenId);

        _amountInBase = 0;
        for (uint256 j = 0; j < _assetsFromNFTBond.length; ++j) {
            _amountInBase += getOracle().consult(_assetsFromNFTBond[j], _amountsFromNFTBond[j]);
        }
    }

    function updateAllRelatedOracleAssets()
        public
    {
        getOracle().updateAllWithoutHistory();

        // update All assets in staking
        uint256 _count = assetWithRewardCoefficients.length();
        for (uint256 i = 0; i < _count; ++i) {
            (address _asset, uint256 _rewardCoefficient) = assetWithRewardCoefficients.at(i);
            if (_rewardCoefficient > 0) {
                getOracle().updateHistory(_asset);
            }
        }

        // update All assets in nftBond
        (address[] memory _assetsInNFTBond,) = getNFTBondManager().getAssetWithCaps();
        _count = _assetsInNFTBond.length;
        for (uint256 i = 0; i < _count; ++i) {
            getOracle().updateHistory(_assetsInNFTBond[i]);
        }
    }

////////////////////////////////////////// fullBalance DevOnly todo rm in prod

    function devOnlyShowAllRelatedOracleAssets()
        public
        view
        returns (address[] memory _assetsInStaking, address[] memory _assetsInNFTBond)
    {
        (_assetsInStaking,) = getAssetWithRewardCoefficients();
        (_assetsInNFTBond,) = getNFTBondManager().getAssetWithCaps();
    }

////////////////////////////////////////// PendingCalculator

    function pendingFull()
        public
        view
        returns (uint256 _rewardAllowedToClaim, uint256 _rewardInDelay)
    {
        return __calculatePendingFull();
    }

    function pending(address _account)
        public
        view
        returns (uint256 _rewardAllowedToClaim, uint256 _rewardInDelay)
    {
        return __calculatePendingForView(_account);
    }

////////////////////////////////////////// StableCoinIntegration

    modifier onlyStableCoin() {
        require(stablecoin == _msgSender(), "onlyStableCoin: caller is not the stableCoin");
        _;
    }

    function runStaking()
        public
        onlyStableCoin
    {
        _finishLastSuspensionPeriod();
    }
    function disableStaking()
        public
        onlyStableCoin
    {
        _startNewSuspensionPeriod(block.timestamp);
    }
    function rewardAnnulation()
        public
        onlyStableCoin
    {
        _startNewSuspensionPeriod(block.timestamp - rewardDelayPeriod);
    }

    //todo rm in prod
    function devOnlyDisableStaking(uint256 _suspensionPeriodBegin)
        public
    {
        _startNewSuspensionPeriod(block.timestamp - _suspensionPeriodBegin);
    }
    function devOnlyRunStaking()
        public
    {
        _finishLastSuspensionPeriod();
    }
////////////////////////////////////////// ClaimSender

    function claim()
        public
    {
        __claim(_msgSender());
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableMapUpgradeable.sol";

library AddressToUintMapAdditionalMethods {
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.AddressToUintMap;

    function cloneFrom(EnumerableMapUpgradeable.AddressToUintMap storage map, EnumerableMapUpgradeable.AddressToUintMap storage mapSource)
        internal
    {
        uint256 count = mapSource.length();

        for (uint256 i = 0; i < count; ++i) {
            (address key, uint256 value) = mapSource.at(i);
            if (value != 0) {
                map.set(key, value);
            }
        }
    }

    function getKeyValueList(
        EnumerableMapUpgradeable.AddressToUintMap storage map
    )
        internal
        view
        returns (address[] memory, uint256[] memory)
    {
        uint256 count = map.length();
        address[] memory keys = new address[](count);
        uint256[] memory values = new uint256[](count);

        for (uint256 i = 0; i < count; ++i) {
            (keys[i], values[i]) = map.at(i);
        }

        return (keys, values);
    }

    function getUnsortedKeys(
        EnumerableMapUpgradeable.AddressToUintMap storage map
    )
        internal
        view
        returns (address[] memory)
    {
        uint256 count = map.length();
        address[] memory keys = new address[](count);

        bytes32[] memory keysInBytes = map._inner._keys._inner._values;
        for (uint256 i = 0; i < count; ++i) {
            keys[i] = address(uint160(uint256(keysInBytes[i])));
        }

        return keys;
    }


    function add(
        EnumerableMapUpgradeable.AddressToUintMap storage map,
        address key,
        uint256 value
    ) internal returns (bool) {
        (, uint256 oldValue) = map.tryGet(key);
        return map.set(key, oldValue + value);
    }

    function sub(
        EnumerableMapUpgradeable.AddressToUintMap storage map,
        address key,
        uint256 value
    ) internal returns (bool) {
        return sub(map, key, value, '');
    }

    function sub(
        EnumerableMapUpgradeable.AddressToUintMap storage map,
        address key,
        uint256 value,
        string memory message
    ) internal returns (bool) {
        if (value == 0) {
            return false;
        }
        uint256 oldValue = map.get(key);
        if (oldValue == value) {
            return map.remove(key);
        }
        require(oldValue > value, message);
        return map.set(key, oldValue - value);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";


/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts only self initiated token transfers.
 */
abstract contract ERC721OnlySelfInitHolder is IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        if (operator == address(this)) {
            return this.onERC721Received.selector;
        }
        return bytes4(0);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library DoubleMath {
    uint256 constant doubleScale = 1e36;

    struct Double {
        uint256 mantissa;
    }

    function newDouble(uint256 a) pure internal returns (Double memory) {
        return Double({mantissa: a * doubleScale});
    }
    /**
     * @dev Truncates the given exp to a whole number value.
     *      For example, truncate(Double{mantissa: 15 * doubleScale}) = 15
     */
    function truncate(Double memory exp) pure internal returns (uint256) {
        // Note: We are not using careful math here as we're performing a division that cannot fail
        return exp.mantissa / doubleScale;
    }

    /**
     * @dev returns true if Double is exactly zero
     */
    function isZero(Double memory value) pure internal returns (bool) {
        return value.mantissa == 0;
    }

    function add_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: a.mantissa + b.mantissa});
    }

    function add_(Double memory a, uint256 b) pure internal returns (Double memory) {
        return Double({mantissa: a.mantissa + b * doubleScale});
    }

    function sub_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: a.mantissa - b.mantissa});
    }

    function mul_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: (a.mantissa * b.mantissa) / doubleScale});
    }

    function mul_(Double memory a, uint256 b) pure internal returns (Double memory) {
        return Double({mantissa: a.mantissa * b});
    }

    function mul_(uint256 a, Double memory b) pure internal returns (uint256) {
        return (a * b.mantissa) / doubleScale;
    }

    function div_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: a.mantissa * doubleScale / b.mantissa});
    }

    function div_(Double memory a, uint256 b) pure internal returns (Double memory) {
        return Double({mantissa: a.mantissa / b});
    }

    function div_(uint256 a, Double memory b) pure internal returns (uint256) {
        return (a * doubleScale) / b.mantissa;
    }

    function fraction(uint256 a, uint256 b) pure internal returns (Double memory) {
        return Double({mantissa: (a * doubleScale) / b});
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ABDKMath64x64.sol";
import "./DoubleMath.sol";

library CompoundPercent {
    using ABDKMath64x64 for int128;

    function compound(uint256 amount, DoubleMath.Double memory yearPercent, uint256 period)
        internal
        pure
        returns (uint)
    {
        return ABDKMath64x64.mulu(
            ABDKMath64x64.add(
                ABDKMath64x64.fromUInt(1),
                ABDKMath64x64.divu(yearPercent.mantissa / (100 * 365 * 24 * 60 * 60), DoubleMath.doubleScale)
            ).pow(period).sub(ABDKMath64x64.fromUInt(1)),
            amount
        );
    }
//    APY = [1 + (APR / Number of Periods)]^(Number of Periods) - 1

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * Smart contract library of mathematical functions operating with signed
 * 64.64-bit fixed point numbers.  Signed 64.64-bit fixed point number is
 * basically a simple fraction whose numerator is signed 128-bit integer and
 * denominator is 2^64.  As long as denominator is always the same, there is no
 * need to store it, thus in Solidity signed 64.64-bit fixed point numbers are
 * represented by int128 type holding only the numerator.
 */
library ABDKMath64x64 {
    /*
     * Minimum value signed 64.64-bit fixed point number may have.
     */
    int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;

    /*
     * Maximum value signed 64.64-bit fixed point number may have.
     */
    int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    /**
     * Convert signed 256-bit integer number into signed 64.64-bit fixed point
     * number.  Revert on overflow.
     *
     * @param x signed 256-bit integer number
   * @return signed 64.64-bit fixed point number
   */
    function fromInt (int256 x) internal pure returns (int128) {
    unchecked {
        require (x >= -0x8000000000000000 && x <= 0x7FFFFFFFFFFFFFFF);
        return int128 (x << 64);
    }
    }

    /**
     * Convert signed 64.64 fixed point number into signed 64-bit integer number
     * rounding down.
     *
     * @param x signed 64.64-bit fixed point number
   * @return signed 64-bit integer number
   */
    function toInt (int128 x) internal pure returns (int64) {
    unchecked {
        return int64 (x >> 64);
    }
    }

    /**
     * Convert unsigned 256-bit integer number into signed 64.64-bit fixed point
     * number.  Revert on overflow.
     *
     * @param x unsigned 256-bit integer number
   * @return signed 64.64-bit fixed point number
   */
    function fromUInt (uint256 x) internal pure returns (int128) {
    unchecked {
        require (x <= 0x7FFFFFFFFFFFFFFF);
        return int128 (int256 (x << 64));
    }
    }

    /**
     * Convert signed 64.64 fixed point number into unsigned 64-bit integer
     * number rounding down.  Revert on underflow.
     *
     * @param x signed 64.64-bit fixed point number
   * @return unsigned 64-bit integer number
   */
    function toUInt (int128 x) internal pure returns (uint64) {
    unchecked {
        require (x >= 0);
        return uint64 (uint128 (x >> 64));
    }
    }

    /**
     * Convert signed 128.128 fixed point number into signed 64.64-bit fixed point
     * number rounding down.  Revert on overflow.
     *
     * @param x signed 128.128-bin fixed point number
   * @return signed 64.64-bit fixed point number
   */
    function from128x128 (int256 x) internal pure returns (int128) {
    unchecked {
        int256 result = x >> 64;
        require (result >= MIN_64x64 && result <= MAX_64x64);
        return int128 (result);
    }
    }

    /**
     * Convert signed 64.64 fixed point number into signed 128.128 fixed point
     * number.
     *
     * @param x signed 64.64-bit fixed point number
   * @return signed 128.128 fixed point number
   */
    function to128x128 (int128 x) internal pure returns (int256) {
    unchecked {
        return int256 (x) << 64;
    }
    }

    /**
     * Calculate x + y.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
    function add (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
        int256 result = int256(x) + y;
        require (result >= MIN_64x64 && result <= MAX_64x64);
        return int128 (result);
    }
    }

    /**
     * Calculate x - y.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
    function sub (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
        int256 result = int256(x) - y;
        require (result >= MIN_64x64 && result <= MAX_64x64);
        return int128 (result);
    }
    }

    /**
     * Calculate x * y rounding down.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
    function mul (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
        int256 result = int256(x) * y >> 64;
        require (result >= MIN_64x64 && result <= MAX_64x64);
        return int128 (result);
    }
    }

    /**
     * Calculate x * y rounding towards zero, where x is signed 64.64 fixed point
     * number and y is signed 256-bit integer number.  Revert on overflow.
     *
     * @param x signed 64.64 fixed point number
   * @param y signed 256-bit integer number
   * @return signed 256-bit integer number
   */
    function muli (int128 x, int256 y) internal pure returns (int256) {
    unchecked {
        if (x == MIN_64x64) {
            require (y >= -0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF &&
            y <= 0x1000000000000000000000000000000000000000000000000);
            return -y << 63;
        } else {
            bool negativeResult = false;
            if (x < 0) {
                x = -x;
                negativeResult = true;
            }
            if (y < 0) {
                y = -y; // We rely on overflow behavior here
                negativeResult = !negativeResult;
            }
            uint256 absoluteResult = mulu (x, uint256 (y));
            if (negativeResult) {
                require (absoluteResult <=
                    0x8000000000000000000000000000000000000000000000000000000000000000);
                return -int256 (absoluteResult); // We rely on overflow behavior here
            } else {
                require (absoluteResult <=
                    0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
                return int256 (absoluteResult);
            }
        }
    }
    }

    /**
     * Calculate x * y rounding down, where x is signed 64.64 fixed point number
     * and y is unsigned 256-bit integer number.  Revert on overflow.
     *
     * @param x signed 64.64 fixed point number
   * @param y unsigned 256-bit integer number
   * @return unsigned 256-bit integer number
   */
    function mulu (int128 x, uint256 y) internal pure returns (uint256) {
    unchecked {
        if (y == 0) return 0;

        require (x >= 0);

        uint256 lo = (uint256 (int256 (x)) * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >> 64;
        uint256 hi = uint256 (int256 (x)) * (y >> 128);

        require (hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        hi <<= 64;

        require (hi <=
            0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - lo);
        return hi + lo;
    }
    }

    /**
     * Calculate x / y rounding towards zero.  Revert on overflow or when y is
     * zero.
     *
     * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
    function div (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
        require (y != 0);
        int256 result = (int256 (x) << 64) / y;
        require (result >= MIN_64x64 && result <= MAX_64x64);
        return int128 (result);
    }
    }

    /**
     * Calculate x / y rounding towards zero, where x and y are signed 256-bit
     * integer numbers.  Revert on overflow or when y is zero.
     *
     * @param x signed 256-bit integer number
   * @param y signed 256-bit integer number
   * @return signed 64.64-bit fixed point number
   */
    function divi (int256 x, int256 y) internal pure returns (int128) {
    unchecked {
        require (y != 0);

        bool negativeResult = false;
        if (x < 0) {
            x = -x; // We rely on overflow behavior here
            negativeResult = true;
        }
        if (y < 0) {
            y = -y; // We rely on overflow behavior here
            negativeResult = !negativeResult;
        }
        uint128 absoluteResult = divuu (uint256 (x), uint256 (y));
        if (negativeResult) {
            require (absoluteResult <= 0x80000000000000000000000000000000);
            return -int128 (absoluteResult); // We rely on overflow behavior here
        } else {
            require (absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            return int128 (absoluteResult); // We rely on overflow behavior here
        }
    }
    }

    /**
     * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
     * integer numbers.  Revert on overflow or when y is zero.
     *
     * @param x unsigned 256-bit integer number
   * @param y unsigned 256-bit integer number
   * @return signed 64.64-bit fixed point number
   */
    function divu (uint256 x, uint256 y) internal pure returns (int128) {
    unchecked {
        require (y != 0);
        uint128 result = divuu (x, y);
        require (result <= uint128 (MAX_64x64));
        return int128 (result);
    }
    }

    /**
     * Calculate -x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
    function neg (int128 x) internal pure returns (int128) {
    unchecked {
        require (x != MIN_64x64);
        return -x;
    }
    }

    /**
     * Calculate |x|.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
    function abs (int128 x) internal pure returns (int128) {
    unchecked {
        require (x != MIN_64x64);
        return x < 0 ? -x : x;
    }
    }

    /**
     * Calculate 1 / x rounding towards zero.  Revert on overflow or when x is
     * zero.
     *
     * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
    function inv (int128 x) internal pure returns (int128) {
    unchecked {
        require (x != 0);
        int256 result = int256 (0x100000000000000000000000000000000) / x;
        require (result >= MIN_64x64 && result <= MAX_64x64);
        return int128 (result);
    }
    }

    /**
     * Calculate arithmetics average of x and y, i.e. (x + y) / 2 rounding down.
     *
     * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
    function avg (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
        return int128 ((int256 (x) + int256 (y)) >> 1);
    }
    }

    /**
     * Calculate geometric average of x and y, i.e. sqrt (x * y) rounding down.
     * Revert on overflow or in case x * y is negative.
     *
     * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
    function gavg (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
        int256 m = int256 (x) * int256 (y);
        require (m >= 0);
        require (m <
            0x4000000000000000000000000000000000000000000000000000000000000000);
        return int128 (sqrtu (uint256 (m)));
    }
    }

    /**
     * Calculate x^y assuming 0^0 is 1, where x is signed 64.64 fixed point number
     * and y is unsigned 256-bit integer number.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
   * @param y uint256 value
   * @return signed 64.64-bit fixed point number
   */
    function pow (int128 x, uint256 y) internal pure returns (int128) {
    unchecked {
        bool negative = x < 0 && y & 1 == 1;

        uint256 absX = uint128 (x < 0 ? -x : x);
        uint256 absResult;
        absResult = 0x100000000000000000000000000000000;

        if (absX <= 0x10000000000000000) {
            absX <<= 63;
            while (y != 0) {
                if (y & 0x1 != 0) {
                    absResult = absResult * absX >> 127;
                }
                absX = absX * absX >> 127;

                if (y & 0x2 != 0) {
                    absResult = absResult * absX >> 127;
                }
                absX = absX * absX >> 127;

                if (y & 0x4 != 0) {
                    absResult = absResult * absX >> 127;
                }
                absX = absX * absX >> 127;

                if (y & 0x8 != 0) {
                    absResult = absResult * absX >> 127;
                }
                absX = absX * absX >> 127;

                y >>= 4;
            }

            absResult >>= 64;
        } else {
            uint256 absXShift = 63;
            if (absX < 0x1000000000000000000000000) { absX <<= 32; absXShift -= 32; }
            if (absX < 0x10000000000000000000000000000) { absX <<= 16; absXShift -= 16; }
            if (absX < 0x1000000000000000000000000000000) { absX <<= 8; absXShift -= 8; }
            if (absX < 0x10000000000000000000000000000000) { absX <<= 4; absXShift -= 4; }
            if (absX < 0x40000000000000000000000000000000) { absX <<= 2; absXShift -= 2; }
            if (absX < 0x80000000000000000000000000000000) { absX <<= 1; absXShift -= 1; }

            uint256 resultShift = 0;
            while (y != 0) {
                require (absXShift < 64);

                if (y & 0x1 != 0) {
                    absResult = absResult * absX >> 127;
                    resultShift += absXShift;
                    if (absResult > 0x100000000000000000000000000000000) {
                        absResult >>= 1;
                        resultShift += 1;
                    }
                }
                absX = absX * absX >> 127;
                absXShift <<= 1;
                if (absX >= 0x100000000000000000000000000000000) {
                    absX >>= 1;
                    absXShift += 1;
                }

                y >>= 1;
            }

            require (resultShift < 64);
            absResult >>= 64 - resultShift;
        }
        int256 result = negative ? -int256 (absResult) : int256 (absResult);
        require (result >= MIN_64x64 && result <= MAX_64x64);
        return int128 (result);
    }
    }

    /**
     * Calculate sqrt (x) rounding down.  Revert if x < 0.
     *
     * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
    function sqrt (int128 x) internal pure returns (int128) {
    unchecked {
        require (x >= 0);
        return int128 (sqrtu (uint256 (int256 (x)) << 64));
    }
    }

    /**
     * Calculate binary logarithm of x.  Revert if x <= 0.
     *
     * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
    function log_2 (int128 x) internal pure returns (int128) {
    unchecked {
        require (x > 0);

        int256 msb = 0;
        int256 xc = x;
        if (xc >= 0x10000000000000000) { xc >>= 64; msb += 64; }
        if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
        if (xc >= 0x10000) { xc >>= 16; msb += 16; }
        if (xc >= 0x100) { xc >>= 8; msb += 8; }
        if (xc >= 0x10) { xc >>= 4; msb += 4; }
        if (xc >= 0x4) { xc >>= 2; msb += 2; }
        if (xc >= 0x2) msb += 1;  // No need to shift xc anymore

        int256 result = msb - 64 << 64;
        uint256 ux = uint256 (int256 (x)) << uint256 (127 - msb);
        for (int256 bit = 0x8000000000000000; bit > 0; bit >>= 1) {
            ux *= ux;
            uint256 b = ux >> 255;
            ux >>= 127 + b;
            result += bit * int256 (b);
        }

        return int128 (result);
    }
    }

    /**
     * Calculate natural logarithm of x.  Revert if x <= 0.
     *
     * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
    function ln (int128 x) internal pure returns (int128) {
    unchecked {
        require (x > 0);

        return int128 (int256 (
                uint256 (int256 (log_2 (x))) * 0xB17217F7D1CF79ABC9E3B39803F2F6AF >> 128));
    }
    }

    /**
     * Calculate binary exponent of x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
    function exp_2 (int128 x) internal pure returns (int128) {
    unchecked {
        require (x < 0x400000000000000000); // Overflow

        if (x < -0x400000000000000000) return 0; // Underflow

        uint256 result = 0x80000000000000000000000000000000;

        if (x & 0x8000000000000000 > 0)
            result = result * 0x16A09E667F3BCC908B2FB1366EA957D3E >> 128;
        if (x & 0x4000000000000000 > 0)
            result = result * 0x1306FE0A31B7152DE8D5A46305C85EDEC >> 128;
        if (x & 0x2000000000000000 > 0)
            result = result * 0x1172B83C7D517ADCDF7C8C50EB14A791F >> 128;
        if (x & 0x1000000000000000 > 0)
            result = result * 0x10B5586CF9890F6298B92B71842A98363 >> 128;
        if (x & 0x800000000000000 > 0)
            result = result * 0x1059B0D31585743AE7C548EB68CA417FD >> 128;
        if (x & 0x400000000000000 > 0)
            result = result * 0x102C9A3E778060EE6F7CACA4F7A29BDE8 >> 128;
        if (x & 0x200000000000000 > 0)
            result = result * 0x10163DA9FB33356D84A66AE336DCDFA3F >> 128;
        if (x & 0x100000000000000 > 0)
            result = result * 0x100B1AFA5ABCBED6129AB13EC11DC9543 >> 128;
        if (x & 0x80000000000000 > 0)
            result = result * 0x10058C86DA1C09EA1FF19D294CF2F679B >> 128;
        if (x & 0x40000000000000 > 0)
            result = result * 0x1002C605E2E8CEC506D21BFC89A23A00F >> 128;
        if (x & 0x20000000000000 > 0)
            result = result * 0x100162F3904051FA128BCA9C55C31E5DF >> 128;
        if (x & 0x10000000000000 > 0)
            result = result * 0x1000B175EFFDC76BA38E31671CA939725 >> 128;
        if (x & 0x8000000000000 > 0)
            result = result * 0x100058BA01FB9F96D6CACD4B180917C3D >> 128;
        if (x & 0x4000000000000 > 0)
            result = result * 0x10002C5CC37DA9491D0985C348C68E7B3 >> 128;
        if (x & 0x2000000000000 > 0)
            result = result * 0x1000162E525EE054754457D5995292026 >> 128;
        if (x & 0x1000000000000 > 0)
            result = result * 0x10000B17255775C040618BF4A4ADE83FC >> 128;
        if (x & 0x800000000000 > 0)
            result = result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB >> 128;
        if (x & 0x400000000000 > 0)
            result = result * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9 >> 128;
        if (x & 0x200000000000 > 0)
            result = result * 0x10000162E43F4F831060E02D839A9D16D >> 128;
        if (x & 0x100000000000 > 0)
            result = result * 0x100000B1721BCFC99D9F890EA06911763 >> 128;
        if (x & 0x80000000000 > 0)
            result = result * 0x10000058B90CF1E6D97F9CA14DBCC1628 >> 128;
        if (x & 0x40000000000 > 0)
            result = result * 0x1000002C5C863B73F016468F6BAC5CA2B >> 128;
        if (x & 0x20000000000 > 0)
            result = result * 0x100000162E430E5A18F6119E3C02282A5 >> 128;
        if (x & 0x10000000000 > 0)
            result = result * 0x1000000B1721835514B86E6D96EFD1BFE >> 128;
        if (x & 0x8000000000 > 0)
            result = result * 0x100000058B90C0B48C6BE5DF846C5B2EF >> 128;
        if (x & 0x4000000000 > 0)
            result = result * 0x10000002C5C8601CC6B9E94213C72737A >> 128;
        if (x & 0x2000000000 > 0)
            result = result * 0x1000000162E42FFF037DF38AA2B219F06 >> 128;
        if (x & 0x1000000000 > 0)
            result = result * 0x10000000B17217FBA9C739AA5819F44F9 >> 128;
        if (x & 0x800000000 > 0)
            result = result * 0x1000000058B90BFCDEE5ACD3C1CEDC823 >> 128;
        if (x & 0x400000000 > 0)
            result = result * 0x100000002C5C85FE31F35A6A30DA1BE50 >> 128;
        if (x & 0x200000000 > 0)
            result = result * 0x10000000162E42FF0999CE3541B9FFFCF >> 128;
        if (x & 0x100000000 > 0)
            result = result * 0x100000000B17217F80F4EF5AADDA45554 >> 128;
        if (x & 0x80000000 > 0)
            result = result * 0x10000000058B90BFBF8479BD5A81B51AD >> 128;
        if (x & 0x40000000 > 0)
            result = result * 0x1000000002C5C85FDF84BD62AE30A74CC >> 128;
        if (x & 0x20000000 > 0)
            result = result * 0x100000000162E42FEFB2FED257559BDAA >> 128;
        if (x & 0x10000000 > 0)
            result = result * 0x1000000000B17217F7D5A7716BBA4A9AE >> 128;
        if (x & 0x8000000 > 0)
            result = result * 0x100000000058B90BFBE9DDBAC5E109CCE >> 128;
        if (x & 0x4000000 > 0)
            result = result * 0x10000000002C5C85FDF4B15DE6F17EB0D >> 128;
        if (x & 0x2000000 > 0)
            result = result * 0x1000000000162E42FEFA494F1478FDE05 >> 128;
        if (x & 0x1000000 > 0)
            result = result * 0x10000000000B17217F7D20CF927C8E94C >> 128;
        if (x & 0x800000 > 0)
            result = result * 0x1000000000058B90BFBE8F71CB4E4B33D >> 128;
        if (x & 0x400000 > 0)
            result = result * 0x100000000002C5C85FDF477B662B26945 >> 128;
        if (x & 0x200000 > 0)
            result = result * 0x10000000000162E42FEFA3AE53369388C >> 128;
        if (x & 0x100000 > 0)
            result = result * 0x100000000000B17217F7D1D351A389D40 >> 128;
        if (x & 0x80000 > 0)
            result = result * 0x10000000000058B90BFBE8E8B2D3D4EDE >> 128;
        if (x & 0x40000 > 0)
            result = result * 0x1000000000002C5C85FDF4741BEA6E77E >> 128;
        if (x & 0x20000 > 0)
            result = result * 0x100000000000162E42FEFA39FE95583C2 >> 128;
        if (x & 0x10000 > 0)
            result = result * 0x1000000000000B17217F7D1CFB72B45E1 >> 128;
        if (x & 0x8000 > 0)
            result = result * 0x100000000000058B90BFBE8E7CC35C3F0 >> 128;
        if (x & 0x4000 > 0)
            result = result * 0x10000000000002C5C85FDF473E242EA38 >> 128;
        if (x & 0x2000 > 0)
            result = result * 0x1000000000000162E42FEFA39F02B772C >> 128;
        if (x & 0x1000 > 0)
            result = result * 0x10000000000000B17217F7D1CF7D83C1A >> 128;
        if (x & 0x800 > 0)
            result = result * 0x1000000000000058B90BFBE8E7BDCBE2E >> 128;
        if (x & 0x400 > 0)
            result = result * 0x100000000000002C5C85FDF473DEA871F >> 128;
        if (x & 0x200 > 0)
            result = result * 0x10000000000000162E42FEFA39EF44D91 >> 128;
        if (x & 0x100 > 0)
            result = result * 0x100000000000000B17217F7D1CF79E949 >> 128;
        if (x & 0x80 > 0)
            result = result * 0x10000000000000058B90BFBE8E7BCE544 >> 128;
        if (x & 0x40 > 0)
            result = result * 0x1000000000000002C5C85FDF473DE6ECA >> 128;
        if (x & 0x20 > 0)
            result = result * 0x100000000000000162E42FEFA39EF366F >> 128;
        if (x & 0x10 > 0)
            result = result * 0x1000000000000000B17217F7D1CF79AFA >> 128;
        if (x & 0x8 > 0)
            result = result * 0x100000000000000058B90BFBE8E7BCD6D >> 128;
        if (x & 0x4 > 0)
            result = result * 0x10000000000000002C5C85FDF473DE6B2 >> 128;
        if (x & 0x2 > 0)
            result = result * 0x1000000000000000162E42FEFA39EF358 >> 128;
        if (x & 0x1 > 0)
            result = result * 0x10000000000000000B17217F7D1CF79AB >> 128;

        result >>= uint256 (int256 (63 - (x >> 64)));
        require (result <= uint256 (int256 (MAX_64x64)));

        return int128 (int256 (result));
    }
    }

    /**
     * Calculate natural exponent of x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
    function exp (int128 x) internal pure returns (int128) {
    unchecked {
        require (x < 0x400000000000000000); // Overflow

        if (x < -0x400000000000000000) return 0; // Underflow

        return exp_2 (
            int128 (int256 (x) * 0x171547652B82FE1777D0FFDA0D23A7D12 >> 128));
    }
    }

    /**
     * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
     * integer numbers.  Revert on overflow or when y is zero.
     *
     * @param x unsigned 256-bit integer number
   * @param y unsigned 256-bit integer number
   * @return unsigned 64.64-bit fixed point number
   */
    function divuu (uint256 x, uint256 y) private pure returns (uint128) {
    unchecked {
        require (y != 0);

        uint256 result;

        if (x <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            result = (x << 64) / y;
        else {
            uint256 msb = 192;
            uint256 xc = x >> 192;
            if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
            if (xc >= 0x10000) { xc >>= 16; msb += 16; }
            if (xc >= 0x100) { xc >>= 8; msb += 8; }
            if (xc >= 0x10) { xc >>= 4; msb += 4; }
            if (xc >= 0x4) { xc >>= 2; msb += 2; }
            if (xc >= 0x2) msb += 1;  // No need to shift xc anymore

            result = (x << 255 - msb) / ((y - 1 >> msb - 191) + 1);
            require (result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

            uint256 hi = result * (y >> 128);
            uint256 lo = result * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

            uint256 xh = x >> 192;
            uint256 xl = x << 64;

            if (xl < lo) xh -= 1;
            xl -= lo; // We rely on overflow behavior here
            lo = hi << 128;
            if (xl < lo) xh -= 1;
            xl -= lo; // We rely on overflow behavior here

            assert (xh == hi >> 128);

            result += xl / y;
        }

        require (result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        return uint128 (result);
    }
    }

    /**
     * Calculate sqrt (x) rounding down, where x is unsigned 256-bit integer
     * number.
     *
     * @param x unsigned 256-bit integer number
   * @return unsigned 128-bit integer number
   */
    function sqrtu (uint256 x) private pure returns (uint128) {
    unchecked {
        if (x == 0) return 0;
        else {
            uint256 xx = x;
            uint256 r = 1;
            if (xx >= 0x100000000000000000000000000000000) { xx >>= 128; r <<= 64; }
            if (xx >= 0x10000000000000000) { xx >>= 64; r <<= 32; }
            if (xx >= 0x100000000) { xx >>= 32; r <<= 16; }
            if (xx >= 0x10000) { xx >>= 16; r <<= 8; }
            if (xx >= 0x100) { xx >>= 8; r <<= 4; }
            if (xx >= 0x10) { xx >>= 4; r <<= 2; }
            if (xx >= 0x8) { r <<= 1; }
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1; // Seven iterations should be enough
            uint256 r1 = x / r;
            return uint128 (r < r1 ? r : r1);
        }
    }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStakingProtocol {
    function pendingFull() external view returns (uint256 _rewardAllowedToClaim, uint256 _rewardInDelay);

    function runStaking() external;
    function disableStaking() external;
    function rewardAnnulation() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStablecoin {
    function divisor() external view returns (uint256);
    function mint(address to, uint value) external returns (bool);
    function burn(address to, uint value) external returns (bool);
    function ccr() external view returns (uint256);
    function checkCcrEvents() external view returns (bool);
    function runCcrEvents() external;
}

// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOracleHistory {
    function updateAllWithoutHistory() external ;
    function updateHistory(address _token) external ;
    function consultByHistory(address token, uint256 timeFrom, uint256 timeTo) external view returns (uint256);
    function consult(address _base, address  _money , uint256 _amountIn) external  view returns (uint256 _amountOut);
    function consult(address _token, uint256 _amountIn)  external view returns (uint256 _amountOut);
    function r_consult(address _base, uint256 _amountIn) external view returns (uint256 _amountOut);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBalancesLikeERC1155.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC721MetadataUpgradeable.sol";

interface INFTSmart is IBalancesLikeERC1155, IERC721Upgradeable, IERC721MetadataUpgradeable {

    function getCreatedAt(uint256 tokenId) external view returns (uint256);
    function getLifeTime(uint256 tokenId) external view returns (uint256);
    function getRare(uint256 tokenId) external view returns (uint256);
    function getLevel(uint256 tokenId) external view returns (uint256);

    function getBoostCoefficient(uint256 tokenId) external view returns (uint256);
    function getSeparatedBoostCoefficients(uint256 tokenId) external view returns (uint256 levelBoostCoefficient, uint256 rareBoostCoefficient);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./INFTBondManager.sol";
import "./IAssetsManagerWithCaps.sol";

interface INFTBondManagerFull is
   INFTBondManager,
   IAssetsManagerWithCaps
{}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface INFTBondManager {

   function currencyBalancesList(uint256 tokenId) external view returns(address[] memory, uint256[] memory);

   function _NFTBond() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBalancesLikeERC1155.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC721MetadataUpgradeable.sol";

interface INFTBond is IBalancesLikeERC1155, IERC721Upgradeable, IERC721MetadataUpgradeable {
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

interface IBalancesLikeERC1155
{
    event TransferSingle(uint256 indexed tokenIdFrom, uint256 indexed tokenIdTo, uint256 key, uint256 value);

    function tokensCount() view external returns(uint256);

    function burn(uint256 tokenId) external ;
    function mint(address to) external returns (uint256);

    function get(uint256 tokenId, address parameter) view external returns(uint256 balance);
    function add(uint256 tokenId, address parameter, uint256 value) external;
    function set(uint256 tokenId, address parameter, uint256 value) external;
    function sub(uint256 tokenId, address parameter, uint256 value) external;

    function get(uint256 tokenId, uint256 parameter) view external returns(uint256 balance);
    function add(uint256 tokenId, uint256 parameter, uint256 value) external;
    function set(uint256 tokenId, uint256 parameter, uint256 value) external;
    function sub(uint256 tokenId, uint256 parameter, uint256 value) external;
 
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAssetsManagerWithRewardCoefficient {
   function getAssetWithRewardCoefficients() external view returns (address[] memory, uint256[] memory);
   function getRewardCoefficient(address _asset) external view returns (uint256);

   function assetsManagerAddAsset(address _asset, uint256 _rewardCoefficientInPercent) external;
   function assetsManagerEditAssetRewardCoefficient(address _asset, uint256 _rewardCoefficientInPercent) external;
   function assetsManagerRemoveAsset(address _asset) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAssetsManagerWithCaps {
   function getAssetWithCaps() external view returns (address[] memory, uint256[] memory);
   function getAssetCap(address _asset) external view returns (uint256);
   function getAssetBalance(address _asset) external view returns (uint256);

   function addAsset(address _asset, uint256 _cap) external;
   function setAssetCap(address _asset, uint256 _cap) external;
   function removeAsset(address _asset) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract SuspensionPeriods
{

////////////////////////////////////////// structs

    struct SuspensionPeriod {
        uint256 suspensionPeriodBegin;
        uint256 suspensionPeriodEnd;
    }

////////////////////////////////////////// fields definition

    SuspensionPeriod[] suspensionPeriods;

    /** see https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps */
    uint256[49] private __gap;

////////////////////////////////////////// methods for manage stop periods

    function _startNewSuspensionPeriod(uint256 _suspensionPeriodBegin)
        internal
    {
        require(_suspensionPeriodBegin <= block.timestamp, 'UsdHistoryConsultant::_startNewSuspensionPeriod - incorrect value');

        // case: first interaction
        if (suspensionPeriods.length == 0) {
            SuspensionPeriod memory newSuspensionPeriod = SuspensionPeriod({
                suspensionPeriodBegin: _suspensionPeriodBegin,
                suspensionPeriodEnd: 0
            });
            suspensionPeriods.push(newSuspensionPeriod);
            return;
        }

        for (uint256 i = suspensionPeriods.length; i > 0;) {
            --i;
            SuspensionPeriod storage lastSuspensionPeriod = suspensionPeriods[i];
            if (lastSuspensionPeriod.suspensionPeriodBegin >= _suspensionPeriodBegin) {
                suspensionPeriods.pop();
                continue;
            }
            if (lastSuspensionPeriod.suspensionPeriodEnd == 0) {
                break;
            }
            if (lastSuspensionPeriod.suspensionPeriodEnd > _suspensionPeriodBegin) {
                lastSuspensionPeriod.suspensionPeriodEnd = 0;
                break;
            }
            SuspensionPeriod memory newSuspensionPeriod = SuspensionPeriod({
                suspensionPeriodBegin: _suspensionPeriodBegin,
                suspensionPeriodEnd: 0
            });
            suspensionPeriods.push(newSuspensionPeriod);
        }
    }

    function _finishLastSuspensionPeriod()
        internal
    {
        if (suspensionPeriods.length == 0) {
            return;
        }
        SuspensionPeriod storage lastSuspensionPeriod = suspensionPeriods[suspensionPeriods.length - 1];
        if (lastSuspensionPeriod.suspensionPeriodBegin == block.timestamp) {
            suspensionPeriods.pop();
        } else {
            lastSuspensionPeriod.suspensionPeriodEnd = block.timestamp;
        }
    }

    function _calculateNonSuspensionPeriod(uint256 _currentPeriodBegin, uint256 _currentPeriodEnd)
        internal
        view
        returns(uint256)
    {
        if (_currentPeriodBegin ==  _currentPeriodEnd) {
            return 0;
        }
        require(_currentPeriodBegin < _currentPeriodEnd, '_calculateNonSuspensionPeriod - incorrect period');
        uint256 excessPeriod = 0;

        for (uint256 i = suspensionPeriods.length; i > 0;) {
            --i;
            SuspensionPeriod storage lastSuspensionPeriod = suspensionPeriods[i];
            uint256 currentSuspensionPeriodBegin = lastSuspensionPeriod.suspensionPeriodBegin;
            uint256 currentSuspensionPeriodEnd = lastSuspensionPeriod.suspensionPeriodEnd;
            if (currentSuspensionPeriodEnd == 0) {
                currentSuspensionPeriodEnd = _currentPeriodEnd;
            }

            if (currentSuspensionPeriodEnd < _currentPeriodBegin) {
                break;
            }
            if (currentSuspensionPeriodBegin > _currentPeriodEnd) {
                continue;
            }

            if (currentSuspensionPeriodEnd > _currentPeriodEnd) {
                _currentPeriodEnd = currentSuspensionPeriodBegin;
            }
            if (currentSuspensionPeriodBegin < _currentPeriodBegin) {
                _currentPeriodBegin = currentSuspensionPeriodEnd;
            }


            if (_currentPeriodEnd <= _currentPeriodBegin) {
                return 0;
            }

            if (
                _currentPeriodBegin < currentSuspensionPeriodBegin &&
                _currentPeriodEnd >= currentSuspensionPeriodEnd
            ) {
                excessPeriod += currentSuspensionPeriodEnd - currentSuspensionPeriodBegin;
            }

        }

        return _currentPeriodEnd - _currentPeriodBegin - excessPeriod;
    }

    function showSuspensionPeriods()
        public
        view
        returns (uint256[] memory periodBegins, uint256[] memory periodEnds)
    {
        uint256 i = suspensionPeriods.length;
        periodBegins = new uint256[](i);
        periodEnds = new uint256[](i);
        for (;i > 0;) {
            --i;
            SuspensionPeriod memory suspensionPeriod = suspensionPeriods[i];

            periodBegins[i] = suspensionPeriod.suspensionPeriodBegin;
            periodEnds[i] = suspensionPeriod.suspensionPeriodEnd;
        }

        return (periodBegins, periodEnds);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AssetsManager.sol";
import "../../libs/interfaces/INFTBond.sol";
import "../../libs/interfaces/IOracleHistory.sol";
import "../../libs/math/DoubleMath.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "../../libs/interfaces/INFTBondManagerFull.sol";
import "../../libs/interfaces/INFTSmart.sol";
import "../../libs/interfaces/IStablecoin.sol";

abstract contract StakingStorage is
    AssetsManager,
    ReentrancyGuardUpgradeable
{
    using SafeERC20Upgradeable for IERC20MetadataUpgradeable;
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.AddressToUintMap;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using AddressToUintMapAdditionalMethods for EnumerableMapUpgradeable.AddressToUintMap;

////////////////////////////////////////// initialize

    function __init_StakingStorage(
        address _stablecoin,
        address _oracle,
        address _nftBondManager,
        address _nftSmart
    ) internal {
        stablecoin = _stablecoin;
        oracle = _oracle;
        nftBondManager = _nftBondManager;
        nftSmart = _nftSmart;
        stakingStartDate = block.timestamp;
        stakingLastUpdateDate = block.timestamp;
    }

////////////////////////////////////////// fields definition

    address public oracle;
    address public nftBondManager;
    address public nftSmart;

    // Account address => rbis/stablecoin/lp_token => amount
    mapping (address => EnumerableMapUpgradeable.AddressToUintMap) internal actualAccountBalancesInERC20;
    // Account address => NFT Bond tokenId[]
    mapping (address => EnumerableSetUpgradeable.UintSet) internal actualAccountBondNFTs;
    // Account address => NFT Smart tokenId
    EnumerableMapUpgradeable.AddressToUintMap internal actualAccountNftSmart;

    struct AccountPeriodInfo {
        uint256 timeBegin;
        EnumerableMapUpgradeable.AddressToUintMap assetsAmounts; // rbis/stablecoin/lp_token/flat_Nft_Obligation_value
        uint256 smartNFTCreatedAt;
        uint256 smartNFTLastTime;
        uint256 smartNFTBoostCoefficient;
        uint256 amountInBase;
        bool isCalculated;
        bool isWithdraw;
    }

    // Account address => lastPeriodNumber
    mapping (address => uint256) internal accountLastPeriodNumber;
    // Account address => periodNumber => AccountPeriodInfo
    mapping (address => mapping (uint256 => AccountPeriodInfo)) internal accountPeriodDataByPeriodNumber;

    uint256 internal stakingStartDate;
    uint256 private stakingLastUpdateDate;
    uint256 internal approximateFullBalanceInBase;
    uint256 internal approximateFullNFTSmartBoostCoeficient;
    uint256 internal approximateFullNFTSmartBoostCreatedAt;
    uint256 internal approximateFullNFTSmartBoostLifeTime;
    EnumerableMapUpgradeable.AddressToUintMap private fullAssetsAmounts;

    address public stablecoin;
    /** see https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps */
    uint256[34] private __gap;

////////////////////////////////////////// view methods

    function getAccountBalances(address _account)
        public
        view
        returns (address[] memory assets, uint256[] memory balances, uint256[] memory nftBonds, bool nftSmartExists, uint256 nftSmartId)
    {
        (assets, balances) = actualAccountBalancesInERC20[_account].getKeyValueList();
        nftBonds = actualAccountBondNFTs[_account].values();
        (nftSmartExists, nftSmartId) = actualAccountNftSmart.tryGet(_account);
    }

    function getFlatAccountBalance(address _account)
        public
        view
        returns (address[] memory assets, uint256[] memory balances)
    {
        AccountPeriodInfo storage _accountPeriodInfo = accountPeriodDataByPeriodNumber[_account][accountLastPeriodNumber[_account]];
        (assets, balances) = _accountPeriodInfo.assetsAmounts.getKeyValueList();
    }

    function getOracle()
        internal
        view
        returns (IOracleHistory)
    {
        return IOracleHistory(oracle);
    }

    function getNFTBondManager()
        internal
        view
        returns (INFTBondManagerFull)
    {
        return INFTBondManagerFull(nftBondManager);
    }

    function getNFTBond()
        internal
        view
        returns (INFTBond)
    {
        return INFTBond(getNFTBondManager()._NFTBond());
    }

    function getNFTSmart()
        internal
        view
        returns (INFTSmart)
    {
        return INFTSmart(nftSmart);
    }

    function __getAmountInBase(
        AccountPeriodInfo storage _accountPeriodInfo
    )
        internal
        view
        returns(uint256 _amountInBase)
    {
        if (_accountPeriodInfo.timeBegin == 0) {
            return 0;
        }
        if (_accountPeriodInfo.isCalculated) {
            return _accountPeriodInfo.amountInBase;
        }
        uint256 timeEnd = block.timestamp;

        _amountInBase = 0;
        for (uint256 i = 0; i < _accountPeriodInfo.assetsAmounts.length(); ++i) {
            (address _asset, uint256 _amount) = _accountPeriodInfo.assetsAmounts.at(i);
            _amountInBase += getOracle().consultByHistory(_asset, _accountPeriodInfo.timeBegin, timeEnd)
                * _amount
                * __getRewardCoefficientForAmountInBase(_asset)
                / PERCENT
                / 10 ** IERC20MetadataUpgradeable(_asset).decimals()
            ;
        }

        DoubleMath.Double memory smartNFTBoostCoefficient = __getSmartNFTBoostCoefficientForPeriod(_accountPeriodInfo, timeEnd);
        if (smartNFTBoostCoefficient.mantissa != 0) {
            _amountInBase = DoubleMath.mul_(_amountInBase, smartNFTBoostCoefficient);
        }
    }

    function __getSmartNFTBoostCoefficientForPeriod(
        AccountPeriodInfo storage _accountPeriodInfo,
        uint256 timeEnd
    )
        private
        view
        returns(DoubleMath.Double memory)
    {
        require(timeEnd >= _accountPeriodInfo.timeBegin, '__getSmartNFTBoostCoefficientForPeriod::incorrect timeEnd');
        if (_accountPeriodInfo.smartNFTCreatedAt == 0) {
            return DoubleMath.Double({mantissa: 0});
        }
        if (_accountPeriodInfo.smartNFTLastTime <= _accountPeriodInfo.timeBegin) {
            return DoubleMath.Double({mantissa: 0});
        }

        uint256 smartNFTBegin = _accountPeriodInfo.smartNFTCreatedAt > _accountPeriodInfo.timeBegin
            ? _accountPeriodInfo.smartNFTCreatedAt
            : _accountPeriodInfo.timeBegin;

        uint256 smartNFTEnd = _accountPeriodInfo.smartNFTLastTime <= block.timestamp
            ? _accountPeriodInfo.smartNFTLastTime
            : block.timestamp;

        if (smartNFTBegin == _accountPeriodInfo.timeBegin && smartNFTEnd == block.timestamp) {
            return DoubleMath.fraction(_accountPeriodInfo.smartNFTBoostCoefficient, PERCENT);
        }

        uint256 periodFull = block.timestamp - smartNFTBegin;
        if (periodFull == 0) {
            return DoubleMath.Double({mantissa: 0});
        }

        uint256 periodWithBoost = smartNFTEnd - smartNFTBegin;
        uint256 periodWithoutBoost = periodFull - periodWithBoost;

        return DoubleMath.fraction(periodWithBoost * _accountPeriodInfo.smartNFTBoostCoefficient + periodWithoutBoost * PERCENT, periodFull * PERCENT);
    }

////////////////////////////////////////// fullBalance


    function getApproximateFullBalanceInBase()
        public
        view
        returns(uint256)
    {
        uint256 currentFullBalanceInBase = __getFullAmountInBase();

        uint256 cumulativePreviousFullBalance = (stakingLastUpdateDate - stakingStartDate) * approximateFullBalanceInBase;
        uint256 cumulativeCurrentFullBalance = (block.timestamp - stakingLastUpdateDate) * currentFullBalanceInBase;

        return (cumulativePreviousFullBalance + cumulativeCurrentFullBalance) / (block.timestamp - stakingStartDate);
    }

    function __recalculateFullBalance(
        address _account
    )
        internal
    {
        AccountPeriodInfo storage _previousAccountPeriodInfo = accountPeriodDataByPeriodNumber[_account][accountLastPeriodNumber[_account] - 1];
        AccountPeriodInfo storage _currentAccountPeriodInfo = accountPeriodDataByPeriodNumber[_account][accountLastPeriodNumber[_account]];

        uint256 count = assetWithRewardCoefficients.length();
        for (uint256 i = 0; i < count; ++i) {
            (address asset, uint256 rewardCoefficient) = assetWithRewardCoefficients.at(i);
            if (rewardCoefficient == 0) {
                continue;
            }
            (,uint256 previousAmount) = _previousAccountPeriodInfo.assetsAmounts.tryGet(asset);
            (,uint256 currentAmount) = _currentAccountPeriodInfo.assetsAmounts.tryGet(asset);
            fullAssetsAmounts.add(asset, currentAmount);
            fullAssetsAmounts.sub(asset, previousAmount);
            getOracle().updateHistory(asset);
        }

        approximateFullBalanceInBase = getApproximateFullBalanceInBase();
        stakingLastUpdateDate = block.timestamp;
    }

    function __getFullAmountInBase()
        internal
        view
        returns(uint256 _amountInBase)
    {
        _amountInBase = 0;
        for (uint256 i = 0; i < fullAssetsAmounts.length(); ++i) {
            (address _asset, uint256 _amount) = fullAssetsAmounts.at(i);

            _amountInBase += getOracle().consultByHistory(_asset, stakingLastUpdateDate, block.timestamp)
                * _amount
                * __getRewardCoefficientForAmountInBase(_asset)
                / PERCENT
                / 10 ** IERC20MetadataUpgradeable(_asset).decimals()
            ;
        }
    }

////////////////////////////////////////// deposit/withdraw

    function __UpdateRates(EnumerableMapUpgradeable.AddressToUintMap storage assetsAmounts)
        private
    {
        address[] memory _assets = assetsAmounts.getUnsortedKeys();
        for (uint256 i = 0; i < _assets.length; ++i) {
            getOracle().updateHistory(_assets[i]);
        }
    }

    function __createNewPeriod(
        address _account,
        bool _isWithdraw
    )
        internal
        nonReentrant
        returns (AccountPeriodInfo storage currentPeriod)
    {
        AccountPeriodInfo storage previousPeriod = accountPeriodDataByPeriodNumber[_account][accountLastPeriodNumber[_account]];
        // close previous period
        __UpdateRates(previousPeriod.assetsAmounts);

        previousPeriod.amountInBase = __getAmountInBase(previousPeriod);
        previousPeriod.isCalculated = true;

        // create new period
        ++accountLastPeriodNumber[_account];
        currentPeriod = accountPeriodDataByPeriodNumber[_account][accountLastPeriodNumber[_account]];
        currentPeriod.timeBegin = block.timestamp;
        currentPeriod.isWithdraw = _isWithdraw;

        currentPeriod.smartNFTBoostCoefficient = previousPeriod.smartNFTBoostCoefficient;
        currentPeriod.smartNFTCreatedAt = previousPeriod.smartNFTCreatedAt;
        currentPeriod.smartNFTLastTime = previousPeriod.smartNFTLastTime;

        currentPeriod.assetsAmounts.cloneFrom(previousPeriod.assetsAmounts);
    }

    function __deposit(
        address _account,
        address[] memory _assets,
        uint256[] memory _amounts,
        uint256[] memory _bondNFTs,
        bool _needDepositSmartNFT,
        uint256 _smartNFT
    ) internal {
        require(_assets.length == _amounts.length, 'different length in assets and amounts');

        AccountPeriodInfo storage currentPeriod = __createNewPeriod(_account, false);

        if (_needDepositSmartNFT) {
            require(actualAccountNftSmart.contains(_account) == false, 'only one SmartNFT allowed in staking');
            getNFTSmart().safeTransferFrom(_account, address(this), _smartNFT);
            actualAccountNftSmart.set(_account, _smartNFT);

            currentPeriod.smartNFTCreatedAt = getNFTSmart().getCreatedAt(_smartNFT);
            currentPeriod.smartNFTLastTime = getNFTSmart().getLifeTime(_smartNFT);
            currentPeriod.smartNFTBoostCoefficient = getNFTSmart().getBoostCoefficient(_smartNFT);
        }

        for (uint256 i = 0; i < _assets.length; ++i) {
            address currentAsset = _assets[i];
            uint256 currentAmount = _amounts[i];

            __AssertAssetIsAllowed(currentAsset);

            uint256 balanceBefore = IERC20MetadataUpgradeable(currentAsset).balanceOf(address(this));
            IERC20MetadataUpgradeable(currentAsset).safeTransferFrom(_account, address(this), currentAmount);
            currentAmount = IERC20MetadataUpgradeable(currentAsset).balanceOf(address(this)) - balanceBefore;

            if (currentAsset == stablecoin) {
                currentAmount = (IStablecoin(stablecoin).divisor() * currentAmount);
            }
            actualAccountBalancesInERC20[_account].add(currentAsset, currentAmount);
            currentPeriod.assetsAmounts.add(currentAsset, currentAmount);
        }

        for (uint256 i = 0; i < _bondNFTs.length; ++i) {
            actualAccountBondNFTs[_account].add(_bondNFTs[i]);
            getNFTBond().safeTransferFrom(_account, address(this), _bondNFTs[i]);

            (address[] memory _assetsFromNFTBond, uint256[] memory _amountsFromNFTBond) = getNFTBondManager().currencyBalancesList(_bondNFTs[i]);

            for (uint256 j = 0; j < _assetsFromNFTBond.length; ++j) {
                currentPeriod.assetsAmounts.add(_assetsFromNFTBond[j], _amountsFromNFTBond[j]);
            }
        }

        __recalculateFullBalance(_account);
    }

    function __withdraw(
        address _account,
        address[] memory _assets,
        uint256[] memory _amounts,
        uint256[] memory _bondNFTs,
        bool _needWithdrawSmartNFT
    ) internal {
        require(_assets.length == _amounts.length, 'different length in assets and amounts');

        AccountPeriodInfo storage currentPeriod = __createNewPeriod(_account, true); // todo возможно AccountPeriodInfo нужно вписывать

        if (_needWithdrawSmartNFT) {
            require(actualAccountNftSmart.contains(_account) == true, 'Current account don`t have SmartNFT in staking');
            uint256 _smartNFT = actualAccountNftSmart.get(_account);
            getNFTSmart().safeTransferFrom(address(this), _account, _smartNFT);
            actualAccountNftSmart.remove(_account);

            currentPeriod.smartNFTCreatedAt = 0;
            currentPeriod.smartNFTLastTime = 0;
            currentPeriod.smartNFTBoostCoefficient = 0;
        }

        for (uint256 i = 0; i < _assets.length; ++i) {
            address currentAsset = _assets[i];
            uint256 currentAmount = _amounts[i];

            __AssertAssetIsAllowed(currentAsset);
            IERC20MetadataUpgradeable(currentAsset).safeTransfer(_account, currentAmount);

            if (currentAsset == stablecoin) {
                currentAmount = (IStablecoin(stablecoin).divisor() * currentAmount);
            }
            actualAccountBalancesInERC20[_account].sub(currentAsset, currentAmount, 'Balance not enough!');
            currentPeriod.assetsAmounts.sub(currentAsset, currentAmount);
        }

        for (uint256 i = 0; i < _bondNFTs.length; ++i) {
            bool _tokenExist = actualAccountBondNFTs[_account].remove(_bondNFTs[i]);
            require(_tokenExist, "StakingStorage::__withdraw - only NFTBond token owner");

            getNFTBond().safeTransferFrom(address(this), _account, _bondNFTs[i]);

            (address[] memory _assetsFromNFTBond, uint256[] memory _amountsFromNFTBond) = getNFTBondManager().currencyBalancesList(_bondNFTs[i]);

            for (uint256 j = 0; j < _assetsFromNFTBond.length; ++j) {
                currentPeriod.assetsAmounts.sub(_assetsFromNFTBond[j], _amountsFromNFTBond[j]);
            }
        }

        if (_assets.length == 0 && _bondNFTs.length == 0) {
            currentPeriod.isWithdraw = false;
        }
        __recalculateFullBalance(_account);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../libs/math/CompoundPercent.sol";
import "../../libs/math/DoubleMath.sol";
import "./StakingStorage.sol";
import "./SuspensionPeriods.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

abstract contract PendingCalculator is
    StakingStorage,
    SuspensionPeriods
{
    using StringsUpgradeable for uint256;
    using DoubleMath for DoubleMath.Double;

////////////////////////////////////////// initialize

    function __init_PendingCalculator(
        uint256 _rewardDelayPeriod,
        uint256 _baseRewardInPercent,
        uint256 _timedRewardInPercent,
        uint256 _timedRewardPeriod
    ) internal {
        rewardDelayPeriod = _rewardDelayPeriod;
        baseRewardInPercent = _baseRewardInPercent;
        timedRewardInPercent = _timedRewardInPercent;
        timedRewardPeriod = _timedRewardPeriod;
        claimedTotal = 0;
    }

////////////////////////////////////////// fields definition

    uint256 public rewardDelayPeriod;
    uint256 public baseRewardInPercent;
    uint256 public timedRewardInPercent;
    uint256 public timedRewardPeriod;

    // Account address => last Claim Time = claim.times - delay
    mapping (address => uint256) internal accountLastClaimTime;
    uint256 public claimedTotal;

    /** see https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps */
    uint256[43] private __gap;

////////////////////////////////////////// methods for full balance

    function __calculatePendingFull()
        internal
        view
        returns (uint256 _rewardAllowedToClaim, uint256 _rewardInDelay)
    {
        uint256 approximateFullBalanceInBase = getApproximateFullBalanceInBase();
        uint256 _period = _calculateNonSuspensionPeriod(stakingStartDate, block.timestamp);
        DoubleMath.Double memory _totalPercent = DoubleMath.newDouble(baseRewardInPercent + timedRewardInPercent);

        _rewardAllowedToClaim = 0;
        _rewardInDelay = CompoundPercent.compound(approximateFullBalanceInBase, _totalPercent, _period);

        if (rewardDelayPeriod >= _period) {
            return (_rewardAllowedToClaim, _rewardInDelay);
        }

        _rewardAllowedToClaim = CompoundPercent.compound(approximateFullBalanceInBase, _totalPercent, _period - rewardDelayPeriod);
        _rewardInDelay -= _rewardAllowedToClaim;
        _rewardAllowedToClaim -= claimedTotal;

        return (_rewardAllowedToClaim, _rewardInDelay);
    }

////////////////////////////////////////// methods for calculate individual pending

    function __calculatePendingForView(address _account)
        internal
        view
        returns (uint256 _rewardAllowedToClaim, uint256 _rewardInDelay)
    {
        _rewardAllowedToClaim = 0;
        _rewardInDelay = 0;

        (
            uint256 _cumulativeFullBalance,
            uint256 _cumulativeFullPercent,
            uint256 _cumulativeAvailableBalance,
            uint256 _cumulativeAvailablePercent,
            uint256 _periodBegin
        ) = __calculateCumulativeValuesForView(_account);
        if (_cumulativeFullBalance == 0) {
            return (_rewardAllowedToClaim, _rewardInDelay);
        }
        uint256 _nonSuspensionPeriodFull = _calculateNonSuspensionPeriod(_periodBegin, block.timestamp);
        if (_nonSuspensionPeriodFull == 0) {
            return (_rewardAllowedToClaim, _rewardInDelay);
        }

        {
            uint256 _periodFull = block.timestamp - _periodBegin;
            uint256 _medianOfBalanceFull = _cumulativeFullBalance / _periodFull;
            DoubleMath.Double memory _medianOfPercentFull = DoubleMath.fraction(_cumulativeFullPercent, _nonSuspensionPeriodFull).add_(baseRewardInPercent);

            _rewardInDelay = CompoundPercent.compound(_medianOfBalanceFull, _medianOfPercentFull, _nonSuspensionPeriodFull); // _compoundInterestOfFull
        }


        if (rewardDelayPeriod >= _nonSuspensionPeriodFull) {
            return (_rewardAllowedToClaim, _rewardInDelay);
        }

        {
            uint256 _periodAllowedToClaim = block.timestamp - _periodBegin - rewardDelayPeriod;
            uint256 _nonSuspensionPeriodAllowedToClaim = _calculateNonSuspensionPeriod(_periodBegin, block.timestamp - rewardDelayPeriod);

            uint256 _medianOfBalanceAllowedToClaim = _cumulativeAvailableBalance / _periodAllowedToClaim;
            DoubleMath.Double memory _medianOfPercentAllowedToClaim = DoubleMath.fraction(_cumulativeAvailablePercent, _nonSuspensionPeriodAllowedToClaim).add_(baseRewardInPercent);

            _rewardAllowedToClaim = CompoundPercent.compound(_medianOfBalanceAllowedToClaim, _medianOfPercentAllowedToClaim, _nonSuspensionPeriodAllowedToClaim); // _compoundInterestOfAvailable
        }

        require(_rewardInDelay >= _rewardAllowedToClaim,
            string.concat(
                '; _rewardInDelay: ', _rewardInDelay.toString(),
                '; _rewardAllowedToClaim: ', _rewardAllowedToClaim.toString(),
                ''
            )
        );
        _rewardInDelay -= _rewardAllowedToClaim;

        return (_rewardAllowedToClaim, _rewardInDelay);
    }

    function __calculateCumulativeValuesForView(address _account)
        private
        view
        returns (
            uint256 _cumulativeFullBalance,
            uint256 _cumulativeFullPercent,
            uint256 _cumulativeAvailableBalance,
            uint256 _cumulativeAvailablePercent,
            uint256 _periodBegin
        )
    {
        _cumulativeFullBalance = 0;
        _cumulativeFullPercent = 0;
        _cumulativeAvailableBalance = 0;
        _cumulativeAvailablePercent = 0;
        _periodBegin = 0;
        uint256 _periodAvailableEnd = block.timestamp - rewardDelayPeriod;

        uint256 _periodEnd = block.timestamp;
        uint256 _timedRewardPeriodEnd = block.timestamp;

        bool _calculationOfCumulativeAvailableBalanceFirstTouch = true;
        bool _calculationOfCumulativeAvailablePercentFirstTouch = true;

        bool _needBreak = false;
        for (uint256 i = accountLastPeriodNumber[_account]; i > 0; --i)
        {
            AccountPeriodInfo storage _period = accountPeriodDataByPeriodNumber[_account][i];
            if (_period.timeBegin <= accountLastClaimTime[_account]) {
                _periodBegin = accountLastClaimTime[_account];
                _needBreak = true;
            } else {
                _periodBegin = _period.timeBegin;
            }

            if (_periodBegin == 0) {
                _periodBegin = _periodEnd; // _periodEnd - previous period begin
                break;
            }

            {
                uint256 _periodAmountInBase = __getAmountInBase(_period);
                _cumulativeFullBalance += (_periodEnd - _periodBegin) * _periodAmountInBase;

                if (_periodAvailableEnd >= _periodBegin) {
                    if (_calculationOfCumulativeAvailableBalanceFirstTouch) {
                        _cumulativeAvailableBalance = (_periodAvailableEnd - _periodBegin) * _periodAmountInBase;
                        _calculationOfCumulativeAvailableBalanceFirstTouch = false;
                    } else {
                        _cumulativeAvailableBalance += (_periodEnd - _periodBegin) * _periodAmountInBase;
                    }
                }
            }

            if (_period.isWithdraw || _needBreak) { // end of Basic time coefficients
                uint256 _calculatedCumulativeTimePercent = __calculateCumulativeTimePercent(_periodBegin, _timedRewardPeriodEnd);

                _cumulativeFullPercent += _calculatedCumulativeTimePercent;
                if (_periodAvailableEnd >= _periodBegin) {
                    if (_calculationOfCumulativeAvailablePercentFirstTouch) {
                        _cumulativeAvailablePercent = __calculateCumulativeTimePercent(_periodBegin, _periodAvailableEnd);
                        _calculationOfCumulativeAvailablePercentFirstTouch = false;
                    } else {
                        _cumulativeAvailablePercent += _calculatedCumulativeTimePercent;
                    }
                }

                _timedRewardPeriodEnd = _periodBegin;
            }

            _periodEnd = _periodBegin;
            if (_needBreak) {
                break;
            }
        }

        {
            uint256 _calculatedCumulativeTimePercent = __calculateCumulativeTimePercent(_periodBegin, _timedRewardPeriodEnd);
            _cumulativeFullPercent += _calculatedCumulativeTimePercent;
            if (_periodAvailableEnd >= _periodBegin) {
                if (_calculationOfCumulativeAvailablePercentFirstTouch) {
                    _cumulativeAvailablePercent = __calculateCumulativeTimePercent(_periodBegin, _periodAvailableEnd);
                } else {
                    _cumulativeAvailablePercent += _calculatedCumulativeTimePercent;
                }
            }
        }
    }

    function __calculateCumulativeTimePercent(uint256 _timedRewardPeriodBegin, uint256 _timedRewardPeriodEnd)
        private
        view
        returns (uint256)
    {
        uint256 _timedRewardPeriod = _calculateNonSuspensionPeriod(_timedRewardPeriodBegin, _timedRewardPeriodEnd);
        if (_timedRewardPeriod == 0) {
            return 0;
        }


        if (timedRewardPeriod <= _timedRewardPeriod) {
            // timedRewardInPercent / 2 * timedRewardPeriod + timedRewardInPercent * (_timedRewardPeriod - timedRewardPeriod);
            return (_timedRewardPeriod - timedRewardPeriod / 2) * timedRewardInPercent;
        }
        // _timedRewardPeriod * timedRewardInPercent / 2 * _timedRewardPeriod / timedRewardPeriod;
        return _timedRewardPeriod * _timedRewardPeriod * timedRewardInPercent / 2 / timedRewardPeriod;
    }

////////////////////////////////////////// methods for calculate individual claim amount

    function __calculatePendingForClaim(address _account)
        internal
        view
        returns (uint256)
    {
        (
            uint256 _cumulativeAvailableBalance,
            uint256 _cumulativeAvailablePercent,
            uint256 _periodBegin
        ) = __calculateCumulativeValuesForClaim(_account);

        if (_cumulativeAvailableBalance == 0) {
            return 0;
        }

        uint256 _period = block.timestamp - rewardDelayPeriod - _periodBegin;
        uint256 _nonSuspensionPeriod = _calculateNonSuspensionPeriod(_periodBegin, block.timestamp - rewardDelayPeriod);

        if (_nonSuspensionPeriod == 0) {
            return 0;
        }

        uint256 _medianOfBalance = _cumulativeAvailableBalance / _period;
        DoubleMath.Double memory _medianOfPercent = DoubleMath.fraction(_cumulativeAvailablePercent, _nonSuspensionPeriod);

        return CompoundPercent.compound(_medianOfBalance, DoubleMath.add_(_medianOfPercent, baseRewardInPercent), _nonSuspensionPeriod);
    }

    function __calculateCumulativeValuesForClaim(address _account)
        private
        view
        returns (
            uint256 _cumulativeAvailableBalance,
            uint256 _cumulativeAvailablePercent,
            uint256 _periodBegin
        )
    {
        _cumulativeAvailableBalance = 0;
        _cumulativeAvailablePercent = 0;
        _periodBegin = 0;
        uint256 _periodAvailableEnd = block.timestamp - rewardDelayPeriod;

        uint256 _periodEnd = block.timestamp;
        uint256 _timedRewardPeriodEnd = block.timestamp;

        bool _calculationOfCumulativeAvailableBalanceFirstTouch = true;
        bool _calculationOfCumulativeAvailablePercentFirstTouch = true;

        bool _needBreak = false;
        for (uint256 i = accountLastPeriodNumber[_account]; i > 0; --i)
        {
            AccountPeriodInfo storage _period = accountPeriodDataByPeriodNumber[_account][i];
            if (_period.timeBegin <= accountLastClaimTime[_account]) {
                _periodBegin = accountLastClaimTime[_account];
                _needBreak = true;
            } else {
                _periodBegin = _period.timeBegin;
            }

            if (_periodBegin == 0) {
                _periodBegin = _periodEnd;
                break;
            }

            if (_periodAvailableEnd >= _periodBegin) {

                uint256 _periodAmountInBase = __getAmountInBase(_period);
                if (_calculationOfCumulativeAvailableBalanceFirstTouch) {
                    _cumulativeAvailableBalance = (_periodAvailableEnd - _periodBegin) * _periodAmountInBase;
                    _calculationOfCumulativeAvailableBalanceFirstTouch = false;
                } else {
                    _cumulativeAvailableBalance += (_periodEnd - _periodBegin) * _periodAmountInBase;
                }


                if (_period.isWithdraw || _needBreak)
                {
                    if (_calculationOfCumulativeAvailablePercentFirstTouch) {
                        _cumulativeAvailablePercent = __calculateCumulativeTimePercent(_periodBegin, _periodAvailableEnd);
                        _calculationOfCumulativeAvailablePercentFirstTouch = false;
                    } else {
                        _cumulativeAvailablePercent += __calculateCumulativeTimePercent(_periodBegin, _timedRewardPeriodEnd);
                    }

                    _timedRewardPeriodEnd = _periodBegin;
                }

            }

            _periodEnd = _periodBegin;
            if (_needBreak) {
                break;
            }
        }

        if (_periodAvailableEnd >= _periodBegin) {
            if (_calculationOfCumulativeAvailablePercentFirstTouch) {
                _cumulativeAvailablePercent = __calculateCumulativeTimePercent(_periodBegin, _periodAvailableEnd);
            } else {
                _cumulativeAvailablePercent += __calculateCumulativeTimePercent(_periodBegin, _timedRewardPeriodEnd);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PendingCalculator.sol";
import "../../libs/interfaces/IStablecoin.sol";

abstract contract ClaimSender is
    PendingCalculator
{

////////////////////////////////////////// initialize

////////////////////////////////////////// fields definition

    /** see https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps */
    uint256[50] private __gap;

////////////////////////////////////////// methods for claim

    function __claim(address _account)
        internal
    {
        __createNewPeriod(_account, true);
        uint256 _rewardAllowedToClaim = __calculatePendingForClaim(_account);
        require(_rewardAllowedToClaim > 0, "StakingProtocol::claim - _rewardAllowedToClaim == 0");

        accountLastClaimTime[_account] = block.timestamp - rewardDelayPeriod;
        claimedTotal += _rewardAllowedToClaim;
        IStablecoin(stablecoin).mint(_account, _rewardAllowedToClaim);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableMapUpgradeable.sol";
import "../../libs/utils/structs/AddressToUintMapAdditionalMethods.sol";
import "../../libs/interfaces/IAssetsManagerWithRewardCoefficient.sol";

abstract contract AssetsManager is
    IAssetsManagerWithRewardCoefficient
{
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.AddressToUintMap;
    using AddressToUintMapAdditionalMethods for EnumerableMapUpgradeable.AddressToUintMap;

////////////////////////////////////////// fields definition

    uint256 internal constant PERCENT = 100;
    uint256 public constant MAX_ALLOWED_REWARD_COEFFICIENT_IN_PERCENT = 200;

    // asset address => asset reward Coefficient
    EnumerableMapUpgradeable.AddressToUintMap internal assetWithRewardCoefficients;

    /** see https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps */
    uint256[49] private __gap;

////////////////////////////////////////// initialize

    function __init_AllowedAssets(
        address[] memory _assets,
        uint256[] memory _assetRewardCoefficients
    ) internal {
        require(_assets.length == _assetRewardCoefficients.length, 'different length in assets and amounts');
        for (uint256 i = 0; i < _assets.length; ++i) {
            __AddAsset(_assets[i], _assetRewardCoefficients[i]);
        }
    }

////////////////////////////////////////// modifiers

    modifier assetIsAllowed(address _asset) {
        __AssertAssetIsAllowed(_asset);
        _;
    }
    modifier assetIsNotExist(address _asset) {
        __AssertAssetNotExist(_asset);
        _;
    }

    function __AssertAssetIsAllowed(address _asset) internal view {
        require(assetWithRewardCoefficients.contains(_asset), 'asset Is Not Allowed');
    }
    function __AssertAssetNotExist(address _asset) internal view {
        require(!assetWithRewardCoefficients.contains(_asset), 'asset Is Exist');
    }

////////////////////////////////////////// write methods

    function __AddAsset(
        address _asset,
        uint256 _rewardCoefficientInPercent
    )
        internal
        assetIsNotExist(_asset)
    {
        require(_rewardCoefficientInPercent <= MAX_ALLOWED_REWARD_COEFFICIENT_IN_PERCENT, '_rewardCoefficient is too big');
        assetWithRewardCoefficients.set(_asset, _rewardCoefficientInPercent);
    }

    function __EditAssetRewardCoefficient(
        address _asset,
        uint256 _rewardCoefficientInPercent
    )
        internal
        assetIsAllowed(_asset)
    {
        require(_rewardCoefficientInPercent <= MAX_ALLOWED_REWARD_COEFFICIENT_IN_PERCENT, '_rewardCoefficient is too big');
        assetWithRewardCoefficients.set(_asset, _rewardCoefficientInPercent);
    }

    function __RemoveAsset(
        address _asset
    )
        internal
        assetIsAllowed(_asset)
    {
        assetWithRewardCoefficients.remove(_asset);
    }

////////////////////////////////////////// view methods

    function getAssetWithRewardCoefficients()
        public
        view
        override
        returns (address[] memory, uint256[] memory)
    {
        return assetWithRewardCoefficients.getKeyValueList();
    }

    function getRewardCoefficient(address _asset)
        public
        view
        override
        assetIsAllowed(_asset)
        returns (uint256)
    {
        return assetWithRewardCoefficients.get(_asset);
    }

    function __getRewardCoefficientForAmountInBase(address _asset)
        internal
        view
        returns (uint256)
    {
        if (assetWithRewardCoefficients.contains(_asset)) {
            return assetWithRewardCoefficients.get(_asset);
        }
        return PERCENT;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSetUpgradeable {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableMap.sol)

pragma solidity ^0.8.0;

import "./EnumerableSetUpgradeable.sol";

/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * The following map types are supported:
 *
 * - `uint256 -> address` (`UintToAddressMap`) since v3.0.0
 * - `address -> uint256` (`AddressToUintMap`) since v4.6.0
 * - `bytes32 -> bytes32` (`Bytes32ToBytes32`) since v4.6.0
 * - `uint256 -> uint256` (`UintToUintMap`) since v4.7.0
 * - `bytes32 -> uint256` (`Bytes32ToUintMap`) since v4.7.0
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableMap, you can either remove all elements one by one or create a fresh instance using an array of EnumerableMap.
 * ====
 */
library EnumerableMapUpgradeable {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.Bytes32Set;

    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Map type with
    // bytes32 keys and values.
    // The Map implementation uses private functions, and user-facing
    // implementations (such as Uint256ToAddressMap) are just wrappers around
    // the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit
    // in bytes32.

    struct Bytes32ToBytes32Map {
        // Storage of keys
        EnumerableSetUpgradeable.Bytes32Set _keys;
        mapping(bytes32 => bytes32) _values;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        Bytes32ToBytes32Map storage map,
        bytes32 key,
        bytes32 value
    ) internal returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToBytes32Map storage map, bytes32 key) internal returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool) {
        return map._keys.contains(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function length(Bytes32ToBytes32Map storage map) internal view returns (uint256) {
        return map._keys.length();
    }

    /**
     * @dev Returns the key-value pair stored at position `index` in the map. O(1).
     *
     * Note that there are no guarantees on the ordering of entries inside the
     * array, and it may change when more entries are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32ToBytes32Map storage map, uint256 index) internal view returns (bytes32, bytes32) {
        bytes32 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool, bytes32) {
        bytes32 value = map._values[key];
        if (value == bytes32(0)) {
            return (contains(map, key), bytes32(0));
        } else {
            return (true, value);
        }
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || contains(map, key), "EnumerableMap: nonexistent key");
        return value;
    }

    /**
     * @dev Same as {_get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {_tryGet}.
     */
    function get(
        Bytes32ToBytes32Map storage map,
        bytes32 key,
        string memory errorMessage
    ) internal view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || contains(map, key), errorMessage);
        return value;
    }

    // UintToUintMap

    struct UintToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        UintToUintMap storage map,
        uint256 key,
        uint256 value
    ) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToUintMap storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToUintMap storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the set. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintToUintMap storage map, uint256 index) internal view returns (uint256, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (uint256(key), uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(UintToUintMap storage map, uint256 key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(key));
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToUintMap storage map, uint256 key) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(key)));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        UintToUintMap storage map,
        uint256 key,
        string memory errorMessage
    ) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(key), errorMessage));
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        UintToAddressMap storage map,
        uint256 key,
        address value
    ) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the set. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     *
     * _Available since v3.4._
     */
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, bytes32(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        UintToAddressMap storage map,
        uint256 key,
        string memory errorMessage
    ) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, bytes32(key), errorMessage))));
    }

    // AddressToUintMap

    struct AddressToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        AddressToUintMap storage map,
        address key,
        uint256 value
    ) internal returns (bool) {
        return set(map._inner, bytes32(uint256(uint160(key))), bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(AddressToUintMap storage map, address key) internal returns (bool) {
        return remove(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(AddressToUintMap storage map, address key) internal view returns (bool) {
        return contains(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(AddressToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the set. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressToUintMap storage map, uint256 index) internal view returns (address, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (address(uint160(uint256(key))), uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(AddressToUintMap storage map, address key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(uint256(uint160(key))));
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(AddressToUintMap storage map, address key) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(uint256(uint160(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        AddressToUintMap storage map,
        address key,
        string memory errorMessage
    ) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(uint256(uint160(key))), errorMessage));
    }

    // Bytes32ToUintMap

    struct Bytes32ToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        Bytes32ToUintMap storage map,
        bytes32 key,
        uint256 value
    ) internal returns (bool) {
        return set(map._inner, key, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToUintMap storage map, bytes32 key) internal returns (bool) {
        return remove(map._inner, key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToUintMap storage map, bytes32 key) internal view returns (bool) {
        return contains(map._inner, key);
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(Bytes32ToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the set. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32ToUintMap storage map, uint256 index) internal view returns (bytes32, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (key, uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToUintMap storage map, bytes32 key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, key);
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToUintMap storage map, bytes32 key) internal view returns (uint256) {
        return uint256(get(map._inner, key));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        Bytes32ToUintMap storage map,
        bytes32 key,
        string memory errorMessage
    ) internal view returns (uint256) {
        return uint256(get(map._inner, key, errorMessage));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
                /// @solidity memory-safe-assembly
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721Upgradeable.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/extensions/IERC721MetadataUpgradeable.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}