/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

// File: contracts/Libraries/FullMath.sol



pragma solidity ^0.8.4;

// The library below is taken from @uniswap/lib/contracts/libraries/FullMath.sol. It has been modified to work with solidity 0.8
library FullMath {
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
    // 512-bit multiply [prod1 prod0] = a * b
    // Compute the product mod 2**256 and mod 2**256 - 1
    // then use the Chinese Remainder Theorem to reconstruct
    // the 512 bit result. The result is stored in two 256
    // variables such that product = prod1 * 2**256 + prod0
    uint256 prod0; // Least significant 256 bits of the product
    uint256 prod1; // Most significant 256 bits of the product
    assembly {
      let mm := mulmod(a, b, not(0))
      prod0 := mul(a, b)
      prod1 := sub(sub(mm, prod0), lt(mm, prod0))
    }

    // Handle non-overflow cases, 256 by 256 division
    if (prod1 == 0) {
      require(denominator > 0);
      assembly {
        result := div(prod0, denominator)
      }
      return result;
    }

    // Make sure the result is less than 2**256.
    // Also prevents denominator == 0
    require(denominator > prod1);

    ///////////////////////////////////////////////
    // 512 by 256 division.
    ///////////////////////////////////////////////

    // Make division exact by subtracting the remainder from [prod1 prod0]
    // Compute remainder using mulmod
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
    // Always >= 1.
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
    uint256 inv = (3 * denominator) ^ 2;
    // Now use Newton-Raphson iteration to improve the precision.
    // Thanks to Hensel's lifting lemma, this also works in modular
    // arithmetic, doubling the correct bits in each step.
    inv *= 2 - denominator * inv; // inverse mod 2**8
    inv *= 2 - denominator * inv; // inverse mod 2**16
    inv *= 2 - denominator * inv; // inverse mod 2**32
    inv *= 2 - denominator * inv; // inverse mod 2**64
    inv *= 2 - denominator * inv; // inverse mod 2**128
    inv *= 2 - denominator * inv; // inverse mod 2**256

    // Because the division is now exact we can divide by multiplying
    // with the modular inverse of denominator. This will give us the
    // correct result modulo 2**256. Since the precoditions guarantee
    // that the outcome is less than 2**256, this is the final result.
    // We don't need to compute the high bits of the result and prod1
    // is no longer required.
    result = prod0 * inv;
    return result;
  }

  /// @notice Calculates ceil(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
  /// @param a The multiplicand
  /// @param b The multiplier
  /// @param denominator The divisor
  /// @return result The 256-bit result
  function mulDivRoundingUp(
    uint256 a,
    uint256 b,
    uint256 denominator
  ) internal pure returns (uint256 result) {
    result = mulDiv(a, b, denominator);
    if (mulmod(a, b, denominator) > 0) {
      require(result < type(uint256).max);
      result++;
    }
  }
}

// File: @uniswap/lib/contracts/libraries/TransferHelper.sol



pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

// File: @uniswap/lib/contracts/libraries/Babylonian.sol



pragma solidity >=0.4.0;

// computes square roots using the babylonian method
// https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method
library Babylonian {
    // credit for this implementation goes to
    // https://github.com/abdk-consulting/abdk-libraries-solidity/blob/master/ABDKMath64x64.sol#L687
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        // this block is equivalent to r = uint256(1) << (BitMath.mostSignificantBit(x) / 2);
        // however that code costs significantly more gas
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
}

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: contracts/Libraries/UniswapHelper.sol



pragma solidity ^0.8.4;







