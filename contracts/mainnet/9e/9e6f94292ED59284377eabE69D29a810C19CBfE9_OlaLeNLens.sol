pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;

import "../../Core/Math/SafeMath.sol";
import "../../Core/Math/Exponential.sol";

interface Erc20ForOlaLeNLens {
    function decimals() external view returns (uint8);
    function balanceOf(address acount) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
}

interface RainMakerForOlaLeNLens {
    function lnIncentiveTokenAddress() external view returns (address);
    function compAccrued(address account) external view returns (uint);
    function claimComp(address account) external;
}

interface PriceOracleForOlaLenLensInterface {
    function getUnderlyingPrice(address oToken) external view returns (uint);
}

interface MinistryOlaLenLensInterface {
    function getOracleForAsset(address asset) external view returns (PriceOracleForOlaLenLensInterface);
    function getPriceForUnderling(address market) external view returns (uint256);
    function getPriceForAsset(address asset) external view returns (uint256);
}

interface ComptrollerOlaLeNLensInterface {
    function getAllMarkets() external view returns (OTokenForOlaLenLensInterface[] memory);

    function getRegistry() external view returns (MinistryOlaLenLensInterface);

    function hasRainMaker() external view returns (bool);
    function rainMaker() external view returns (RainMakerForOlaLeNLens rainMaker);
}

interface OTokenForOlaLenLensInterface {
    function borrowBalanceCurrent(address account) external returns (uint);
    function balanceOfUnderlying(address account) external returns (uint);
    function exchangeRateCurrent() external returns (uint);

    function comptroller() external view returns (ComptrollerOlaLeNLensInterface);

    function underlying() external view returns (address);
    function nativeCoinUnderlying() external view returns (address);
    function decimals() external view returns (uint);
    function totalSupply() external view returns (uint);
    function totalBorrows() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
}

