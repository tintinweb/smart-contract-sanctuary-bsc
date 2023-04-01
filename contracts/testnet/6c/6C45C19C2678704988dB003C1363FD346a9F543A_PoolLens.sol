// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

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

pragma solidity >= 0.8.0;

interface ILevelOracle {
    function getPrice(address token, bool max) external view returns (uint256);
    function getMultiplePrices(address[] calldata tokens, bool max) external view returns (uint256[] memory);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILPToken is IERC20 {
    function mint(address to, uint amount) external;

    function burnFrom(address account, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import {SignedInt} from "../lib/SignedInt.sol";

enum Side {
    LONG,
    SHORT
}

struct TokenWeight {
    address token;
    uint256 weight;
}

interface IPool {
    function increasePosition(
        address _account,
        address _indexToken,
        address _collateralToken,
        uint256 _sizeChanged,
        Side _side
    ) external;

    function decreasePosition(
        address _account,
        address _indexToken,
        address _collateralToken,
        uint256 _desiredCollateralReduce,
        uint256 _sizeChanged,
        Side _side,
        address _receiver
    ) external;

    function liquidatePosition(address _account, address _indexToken, address _collateralToken, Side _side) external;

    function validateToken(address indexToken, address collateralToken, Side side, bool isIncrease)
        external
        view
        returns (bool);

    function swap(address _tokenIn, address _tokenOut, uint256 _minOut, address _to)
        external;

    function addLiquidity(address _tranche, address _token, uint256 _amountIn, uint256 _minLpAmount, address _to)
        external;

    function removeLiquidity(address _tranche, address _tokenOut, uint256 _lpAmount, uint256 _minOut, address _to)
        external;

    // =========== EVENTS ===========
    event SetOrderManager(address indexed orderManager);
    event IncreasePosition(
        bytes32 indexed key,
        address account,
        address collateralToken,
        address indexToken,
        uint256 collateralValue,
        uint256 sizeChanged,
        Side side,
        uint256 indexPrice,
        uint256 feeValue
    );
    event UpdatePosition(
        bytes32 indexed key,
        uint256 size,
        uint256 collateralValue,
        uint256 entryPrice,
        uint256 entryInterestRate,
        uint256 reserveAmount,
        uint256 indexPrice
    );
    event DecreasePosition(
        bytes32 indexed key,
        address account,
        address collateralToken,
        address indexToken,
        uint256 collateralChanged,
        uint256 sizeChanged,
        Side side,
        uint256 indexPrice,
        SignedInt pnl,
        uint256 feeValue
    );
    event ClosePosition(
        bytes32 indexed key,
        uint256 size,
        uint256 collateralValue,
        uint256 entryPrice,
        uint256 entryInterestRate,
        uint256 reserveAmount
    );
    event LiquidatePosition(
        bytes32 indexed key,
        address account,
        address collateralToken,
        address indexToken,
        Side side,
        uint256 size,
        uint256 collateralValue,
        uint256 reserveAmount,
        uint256 indexPrice,
        SignedInt pnl,
        uint256 feeValue
    );
    event DaoFeeWithdrawn(address indexed token, address recipient, uint256 amount);
    event DaoFeeReduced(address indexed token, uint256 amount);
    event FeeDistributorSet(address indexed feeDistributor);
    event LiquidityAdded(
        address indexed tranche, address indexed sender, address token, uint256 amount, uint256 lpAmount, uint256 fee
    );
    event LiquidityRemoved(
        address indexed tranche, address indexed sender, address token, uint256 lpAmount, uint256 amountOut, uint256 fee
    );
    event TokenWeightSet(TokenWeight[]);
    event Swap(
        address indexed sender, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut, uint256 fee
    );
    event PositionFeeSet(uint256 positionFee, uint256 liquidationFee);
    event DaoFeeSet(uint256 value);
    event SwapFeeSet(
        uint256 baseSwapFee, uint256 taxBasisPoint, uint256 stableCoinBaseSwapFee, uint256 stableCoinTaxBasisPoint
    );
    event InterestAccrued(address indexed token, uint256 borrowIndex);
    event MaxLeverageChanged(uint256 maxLeverage);
    event TokenWhitelisted(address indexed token);
    event TokenDelisted(address indexed token);
    event OracleChanged(address indexed oldOracle, address indexed newOracle);
    event InterestRateSet(uint256 interestRate, uint256 interval);
    event MaxPositionSizeSet(uint256 maxPositionSize);
    event PoolHookChanged(address indexed hook);
    event TrancheAdded(address indexed lpToken);
    event TokenRiskFactorUpdated(address indexed token);
    event PnLDistributed(address indexed asset, address indexed tranche, uint256 amount, bool hasProfit);
    event MaintenanceMarginChanged(uint256 ratio);
    event AddRemoveLiquidityFeeSet(uint256 value);
    event MaxGlobalShortSizeSet(address indexed token, uint256 max);
    event MaxGlobalLongSizeRatioSet(address indexed token, uint256 max);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import {Side, IPool} from "./IPool.sol";

interface IPoolHook {
    function postIncreasePosition(
        address owner,
        address indexToken,
        address collateralToken,
        Side side,
        bytes calldata extradata
    ) external;

    function postDecreasePosition(
        address owner,
        address indexToken,
        address collateralToken,
        Side side,
        bytes calldata extradata
    ) external;

    function postLiquidatePosition(
        address owner,
        address indexToken,
        address collateralToken,
        Side side,
        bytes calldata extradata
    ) external;

    function postSwap(address user, address tokenIn, address tokenOut, bytes calldata data) external;

    event PreIncreasePositionExecuted(
        address pool, address owner, address indexToken, address collateralToken, Side side, bytes extradata
    );
    event PostIncreasePositionExecuted(
        address pool, address owner, address indexToken, address collateralToken, Side side, bytes extradata
    );
    event PreDecreasePositionExecuted(
        address pool, address owner, address indexToken, address collateralToken, Side side, bytes extradata
    );
    event PostDecreasePositionExecuted(
        address pool, address owner, address indexToken, address collateralToken, Side side, bytes extradata
    );
    event PreLiquidatePositionExecuted(
        address pool, address owner, address indexToken, address collateralToken, Side side, bytes extradata
    );
    event PostLiquidatePositionExecuted(
        address pool, address owner, address indexToken, address collateralToken, Side side, bytes extradata
    );

    event PostSwapExecuted(address pool, address user, address tokenIn, address tokenOut, bytes data);
}

pragma solidity >=0.8.0;

library MathUtils {
    function diff(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            return a > b ? a - b : b - a;
        }
    }

    function zeroCapSub(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            return a > b ? a - b : 0;
        }
    }

    function frac(uint256 amount, uint256 num, uint256 denom) internal pure returns (uint256) {
        return amount * num / denom;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function addThenSubWithFraction(uint256 orig, uint256 add, uint256 sub, uint256 num, uint256 denum)
        internal
        pure
        returns (uint256)
    {
        return zeroCapSub(orig + MathUtils.frac(add, num, denum), MathUtils.frac(sub, num, denum));
    }
}

// SPDX-License-Identifier: UNLCIENSED

pragma solidity >=0.8.0;

import {Side} from "../interfaces/IPool.sol";
import {SignedInt, SignedIntOps} from "./SignedInt.sol";

library PositionUtils {
    using SignedIntOps for SignedInt;

    function calcPnl(Side _side, uint256 _positionSize, uint256 _entryPrice, uint256 _indexPrice)
        internal
        pure
        returns (SignedInt memory)
    {
        if (_positionSize == 0 || _entryPrice == 0) {
            return SignedIntOps.wrap(uint256(0));
        }
        if (_side == Side.LONG) {
            return SignedIntOps.wrap(_indexPrice).sub(_entryPrice).mul(_positionSize).div(_entryPrice);
        } else {
            return SignedIntOps.wrap(_entryPrice).sub(_indexPrice).mul(_positionSize).div(_entryPrice);
        }
    }

    /// @notice calculate new avg entry price when increase position
    /// @dev for longs: nextAveragePrice = (nextPrice * nextSize)/ (nextSize + delta)
    ///      for shorts: nextAveragePrice = (nextPrice * nextSize) / (nextSize - delta)
    function calcAveragePrice(
        Side _side,
        uint256 _lastSize,
        uint256 _nextSize,
        uint256 _entryPrice,
        uint256 _nextPrice,
        SignedInt memory _realizedPnL
    ) internal pure returns (uint256) {
        if (_nextSize == 0) {
            return 0;
        }
        if (_lastSize == 0) {
            return _nextPrice;
        }
        SignedInt memory pnl = calcPnl(_side, _lastSize, _entryPrice, _nextPrice).sub(_realizedPnL);
        SignedInt memory nextSize = SignedIntOps.wrap(_nextSize);
        SignedInt memory divisor = _side == Side.LONG ? nextSize.add(pnl) : nextSize.sub(pnl);
        return nextSize.mul(_nextPrice).div(divisor).toUint();
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

uint256 constant POS = 1;
uint256 constant NEG = 0;

/// SignedInt is integer number with sign. It value range is -(2 ^ 256 - 1) to (2 ^ 256 - 1)
struct SignedInt {
    /// @dev sig = 1 -> positive, sig = 0 is negative
    /// using uint256 which take up full word to optimize gas and contract size
    uint256 sig;
    uint256 abs;
}

library SignedIntOps {
    function add(SignedInt memory a, SignedInt memory b) internal pure returns (SignedInt memory) {
        if (a.sig == b.sig) {
            return SignedInt({sig: a.sig, abs: a.abs + b.abs});
        }

        if (a.abs == b.abs) {
            return SignedInt(POS, 0); // always return positive zero
        }

        unchecked {
            (uint256 sig, uint256 abs) = a.abs > b.abs ? (a.sig, a.abs - b.abs) : (b.sig, b.abs - a.abs);
            return SignedInt(sig, abs);
        }
    }

    function inv(SignedInt memory a) internal pure returns (SignedInt memory) {
        return a.abs == 0 ? a : (SignedInt({sig: 1 - a.sig, abs: a.abs}));
    }

    function sub(SignedInt memory a, SignedInt memory b) internal pure returns (SignedInt memory) {
        return add(a, inv(b));
    }

    function mul(SignedInt memory a, SignedInt memory b) internal pure returns (SignedInt memory) {
        uint256 sig = (a.sig + b.sig + 1) % 2;
        uint256 abs = a.abs * b.abs;
        return SignedInt(abs == 0 ? POS : sig, abs); // zero is alway positive
    }

    function div(SignedInt memory a, SignedInt memory b) internal pure returns (SignedInt memory) {
        uint256 sig = (a.sig + b.sig + 1) % 2;
        uint256 abs = a.abs / b.abs;
        return SignedInt(abs == 0 ? POS : sig, abs); // zero is alway positive
    }

    function add(SignedInt memory a, uint256 b) internal pure returns (SignedInt memory) {
        return add(a, wrap(b));
    }

    function sub(SignedInt memory a, uint256 b) internal pure returns (SignedInt memory) {
        return sub(a, wrap(b));
    }

    function mul(SignedInt memory a, uint256 b) internal pure returns (SignedInt memory) {
        return mul(a, wrap(b));
    }

    function div(SignedInt memory a, uint256 b) internal pure returns (SignedInt memory) {
        return div(a, wrap(b));
    }

    function wrap(uint256 a) internal pure returns (SignedInt memory) {
        return SignedInt(POS, a);
    }

    function toUint(SignedInt memory a) internal pure returns (uint256) {
        if (a.abs == 0) return 0;
        require(a.sig == POS, "SignedInt: below zero");
        return a.abs;
    }

    function gt(SignedInt memory a, uint256 b) internal pure returns (bool) {
        return a.sig == POS && a.abs > b;
    }

    function lt(SignedInt memory a, uint256 b) internal pure returns (bool) {
        return a.sig == NEG || a.abs < b;
    }

    function isNeg(SignedInt memory a) internal pure returns (bool) {
        return a.sig == NEG;
    }

    function isPos(SignedInt memory a) internal pure returns (bool) {
        return a.sig == POS;
    }

    function frac(SignedInt memory a, uint256 num, uint256 denom) internal pure returns (SignedInt memory) {
        return div(mul(a, num), denom);
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import {PoolStorage, AssetInfo, PoolTokenInfo, Position, MAX_TRANCHES} from "./PoolStorage.sol";
import {Side, IPool} from "../interfaces/IPool.sol";
import {SignedInt, SignedIntOps} from "../lib/SignedInt.sol";
import {PositionUtils} from "../lib/PositionUtils.sol";
import {ILevelOracle} from "../interfaces/ILevelOracle.sol";
import {MathUtils} from "../lib/MathUtils.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

struct PositionView {
    bytes32 key;
    uint256 size;
    uint256 collateralValue;
    uint256 entryPrice;
    uint256 pnl;
    uint256 reserveAmount;
    bool hasProfit;
    address collateralToken;
    uint256 borrowIndex;
    uint256 lastIncreasedTime;
}

struct PoolAsset {
    uint256 poolAmount;
    uint256 reservedAmount;
    uint256 feeReserve;
    uint256 guaranteedValue;
    uint256 totalShortSize;
    uint256 averageShortPrice;
    uint256 poolBalance;
    uint256 lastAccrualTimestamp;
    uint256 borrowIndex;
}

interface IPoolForLens is IPool {
    function getPoolAsset(address _token) external view returns (AssetInfo memory);
    function trancheAssets(address _tranche, address _token) external view returns (AssetInfo memory);
    function getAllTranchesLength() external view returns (uint256);
    function allTranches(uint256) external view returns (address);
    function poolTokens(address) external view returns (PoolTokenInfo memory);
    function positions(bytes32) external view returns (Position memory);
    function oracle() external view returns (ILevelOracle);
    function getPoolValue(bool _max) external view returns (uint256);
    function getTrancheValue(address _tranche, bool _max) external view returns (uint256 sum);
    function averageShortPrices(address _tranche, address _token) external view returns (uint256);
    function targetWeights(address _token) external view returns(uint256);
    function maxGlobalShortSizes(address _token) external view returns(uint256);
    function maxGlobalLongSizeRatios(address _token) external view returns(uint256);

}

contract PoolLens {
    uint256 MAX_INT = 2**256 - 1;
    uint256 public constant POSITION_PROPS_LENGTH = 9;
    using SignedIntOps for SignedInt;

    /**
     * @notice Get pool asset info for a given token.
     * @notice Combines PoolTokenInfo and AssetInfo data.
     * @param _pool The pool address.
     * @param _token The token address.
     * @return poolAsset The pool asset info.
     * - `poolAmount` The amount of tokens in the pool.
     * - `reservedAmount` The amount of tokens reserved for paying out when user decrease long position
     * - `guaranteedValue` The total borrowed (in USD) to leverage.
     * - `totalShortSize` The total size of all short positions of the token.
     * - `averageShortPrice` The calculated average short price of the token in all tranches.
     * - `poolBalance` The recorded balance of token in pool.
     * - `lastAccrualTimestamp` The last borrow index update timestamp.
     * - `borrowIndex` The accumulated interest rate.
     */
    function poolAssets(address _pool, address _token) public view returns (PoolAsset memory poolAsset) {
        IPoolForLens self = IPoolForLens(_pool);
        AssetInfo memory asset = self.getPoolAsset(_token);
        PoolTokenInfo memory tokenInfo = self.poolTokens(_token);
        uint256 avgShortPrice;
        uint256 nTranches = self.getAllTranchesLength();
        for (uint256 i = 0; i < nTranches;) {
            address tranche = self.allTranches(i);
            uint256 shortSize = self.trancheAssets(tranche, _token).totalShortSize;
            avgShortPrice += shortSize * self.averageShortPrices(tranche, _token);
            unchecked {
                ++i;
            }
        }
        poolAsset.poolAmount = asset.poolAmount;
        poolAsset.reservedAmount = asset.reservedAmount;
        poolAsset.guaranteedValue = asset.guaranteedValue;
        poolAsset.totalShortSize = asset.totalShortSize;
        poolAsset.feeReserve = tokenInfo.feeReserve;
        poolAsset.averageShortPrice = asset.totalShortSize == 0 ? 0 : avgShortPrice / asset.totalShortSize;
        poolAsset.poolBalance = tokenInfo.poolBalance;
        poolAsset.lastAccrualTimestamp = tokenInfo.lastAccrualTimestamp;
        poolAsset.borrowIndex = tokenInfo.borrowIndex;
    }

    function getPoolTokenInfo(address _pool, address[] memory _tokens) public view returns (uint256[] memory) {
        uint256 propsLength = 15;
        IPoolForLens pool = IPoolForLens(_pool);
        ILevelOracle oracle = pool.oracle();

        uint256[] memory amounts = new uint256[](_tokens.length * propsLength);
        for (uint256 i = 0; i < _tokens.length; i++) {
            address token = _tokens[i];
            PoolAsset memory poolAsset = poolAssets(_pool, token);

            amounts[i * propsLength]     = poolAsset.poolAmount;
            amounts[i * propsLength + 1] = poolAsset.reservedAmount;
            amounts[i * propsLength + 2] = 0;// vault.usdgAmounts(token);
            amounts[i * propsLength + 3] = 0; //vault.getRedemptionAmount(token, _usdgAmount);
            amounts[i * propsLength + 4] = pool.targetWeights(token);
            amounts[i * propsLength + 5] = 0; //vault.bufferAmounts(token);
            amounts[i * propsLength + 6] = 0;// vault.maxUsdgAmounts(token);
            amounts[i * propsLength + 7] = poolAsset.totalShortSize; //vault.globalShortSizes(token);
            amounts[i * propsLength + 8] = pool.maxGlobalShortSizes(token);       
            amounts[i * propsLength + 9] = pool.maxGlobalLongSizeRatios(token) == 0 ? 0 : MathUtils.frac(poolAsset.poolAmount, pool.maxGlobalLongSizeRatios(token), 1e10); //    ==this disables thes checks==                    positionManager.maxGlobalLongSizes(token);
            amounts[i * propsLength + 10] = oracle.getPrice(token, false);
            amounts[i * propsLength + 11] = oracle.getPrice(token, true);
            amounts[i * propsLength + 12] = poolAsset.guaranteedValue; //  vault.guaranteedUsd(token); this is size - collateral
            amounts[i * propsLength + 13] = oracle.getPrice(token, false);
            amounts[i * propsLength + 14] = oracle.getPrice(token, true);
        }

        return amounts;
    }

    /**
     * @notice Get position info for a given position.
     * @param _pool The pool address.
     * @param _owner The owner of the position.
     * @param _indexToken The position index token address.
     * @param _collateralToken The position collateral token address.
     * @param _side The position side.
     * @return result The position info.
     */
    function getPosition(address _pool, address _owner, address _indexToken, address _collateralToken, Side _side)
        public
        view
        returns (PositionView memory result)
    {
        IPoolForLens self = IPoolForLens(_pool);
        ILevelOracle oracle = self.oracle();
        bytes32 positionKey = _getPositionKey(_owner, _indexToken, _collateralToken, _side);
        Position memory position = self.positions(positionKey);
        uint256 indexPrice =
            _side == Side.LONG ? oracle.getPrice(_indexToken, false) : oracle.getPrice(_indexToken, true);
        SignedInt memory pnl = PositionUtils.calcPnl(_side, position.size, position.entryPrice, indexPrice);

        result.key = positionKey;
        result.size = position.size;
        result.collateralValue = position.collateralValue;
        result.pnl = pnl.abs;
        result.hasProfit = pnl.isPos();
        result.entryPrice = position.entryPrice;
        result.borrowIndex = position.borrowIndex;
        result.reserveAmount = position.reserveAmount;
        result.collateralToken = _collateralToken;
    }

    function getPositions(address pool, address _account, address[] memory _collateralTokens, address[] memory _indexTokens, bool[] memory _isLong) public view returns(uint256[] memory) {
        uint256[] memory amounts = new uint256[](_collateralTokens.length * POSITION_PROPS_LENGTH);
        ILevelOracle oracle = IPoolForLens(pool).oracle();

        for (uint256 i = 0; i < _collateralTokens.length; i++) {
            {
                PositionView memory position = getPosition(pool, _account, _indexTokens[i], _collateralTokens[i], _isLong[i] ? Side.LONG : Side.SHORT);

                amounts[i * POSITION_PROPS_LENGTH] = position.size;
                amounts[i * POSITION_PROPS_LENGTH + 1] = position.collateralValue;
                amounts[i * POSITION_PROPS_LENGTH + 2] = position.entryPrice;
                amounts[i * POSITION_PROPS_LENGTH + 3] = position.borrowIndex;
                amounts[i * POSITION_PROPS_LENGTH + 4] = 0; //hasRealizedProfit
                amounts[i * POSITION_PROPS_LENGTH + 5] = position.pnl;
                amounts[i * POSITION_PROPS_LENGTH + 6] = 0;// TODO: until we modify the pool contract. position.lastIncreasedTime;
                amounts[i * POSITION_PROPS_LENGTH + 7] = position.hasProfit ? 1 : 0;
                if (position.entryPrice > 0) {
                    uint256 price = _isLong[i] ? oracle.getPrice(_indexTokens[i], false) : oracle.getPrice(_indexTokens[i], true);
                    uint256 priceDelta = position.entryPrice > price ? position.entryPrice - price : price - position.entryPrice;
                    uint256 delta = position.size * priceDelta / position.entryPrice;
                    amounts[i * POSITION_PROPS_LENGTH + 8] = delta;
                }
            }
            
        }
        return amounts;
    }

    /**
     * @notice Compute the position key of an owner's position for a index token, collateral token and side.
     * @dev Internal function.
     * @param _owner The address of the owner.
     * @param _indexToken The address of the index token.
     * @param _collateralToken The address of the collateral token.
     * @param _side The side of the position (LONG or SHORT).
     * @return The position key.
     */
    function _getPositionKey(address _owner, address _indexToken, address _collateralToken, Side _side)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(_owner, _indexToken, _collateralToken, _side));
    }

    /**
     * @notice Get the value of a tranche.
     * @notice Calculates the average value of the tranche between the min and max values.
     * @param _pool The pool address.
     * @param _tranche The tranche address.
     * @return The tranche value.
     */
    function getTrancheValue(IPoolForLens _pool, address _tranche) external view returns (uint256) {
        return (_pool.getTrancheValue(_tranche, true) + _pool.getTrancheValue(_tranche, false)) / 2;
    }

    /**
     * @notice Get the value of a pool.
     * @notice Calculates the average value of the pool between the min and max values.
     * @param _pool The pool address.
     * @return The pool value.
     */
    function getPoolValue(IPoolForLens _pool) external view returns (uint256) {
        return (_pool.getPoolValue(true) + _pool.getPoolValue(false)) / 2;
    }

    struct PoolInfo {
        uint256 minValue;
        uint256 maxValue;
        uint256[MAX_TRANCHES] tranchesMinValue;
        uint256[MAX_TRANCHES] tranchesMaxValue;
    }


    function getTokenBalances(address _account, address[] memory _tokens) public view returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](_tokens.length);
        for (uint256 i = 0; i < _tokens.length; i++) {
            address token = _tokens[i];
            if (token == address(0)) {
                balances[i] = _account.balance;
                continue;
            }
            balances[i] = IERC20(token).balanceOf(_account);
        }
        return balances;
    }

    /**
     * @notice Get the pool info across all tranches.
     * @param _pool The pool address.
     * @return info The pool info.
     * - `minValue` The minimum value of the pool.
     * - `maxValue` The maximum value of the pool.
     * - `tranchesMinValue` The minimum value of each tranche.
     * - `tranchesMaxValue` The maximum value of each tranche.
     */
    function getPoolInfo(IPoolForLens _pool) external view returns (PoolInfo memory info) {
        info.minValue = _pool.getPoolValue(false);
        info.maxValue = _pool.getPoolValue(true);
        uint256 nTranches = _pool.getAllTranchesLength();
        for (uint256 i = 0; i < nTranches;) {
            address tranche = _pool.allTranches(i);
            info.tranchesMinValue[i] = _pool.getTrancheValue(tranche, false);
            info.tranchesMaxValue[i] = _pool.getTrancheValue(tranche, true);
            unchecked {
                ++i;
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import {ILevelOracle} from "../interfaces/ILevelOracle.sol";
import {ILPToken} from "../interfaces/ILPToken.sol";
import {IPoolHook} from "../interfaces/IPoolHook.sol";

// common precision for fee, tax, interest rate, maintenance margin ratio
uint256 constant PRECISION = 1e10;
uint256 constant LP_INITIAL_PRICE = 1e12; // fix to 1$
uint256 constant MAX_BASE_SWAP_FEE = 1e8; // 1%
uint256 constant MAX_TAX_BASIS_POINT = 1e8; // 1%
uint256 constant MAX_POSITION_FEE = 1e8; // 1%
uint256 constant MAX_LIQUIDATION_FEE = 10e30; // 10$
uint256 constant MAX_TRANCHES = 3;
uint256 constant MAX_ASSETS = 10;
uint256 constant MAX_INTEREST_RATE = 1e7; // 0.1%
uint256 constant MAX_MAINTENANCE_MARGIN = 5e8; // 5%

struct Fee {
    /// @notice charge when changing position size
    uint256 positionFee;
    /// @notice charge when liquidate position (in dollar)
    uint256 liquidationFee;
    /// @notice swap fee used when add/remove liquidity, swap token
    uint256 baseSwapFee;
    /// @notice tax used to adjust swapFee due to the effect of the action on token's weight
    /// It reduce swap fee when user add some amount of a under weight token to the pool
    uint256 taxBasisPoint;
    /// @notice swap fee used when add/remove liquidity, swap token
    uint256 stableCoinBaseSwapFee;
    /// @notice tax used to adjust swapFee due to the effect of the action on token's weight
    /// It reduce swap fee when user add some amount of a under weight token to the pool
    uint256 stableCoinTaxBasisPoint;
    /// @notice part of fee will be kept for DAO, the rest will be distributed to pool amount, thus
    /// increase the pool value and the price of LP token
    uint256 daoFee;
}

struct Position {
    /// @dev contract size is evaluated in dollar
    uint256 size;
    /// @dev collateral value in dollar
    uint256 collateralValue;
    /// @dev contract size in indexToken
    uint256 reserveAmount;
    /// @dev average entry price
    uint256 entryPrice;
    /// @dev last cumulative interest rate
    uint256 borrowIndex;
}

struct PoolTokenInfo {
    /// @notice amount reserved for fee
    uint256 feeReserve;
    /// @notice recorded balance of token in pool
    uint256 poolBalance;
    /// @notice last borrow index update timestamp
    uint256 lastAccrualTimestamp;
    /// @notice accumulated interest rate
    uint256 borrowIndex;
    /// @notice average entry price of all short position
    /// @deprecated avg short price must be calculate per tranche
    uint256 averageShortPrice;
}

struct AssetInfo {
    /// @notice amount of token deposited (via add liquidity or increase long position)
    uint256 poolAmount;
    /// @notice amount of token reserved for paying out when user decrease long position
    uint256 reservedAmount;
    /// @notice total borrowed (in USD) to leverage
    uint256 guaranteedValue;
    /// @notice total size of all short positions
    uint256 totalShortSize;
}

abstract contract PoolStorage {
    Fee public fee;

    address public feeDistributor;

    ILevelOracle public oracle;

    address public orderManager;

    // ========= Assets management =========
    mapping(address => bool) public isAsset;
    /// @notice A list of all configured assets
    /// @dev use a pseudo address for ETH
    /// Note that token will not be removed from this array when it was delisted. We keep this
    /// list to calculate pool value properly
    address[] public allAssets;

    mapping(address => bool) public isListed;

    mapping(address => bool) public isStableCoin;

    mapping(address => PoolTokenInfo) public poolTokens;

    /// @notice target weight for each tokens
    mapping(address => uint256) public targetWeights;

    mapping(address => bool) public isTranche;
    /// @notice risk factor of each token in each tranche
    /// @dev token => tranche => risk factor
    mapping(address => mapping(address => uint256)) public riskFactor;
    /// @dev token => total risk score
    mapping(address => uint256) public totalRiskFactor;

    address[] public allTranches;
    /// @dev tranche => token => asset info
    mapping(address => mapping(address => AssetInfo)) public trancheAssets;
    /// @notice position reserve in each tranche
    mapping(address => mapping(bytes32 => uint256)) public tranchePositionReserves;

    /// @notice interest rate model
    uint256 public interestRate;

    uint256 public accrualInterval;

    uint256 public totalWeight;
    // ========= Positions management =========
    /// @notice max leverage for each token
    uint256 public maxLeverage;
    /// @notice positions tracks all open positions
    mapping(bytes32 => Position) public positions;

    IPoolHook public poolHook;

    uint256 public maintenanceMargin;

    uint256 public addRemoveLiquidityFee;

    mapping(address => mapping(address => uint256)) public averageShortPrices;
    /// @notice cached pool value for faster computation
    uint256 public virtualPoolValue;
    /// @notice index token => max global short size
    mapping(address => uint256) public maxGlobalShortSizes;
    mapping(address => uint256) public maxGlobalLongSizeRatios;
}