library UniswapHelper {
  using SafeMath for uint256;

  // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut,
    uint256 tradingFee
  ) internal pure returns (uint256 amountOut) {
    uint256 tradingFeeFactor = 10000 - tradingFee;
    require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
    require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
    uint256 amountInWithFee = amountIn * tradingFeeFactor;
    uint256 numerator = amountInWithFee * reserveOut;
    uint256 denominator = reserveIn * 10000 + amountInWithFee;
    amountOut = numerator / denominator;
  }

  // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut,
    uint256 tradingFee
  ) internal pure returns (uint256 amountIn) {
    uint256 tradingFeeFactor = 10000 - tradingFee;
    require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
    require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
    uint256 numerator = reserveIn.mul(amountOut).mul(10000);
    uint256 denominator = reserveOut.sub(amountOut).mul(tradingFeeFactor);
    amountIn = (numerator / denominator).add(1);
  }

  // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) internal pure returns (uint256 amountB) {
    require(amountA > 0, "UniswapV2Library: INSUFFICIENT_AMOUNT");
    require(reserveA > 0 && reserveB > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
    amountB = (amountA * reserveB) / reserveA;
  }

  /**
   * @notice Given the "true" price a token (represented by truePriceTokenA/truePriceTokenB) and the reservers in the
   * uniswap pair, calculate: a) the direction of trade (aToB) and b) the amount needed to trade (amountIn) to move
   * the pool price to be equal to the true price.
   * @dev Note that this method uses the Babylonian square root method which has a small margin of error which will
   * result in a small over or under estimation on the size of the trade needed.
   * @param truePriceTokenA the nominator of the true price.
   * @param truePriceTokenB the denominator of the true price.
   * @param reserveA number of token A in the pair reserves
   * @param reserveB number of token B in the pair reserves
   */
  //
  function computeTradeToMoveMarket(
    uint256 truePriceTokenA,
    uint256 truePriceTokenB,
    uint256 reserveA,
    uint256 reserveB,
    uint256 tradingFee
  ) public pure returns (bool aToB, uint256 amountIn) {
    aToB = FullMath.mulDiv(reserveA, truePriceTokenB, reserveB) < truePriceTokenA;

    uint256 invariant = reserveA.mul(reserveB);
    uint256 tradingFeeFactor = 10000 - tradingFee;
    uint256 leftSide = Babylonian.sqrt(
      FullMath.mulDiv(
        invariant.mul(10000),
        aToB ? truePriceTokenA : truePriceTokenB,
        (aToB ? truePriceTokenB : truePriceTokenA).mul(tradingFeeFactor)
      )
    );
    uint256 rightSide = (aToB ? reserveA.mul(10000) : reserveB.mul(10000)) / tradingFeeFactor;

    if (leftSide < rightSide) return (false, 0);

    amountIn = leftSide.sub(rightSide);
  }

  // The methods below are taken from https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/libraries/UniswapV2Library.sol
  // We could import this library into this contract but this library is dependent Uniswap's SafeMath, which is bound
  // to solidity 6.6.6. UMA uses 0.8.0 and so a modified version is needed to accomidate this solidity version.
  function getReserves(
    address factory,
    address tokenA,
    address tokenB
  ) public view returns (uint256 reserveA, uint256 reserveB) {
    (address token0, ) = sortTokens(tokenA, tokenB);
    (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB))
      .getReserves();
    (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
  }

  function sortTokens(address tokenA, address tokenB)
    internal
    pure
    returns (address token0, address token1)
  {
    require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
    (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
  }

  function pairFor(
    address factory,
    address tokenA,
    address tokenB
  ) public view returns (address pair) {
    return IUniswapV2Factory(factory).getPair(tokenA, tokenB);
  }
}

// File: @uniswap/v2-periphery/contracts/interfaces/IWETH.sol

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol

pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// File: @openzeppelin/contracts/utils/Address.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


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

// File: contracts/Interfaces/UnifiPair.sol


pragma solidity ^0.8.4;