/// This iteration of the contract is not complete
/// Future iterations will include more functionalities and proper documentation
contract OlaLeNLens is Exponential{
    using SafeMath for uint;

    struct LendingNetworkView {
        uint totalSupply;
        uint totalBorrows;
    }

    function viewLendingNetwork(ComptrollerOlaLeNLensInterface unitroller) external returns (LendingNetworkView memory) {
        MinistryOlaLenLensInterface ministry = unitroller.getRegistry();
        OTokenForOlaLenLensInterface[] memory allMarkets = unitroller.getAllMarkets();

        LendingNetworkView memory lendingNetworkView;

        for (uint8 i = 0; i < allMarkets.length; i ++) {
            OTokenForOlaLenLensInterface market = allMarkets[i];

            MarketView memory marketView = viewMarketInternal(market, ministry);

            lendingNetworkView.totalSupply = lendingNetworkView.totalSupply.add(marketView.supplyUsd);
            lendingNetworkView.totalBorrows = lendingNetworkView.totalBorrows.add(marketView.borrowsUsd);
        }

        return lendingNetworkView;
    }

    struct MarketView {
        uint supplyUnits;
        uint supplyUsd;
        uint borrowsUnits;
        uint borrowsUsd;
    }

    function viewMarket(OTokenForOlaLenLensInterface market) external returns (MarketView memory) {
        MarketView memory marketView;

        ComptrollerOlaLeNLensInterface comptroller = market.comptroller();
        MinistryOlaLenLensInterface ministry = MinistryOlaLenLensInterface(comptroller.getRegistry());

        return viewMarketInternal(market, ministry);
    }

    function viewMarketInternal(OTokenForOlaLenLensInterface market, MinistryOlaLenLensInterface ministry) internal returns (MarketView memory) {
        MarketView memory marketView;

        // Note: Calls 'accrue interest'
        uint exchangeRate = market.exchangeRateCurrent();
        address underlying = market.underlying();
        bool isNativeAsset = underlying == market.nativeCoinUnderlying();
        uint underlyingDecimals = isNativeAsset ? 18 : Erc20ForOlaLeNLens(underlying).decimals();
        uint oTokenDecimals = market.decimals();


        // The price scaled by mantissa
        PriceOracleForOlaLenLensInterface priceOracle = ministry.getOracleForAsset(underlying);

        // Scaled to 36 - asset decimals
        uint underlyingPrice = priceOracle.getUnderlyingPrice(address(market));

        uint oTokensCirculation = market.totalSupply();
        (MathError mathErr, uint underlyingAmount) = mulScalarTruncate(Exp({mantissa: exchangeRate}), uint(oTokensCirculation));

        require(mathErr == MathError.NO_ERROR, "Conversion error");

//        uint priceScale = 10 ** (36 - underlyingDecimals);

        marketView.supplyUnits = underlyingAmount
        // Scale to 10^18
        .mul(10**18)
        // Negate original scale
        .div(10**underlyingDecimals);
        marketView.supplyUsd = marketView.supplyUnits.mul(underlyingPrice).div(10 ** (36 - underlyingDecimals));

        uint underlyingBorrowsRaw = market.totalBorrows();
        marketView.borrowsUnits = underlyingBorrowsRaw.mul(10 ** 18).div(10**underlyingDecimals);
        marketView.borrowsUsd = marketView.borrowsUnits.mul(underlyingPrice).div(10 ** (36 - underlyingDecimals));

        return marketView;
    }

    struct OMarketBalances {
        address oToken;
        // Borrow balance scaled to 10*18
        uint borrowBalanceInUnits;
        // The oToken balance in terms of underlying units
        uint supplyBalanceInUnits;

        // Market balances in USD
        uint borrowBalanceInUsd;
        uint supplyBalanceInUsd;

        // OToken balance
        uint accountOTokenBalance;
        // Underlying balance for the account
        uint accountUnderlyingBalanceInUnits;

        // Allowance in underlying given by 'account' to 'market'
        uint marketAllowance;
    }

    function viewMarketBalances(OTokenForOlaLenLensInterface market, address payable account) public returns (OMarketBalances memory) {
        uint borrowBalanceCurrent = market.borrowBalanceCurrent(account);
        uint balanceOfInUnderlying = market.balanceOfUnderlying(account);

        address underlying = market.underlying();
        bool isNativeAsset = underlying == market.nativeCoinUnderlying();
        uint underlyingDecimals = isNativeAsset ? 18 : Erc20ForOlaLeNLens(underlying).decimals();

        uint underlyingPrice = getUnderlyingPriceForMarket(market);

        OMarketBalances memory marketBalances;
        marketBalances.oToken = address(market);
        marketBalances.borrowBalanceInUnits = underlyingAmountToScale(borrowBalanceCurrent, underlyingDecimals);
        marketBalances.supplyBalanceInUnits = underlyingAmountToScale(balanceOfInUnderlying, underlyingDecimals);

        marketBalances.borrowBalanceInUsd = unitsToUsdValue(marketBalances.borrowBalanceInUnits, underlyingDecimals, underlyingPrice);
        marketBalances.supplyBalanceInUsd = unitsToUsdValue(marketBalances.supplyBalanceInUnits, underlyingDecimals, underlyingPrice);

        marketBalances.accountOTokenBalance = market.balanceOf(account);

        uint accountUnderlyingBalance;
        uint marketAllowance;
        if (isNativeAsset) {
            accountUnderlyingBalance = account.balance;
            marketAllowance = account.balance;
        } else {
            Erc20ForOlaLeNLens underlying = Erc20ForOlaLeNLens(market.underlying());
            accountUnderlyingBalance = underlying.balanceOf(account);
            marketAllowance = underlying.allowance(account, address(market));
        }
        marketBalances.accountUnderlyingBalanceInUnits = underlyingAmountToScale(accountUnderlyingBalance,underlyingDecimals);
        marketBalances.marketAllowance = marketAllowance;

        return marketBalances;
    }

    function viewMarketsBalances(OTokenForOlaLenLensInterface[] calldata oMarkets, address payable account) external returns (OMarketBalances[] memory) {
        uint oMarketsCount = oMarkets.length;
        OMarketBalances[] memory res = new OMarketBalances[](oMarketsCount);
        for (uint i = 0; i < oMarketsCount; i++) {
            res[i] = viewMarketBalances(oMarkets[i], account);
        }
        return res;
    }

    function viewMarketBalancesInLeN(ComptrollerOlaLeNLensInterface unitroller, address payable account) external returns (OMarketBalances[] memory) {
        OTokenForOlaLenLensInterface[] memory allMarkets = unitroller.getAllMarkets();

        uint oMarketsCount = allMarkets.length;
        OMarketBalances[] memory res = new OMarketBalances[](oMarketsCount);
        for (uint i = 0; i < oMarketsCount; i++) {
            res[i] = viewMarketBalances(allMarkets[i], account);
        }
        return res;
    }

    struct RainBalances {
        uint balance;
        uint allocated;
    }

    function viewActiveRainBalances(ComptrollerOlaLeNLensInterface unitroller, address account) external returns (RainBalances memory) {
        if (unitroller.hasRainMaker()) {
            RainMakerForOlaLeNLens rainMaker = unitroller.rainMaker();
            Erc20ForOlaLeNLens rainToken = Erc20ForOlaLeNLens(rainMaker.lnIncentiveTokenAddress());

            uint balance = rainToken.balanceOf(account);
            rainMaker.claimComp(account);
            uint newBalance = rainToken.balanceOf(account);

            uint accrued = rainMaker.compAccrued(account);

            uint total = add(accrued, newBalance, "sum comp total");
            uint allocated = sub(total, balance, "sub allocated");

            return RainBalances({
                balance: balance,
                allocated: allocated
            });
        } else {
            return RainBalances({
                balance: 0,
                allocated: 0
            });
        }
    }

    function getUnderlyingPriceForMarket(OTokenForOlaLenLensInterface market) public view returns (uint)  {
        ComptrollerOlaLeNLensInterface comptroller = market.comptroller();
        MinistryOlaLenLensInterface ministry = MinistryOlaLenLensInterface(comptroller.getRegistry());

        // Scaled to 36 - asset decimals
        uint underlyingPrice = ministry.getPriceForUnderling(address(market));

        return underlyingPrice;
    }

    function isMarketForNative(OTokenForOlaLenLensInterface market) public view returns (bool) {
        return market.underlying() == market.nativeCoinUnderlying();
    }

    function underlyingAmountToScale(uint amount, uint underlyingDecimals) public pure returns (uint) {
        return amount
        // Scale to 10^18
        .mul(10**18)
        // Negate original scale
        .div(10**underlyingDecimals);
    }

    function unitsToUsdValue(uint scaledAmount, uint underlyingDecimals, uint underlyingPrice) public pure returns (uint) {
        return scaledAmount.mul(underlyingPrice).div(10 ** (36 - underlyingDecimals));
    }

    function add(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;
        return c;
    }
}

