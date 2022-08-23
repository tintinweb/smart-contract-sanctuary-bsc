// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@interest-protocol/library/RebaseLib.sol";
import "@interest-protocol/dex/interfaces/IERC20.sol";

import "./interfaces/IERC20Market.sol";
import "./interfaces/ILPFreeMarket.sol";
import "./interfaces/INativeTokenMarket.sol";
import "./interfaces/IPriceOracle.sol";

interface InterestViewBalancesInterface {
    function getUserBalances(address account, address[] calldata tokens)
        external
        view
        returns (uint256 nativeBalance, uint256[] memory balances);

    function getUserBalanceAndAllowance(
        address user,
        address spender,
        address token
    ) external view returns (uint256 allowance, uint256 balance);

    function getUserBalancesAndAllowances(
        address user,
        address spender,
        address[] calldata tokens
    )
        external
        view
        returns (uint256[] memory allowances, uint256[] memory balances);
}

contract InterestViewDinero {
    using RebaseLib for Rebase;

    IPriceOracle private immutable ORACLE;
    InterestViewBalancesInterface private immutable INTEREST_VIEW_BALANCES;

    struct DineroMarketSummary {
        uint256 collateralAmount;
        uint256 LTV;
        uint256 interestRate;
        uint256 liquidationFee;
        uint256 collateralUSDPrice;
        uint256 userElasticLoan;
    }

    constructor(
        IPriceOracle oracle,
        InterestViewBalancesInterface interestViewBalances
    ) {
        ORACLE = oracle;
        INTEREST_VIEW_BALANCES = interestViewBalances;
    }

    function getDineroMarketsSummary(
        address user,
        INativeTokenMarket _nativeMarket,
        IERC20Market[] calldata _erc20Markets,
        ILPFreeMarket[] calldata _lpMarkets
    )
        external
        view
        returns (
            DineroMarketSummary memory nativeMarket,
            DineroMarketSummary[] memory erc20Markets,
            DineroMarketSummary[] memory lpMarkets
        )
    {
        nativeMarket = _getNativeMarketSummary(user, _nativeMarket);

        erc20Markets = new DineroMarketSummary[](_erc20Markets.length);

        for (uint256 i; i < _erc20Markets.length; i++) {
            erc20Markets[i] = _getERC20MarketSummary(user, _erc20Markets[i]);
        }

        lpMarkets = new DineroMarketSummary[](_lpMarkets.length);

        for (uint256 i; i < _lpMarkets.length; i++) {
            lpMarkets[i] = _getLPMarketSummary(user, _lpMarkets[i]);
        }
    }

    function _getNativeMarketSummary(address user, INativeTokenMarket market)
        private
        view
        returns (DineroMarketSummary memory)
    {
        (, uint128 interestRate, , ) = market.loanTerms();

        (uint128 elastic, uint128 base) = market.loan();

        Rebase memory loan = Rebase(elastic, base);

        (, uint128 principal) = market.accountOf(user);

        return
            DineroMarketSummary(
                address(market).balance,
                market.maxLTVRatio(),
                interestRate,
                market.liquidationFee(),
                ORACLE.getNativeTokenUSDPrice(1 ether),
                loan.toElastic(principal, false)
            );
    }

    function _getERC20MarketSummary(address user, IERC20Market market)
        private
        view
        returns (DineroMarketSummary memory)
    {
        (, uint128 interestRate, , ) = market.loanTerms();

        address token = market.COLLATERAL();

        (uint128 elastic, uint128 base) = market.loan();

        Rebase memory loan = Rebase(elastic, base);

        (, uint128 principal) = market.accountOf(user);

        return
            DineroMarketSummary(
                IERC20(token).balanceOf(address(market)),
                market.maxLTVRatio(),
                interestRate,
                market.liquidationFee(),
                ORACLE.getTokenUSDPrice(token, 1 ether),
                loan.toElastic(principal, false)
            );
    }

    function _getLPMarketSummary(address user, ILPFreeMarket market)
        private
        view
        returns (DineroMarketSummary memory)
    {
        (, , , uint256 principal) = market.accountOf(user);

        return
            DineroMarketSummary(
                market.totalCollateral(),
                market.maxLTVRatio(),
                0,
                market.liquidationFee(),
                ORACLE.getIPXLPTokenUSDPrice(market.COLLATERAL(), 1 ether),
                principal
            );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./SafeCastLib.sol";
import "./MathLib.sol";

/// @dev The elastic represents an arbitrary amount, while the base is the shares of said amount. We save the base and elastic as uint128 instead of uint256 to optimize gas consumption by storing them in one storage slot. A maximum number of 2**128-1 should be enough to cover most of the use cases.
struct Rebase {
    uint128 elastic;
    uint128 base;
}

/**
 * @title A set of functions to manage the change in numbers of tokens and to properly represent them in shares.
 * @dev This library provides a collection of functions to manipulate the base and elastic values saved in a Rebase struct. In a pool context, the percentage of tokens a user owns. The elastic value represents the current number of pool tokens after incurring losses or profits. The functions in this library will revert if the base or elastic goes over 2**1281. Therefore, it is crucial to keep in mind the upper bound limit number this library supports.
 */
library RebaseLib {
    using SafeCastLib for uint256;
    using MathLib for uint256;

    /**
     * @dev Calculates a base value from an elastic value using the ratio of a {Rebase} struct.
     * @param total A {Rebase} struct, which represents a base/elastic pair.
     * @param elastic The new base is calculated from this elastic.
     * @param roundUp Rounding logic due to solidity always rounding down. If this argument is true, the final value will always be rounded up.
     * @return base The base value calculated from the elastic and total arguments.
     */
    function toBase(
        Rebase memory total,
        uint256 elastic,
        bool roundUp
    ) internal pure returns (uint256 base) {
        if (total.elastic == 0) {
            base = elastic;
        } else {
            base = elastic.mulDiv(total.base, total.elastic);
            if (roundUp && base.mulDiv(total.elastic, total.base) < elastic) {
                base += 1;
            }
        }
    }

    /**
     * @dev Calculates the elastic value from a base value using the ratio of a {Rebase} struct.
     * @param total A {Rebase} struct, which represents a base/elastic pair.
     * @param base The returned elastic is calculated from this base.
     * @param roundUp  Rounding logic due to solidity always rounding down. If this argument is true, the final value will always be rounded up.
     * @return elastic The elastic value calculated from the base and total arguments.
     *
     */
    function toElastic(
        Rebase memory total,
        uint256 base,
        bool roundUp
    ) internal pure returns (uint256 elastic) {
        if (total.base == 0) {
            elastic = base;
        } else {
            elastic = base.mulDiv(total.elastic, total.base);
            if (roundUp && elastic.mulDiv(total.base, total.elastic) < base) {
                elastic += 1;
            }
        }
    }

    /**
     * @dev Calculates new elastic and base values to a {Rebase} pair by increasing the elastic value. This function maintains the ratio of the current {Rebase} pair.
     * @param total The {Rebase} struct that we will be adding the additional elastic value.
     * @param elastic The additional elastic value to add to a {Rebase} struct.
     * @param roundUp  Rounding logic due to solidity always rounding down. If this argument is true, the final value will always be rounded up.
     * @return total The new {Rebase} struct.
     * @return base The additional base value that was added to the new {Rebase} struct.
     */
    function add(
        Rebase memory total,
        uint256 elastic,
        bool roundUp
    ) internal pure returns (Rebase memory, uint256 base) {
        base = toBase(total, elastic, roundUp);
        total.elastic += elastic.toUint128();
        total.base += base.toUint128();
        return (total, base);
    }

    /**
     * @dev Calculates new elastic and base values to a {Rebase} pair by decreasing the base value. This function maintains the ratio of the current {Rebase} pair.
     * @param total The {Rebase} struct that we will be adding the additional elastic value.
     * @param base The amount of base to subtract from the {Rebase} struct.
     * @param roundUp  Rounding logic due to solidity always rounding down. If this argument is true, the final value will always be rounded up.
     * @return total The new {Rebase} struct.
     * @return elastic The amount of elastic that was removed from the {Rebase} struct.
     */
    function sub(
        Rebase memory total,
        uint256 base,
        bool roundUp
    ) internal pure returns (Rebase memory, uint256 elastic) {
        elastic = toElastic(total, base, roundUp);
        total.elastic -= elastic.toUint128();
        total.base -= base.toUint128();
        return (total, elastic);
    }

    /**
     * @dev Adds a base and elastic value to a {Rebase} struct.
     * @param total This function will update the base and elastic values of this {Rebase} struct.
     * @param base The value to be added to the `total.base`.
     * @param elastic The value to be added to the `total.elastic`.
     * @return total The new {Rebase} struct is calculated by adding the `base` and `elastic` values.
     */
    function add(
        Rebase memory total,
        uint256 base,
        uint256 elastic
    ) internal pure returns (Rebase memory) {
        total.base += base.toUint128();
        total.elastic += elastic.toUint128();
        return total;
    }

    /**
     * @dev Substracts a base and elastic value to a {Rebase} struct.
     * @param total This function will update the base and elastic values of this {Rebase} struct.
     * @param base The `total.base` will be decreased by this value.
     * @param elastic The `total.elastic` will be decreased by this value.
     * @return total The new {Rebase} struct is calculated by decreasing the `base` and `elastic` values.
     */
    function sub(
        Rebase memory total,
        uint256 base,
        uint256 elastic
    ) internal pure returns (Rebase memory) {
        total.base -= base.toUint128();
        total.elastic -= elastic.toUint128();
        return total;
    }

    /**
     * @dev This function increases the elastic value of a {Rebase} pair. The `total` parameter is saved in storage. This function will update the global state of the caller contract.
     * @param total This function will update the base and elastic values of this {Rebase} struct.
     * @param elastic The value to be added to the `total.elastic`.
     * @return newElastic The new elastic value after reducing `elastic` from `total.elastic`.
     */
    function addElastic(Rebase storage total, uint256 elastic)
        internal
        returns (uint256 newElastic)
    {
        newElastic = total.elastic += elastic.toUint128();
    }

    /**
     * @dev This function decreases the elastic value of a {Rebase} pair. The `total` parameter is saved in storage. This function will update the global state of the caller contract.
     * @param total This function will update the base and elastic values of this {Rebase} struct.
     * @param elastic The value to be removed to the `total.elastic`.
     * @return newElastic The new elastic value after reducing `elastic` from `total.elastic`.
     */
    function subElastic(Rebase storage total, uint256 elastic)
        internal
        returns (uint256 newElastic)
    {
        newElastic = total.elastic -= elastic.toUint128();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface IERC20Market {
    function treasury() external view returns (address);

    function COLLATERAL() external view returns (address);

    function liquidationFee() external view returns (uint96);

    function maxBorrowAmount() external view returns (uint128);

    function maxLTVRatio() external view returns (uint128);

    function loan() external view returns (uint128 elastic, uint128 base);

    function loanTerms()
        external
        view
        returns (
            uint128 lastAccrued,
            uint128 interestRate,
            uint128 dnrEarned,
            uint128 collateralEarned
        );

    function accountOf(address account)
        external
        view
        returns (uint128 collateral, uint128 principal);

    function getDineroEarnings() external;

    function getCollateralEarnings() external;

    function accrue() external;

    function deposit(address to, uint256 amount) external;

    function withdraw(address to, uint256 amount) external;

    function borrow(address to, uint256 amount) external;

    function repay(address account, uint256 amount) external;

    function request(uint256[] calldata requests, bytes[] calldata requestArgs)
        external;

    function liquidate(
        address[] calldata accounts,
        uint256[] calldata principals,
        address recipient,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface ILPFreeMarket {
    function COLLATERAL() external view returns (address);

    function liquidationFee() external view returns (uint96);

    function POOL_ID() external view returns (uint96);

    function maxLTVRatio() external view returns (uint128);

    function totalCollateral() external view returns (uint128);

    function totalPrincipal() external view returns (uint128);

    function maxBorrowAmount() external view returns (uint128);

    function totalRewardsPerToken() external view returns (uint256);

    function accountOf(address account)
        external
        view
        returns (
            uint128 collateral,
            uint128 rewards,
            uint256 rewardDebt,
            uint256 principal
        );

    function collateralEarnings() external view returns (uint256);

    function treasury() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface INativeTokenMarket {
    function treasury() external view returns (address);

    function liquidationFee() external view returns (uint96);

    function maxBorrowAmount() external view returns (uint128);

    function maxLTVRatio() external view returns (uint128);

    function loan() external view returns (uint128 elastic, uint128 base);

    function loanTerms()
        external
        view
        returns (
            uint128 lastAccrued,
            uint128 interestRate,
            uint128 dnrEarned,
            uint128 collateralEarned
        );

    function accountOf(address account)
        external
        view
        returns (uint128 collateral, uint128 principal);

    function getDineroEarnings() external;

    function getCollateralEarnings() external;

    function accrue() external;

    function deposit(address to) external payable;

    function withdraw(address to, uint256 amount) external;

    function borrow(address to, uint256 amount) external;

    function repay(address account, uint256 amount) external;

    function request(uint256[] calldata requests, bytes[] calldata requestArgs)
        external
        payable;

    function liquidate(
        address[] calldata accounts,
        uint256[] calldata principals,
        address recipient,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface IPriceOracle {
    function getTokenUSDPrice(address token, uint256 amount)
        external
        view
        returns (uint256 price);

    function getIPXLPTokenUSDPrice(address pair, uint256 amount)
        external
        view
        returns (uint256 price);

    function getNativeTokenUSDPrice(uint256 amount)
        external
        view
        returns (uint256 price);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title Set of functions to safely cast uint256 numbers to smaller uint bit numbers.
 * @dev We use solidity to optimize the gas consumption, and the functions will revert without any reason.
 */
library SafeCastLib {
    /**
     * @notice Casts a uint256 to uint128 for memory optimization.
     *
     * @param x The uint256 that will be casted to uint128
     * @return y The uint128 version of `x`
     *
     * @dev It will revert if `x` is higher than 2**128 - 1
     */
    function toUint128(uint256 x) internal pure returns (uint128 y) {
        //solhint-disable-next-line no-inline-assembly
        assembly {
            if gt(shr(128, x), 0) {
                revert(0, 0)
            }
            y := x
        }
    }

    /**
     * @notice Casts a uint256 to uint112 for memory optimization.
     *
     * @param x The uint256 that will be casted to uint112
     * @return y The uint112 version of `x`
     *
     * @dev It will revert if `x` is higher than 2**112 - 1
     */
    function toUint112(uint256 x) internal pure returns (uint112 y) {
        //solhint-disable-next-line no-inline-assembly
        assembly {
            if gt(shr(112, x), 0) {
                revert(0, 0)
            }
            y := x
        }
    }

    /**
     * @notice Casts a uint256 to uint96 for memory optimization.
     *
     * @param x The uint256 that will be casted to uint96
     * @return y The uint96 version of `x`
     *
     * @dev It will revert if `x` is higher than 2**96 - 1
     */
    function toUint96(uint256 x) internal pure returns (uint96 y) {
        //solhint-disable-next-line no-inline-assembly
        assembly {
            if gt(shr(96, x), 0) {
                revert(0, 0)
            }
            y := x
        }
    }

    /**
     * @notice Casts a uint256 to uint64 for memory optimization
     *
     * @param x The uint256 that will be casted to uint64
     * @return y The uint64 version of `x`
     *
     * @dev It will revert if `x` is higher than 2**64 - 1
     */
    function toUint64(uint256 x) internal pure returns (uint64 y) {
        //solhint-disable-next-line no-inline-assembly
        assembly {
            if gt(shr(64, x), 0) {
                revert(0, 0)
            }
            y := x
        }
    }

    /**
     * @notice Casts a uint256 to uint32 for memory optimization
     *
     * @param x The uint256 that will be casted to uint32
     * @return y The uint64 version of `x`
     *
     * @dev It will revert if `x` is higher than 2**32 - 1
     */
    function toUint32(uint256 x) internal pure returns (uint32 y) {
        //solhint-disable-next-line no-inline-assembly
        assembly {
            if gt(shr(32, x), 0) {
                revert(0, 0)
            }
            y := x
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title Set of utility functions to perform mathematical operations.
 */
library MathLib {
    /// @notice The decimal houses of most ERC20 tokens and native tokens.
    uint256 private constant SCALAR = 1e18;

    /**
     * @notice It multiplies two fixed point numbers.
     * @dev It assumes the arguments are fixed point numbers with 18 decimal houses. It reverts if the result overflows 2**256-1. Source: https://twitter.com/transmissions11/status/1451129626432978944/photo/1
     * @param x First operand
     * @param y The second operand
     * @return z The result of multiplying x and y
     */
    function fmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// We use assembly to optimize gas consumption.
        assembly {
            if iszero(or(iszero(x), eq(div(mul(x, y), x), y))) {
                revert(0, 0)
            }

            z := div(mul(x, y), SCALAR)
        }
    }

    /**
     * @notice It divides two fixed point numbers.
     * @dev It assumes the arguments are fixed point numbers with 18 decimal houses. It reverts if the result overflows 2**256-1. It does not guard against underflows because the EVM div opcode cannot underflow. Source: https://twitter.com/transmissions11/status/1451129626432978944/photo/1
     * @param x First operand
     * @param y The second operand
     * @return z The result of multiplying x and y
     */
    function fdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// We use assembly to optimize gas consumption.
        assembly {
            if or(
                iszero(y),
                iszero(or(iszero(x), eq(div(mul(x, SCALAR), x), SCALAR)))
            ) {
                revert(0, 0)
            }
            z := div(mul(x, SCALAR), y)
        }
    }

    /**
     * @notice It returns a version of the first argument with 18 decimals.
     * @dev This function protects against shadow integer overflow.
     * @param x Number that will be manipulated to have 18 decimals.
     * @param decimals The current decimal houses of the first argument
     * @return z A version of the first argument with 18 decimals.
     */
    function adjust(uint256 x, uint8 decimals) internal pure returns (uint256) {
        /// If the number has 18 decimals, we do not need to do anything.
        /// Since {mulDiv} protects against shadow overflow, we can first add 18 decimal houses and then remove the current decimal houses.
        return decimals == 18 ? x : mulDiv(x, SCALAR, 10**decimals);
    }

    /**
     * @notice It adds two numbers.
     * @dev This function has no protection against integer overflow to optimize gas consumption. It must only be used when we are 100% certain it will not overflow. E.g., to calculate the number of blocks elapsed.
     * @param x First operand.
     * @param y The second operand.
     * @return z The result of adding x and y.
     */
    function uAdd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := add(x, y)
        }
    }

    /**
     * @notice It subtracts two numbers.
     * @dev This function has no protection against integer underflow to optimize gas consumption. It must only be used when we are 100% certain it will not underflow. E.g., to calculate the number of blocks elapsed.
     * @param x First operand.
     * @param y The second operand.
     * @return z The result of adding x and y.
     */
    function uSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := sub(x, y)
        }
    }

    /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // Handle division by zero
        require(denominator > 0);

        // 512-bit multiply [prod1 prod0] = a * b
        // Compute the product mod 2**256 and mod 2**256 - 1
        // then use the Chinese Remiander Theorem to reconstruct
        // the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2**256 + prod0
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Short circuit 256 by 256 division
        // This saves gas when a * b is small, at the cost of making the
        // large case a bit more expensive. Depending on your use case you
        // may want to remove this short circuit and always go through the
        // 512 bit path.
        if (prod1 == 0) {
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Handle overflow, the result must be < 2**256
        require(prod1 < denominator);

        // Make division exact by subtracting the remainder from [prod1 prod0]
        // Compute remainder using mulmod
        // Note mulmod(_, _, 0) == 0
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        // Subtract 256 bit number from 512 bit number
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator
        // Compute largest power of two divisor of denominator.
        // Always >= 1 unless denominator is zero, then twos is zero.
        uint256 twos = denominator & (~denominator + 1);
        // Divide denominator by power of two
        assembly {
            denominator := div(denominator, twos)
        }

        // Divide [prod1 prod0] by the factors of two
        assembly {
            prod0 := div(prod0, twos)
        }
        // Shift in bits from prod1 into prod0. For this we need
        // to flip `twos` such that it is 2**256 / twos.
        // If twos is zero, then it becomes one
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        // Invert denominator mod 2**256
        // Now that denominator is an odd number, it has an inverse
        // modulo 2**256 such that denominator * inv = 1 mod 2**256.
        // Compute the inverse by starting with a seed that is correct
        // correct for four bits. That is, denominator * inv = 1 mod 2**4
        // If denominator is zero the inverse starts with 2
        uint256 inv = (3 * denominator) ^ 2;
        // Now use Newton-Raphson itteration to improve the precision.
        // Thanks to Hensel's lifting lemma, this also works in modular
        // arithmetic, doubling the correct bits in each step.
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256
        // If denominator is zero, inv is now 128

        // Because the division is now exact we can divide by multiplying
        // with the modular inverse of denominator. This will give us the
        // correct result modulo 2**256. Since the precoditions guarantee
        // that the outcome is less than 2**256, this is the final result.
        // We don't need to compute the high bits of the result and prod1
        // is no longer required.
        result = prod0 * inv;
        return result;
    }

    /**
     * @notice This function finds the square root of a number.
     * @dev It was taken from https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol.
     * @param x This function will find the square root of this number.
     * @return The square root of x.
     */
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 xx = x;
        uint256 r = 1;

        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }

        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }

    /**
     * @notice It returns the smaller number between the two arguments.
     * @param x Any uint256 number.
     * @param y Any uint256 number.
     * @return It returns whichever is smaller between x and y.
     */
    function min(uint256 x, uint256 y) internal pure returns (uint256) {
        return x > y ? y : x;
    }
}