interface IUnifiPair is IERC20 {
  function claimUP(address to) external returns (uint256 upReceived);
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;



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

// File: contracts/Helpers/Safe.sol



pragma solidity ^0.8.4;


abstract contract Safe {
  using SafeERC20 for IERC20;

  address target;

  constructor(address _target) {
    target = _target;
  }

  function _withdrawFunds() internal returns (bool) {
    (bool sent, ) = address(target).call{value: address(this).balance}("");
    require(sent, "Safe: Failed to send Ether");
    return sent;
  }

  function _withdrawFundsERC20(address tokenAddress) internal returns (bool) {
    IERC20 token = IERC20(tokenAddress);
    token.safeTransfer(target, token.balanceOf(address(this)));
    return true;
  }
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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
interface IERC165 {
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

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
}

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




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
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/access/IAccessControl.sol


// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// File: @openzeppelin/contracts/access/AccessControl.sol


// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;





/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// File: contracts/Strategies/Strategy.sol



pragma solidity ^0.8.4;




// Contract Strategy must use our customized Safe.sol and OpenZeppelin's AccessControl and Pauseable Contracts.
// Safe.sol is utilized so the DAO can retrieve any lost assets within the Strategy Contract.
// AccessControl.sol is utilized so only the Rebalancer can interact with the strategy, and only the DAO can update the Rebalancer Contract.
// Pausable.sol is utilized so that DAO can pause the strategy in an emergency.

contract Strategy is Safe, AccessControl, Pausable {
  bytes32 public constant REBALANCER_ROLE = keccak256("REBALANCER_ROLE");

  /// @notice The amountDeposited MUST reflect the amount of native tokens currently deposited into other contracts.
  uint256 public amountDeposited = 0;

  modifier onlyAdmin() {
    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Strategy: ONLY_ADMIN");
    _;
  }

  modifier onlyRebalancer() {
    require(hasRole(REBALANCER_ROLE, msg.sender), "Strategy: ONLY_REBALANCER");
    _;
  }

  constructor(address _fundsTarget) Safe(_fundsTarget) {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  receive() external payable virtual {}

  event Gather();
  event Deposit(uint256);
  event Withdraw(uint256);

  struct Rewards {
    uint256 rewardsAmount;
    uint256 depositedAmount;
    uint256 timestamp;
  }

  // Read Functions

  ///@notice The public checkRewards function MUST return a struct with the amount of pending rewards valued in native tokens, the total amount deposited, and the block timestamp.
  ///For example, if 500 NativeTokens are deposited, and the strategy has earned 5 Native Tokens and 2 of TokenA,
  ///the function should calculate the return for selling 2 TokenA, and add to the 5 Native Tokens.
  ///If we assume that each TokenA is worth 4 native tokens, then the unclaimedEarnings value should return a value of 13, adjusted for percision.

  function checkRewards() public view virtual returns (Rewards memory) {
    uint256 rewards = address(this).balance - amountDeposited;
    Rewards memory result = Rewards(rewards, amountDeposited, block.timestamp * 1000);
    return result;
  }

  // Write Functions

  ///@notice The deposit function should receive native tokens and then deposit them into your strategy.
  ///For example, if your strategy is depositing native tokens into a lending protocol, the deposit function should contain all the logic to transfer tokens into the lending protocol.
  ///In addition, the depositValue should be updated to reflect the tokens deposited into your strategy.
  ///@param depositValue If using native tokens, the parameter should equal the payable amount of the function. This is kept as a parameter in the case a strategy is utilized that does not use native tokens. You will receive an unused parameter warning.

  function deposit(uint256 depositValue)
    public
    payable
    virtual
    onlyRebalancer
    whenNotPaused
    returns (bool)
  {
    require(
      depositValue == msg.value,
      "Strategy: Deposit Value Parameter does not equal payable amount"
    );
    //Work your magic here - Code the logic to earn yield!
    amountDeposited += depositValue;
    emit Deposit(depositValue);
    return true;
  }

  ///@notice The withdraw function should withdraw an amount from your strategy and send them to the rebalancer.
  ///For example, if using a lending protocol, this function should withdraw tokens from the strategy, and send them to the rebalancer.
  ///In addition, the depositValue should be updated to reflect the tokens withdrawn into your strategy. UP requires all tokens returned to the balancer be in native token format.
  ///@param amount This is the amount of native tokens that is to be withdrawn from the strategy.

  function withdraw(uint256 amount) public virtual onlyRebalancer whenNotPaused returns (bool) {
    require(
      amount <= amountDeposited,
      "Strategy: Amount Requested to Withdraw is Greater Than Amount Deposited"
    );
    //Work your magic here - Code the logic to withdraw and send the requested amount of native tokens here!
    (bool successTransfer, ) = address(msg.sender).call{value: amount}("");
    require(successTransfer, "Strategy: FAIL_SENDING_NATIVE");
    amountDeposited -= amount;
    emit Withdraw(amount);
    return successTransfer;
  }

  ///@notice The withdrawAll function should withdraw all native tokens, including rewards as native tokens, and send them to the rebalancer.

  function withdrawAll() external virtual onlyRebalancer whenNotPaused returns (bool) {
    //Get all those tokens here - code the logic to withdraw all here!
    uint256 balance = address(this).balance;
    (bool successTransfer, ) = address(msg.sender).call{value: balance}("");
    require(successTransfer, "Strategy: FAIL_SENDING_NATIVE");
    amountDeposited -= balance;
    return true;
  }

  ///@notice The gather function should claim all yield earned from the native tokens while leaving the amount deposited intact.
  ///Then, this function should send all earnings to the rebalancer contract. This function MUST only send native tokens to the rebalancer.
  ///For example, if the tokens are deposited in a lending protocol, it should the totalBalance minus the amountDeposited.

  function gather() public virtual onlyRebalancer whenNotPaused {
    //Claim all those rewards here
    uint256 nativeAmount = address(this).balance - amountDeposited;
    (bool successTransfer, ) = address(msg.sender).call{value: nativeAmount}("");
    require(successTransfer, "Strategy: FAIL_SENDING_NATIVE");
    emit Gather();
  }

  function withdrawFunds() public onlyAdmin returns (bool) {
    return _withdrawFunds();
  }

  function withdrawFundsERC20(address tokenAddress) public onlyAdmin returns (bool) {
    return _withdrawFundsERC20(tokenAddress);
  }
}

// File: contracts/UP.sol



pragma solidity ^0.8.4;



contract UP is ERC20, AccessControl {
  bytes32 public constant MINT_ROLE = keccak256("MINT_ROLE");
  bytes32 public constant LEGACY_MINT_ROLE = keccak256("LEGACY_MINT_ROLE");
  address public UP_CONTROLLER = address(0);

  event SetUPController(address _setter, address _newController);

  modifier onlyMint() {
    require(hasRole(MINT_ROLE, msg.sender), "UP: ONLY_MINT");
    _;
  }

  modifier onlyAdmin() {
    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "UP: ONLY_ADMIN");
    _;
  }

  constructor() ERC20("UP", "UP") {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  /// @notice UPv1 legacy
  receive() external payable {}

  function burn(uint256 amount) public {
    _burn(_msgSender(), amount);
  }

  function burnFrom(address account, uint256 amount) public {
    _spendAllowance(account, _msgSender(), amount);
    _burn(account, amount);
  }

  /// @notice Retrocompatible function with v1
  function justBurn(uint256 amount) external {
    burn(amount);
  }

  /// @notice Mints token and have logic for supporting legacy mint logic
  function mint(address to, uint256 amount) public payable onlyMint returns (bool) {
    /// LEGACY_MINT_ROLE retrocompatible with UPv1
    if (hasRole(LEGACY_MINT_ROLE, msg.sender) && UP_CONTROLLER != address(0)) {
      (bool success, ) = UP_CONTROLLER.call{value: msg.value}(
        abi.encodeWithSignature(("mintUP(address)"), to)
      );
      require(success, "UP: LEGACY_MINT_FAILED");
    } else {
      _mint(to, amount);
    }
    /// Legacy UPv1 return
    return true;
  }

  /// @notice Sets a controller address that will receive the funds from LEGACY_MINT_ROLE
  function setController(address newController) public onlyAdmin {
    UP_CONTROLLER = newController;
    emit SetUPController(msg.sender, newController);
  }

  function withdrawFunds() public {
    require(UP_CONTROLLER != address(0));
    (bool success, ) = UP_CONTROLLER.call{value: address(this).balance}("");
    require(success);
  }
}

// File: contracts/UPController.sol



pragma solidity ^0.8.4;





/// @title UP Controller
/// @author dxffffff & A Fistful of Stray Cat Hair
/// @notice This controller back up the UP token and has the logic for borrowing tokens.

contract UPController is AccessControl, Safe, Pausable {
  bytes32 public constant REBALANCER_ROLE = keccak256("REBALANCER_ROLE");
  bytes32 public constant REDEEMER_ROLE = keccak256("REDEEMER_ROLE");

  address payable public UP_TOKEN = payable(address(0));
  uint256 public nativeBorrowed = 0;
  uint256 public upBorrowed = 0;

  event SyntheticMint(address _from, uint256 _amount, uint256 _newUpBorrowed);
  event BorrowNative(address _from, uint256 _amount, uint256 _newNativeBorrowed);
  event Repay(uint256 _nativeAmount, uint256 _upAmount);
  event Redeem(uint256 _upAmount, uint256 _redeemAmount);

  modifier onlyRebalancer() {
    require(hasRole(REBALANCER_ROLE, msg.sender), "UPController: ONLY_REBALANCER");
    _;
  }

  modifier onlyAdmin() {
    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "UPController: ONLY_ADMIN");
    _;
  }

  modifier onlyRedeemer() {
    require(hasRole(REDEEMER_ROLE, msg.sender), "UPController: ONLY_REDEEMER");
    _;
  }

  constructor(address _UP, address _fundsTarget) Safe(_fundsTarget) {
    require(_UP != address(0), "UPController: INVALID_UP_ADDRESS");
    UP_TOKEN = payable(_UP);
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  receive() external payable {}

  /// @notice Returns price of UP token based on its reserves
  function getVirtualPrice() public view returns (uint256) {
    if (getNativeBalance() == 0) return 0;
    return ((getNativeBalance() * 1e18) / actualTotalSupply());
  }

  /// @notice Returns price of UP token based on its reserves minus amount sent to the contract
  /// Note this is for legacy V1 uTrade transactions
  function getVirtualPrice(uint256 sentValue) public view returns (uint256) {
    if (getNativeBalance() == 0) return 0;
    uint256 nativeBalance = getNativeBalance() - sentValue;
    return ((nativeBalance * 1e18) / actualTotalSupply());
  }

  /// @notice Computed the actual native balances of the contract
  function getNativeBalance() public view returns (uint256) {
    return address(this).balance + nativeBorrowed;
  }

  /// @notice Computed total supply of UP token
  function actualTotalSupply() public view returns (uint256) {
    return UP(UP_TOKEN).totalSupply() - upBorrowed;
  }

  /// @notice Borrows native tokens from comntroller
  function borrowNative(uint256 _borrowAmount, address _to) public onlyRebalancer whenNotPaused {
    require(address(this).balance >= _borrowAmount, "UPController: NOT_ENOUGH_BALANCE");
    (bool success, ) = _to.call{value: _borrowAmount}("");
    require(success, "UPController: BORROW_NATIVE_FAILED");
    emit BorrowNative(_to, _borrowAmount, nativeBorrowed);
  }

  /// @notice Borrows UP token minting it
  function borrowUP(uint256 _borrowAmount, address _to) public onlyRebalancer whenNotPaused {
    UP(UP_TOKEN).mint(_to, _borrowAmount);
  }

  /// @notice Mints UP based on virtual price - UPv1 logic
  function mintUP(address to) external payable whenNotPaused {
    require(msg.sender == UP_TOKEN, "UPController: NON_UP_CONTRACT");
    uint256 mintAmount = (msg.value * 1e18) / getVirtualPrice(msg.value);
    UP(UP_TOKEN).mint(to, mintAmount);
  }

  /// @notice Allows to return back borrowed amounts to the controller
  function repay(uint256 upAmount) public payable onlyRebalancer whenNotPaused {
    UP(UP_TOKEN).burnFrom(msg.sender, upAmount);
  }

  function setBorrowedAmounts(
    uint256 upAmount,
    uint256 nativeAmount
  ) public onlyRebalancer whenNotPaused {
    upBorrowed = upAmount;
    nativeBorrowed = nativeAmount;
  }

  /// @notice Swaps UP token by native token
  function redeem(uint256 upAmount) public onlyRedeemer onlyRebalancer whenNotPaused {
    require(upAmount > 0, "UPController: AMOUNT_EQ_0");
    uint256 redeemAmount = (getVirtualPrice() * upAmount) / 1e18;
    UP(UP_TOKEN).burnFrom(msg.sender, upAmount);
    (bool success, ) = msg.sender.call{value: redeemAmount}("");
    require(success, "UPController: REDEEM_FAILED");
    emit Redeem(upAmount, redeemAmount);
  }

  function pause() public onlyAdmin {
    _pause();
  }

  function unpause() public onlyAdmin {
    _unpause();
  }

  function withdrawFunds() public onlyAdmin returns (bool) {
    return _withdrawFunds();
  }

  function withdrawFundsERC20(address tokenAddress) public onlyAdmin returns (bool) {
    return _withdrawFundsERC20(tokenAddress);
  }
}

// File: contracts/Rebalancer.sol



pragma solidity ^0.8.4;












contract Rebalancer is AccessControl, Pausable, Safe {
  using SafeERC20 for IERC20;

  address public WETH;
  address public factory;
  uint256 public tradingFeeOfAMM = 25; //Calculated in basis points. i.e. 30 = 0.3%
  uint256 public maximumAllocationLPWithLockup = 79; // Whole Number for Percent, i.e. 5 = 5%. MAKE UPGRADEABLE
  bool public strategyLockup; // if True, funds in Strategy are cannot be withdrawn immediately (such as staking on Harmony). If false, funds in Strategy are always available (such as AAVE on Polygon).

  IUnifiPair public liquidityPool;
  IUniswapV2Router02 public router;
  UP public UPToken;
  UPController public UP_CONTROLLER;
  Strategy public strategy;
  uint256 private initRewardsPos = 0;
  Strategy.Rewards[] public rewards;

  //DAO Parameters

  uint256 public allocationLP = 100; // Whole Number for Percent, i.e. 5 = 5%. If StrategyLockup = true, maximum amount is 100 - maximumAllocationLPWithLockup
  //If there is no strategy, the allocationLP will default to 100%
  uint256 public callerReward = 10; // Whole Number for Percent, i.e. 5 = 5%. Represents the profit of rebalance that will go to the caller of the rebalance.
  uint256 public allocationRedeem = 0; //Whole Number for Percent, i.e 5 = 5%. If a balance is required for redeeming UP, simply set this variable to a percent.
  modifier onlyAdmin() {
    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Rebalancer: ONLY_ADMIN");
    _;
  }

  constructor(
    address _WETH,
    address _factory,
    address _Strategy,
    address _UPAddress,
    address _UPController,
    address _router,
    address _liquidityPool,
    address _fundsTarget
  ) Safe(_fundsTarget) {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    WETH = _WETH;
    setUPController(_UPController);
    strategy = Strategy(payable(_Strategy));
    UPToken = UP(payable(_UPAddress));
    router = IUniswapV2Router02(_router);
    factory = _factory;
    liquidityPool = IUnifiPair(payable(_liquidityPool));
  }

  // Read Functions

  function getLiquidityPoolBalance(
    uint256 reserves0,
    uint256 reserves1
  ) public view returns (uint256, uint256) {
    uint256 lpBalance = liquidityPool.balanceOf(address(this));
    if (lpBalance == 0) {
      return (0, 0);
    }
    uint256 totalSupply = liquidityPool.totalSupply();
    uint256 amount0 = (lpBalance * reserves0) / totalSupply;
    uint256 amount1 = (lpBalance * reserves1) / totalSupply;
    return (amount0, amount1);
  }

  function moveMarketBuyAmount()
    public
    view
    returns (bool aToB, uint256 amountIn, uint256 reservesUP, uint256 reservesETH, uint256 upPrice)
  {
    (reservesUP, reservesETH) = UniswapHelper.getReserves(factory, address(UPToken), address(WETH));
    upPrice = UP_CONTROLLER.getVirtualPrice();

    (aToB, amountIn) = UniswapHelper.computeTradeToMoveMarket(
      1000000000000000000, // Ratio = 1:UPVirtualPrice
      upPrice,
      reservesUP,
      reservesETH,
      tradingFeeOfAMM
    );
    return (aToB, amountIn, reservesUP, reservesETH, upPrice);
  }

  function getRewardsLength() public view returns (uint256) {
    return rewards.length - initRewardsPos;
  }

  function getReward(uint256 position) public view returns (Strategy.Rewards memory) {
    return rewards[initRewardsPos + position];
  }

  // Write Functions

  function rebalance() public whenNotPaused returns (uint256 proceeds, uint256 callerProfit) {
    // Store a snapshot of the rewards
    // Step 1
    if (address(strategy) != address(0)) {
      Strategy.Rewards memory strategyRewards = strategy.checkRewards();
      _saveReward(strategyRewards);

      // Withdraw the entire balance of the strategy
      // Step 2

      if (strategyLockup == true) {
        strategy.gather();
        uint256 amountToWithdraw = address(strategy).balance;
        strategy.withdraw(amountToWithdraw);
        (bool success1, ) = address(UP_CONTROLLER).call{value: address(this).balance}("");
        require(success1, "Rebalancer: FAIL_WITHDRAWING_FROM_STRATEGY");
      } else {
        strategy.withdrawAll();
        (bool success2, ) = address(UP_CONTROLLER).call{value: address(this).balance}("");
        require(success2, "Rebalancer: FAIL_WITHDRAWING_ALL_FROM_STRATEGY");
      }
    }

    // Withdraw the entire balance of the LP
    // Step 3
    uint256 lpTokenBalance = IERC20(liquidityPool).balanceOf(address(this));
    if (lpTokenBalance != 0) {
      liquidityPool.approve(address(router), lpTokenBalance);
      (uint256 amountToken, ) = router.removeLiquidityETH(
        address(UPToken),
        lpTokenBalance,
        0,
        0,
        address(this),
        block.timestamp + 150
      );
      UPToken.approve(address(UP_CONTROLLER), amountToken);
      UPController(UP_CONTROLLER).repay{value: address(this).balance}(amountToken);
    }
    _setBorrowedBalances();
    // UP Controller now has all available funds
    // Step 4 - Arbitrage
    _arbitrage();
    // Calculate Allocations
    // MOVE REFUND HERE?
    (proceeds, callerProfit) = _refund();
    // Step 5 - Refill LP
    uint256 totalETH = UP_CONTROLLER.getNativeBalance(); //Accounts for locked strategies as well as rebalanced pool
    uint256 targetLpAmount = (totalETH * allocationLP) / 100; // NEED TO ADD IF THERE IS NO STRAT
    uint256 backedValue = UP_CONTROLLER.getVirtualPrice(); // This Virtual Price will be inaccurate
    uint256 upToAdd = ((targetLpAmount * 1e18) / backedValue);
    UP_CONTROLLER.borrowUP(upToAdd, address(this));
    UP_CONTROLLER.borrowNative(targetLpAmount, address(this));
    // ERC20 Approval
    UPToken.approve(address(router), upToAdd);
    // Adds liquidity
    router.addLiquidityETH{value: targetLpAmount}(
      address(UPToken),
      upToAdd,
      0,
      0,
      address(this),
      block.timestamp + 150
    );
    // Step 6 - Refill Strategy
    if (address(strategy) != address(0)) {
      uint256 strategySend = address(UP_CONTROLLER).balance;
      if (allocationRedeem > 0) {
        uint256 strategyAllocation = 100 - allocationRedeem;
        uint256 strategyAmount = (strategySend * strategyAllocation) / 100;
        strategySend = strategyAmount;
      }
      UP_CONTROLLER.borrowNative(strategySend, address(this));
      strategy.deposit{value: strategySend}(strategySend);
    }
    // Step 7 - Profit?

    //EMIT EVENT HERE
    //Step 8 - Update UP Controller Variables
    uint256 nativeRemoved = targetLpAmount;
    if (address(strategy) != address(0)) {
      nativeRemoved += strategy.amountDeposited();
    }
    UP_CONTROLLER.setBorrowedAmounts(upToAdd, nativeRemoved);

    return (proceeds, callerProfit);
  }

  // ADD WITHDRAW FROM LP ADMIN FUNCTION
  // ADD WITHDRAW FROM STRATEGY ADMIN FUNCTION

  // Internal Functions

  function _arbitrage() internal {
    (
      bool aToB, // The direction of the arbitrage. If true, Darbi is buying UP from the LP. If false, Darbi is selling UP to the LP.
      uint256 amountIn, //if buying UP, number returned is in native value. If selling UP, number returned in UP value.
      uint256 reserves0,
      uint256 reserves1,
      uint256 backedValue // The current backed Value of
    ) = moveMarketBuyAmount();

    // aToB == true == Buys UP
    // aToB == fals == Sells UP
    uint256 fundsAvailable = (address(UP_CONTROLLER).balance / 3);
    // Checks amount Native Tokens available for Darbi, either from the Controller or the Strategy
    uint256 tradeSize;
    // Declaring variable in advance. Represents the amount of token input per transaction, determined based on the actual trade size, or the maximum size available - whichever is lower.
    // For example, if buying UP, and if 100 BNB is required to move the market so that backed value = market value, and 120 BNB is available - then the tradeSize is 100 BNB.
    // However, if buying UP, and if 100 BNB is requred to move the market so that backed value = market value, and 50 BNB is available - then the tradeSize is 50 BNB.
    uint256 actualAmountIn;
    // Declaring variable in advance. Represents the total amount of native token input required to move the market so backed value = market value.
    // If buying UP, this value will be the same as the amountIn. If selling UP, this value will be the amountIn * backedValue.

    // If Buying UP
    if (!aToB) {
      actualAmountIn == amountIn;
      while (actualAmountIn > 0) {
        // Sets a loop so that if the amount of native tokens required to move the market so that MV = BV is larger than the funds available, the transaction will repeat until the prices match.
        if (actualAmountIn > fundsAvailable) {
          // Checks if amount of native required to move the market is greater than funds available in the strategy / controller
          tradeSize = fundsAvailable;
          // Sets tradesize to amount of funds Darbi has access to.
          actualAmountIn -= tradeSize;
          // Reduces the amount required to complete market movement.
        } else {
          // If there is enough funds available to move the market so that MV = BV, the tradeSize will equal the amount required, and will not repeat.
          tradeSize = actualAmountIn;
          actualAmountIn == 0;
        }

        uint256 expectedReturn = UniswapHelper.getAmountOut(
          tradeSize,
          reserves1,
          reserves0,
          tradingFeeOfAMM
        ); // Amount of UP expected from Buy
        uint256 expectedNativeReturn = (expectedReturn * backedValue) / 1e18; //Amount of Native Tokens Expected to Receive from Redeem
        uint256 upControllerBalance = (address(UP_CONTROLLER).balance / 3) * 2;

        if (upControllerBalance < expectedNativeReturn) {
          // If upControllerBalance below amountOut of UP required, then triggers rebalance.
          // Checks if there is enough native tokens in the UP Controller to redeem the UP purchased
          uint256 upOutput = (upControllerBalance * 1e18) / backedValue;
          // Gets the maximum amount of UP that can be redeemed.
          tradeSize = UniswapHelper.getAmountIn(upOutput, reserves1, reserves0, tradingFeeOfAMM);
          // Calculates the amount of native tokens required to purchase the maxiumum of UP that can be redeemed.
          actualAmountIn += (tradeSize - upOutput);
          // Adjusts the total amount required to move market to account for the smaller trade size. Note this transaction will still end with MV=BV, just requires more loops.
        }

        UP_CONTROLLER.borrowNative(tradeSize, address(this));
        _arbitrageBuy(tradeSize, expectedReturn);
        UP_CONTROLLER.repay{value: tradeSize}(0);
      }
    } else {
      // If Selling Up
      while (
        amountIn > 100 //As there may be a slight rounding in UP sales, a small amount of UP token dust may occur. This allows for dust + rounding of 100 gwei of UP
      ) {
        actualAmountIn = amountIn *= backedValue;
        // Calculates the amount of native tokens required to mint the amount of UP to sell into the LP.
        if (actualAmountIn > fundsAvailable) {
          // Checks if amount of native required to move the market is greater than funds available in the strategy / controller
          tradeSize = fundsAvailable;
          // Sets tradesize to amount of funds Darbi has access to.
          actualAmountIn -= tradeSize;
          // Reduces the amount required to complete market movement.
        } else {
          // If there is enough funds available to move the market so that MV = BV, the tradeSize will equal the amount required, and will not repeat.
          tradeSize = actualAmountIn;
          actualAmountIn == 0;
        }
        uint256 minNativeFromSale = tradeSize / backedValue;
        UP_CONTROLLER.borrowNative(tradeSize, address(this));
        uint256 upSold = _arbitrageSell(tradeSize, minNativeFromSale, backedValue);
        //Needs
        amountIn -= upSold;
        // Takes the amount of UP minted and sold in this transaction, and subtracts it from the total amount of UP required to move the market so that MV = BV
      }
    }
    // Returns the total profit in native tokens expected by the transaction.
    // If this arbitrage is triggered by a public caller, returns the amount of 'reward' the caller will receive. If triggered by the rebalancer, returns 0.
  }

  function _arbitrageBuy(uint256 amountIn, uint256 expectedReturn) internal {
    address[] memory path = new address[](2);
    path[0] = WETH;
    path[1] = address(UPToken);

    uint256[] memory amounts = router.swapExactETHForTokens{value: amountIn}(
      expectedReturn,
      path,
      address(this),
      block.timestamp + 150
    );

    UPToken.approve(address(UP_CONTROLLER), amounts[1]);
    _redeem(amounts[1]);
  }

  function _arbitrageSell(
    uint256 tradeSize,
    uint256 minNativeFromSale,
    uint256 backedValue
  ) internal returns (uint256 up2Balance) {
    // If selling UP
    _mintUP(tradeSize, backedValue);

    address[] memory path = new address[](2);
    path[0] = address(UPToken);
    path[1] = WETH;

    up2Balance = UPToken.balanceOf(address(this));
    UPToken.approve(address(router), up2Balance);
    router.swapExactTokensForETH(
      up2Balance,
      minNativeFromSale,
      path,
      address(this),
      block.timestamp + 150
    );
  }

  function _setBorrowedBalances() internal whenNotPaused {
    if (strategyLockup == true) {
      UP_CONTROLLER.setBorrowedAmounts(
        0,
        (address(UP_CONTROLLER).balance - strategy.amountDeposited())
      );
    } else {
      UP_CONTROLLER.setBorrowedAmounts(0, 0);
    }
  }

  /// @notice Mints UP at the mint rate, deposits the native tokens to the UP Controller, Sends UP to the Msg.sender
  function _mintUP(uint256 tradeSize, uint256 backedValue) internal whenNotPaused {
    if (backedValue == 0) return;
    uint256 mintAmount = (tradeSize * 1e18) / backedValue;
    UPToken.mint(address(this), mintAmount);
    (bool success, ) = address(UP_CONTROLLER).call{value: tradeSize}("");
    require(success, "Rebalancer: FAIL_SENDING_UP_BACKIng_TO_CONTROLLER");
  }

  /// @notice Allows Rebalancer to redeem the native tokens backing UP
  function _redeem(uint256 upAmount) internal whenNotPaused {
    UPToken.approve(address(UP_CONTROLLER), upAmount);
    uint256 prevBalance = address(this).balance;
    UP_CONTROLLER.redeem(upAmount);
    uint256 postBalance = address(this).balance;
    require(postBalance > prevBalance, "Rebalancer: FAIL_TO_REDEEM_ON_ARBITRAGE_SELL");
  }

  function _refund() internal returns (uint256 proceeds, uint256 callerBonus) {
    proceeds = address(this).balance;
    // Any leftover funds in the contract is profit. Yay!
    callerBonus = ((proceeds * callerReward) / 100);
    (bool success2, ) = (msg.sender).call{value: callerBonus}("");
    require(success2, "Rebalancer: FAIL_SENDING_PROFITS_TO_CALLER");
    //Could be a check if Redeem is turned on
    UP_CONTROLLER.repay{value: address(this).balance}(0);
    return (proceeds, callerBonus);
  }

  function _saveReward(Strategy.Rewards memory reward) internal {
    if (getRewardsLength() == 10) {
      delete rewards[initRewardsPos];
      initRewardsPos += 1;
    }
    rewards.push(reward);
  }

  // Setter Functions

  function setStrategy(address newAddress) public onlyAdmin {
    // Can be 0x00
    strategy = Strategy(payable(newAddress));
  }

  function setUPController(address newAddress) public onlyAdmin {
    require(newAddress != address(0));
    UP_CONTROLLER = UPController(payable(newAddress));
  }

  function setStrategyLockup(bool isTrue) public onlyAdmin {
    strategyLockup = isTrue;
  }

  function setCallerReward(uint256 percentCallerReward) public onlyAdmin {
    require(percentCallerReward <= 100);
    callerReward = percentCallerReward;
  }

  function setAllocationLP(uint256 _allocationLP) public onlyAdmin {
    if (strategyLockup == true) {
      require(_allocationLP < maximumAllocationLPWithLockup);
    }
    allocationLP = _allocationLP;
  }

  function setAllocationRedeem(uint256 _allocationRedeem) public onlyAdmin {
    require(_allocationRedeem <= 100);
    allocationRedeem = _allocationRedeem;
  }

  function setmaximumAllocationLPWithLockup(
    uint256 _maximumAllocationLPWithLockup
  ) public onlyAdmin {
    require(_maximumAllocationLPWithLockup <= 100);
    maximumAllocationLPWithLockup = _maximumAllocationLPWithLockup;
  }

  // Admin Functions

  /// @notice Permissioned function to withdraw any native coins accidentally deposited to the Public Mint contract.
  function withdrawFunds() public onlyAdmin returns (bool) {
    return _withdrawFunds();
  }

  /// @notice Permissioned function to withdraw any tokens accidentally deposited to the Public Mint contract.
  function withdrawFundsERC20(address tokenAddress) public onlyAdmin returns (bool) {
    return _withdrawFundsERC20(tokenAddress);
  }

  // Fallback Function
  receive() external payable {}
}