pragma solidity ^0.5.16;

// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/Math.sol
// Subject to the MIT license.

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting with custom message on overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on underflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot underflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction underflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on underflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot underflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers.
     * Reverts on division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers.
     * Reverts with custom message on division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.5.16;

import "./CarefulMath.sol";
import "./ExponentialNoError.sol";

/**
 * @title Exponential module for storing fixed-precision decimals
 * @author Compound
 * @dev Legacy contract for compatibility reasons with existing contracts that still use MathError
 * @notice Exp is a struct which stores decimals with a fixed precision of 18 decimal places.
 *         Thus, if we wanted to store the 5.1, mantissa would store 5.1e18. That is:
 *         `Exp({mantissa: 5100000000000000000})`.
 */
contract Exponential is CarefulMath, ExponentialNoError {
    /**
     * @dev Creates an exponential from numerator and denominator values.
     *      Note: Returns an error if (`num` * 10e18) > MAX_INT,
     *            or if `denom` is zero.
     */
    function getExp(uint num, uint denom) pure internal returns (MathError, Exp memory) {
        (MathError err0, uint scaledNumerator) = mulUInt(num, expScale);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (MathError err1, uint rational) = divUInt(scaledNumerator, denom);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: rational}));
    }

    /**
     * @dev Adds two exponentials, returning a new exponential.
     */
    function addExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {
        (MathError error, uint result) = addUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    /**
     * @dev Subtracts two exponentials, returning a new exponential.
     */
    function subExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {
        (MathError error, uint result) = subUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    /**
     * @dev Multiply an Exp by a scalar, returning a new Exp.
     */
    function mulScalar(Exp memory a, uint scalar) pure internal returns (MathError, Exp memory) {
        (MathError err0, uint scaledMantissa) = mulUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: scaledMantissa}));
    }

    /**
     * @dev Multiply an Exp by a scalar, then truncate to return an unsigned integer.
     */
    function mulScalarTruncate(Exp memory a, uint scalar) pure internal returns (MathError, uint) {
        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(product));
    }

    /**
     * @dev Multiply an Exp by a scalar, truncate, then add an to an unsigned integer, returning an unsigned integer.
     */
    function mulScalarTruncateAddUInt(Exp memory a, uint scalar, uint addend) pure internal returns (MathError, uint) {
        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return addUInt(truncate(product), addend);
    }

    /**
     * @dev Divide an Exp by a scalar, returning a new Exp.
     */
    function divScalar(Exp memory a, uint scalar) pure internal returns (MathError, Exp memory) {
        (MathError err0, uint descaledMantissa) = divUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: descaledMantissa}));
    }

    /**
     * @dev Divide a scalar by an Exp, returning a new Exp.
     */
    function divScalarByExp(uint scalar, Exp memory divisor) pure internal returns (MathError, Exp memory) {
        /*
          We are doing this as:
          getExp(mulUInt(expScale, scalar), divisor.mantissa)

          How it works:
          Exp = a / b;
          Scalar = s;
          `s / (a / b)` = `b * s / a` and since for an Exp `a = mantissa, b = expScale`
        */
        (MathError err0, uint numerator) = mulUInt(expScale, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        return getExp(numerator, divisor.mantissa);
    }

    /**
     * @dev Divide a scalar by an Exp, then truncate to return an unsigned integer.
     */
    function divScalarByExpTruncate(uint scalar, Exp memory divisor) pure internal returns (MathError, uint) {
        (MathError err, Exp memory fraction) = divScalarByExp(scalar, divisor);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(fraction));
    }

    /**
     * @dev Multiplies two exponentials, returning a new exponential.
     */
    function mulExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {

        (MathError err0, uint doubleScaledProduct) = mulUInt(a.mantissa, b.mantissa);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        // We add half the scale before dividing so that we get rounding instead of truncation.
        //  See "Listing 6" and text above it at https://accu.org/index.php/journals/1717
        // Without this change, a result like 6.6...e-19 will be truncated to 0 instead of being rounded to 1e-18.
        (MathError err1, uint doubleScaledProductWithHalfScale) = addUInt(halfExpScale, doubleScaledProduct);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        (MathError err2, uint product) = divUInt(doubleScaledProductWithHalfScale, expScale);
        // The only error `div` can return is MathError.DIVISION_BY_ZERO but we control `expScale` and it is not zero.
        assert(err2 == MathError.NO_ERROR);

        return (MathError.NO_ERROR, Exp({mantissa: product}));
    }

    /**
     * @dev Multiplies two exponentials given their mantissas, returning a new exponential.
     */
    function mulExp(uint a, uint b) pure internal returns (MathError, Exp memory) {
        return mulExp(Exp({mantissa: a}), Exp({mantissa: b}));
    }

    /**
     * @dev Multiplies three exponentials, returning a new exponential.
     */
    function mulExp3(Exp memory a, Exp memory b, Exp memory c) pure internal returns (MathError, Exp memory) {
        (MathError err, Exp memory ab) = mulExp(a, b);
        if (err != MathError.NO_ERROR) {
            return (err, ab);
        }
        return mulExp(ab, c);
    }

    /**
     * @dev Divides two exponentials, returning a new exponential.
     *     (a/scale) / (b/scale) = (a/scale) * (scale/b) = a/b,
     *  which we can scale as an Exp by calling getExp(a.mantissa, b.mantissa)
     */
    function divExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {
        return getExp(a.mantissa, b.mantissa);
    }
}

