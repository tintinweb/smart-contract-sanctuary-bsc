// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC20, IERC20WithDecimals} from "../interfaces/IERC20WithDecimals.sol";
import {IZapDepositor} from "../interfaces/IZapDepositor.sol";
import {IStableSwap} from "../interfaces/IStableSwap.sol";
import {ICurveSwapRouter} from "../interfaces/ICurveSwapRouter.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import { IARTHusdRebase } from "../interfaces/IARTHusdRebase.sol";

contract CurveSwapRouter is ICurveSwapRouter {
  using SafeMath for uint256;

  IERC20WithDecimals public lp;
  IZapDepositor public zap;
  address public pool;

  IARTHusdRebase public arthUsd;
  IERC20WithDecimals public arth;
  IERC20WithDecimals public usdc;
  IERC20WithDecimals public usdt;
  IERC20WithDecimals public busd;

  address private me;

  constructor(
    address _zap,
    address _lp,
    address _pool,
    address _arth,
    address _arthUsd,
    address _usdc,
    address _usdt,
    address _busd
  ) {
    pool = _pool;

    arthUsd = IARTHusdRebase(_arthUsd);
    zap = IZapDepositor(_zap);

    lp = IERC20WithDecimals(_lp);
    arth = IERC20WithDecimals(_arth);
    usdc = IERC20WithDecimals(_usdc);
    usdt = IERC20WithDecimals(_usdt);
    busd = IERC20WithDecimals(_busd);

    me = address(this);
  }

  function _sellARTHUSDForExact(
    uint256 amountARTHUSDInForBUSD,
    uint256 amountARTHUSDInForUSDC,
    uint256 amountARTHUSDInForUSDT,
    uint256 amountBUSDOutMin,
    uint256 amountUSDCOutMin,
    uint256 amountUSDTOutMin,
    address to,
    uint256 deadline
  ) internal {
    IStableSwap swap = IStableSwap(pool);

    if (amountBUSDOutMin > 0) {
      uint256 amountBUSDOutExpected = swap.get_dy_underlying(0, 1, amountARTHUSDInForBUSD);
      _requireExpectedOutGreaterThanMinOut(amountBUSDOutExpected, amountBUSDOutMin);
      swap.exchange_underlying(0, 1, amountARTHUSDInForBUSD, amountBUSDOutExpected, me);
    }

    if (amountUSDCOutMin > 0) {
      uint256 amountUSDCOutExpected = swap.get_dy_underlying(0, 2, amountARTHUSDInForUSDC);
      _requireExpectedOutGreaterThanMinOut(amountUSDCOutExpected, amountUSDCOutMin);
      swap.exchange_underlying(0, 2, amountARTHUSDInForUSDC, amountUSDCOutExpected, me);
    }

    if (amountUSDTOutMin > 0) {
      uint256 amountUSDTOutExpected = swap.get_dy_underlying(0, 3, amountARTHUSDInForUSDT);
      _requireExpectedOutGreaterThanMinOut(amountUSDTOutExpected, amountUSDTOutMin);
      swap.exchange_underlying(0, 3, amountARTHUSDInForUSDT, amountUSDTOutExpected, me);
    }

    require(block.timestamp <= deadline, "Swap: Deadline expired");
    _flush(to);
  }

  function sellARTHUSDForExact(
    uint256 amountARTHUSDInForBUSD,
    uint256 amountARTHUSDInForUSDC,
    uint256 amountARTHUSDInForUSDT,
    uint256 amountBUSDOutMin,
    uint256 amountUSDCOutMin,
    uint256 amountUSDTOutMin,
    address to,
    uint256 deadline
  ) external override {
    uint256 amountARTHUSDIn = amountARTHUSDInForBUSD
      .add(amountARTHUSDInForUSDC)
      .add(amountARTHUSDInForUSDT);
    arthUsd.transferFrom(msg.sender, me, amountARTHUSDIn);
    arthUsd.approve(pool, amountARTHUSDIn);

    _sellARTHUSDForExact(
      amountARTHUSDInForBUSD, 
      amountARTHUSDInForUSDC, 
      amountARTHUSDInForUSDT, 
      amountBUSDOutMin, 
      amountUSDCOutMin, 
      amountUSDTOutMin, 
      to, 
      deadline
    );
  }

  function _buyARTHUSDForExact(
    uint256 amountBUSDIn,
    uint256 amountUSDCIn,
    uint256 amountUSDTIn,
    uint256 amountARTHUSDOutMinForBUSD,
    uint256 amountARTHUSDOutMinForUSDC,
    uint256 amountARTHUSDOutMinForUSDT,
    uint256 deadline
  ) internal {
    IStableSwap swap = IStableSwap(pool);

    if (amountBUSDIn > 0) {
      busd.transferFrom(msg.sender, me, amountBUSDIn);
      busd.approve(pool, amountBUSDIn);
      uint256 arthUsdAmountExpected = swap.get_dy_underlying(1, 0, amountBUSDIn);
      _requireExpectedOutGreaterThanMinOut(arthUsdAmountExpected, amountARTHUSDOutMinForBUSD);
      swap.exchange_underlying(1, 0, amountBUSDIn, arthUsdAmountExpected, me);
    }

    if (amountUSDCIn > 0) {
      usdc.transferFrom(msg.sender, me, amountUSDCIn);
      usdc.approve(pool, amountUSDCIn);
      uint256 arthUsdAmountExpected = swap.get_dy_underlying(2, 0, amountUSDCIn);
      _requireExpectedOutGreaterThanMinOut(arthUsdAmountExpected, amountARTHUSDOutMinForUSDC);
      swap.exchange_underlying(2, 0, amountUSDCIn, arthUsdAmountExpected, me);
    }

    if (amountUSDTIn > 0) {
      usdt.transferFrom(msg.sender, me, amountUSDTIn);
      usdt.approve(pool, amountUSDTIn);
      uint256 arthUsdAmountExpected = swap.get_dy_underlying(3, 0, amountUSDTIn);
      _requireExpectedOutGreaterThanMinOut(arthUsdAmountExpected, amountARTHUSDOutMinForUSDT);
      swap.exchange_underlying(3, 0, amountUSDTIn, arthUsdAmountExpected, me);
    }

    require(block.timestamp <= deadline, "Swap: Deadline expired");
  }

  function buyARTHUSDForExact(
    uint256 amountBUSDIn,
    uint256 amountUSDCIn,
    uint256 amountUSDTIn,
    uint256 amountARTHUSDOutMinForBUSD,
    uint256 amountARTHUSDOutMinForUSDC,
    uint256 amountARTHUSDOutMinForUSDT,
    address to,
    uint256 deadline
  ) external override {
    _buyARTHUSDForExact(
      amountBUSDIn, 
      amountUSDCIn, 
      amountUSDTIn, 
      amountARTHUSDOutMinForBUSD, 
      amountARTHUSDOutMinForUSDC, 
      amountARTHUSDOutMinForUSDT,
      deadline
    );
    _flush(to);
  }

  function sellARTHForExact(
    uint256 amountARTHInForBUSD,
    uint256 amountARTHInForUSDC,
    uint256 amountARTHInForUSDT,
    uint256 amountBUSDOutMin,
    uint256 amountUSDCOutMin,
    uint256 amountUSDTOutMin,
    address to,
    uint256 deadline
  ) external override {
    uint256 amountARTHIn = amountARTHInForBUSD
      .add(amountARTHInForUSDC)
      .add(amountARTHInForUSDT);
    arth.transferFrom(msg.sender, me, amountARTHIn);

    uint256 arthUSDBalanceFromARTHForBUSD;
    uint256 arthUSDBalanceFromARTHForUSDC;
    uint256 arthUSDBalanceFromARTHForUSDT;

    if (amountBUSDOutMin > 0) {
      arthUsd.deposit(amountARTHInForBUSD);
      arthUSDBalanceFromARTHForBUSD = arthUsd.balanceOf(me);
    }

    if (amountUSDCOutMin > 0) {
      arthUsd.deposit(amountARTHInForUSDC);
      arthUSDBalanceFromARTHForUSDC = arthUsd.balanceOf(me).sub(arthUSDBalanceFromARTHForBUSD);
    }

    if (amountUSDTOutMin > 0) {
      arthUsd.deposit(amountARTHInForUSDT);
      arthUSDBalanceFromARTHForUSDT = arthUsd.balanceOf(me)
        .sub(arthUSDBalanceFromARTHForBUSD)
        .sub(arthUSDBalanceFromARTHForUSDC);
    }

    arthUsd.approve(pool, arthUsd.balanceOf(me));
    _sellARTHUSDForExact(
      arthUSDBalanceFromARTHForBUSD, 
      arthUSDBalanceFromARTHForUSDC, 
      arthUSDBalanceFromARTHForUSDT, 
      amountBUSDOutMin, 
      amountUSDCOutMin,
      amountUSDTOutMin, 
      to, 
      deadline
    );
  }

  function buyARTHForExact(
    uint256 amountBUSDIn,
    uint256 amountUSDCIn,
    uint256 amountUSDTIn,
    uint256 amountARTHUSDOutMinForBUSD,
    uint256 amountARTHUSDOutMinForUSDC,
    uint256 amountARTHUSDOutMinForUSDT,
    address to,
    uint256 deadline
  ) external override {
    _buyARTHUSDForExact(
      amountBUSDIn, 
      amountUSDCIn, 
      amountUSDTIn, 
      amountARTHUSDOutMinForBUSD, 
      amountARTHUSDOutMinForUSDC, 
      amountARTHUSDOutMinForUSDT,
      deadline
    );

    arthUsd.withdraw(
      arthUsd.balanceOf(me).mul(arthUsd.gonsPercision()).div(arthUsd.gonsPerFragment())
    );
    _flush(to);
  }

  function _addLiquidityUsingARTHusd(
    uint256 amountARTHusdIn,
    uint256 amountBUSDIn,
    uint256 amountUSDCIn,
    uint256 amountUSDTIn,
    uint256 minLpTokensOut,
    address to,
    uint256 deadline
  ) internal {
    busd.transferFrom(msg.sender, me, amountBUSDIn);
    usdc.transferFrom(msg.sender, me, amountUSDCIn);
    usdt.transferFrom(msg.sender, me, amountUSDTIn);

    arthUsd.approve(address(zap), amountARTHusdIn);
    busd.approve(address(zap), amountBUSDIn);
    usdc.approve(address(zap), amountUSDCIn);
    usdt.approve(address(zap), amountUSDTIn);

    uint256[4] memory amounts = [amountARTHusdIn, amountBUSDIn, amountUSDCIn, amountUSDTIn];
    
    uint256 expectedLpTokensOut = zap.calc_token_amount(pool, amounts, true);
    _requireExpectedOutGreaterThanMinOut(expectedLpTokensOut, minLpTokensOut);
    
    zap.add_liquidity(
      pool, 
      amounts,
      expectedLpTokensOut
    );

    require(block.timestamp <= deadline, "Swap: tx expired");
    _flush(to);
  }

  function addLiquidityUsingARTHusd(
    uint256 amountARTHusdIn,
    uint256 amountBUSDIn,
    uint256 amountUSDCIn,
    uint256 amountUSDTIn,
    uint256 minLpTokensOut,
    address to,
    uint256 deadline
  ) external override {
    arthUsd.transferFrom(msg.sender, me, amountARTHusdIn);
    _addLiquidityUsingARTHusd(
      amountARTHusdIn, 
      amountBUSDIn, 
      amountUSDCIn, 
      amountUSDTIn, 
      minLpTokensOut, 
      to, 
      deadline
    );
  }

  function addLiquidityUsingARTH(
    uint256 amountARTHIn,
    uint256 amountBUSDIn,
    uint256 amountUSDCIn,
    uint256 amountUSDTIn,
    uint256 minLpTokensOut,
    address to,
    uint256 deadline
  ) external override {
    arth.transferFrom(msg.sender, me, amountARTHIn);
    arthUsd.deposit(amountARTHIn);
   _addLiquidityUsingARTHusd(
      arthUsd.balanceOf(me), 
      amountBUSDIn, 
      amountUSDCIn, 
      amountUSDTIn, 
      minLpTokensOut, 
      to, 
      deadline
    );
  }

  function _removeLiquidityUsingARTHusd(
    uint256 amountLpIn,
    uint256 minBUSDOut,
    uint256 minUSDCOut,
    uint256 minUSDTOut,
    uint256 minARTHusdOut,
    uint256 deadline
  ) internal {
    lp.transferFrom(msg.sender, me, amountLpIn);
    lp.approve(address(zap), amountLpIn);

    uint256[4] memory minAmountsOut = [minARTHusdOut, minBUSDOut, minUSDCOut, minUSDTOut];
    zap.remove_liquidity(pool, amountLpIn, minAmountsOut);

    require(block.timestamp <= deadline, "Swap: expirde");
  }

  function removeLiquidityUsingARTHusd(
    uint256 amountLpIn,
    uint256 minBUSDOut,
    uint256 minUSDCOut,
    uint256 minUSDTOut,
    uint256 minARTHusdOut,
    address to,
    uint256 deadline
  ) external override {
    _removeLiquidityUsingARTHusd(
      amountLpIn,
      minBUSDOut,
      minUSDCOut,
      minUSDTOut,
      minARTHusdOut,
      deadline
    );

    _flush(to);
  }

  function removeLiquidityUsingARTH(
    uint256 amountLpIn,
    uint256 minBUSDOut,
    uint256 minUSDCOut,
    uint256 minUSDTOut,
    uint256 minARTHusdOut,
    address to,
    uint256 deadline
  ) external override {
    _removeLiquidityUsingARTHusd(
      amountLpIn,
      minBUSDOut,
      minUSDCOut,
      minUSDTOut,
      minARTHusdOut,
      deadline
    );

    arthUsd.withdraw(arthUsd.balanceOf(me));
    _flush(to);
  }

  function _flush(address to) internal {
    if (lp.balanceOf(me) > 0) lp.transfer(to, lp.balanceOf(me));
    if (arth.balanceOf(me) > 0) arth.transfer(to, arth.balanceOf(me));
    if (arthUsd.balanceOf(me) > 0) arthUsd.transfer(to, arthUsd.balanceOf(me));
    if (usdc.balanceOf(me) > 0) usdc.transfer(to, usdc.balanceOf(me));
    if (usdt.balanceOf(me) > 0) usdt.transfer(to, usdt.balanceOf(me));
    if (busd.balanceOf(me) > 0) busd.transfer(to, busd.balanceOf(me));
  }

  function _requireExpectedOutGreaterThanMinOut(uint256 expectedOut, uint256 minOut) internal pure {
    require(expectedOut >= minOut, "Swap: price has moved");
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20WithDecimals is IERC20 {
  function decimals() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IZapDepositor {
  function get_virtual_price() external view returns (uint256);

  function calc_token_amount(
    address pool,
    uint256[4] memory amounts,
    bool _is_deposit
  ) external view returns (uint256);

  function calc_withdraw_one_coin(
    address pool,
    uint256 _burn_amount,
    int128 i
  ) external view returns (uint256);

  function remove_liquidity_one_coin(
    address pool,
    uint256 _burn_amount,
    int128 i,
    uint256 _min_received
  ) external;

  function remove_liquidity_imbalance(
    address pool,
    uint256[4] memory _amounts,
    uint256 _max_burn_amount
  ) external;

  function remove_liquidity(
    address pool,
    uint256 burn_amount,
    uint256[4] memory min_amounts
  ) external;

  function add_liquidity(
    address pool,
    uint256[4] memory _deposit_amounts,
    uint256 min_mint_amount
  ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStableSwap {
  function get_dy(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);

  function exchange_underlying(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy,
    address _receiver
  ) external returns (uint256);

  function get_dy_underlying(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);

  function get_virtual_price() external view returns (uint256);

  function calc_token_amount(uint256[] memory amounts, bool _is_deposit)
    external
    view
    returns (uint256);

  function calc_withdraw_one_coin(uint256 _burn_amount, int128 i) external view returns (uint256);

  function remove_liquidity_one_coin(
    uint256 _burn_amount,
    int128 i,
    uint256 _min_received
  ) external;

  function remove_liquidity_imbalance(uint256[] memory _amounts, uint256 _max_burn_amount) external;

  function remove_liquidity(uint256 burn_amount, uint256[] memory min_amounts) external;

  function add_liquidity(uint256[] memory _deposit_amounts, uint256 min_mint_amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICurveSwapRouter {
  function sellARTHUSDForExact(
    uint256 amountARTHUSDInForBUSD,
    uint256 amountARTHUSDInForUSDC,
    uint256 amountARTHUSDInForUSDT,
    uint256 amountBUSDOutMin,
    uint256 amountUSDCOutMin,
    uint256 amountUSDTOutMin,
    address to,
    uint256 deadline
  ) external;

  function buyARTHUSDForExact(
    uint256 amountBUSDIn,
    uint256 amountUSDCIn,
    uint256 amountUSDTIn,
    uint256 amountARTHUSDOutMinForBUSD,
    uint256 amountARTHUSDOutMinForUSDC,
    uint256 amountARTHUSDOutMinForUSDT,
    address to,
    uint256 deadline
  ) external;
  
  function sellARTHForExact(
    uint256 amountARTHInForBUSD,
    uint256 amountARTHInForUSDC,
    uint256 amountARTHInForUSDT,
    uint256 amountBUSDOutMin,
    uint256 amountUSDCOutMin,
    uint256 amountUSDTOutMin,
    address to,
    uint256 deadline
  ) external;

  function buyARTHForExact(
    uint256 amountBUSDIn,
    uint256 amountUSDCIn,
    uint256 amountUSDTIn,
    uint256 amountARTHMinForBUSD,
    uint256 amountARTHMinForUSDC,
    uint256 amountARTHMinForUSDT,
    address to,
    uint256 deadline
  ) external;

  function addLiquidityUsingARTHusd(
    uint256 amountARTHusdIn,
    uint256 amountBUSDIn,
    uint256 amountUSDCIn,
    uint256 amountUSDTIn,
    uint256 minLpTokensOut,
    address to,
    uint256 deadline
  ) external;

  function addLiquidityUsingARTH(
    uint256 amountARTHIn,
    uint256 amountBUSDIn,
    uint256 amountUSDCIn,
    uint256 amountUSDTIn,
    uint256 minLpTokensOut,
    address to,
    uint256 deadline
  ) external;

  function removeLiquidityUsingARTHusd(
    uint256 amountLpIn,
    uint256 minBUSDOut,
    uint256 minUSDCOut,
    uint256 minUSDTOut,
    uint256 minARTHusdOut,
    address to,
    uint256 deadline
  ) external;

  function removeLiquidityUsingARTH(
    uint256 amountLpIn,
    uint256 minBUSDOut,
    uint256 minUSDCOut,
    uint256 minUSDTOut,
    uint256 minARTHusdOut,
    address to,
    uint256 deadline
  ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20Wrapper} from "./IERC20Wrapper.sol";

interface IARTHusdRebase is IERC20Wrapper {
  function gonsPerFragment()
    external
    view
    returns (uint256);

  function gonsDecimals()
    external
    view
    returns (uint256);

  function gonsPercision()
    external
    view
    returns (uint256);
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
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IERC20Wrapper is IERC20 {
  /// @dev Mint ERC20 token
  /// @param amount Token amount to wrap
  function deposit(uint256 amount) external returns (bool);

  /// @dev Burn ERC20 token to redeem LP ERC20 token back plus SUSHI rewards.
  /// @param amount Token amount to burn
  function withdraw(uint256 amount) external returns (bool);

  /// @dev pending rewards
  function accumulatedRewards() external view returns (uint256);

  function accumulatedRewardsFor(address _user) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[owner][spender];
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
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
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