pragma solidity ^0.5.16;

/**
  * @title Careful Math
  * @author Compound
  * @notice Derived from OpenZeppelin's SafeMath library
  *         https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol
  */
contract CarefulMath {

    /**
     * @dev Possible error codes that we can return
     */
    enum MathError {
        NO_ERROR,
        DIVISION_BY_ZERO,
        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW
    }

    /**
    * @dev Multiplies two numbers, returns an error on overflow.
    */
    function mulUInt(uint a, uint b) internal pure returns (MathError, uint) {
        if (a == 0) {
            return (MathError.NO_ERROR, 0);
        }

        uint c = a * b;

        if (c / a != b) {
            return (MathError.INTEGER_OVERFLOW, 0);
        } else {
            return (MathError.NO_ERROR, c);
        }
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function divUInt(uint a, uint b) internal pure returns (MathError, uint) {
        if (b == 0) {
            return (MathError.DIVISION_BY_ZERO, 0);
        }

        return (MathError.NO_ERROR, a / b);
    }

    /**
    * @dev Subtracts two numbers, returns an error on overflow (i.e. if subtrahend is greater than minuend).
    */
    function subUInt(uint a, uint b) internal pure returns (MathError, uint) {
        if (b <= a) {
            return (MathError.NO_ERROR, a - b);
        } else {
            return (MathError.INTEGER_UNDERFLOW, 0);
        }
    }

    /**
    * @dev Adds two numbers, returns an error on overflow.
    */
    function addUInt(uint a, uint b) internal pure returns (MathError, uint) {
        uint c = a + b;

        if (c >= a) {
            return (MathError.NO_ERROR, c);
        } else {
            return (MathError.INTEGER_OVERFLOW, 0);
        }
    }

    /**
    * @dev add a and b and then subtract c
    */
    function addThenSubUInt(uint a, uint b, uint c) internal pure returns (MathError, uint) {
        (MathError err0, uint sum) = addUInt(a, b);

        if (err0 != MathError.NO_ERROR) {
            return (err0, 0);
        }

        return subUInt(sum, c);
    }
}

pragma solidity ^0.5.16;

/**
 * @title Exponential module for storing fixed-precision decimals
 * @author Compound
 * @notice Exp is a struct which stores decimals with a fixed precision of 18 decimal places.
 *         Thus, if we wanted to store the 5.1, mantissa would store 5.1e18. That is:
 *         `Exp({mantissa: 5100000000000000000})`.
 */
contract ExponentialNoError {
    uint constant expScale = 1e18;
    uint constant doubleScale = 1e36;
    uint constant halfExpScale = expScale/2;
    uint constant mantissaOne = expScale;

    struct Exp {
        uint mantissa;
    }

    struct Double {
        uint mantissa;
    }

    /**
     * @dev Truncates the given exp to a whole number value.
     *      For example, truncate(Exp{mantissa: 15 * expScale}) = 15
     */
    function truncate(Exp memory exp) pure internal returns (uint) {
        // Note: We are not using careful Math here as we're performing a division that cannot fail
        return exp.mantissa / expScale;
    }

    /**
     * @dev Multiply an Exp by a scalar, then truncate to return an unsigned integer.
     */
    function mul_ScalarTruncate(Exp memory a, uint scalar) pure internal returns (uint) {
        Exp memory product = mul_(a, scalar);
        return truncate(product);
    }

    /**
     * @dev Multiply an Exp by a scalar, truncate, then add an to an unsigned integer, returning an unsigned integer.
     */
    function mul_ScalarTruncateAddUInt(Exp memory a, uint scalar, uint addend) pure internal returns (uint) {
        Exp memory product = mul_(a, scalar);
        return add_(truncate(product), addend);
    }

    /**
     * @dev Checks if first Exp is less than second Exp.
     */
    function lessThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa < right.mantissa;
    }

    /**
     * @dev Checks if left Exp <= right Exp.
     */
    function lessThanOrEqualExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa <= right.mantissa;
    }

    /**
     * @dev Checks if left Exp > right Exp.
     */
    function greaterThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa > right.mantissa;
    }

    /**
     * @dev returns true if Exp is exactly zero
     */
    function isZeroExp(Exp memory value) pure internal returns (bool) {
        return value.mantissa == 0;
    }

    function safe224(uint n, string memory errorMessage) pure internal returns (uint224) {
        require(n < 2**224, errorMessage);
        return uint224(n);
    }

    function safe32(uint n, string memory errorMessage) pure internal returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function add_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(uint a, uint b) pure internal returns (uint) {
        return add_(a, b, "addition overflow");
    }

    function add_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        uint c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(uint a, uint b) pure internal returns (uint) {
        return sub_(a, b, "subtraction underflow");
    }

    function sub_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function mul_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b.mantissa) / expScale});
    }

    function mul_(Exp memory a, uint b) pure internal returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Exp memory b) pure internal returns (uint) {
        return mul_(a, b.mantissa) / expScale;
    }

    function mul_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b.mantissa) / doubleScale});
    }

    function mul_(Double memory a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Double memory b) pure internal returns (uint) {
        return mul_(a, b.mantissa) / doubleScale;
    }

    function mul_(uint a, uint b) pure internal returns (uint) {
        return mul_(a, b, "multiplication overflow");
    }

    function mul_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: div_(mul_(a.mantissa, expScale), b.mantissa)});
    }

    function div_(Exp memory a, uint b) pure internal returns (Exp memory) {
        return Exp({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Exp memory b) pure internal returns (uint) {
        return div_(mul_(a, expScale), b.mantissa);
    }

    function div_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)});
    }

    function div_(Double memory a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Double memory b) pure internal returns (uint) {
        return div_(mul_(a, doubleScale), b.mantissa);
    }

    function div_(uint a, uint b) pure internal returns (uint) {
        return div_(a, b, "divide by zero");
    }

    function div_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function fraction(uint a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: div_(mul_(a, doubleScale), b)});
    }
}