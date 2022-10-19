/**
 *Submitted for verification at BscScan.com on 2022-10-19
*/

// SPDX-License-Identifier: MIT
// File: @uniswap/v2-periphery/contracts/interfaces/IWETH.sol

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// File: contracts/Strategies/IStrategy.sol

pragma solidity ^0.8.4;

interface IStrategy {
  struct Rewards {
    uint256 rewardsAmount;
    uint256 depositedAmount;
    uint256 timestamp;
  }

  /// @notice Deposits an initial or more liquidity in the external contract
  function deposit(uint256 amount) external payable returns (bool);

  /// @notice Withdraws all the funds deposited in the external contract
  function withdraw(uint256 amount) external returns (bool);

  function withdrawAll() external returns (bool);

  /// @notice This function will get all the rewards from the external service and send them to the invoker
  function gather() external;

  /// @notice Returns the amount staked plus the earnings
  function checkRewards() external view returns (Rewards memory);
}

// File: @openzeppelin/contracts/utils/Address.sol
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

library Address {
    
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

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

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

// File: @openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

interface IERC20Permit {
 
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

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

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
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

    function safePermit(
        IERC20Permit token,
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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// File: contracts/Interfaces/UnifiPair.sol

pragma solidity ^0.8.4;

interface IUnifiPair is IERC20 {
  function claimUP(address to) external returns (uint256 upReceived);
}

// File: contracts/Interfaces/IFactory.sol

pragma solidity ^0.8.4;

interface IFactory {
    function INIT_CODE_PAIR_HASH() external pure returns(bytes32);
}

// File: contracts/Libraries/FullMath.sol

pragma solidity ^0.8.4;

library FullMath {

  function mulDiv(
    uint256 a,
    uint256 b,
    uint256 denominator
  ) internal pure returns (uint256 result) {
    uint256 prod0; 
    uint256 prod1; 
    assembly {
      let mm := mulmod(a, b, not(0))
      prod0 := mul(a, b)
      prod1 := sub(sub(mm, prod0), lt(mm, prod0))
    }

    if (prod1 == 0) {
      require(denominator > 0);
      assembly {
        result := div(prod0, denominator)
      }
      return result;
    }
    require(denominator > prod1);
    uint256 remainder;
    assembly {
      remainder := mulmod(a, b, denominator)
    }
    assembly {
      prod1 := sub(prod1, gt(remainder, prod0))
      prod0 := sub(prod0, remainder)
    }
    uint256 twos = denominator & (~denominator + 1);
    assembly {
      denominator := div(denominator, twos)
    }
    assembly {
      prod0 := div(prod0, twos)
    }
    assembly {
      twos := add(div(sub(0, twos), twos), 1)
    }
    prod0 |= prod1 * twos;
    uint256 inv = (3 * denominator) ^ 2;
    inv *= 2 - denominator * inv; 
    inv *= 2 - denominator * inv;
    inv *= 2 - denominator * inv;
    inv *= 2 - denominator * inv;
    inv *= 2 - denominator * inv;
    inv *= 2 - denominator * inv;
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

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
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

library Babylonian {
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
        r = (r + x / r) >> 1; 
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }
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

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

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

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) internal pure returns (uint256 amountOut) {
    require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
    require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
    uint256 amountInWithFee = amountIn * 997;
    uint256 numerator = amountInWithFee * reserveOut;
    uint256 denominator = reserveIn * 1000 + amountInWithFee;
    amountOut = numerator / denominator;
  }

  function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
    require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
    require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
    uint numerator = reserveIn.mul(amountOut).mul(1000);
    uint denominator = reserveOut.sub(amountOut).mul(997);
    amountIn = (numerator / denominator).add(1);
  }

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
    uint256 reserveB
  ) public pure returns (bool aToB, uint256 amountIn) {
    aToB = FullMath.mulDiv(reserveA, truePriceTokenB, reserveB) < truePriceTokenA;

    uint256 invariant = reserveA.mul(reserveB);

    uint256 leftSide = Babylonian.sqrt(
        FullMath.mulDiv(
            invariant.mul(1000),
            aToB ? truePriceTokenA : truePriceTokenB,
            (aToB ? truePriceTokenB : truePriceTokenA).mul(997)
        )
    );
    uint256 rightSide = (aToB ? reserveA.mul(1000) : reserveB.mul(1000)) / 997;

    if (leftSide < rightSide) return (false, 0);

    amountIn = leftSide.sub(rightSide);
  }

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
  ) public pure returns (address pair) {
    (address token0, address token1) = sortTokens(tokenA, tokenB);
    bytes32 initCodeHash = IFactory(factory).INIT_CODE_PAIR_HASH();
    pair = address(
      uint160(
        uint256(
          keccak256(
            abi.encodePacked(
              hex"ff",
              factory,
              keccak256(abi.encodePacked(token0, token1)),
              initCodeHash
            )
          )
        )
      )
    );
  }
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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol

// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

abstract contract ERC165 is IERC165 {

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/utils/Strings.sol

// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    function toString(uint256 value) internal pure returns (string memory) {
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

    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol

// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

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

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: @openzeppelin/contracts/security/Pausable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

abstract contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/access/IAccessControl.sol

// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;
}

// File: @openzeppelin/contracts/access/AccessControl.sol
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

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

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
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

  receive() external payable {}

  function burn(uint256 amount) public {
    _burn(_msgSender(), amount);
  }

  function burnFrom(address account, uint256 amount) public {
    _spendAllowance(account, _msgSender(), amount);
    _burn(account, amount);
  }

  function justBurn(uint256 amount) external {
    burn(amount);
  }

  function mint(address to, uint256 amount) public payable onlyMint returns (bool) {
    if (hasRole(LEGACY_MINT_ROLE, msg.sender) && UP_CONTROLLER != address(0)) {
      (bool success, ) = UP_CONTROLLER.call{value: msg.value}(
        abi.encodeWithSignature(("mintUP(address)"), to)
      );
      require(success, "UP: LEGACY_MINT_FAILED");
    } else {
      _mint(to, amount);
    }
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
    require(_UP != address(0), "UPController: Invalid UP address");
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

  /// @notice Borrows native token from the back up reserves
  function borrowNative(uint256 _borrowAmount, address _to) public onlyRebalancer whenNotPaused {
    require(address(this).balance >= _borrowAmount, "UPController: NOT_ENOUGH_BALANCE");
    (bool success, ) = _to.call{value: _borrowAmount}("");
    nativeBorrowed += _borrowAmount;
    require(success, "UPController: BORROW_NATIVE_FAILED");
    emit BorrowNative(_to, _borrowAmount, nativeBorrowed);
  }

  /// @notice Borrows UP token minting it
  function borrowUP(uint256 _borrowAmount, address _to) public onlyRebalancer whenNotPaused {
    upBorrowed += _borrowAmount;
    UP(UP_TOKEN).mint(_to, _borrowAmount);
    emit SyntheticMint(msg.sender, _borrowAmount, upBorrowed);
  }

  function mintSyntheticUP(uint256 _mintAmount, address _to) public onlyRebalancer whenNotPaused {
    borrowUP(_mintAmount, _to);
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
    upBorrowed -= upAmount <= upBorrowed ? upAmount : upBorrowed;
    nativeBorrowed -= msg.value <= nativeBorrowed ? msg.value : nativeBorrowed;
    emit Repay(msg.value, upAmount);
  }

  /// @notice Swaps UP token by native token
  function redeem(uint256 upAmount) public onlyRedeemer whenNotPaused {
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

// File: contracts/Darbi/UPMintDarbi.sol


pragma solidity ^0.8.4;

/// @title UP Darbi Mint
/// @author Daniel Blanco & A Fistful of Stray Cat Hair
/// @notice This contract allows to DARBi to mint UP at virtual price.

contract UPMintDarbi is AccessControl, Pausable, Safe {
  bytes32 public constant DARBI_ROLE = keccak256("DARBI_ROLE");

  address payable public UP_TOKEN = payable(address(0));
  address payable public UP_CONTROLLER = payable(address(0));

  modifier onlyDarbi() {
    require(hasRole(DARBI_ROLE, msg.sender), "UPMintDarbi: ONLY_DARBI");
    _;
  }

  modifier onlyAdmin() {
    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "UPMintDarbi: ONLY_ADMIN");
    _;
  }

  event DarbiMint(address indexed _from, uint256 _amount, uint256 _price, uint256 _value);
  event UpdateController(address _upController);

  constructor(
    address _UP,
    address _UPController,
    address _fundsTarget
  ) Safe(_fundsTarget) {
    require(_UP != address(0), "UPMintDarbi: Invalid UP address");
    UP_TOKEN = payable(_UP);
    UP_CONTROLLER = payable(_UPController);
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  /// @notice Payable function that mints UP at the mint rate, deposits the native tokens to the UP Controller, Sends UP to the Msg.sender
  function mintUP() public payable whenNotPaused onlyDarbi {
    require(msg.value > 0, "UPMintDarbi: INVALID_PAYABLE_AMOUNT");
    uint256 currentPrice = UPController(UP_CONTROLLER).getVirtualPrice();
    if (currentPrice == 0) return;
    uint256 mintAmount = (msg.value * 1e18) / currentPrice;
    UP(UP_TOKEN).mint(msg.sender, mintAmount);
    (bool successTransfer, ) = UP_CONTROLLER.call{value: msg.value}(""); /// GO BACK
    require(successTransfer, "UPMintDarbi: FAIL_SENDING_NATIVE");
    emit DarbiMint(msg.sender, mintAmount, currentPrice, msg.value);
  }

  ///@notice Permissioned function to update the address of the UP Controller
  ///@param _upController - the address of the new UP Controller
  function updateController(address _upController) public onlyAdmin {
    require(_upController != address(0), "UPMintDarbi: INVALID_ADDRESS");
    UP_CONTROLLER = payable(_upController);
    emit UpdateController(_upController);
  }

  ///@notice Grant DARBi role
  ///@param _darbiAddr - a new DARBi address
  function grantDarbiRole(address _darbiAddr) public onlyAdmin {
    require(_darbiAddr != address(0), "UPMintDarbi: INVALID_ADDRESS");
    grantRole(DARBI_ROLE, _darbiAddr);
  }

  ///@notice Revoke DARBi role
  ///@param _darbiAddr - DARBi address to revoke
  function revokeDarbiRole(address _darbiAddr) public onlyAdmin {
    require(_darbiAddr != address(0), "UPMintDarbi: INVALID_ADDRESS");
    revokeRole(DARBI_ROLE, _darbiAddr);
  }

  ///@notice Permissioned function to withdraw any native coins accidentally deposited to the Darbi Mint contract.
  function withdrawFunds() public onlyAdmin returns (bool) {
    return _withdrawFunds();
  }

  ///@notice Permissioned function to withdraw any tokens accidentally deposited to the Darbi Mint contract.
  function withdrawFundsERC20(address tokenAddress) public onlyAdmin returns (bool) {
    return _withdrawFundsERC20(tokenAddress);
  }

  /// @notice Permissioned function to pause UPaddress Controller
  function pause() public onlyAdmin {
    _pause();
  }

  /// @notice Permissioned function to unpause UPaddress Controller
  function unpause() public onlyAdmin {
    _unpause();
  }

  fallback() external payable {}

  receive() external payable {}
}

// File: contracts/Darbi/Darbi.sol

pragma solidity ^0.8.4;

contract Darbi is AccessControl, Pausable, Safe {
  using SafeERC20 for IERC20;

  bytes32 public constant MONITOR_ROLE = keccak256("MONITOR_ROLE");
  bytes32 public constant REBALANCER_ROLE = keccak256("REBALANCER_ROLE");

  address public factory;
  address public WETH;
  address public gasRefundAddress;
  uint256 public arbitrageThreshold = 100000;
  uint256 public gasRefund = 3500000000000000;
  uint256 public darbiDepositBalance = 0.5 ether;
  IERC20 public UP_TOKEN;
  IUniswapV2Router02 public router;
  UPController public UP_CONTROLLER;
  UPMintDarbi public DARBI_MINTER;

  event Arbitrage(bool isSellingUp, uint256 actualAmountIn);

  modifier onlyAdmin() {
    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Darbi: ONLY_ADMIN");
    _;
  }

  modifier onlyMonitor() {
    require(hasRole(MONITOR_ROLE, msg.sender), "Darbi: ONLY_MONITOR");
    _;
  }

  modifier onlyRebalancer() {
    require(hasRole(REBALANCER_ROLE, msg.sender), "Darbi: ONLY_REBALANCER");
    _;
  }

  modifier onlyRebalancerOrMonitor() {
    require(
      hasRole(REBALANCER_ROLE, msg.sender) || hasRole(MONITOR_ROLE, msg.sender),
      "Darbi: ONLY_REBALANCER_OR_MONITOR"
    );
    _;
  }

  constructor(
    address _factory,
    address _router,
    address _WETH,
    address _gasRefundAddress,
    address _UP_CONTROLLER,
    address _darbiMinter,
    address _fundsTarget
  ) Safe(_fundsTarget) {
    factory = _factory;
    router = IUniswapV2Router02(_router);
    WETH = _WETH;
    gasRefundAddress = _gasRefundAddress;
    UP_CONTROLLER = UPController(payable(_UP_CONTROLLER));
    DARBI_MINTER = UPMintDarbi(payable(_darbiMinter));
    UP_TOKEN = IERC20(payable(UP_CONTROLLER.UP_TOKEN()));
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  receive() external payable {}

  function arbitrage() public whenNotPaused onlyMonitor {
    (
      bool aToB,
      uint256 amountIn,
      uint256 reserves0,
      uint256 reserves1,
      uint256 backedValue
    ) = moveMarketBuyAmount();

    uint256 balances = address(this).balance;

    if (!aToB) {
      require(amountIn > gasRefund, "Darbi: Trade will not be profitable");
      if (amountIn < arbitrageThreshold) return;
      _arbitrageBuy(balances, amountIn, backedValue, reserves0, reserves1);
    } else {
      uint256 amountInETHTerms = (amountIn * backedValue) / 1e18;
      require(amountInETHTerms > gasRefund, "Darbi: Trade will not be profitable");
      if (amountInETHTerms < arbitrageThreshold) return;
      _arbitrageSell(balances, amountIn, backedValue);
    }
    refund();
  }

  function forceArbitrage() public whenNotPaused onlyRebalancer {
    (
      bool aToB,
      uint256 amountIn,
      uint256 reservesUP,
      uint256 reservesETH,
      uint256 backedValue
    ) = moveMarketBuyAmount();

    uint256 balances = address(this).balance;

    if (!aToB) {
      if (amountIn < arbitrageThreshold) return;
      _arbitrageBuy(balances, amountIn, backedValue, reservesUP, reservesETH);
    } else {
      uint256 amountInETHTerms = (amountIn * backedValue) / 1e18;
      if (amountInETHTerms < arbitrageThreshold) return;
      _arbitrageSell(balances, amountIn, backedValue);
    }
  }

  function _arbitrageBuy(
    uint256 balances,
    uint256 amountIn,
    uint256 backedValue,
    uint256 reservesUP,
    uint256 reservesETH
  ) internal {
    uint256 actualAmountIn = amountIn <= balances ? amountIn : balances; 
    uint256 expectedReturn = UniswapHelper.getAmountOut(actualAmountIn, reservesETH, reservesUP); 
    uint256 expectedNativeReturn = (expectedReturn * backedValue) / 1e18; 
    uint256 upControllerBalance = address(UP_CONTROLLER).balance;
    if (upControllerBalance < expectedNativeReturn) {
      uint256 upOutput = (upControllerBalance * 1e18) / backedValue; 
      actualAmountIn = UniswapHelper.getAmountIn(upOutput, reservesETH, reservesUP); 
    }

    address[] memory path = new address[](2);
    path[0] = WETH;
    path[1] = address(UP_TOKEN);

    uint256[] memory amounts = router.swapExactETHForTokens{value: actualAmountIn}(
      0,
      path,
      address(this),
      block.timestamp + 150
    );

    UP_TOKEN.approve(address(UP_CONTROLLER), amounts[1]);
    UP_CONTROLLER.redeem(amounts[1]);

    emit Arbitrage(false, actualAmountIn);
  }

  function _arbitrageSell(
    uint256 balances,
    uint256 amountIn,
    uint256 backedValue
  ) internal {
    uint256 darbiBalanceMaximumUpToMint = (balances * 1e18) / backedValue; 
    uint256 actualAmountIn = amountIn <= darbiBalanceMaximumUpToMint
      ? amountIn
      : darbiBalanceMaximumUpToMint; // Value in UP
    uint256 nativeToMint = (actualAmountIn * backedValue) / 1e18;
    DARBI_MINTER.mintUP{value: nativeToMint}();

    address[] memory path = new address[](2);
    path[0] = address(UP_TOKEN);
    path[1] = WETH;

    uint256 up2Balance = UP_TOKEN.balanceOf(address(this));
    UP_TOKEN.approve(address(router), up2Balance);
    router.swapExactTokensForETH(up2Balance, 0, path, address(this), block.timestamp + 150);

    emit Arbitrage(true, up2Balance);
  }

  function refund() public whenNotPaused onlyRebalancerOrMonitor {
    uint256 newBalances0 = address(this).balance;
    if ((newBalances0 + gasRefund) < darbiDepositBalance) return;
    (bool success1, ) = gasRefundAddress.call{value: gasRefund}("");
    require(success1, "Darbi: FAIL_SENDING_GAS_REFUND_TO_MONITOR");
    uint256 newBalances1 = newBalances0 - gasRefund;
    uint256 diffBalances = newBalances1 > darbiDepositBalance ? newBalances1 - darbiDepositBalance : 0;
    if (diffBalances > 0) {
      (bool success2, ) = address(UP_CONTROLLER).call{value: diffBalances}("");
      require(success2, "Darbi: FAIL_SENDING_BALANCES_TO_CONTROLLER");
    }
  }

  function moveMarketBuyAmount()
    public
    view
    returns (
      bool aToB,
      uint256 amountIn,
      uint256 reservesUP,
      uint256 reservesETH,
      uint256 upPrice
    )
  {
    (reservesUP, reservesETH) = UniswapHelper.getReserves(
      factory,
      address(UP_TOKEN),
      address(WETH)
    );
    upPrice = UP_CONTROLLER.getVirtualPrice();
    (aToB, amountIn) = UniswapHelper.computeTradeToMoveMarket(
      1000000000000000000,
      upPrice,
      reservesUP,
      reservesETH
    );
    return (aToB, amountIn, reservesUP, reservesETH, upPrice);
  }

  function addDarbiFunds() public payable {
    uint256 depositAmount = msg.value;
    darbiDepositBalance += depositAmount;
  }

  function redeemUP() internal {
    UP_CONTROLLER.redeem(IERC20(UP_CONTROLLER.UP_TOKEN()).balanceOf(address(this)));
  }

  function setController(address _controller) public onlyAdmin {
    require(_controller != address(0));
    UP_CONTROLLER = UPController(payable(_controller));
  }

  function setDarbiFunds(uint256 setAmount) public onlyAdmin {
    darbiDepositBalance = setAmount;
  }

  function setArbitrageThreshold(uint256 _threshold) public onlyAdmin {
    require(_threshold > 0);
    arbitrageThreshold = _threshold;
  }

  function setGasRefund(uint256 _gasRefund) public onlyAdmin {
    require(_gasRefund > 0);
    gasRefund = _gasRefund;
  }

  function setGasRefundAddress(address _gasRefundAddress) public onlyAdmin {
    require(_gasRefundAddress != address(0));
    gasRefundAddress = _gasRefundAddress;
  }

  function setDarbiMinter(address _newMinter) public onlyAdmin {
    require(_newMinter != address(0));
    DARBI_MINTER = UPMintDarbi(payable(_newMinter));
  }

  function withdrawFunds() public onlyAdmin returns (bool) {
    darbiDepositBalance == 0;
    return _withdrawFunds();
  }

  function withdrawFundsERC20(address tokenAddress) public onlyAdmin returns (bool) {
    return _withdrawFundsERC20(tokenAddress);
  }

  /// @notice Permissioned function to pause UPaddress Controller
  function pause() public onlyAdmin {
    _pause();
  }

  /// @notice Permissioned function to unpause UPaddress Controller
  function unpause() public onlyAdmin {
    _unpause();
  }
}

// File: contracts/Rebalancer.sol

pragma solidity ^0.8.4;

contract Rebalancer is AccessControl, Pausable, Safe {
  bytes32 public constant REBALANCE_ROLE = keccak256("REBALANCE_ROLE");

  address public WETH = address(0);
  address public unifiFactory = address(0);
  IStrategy public strategy;
  IUnifiPair public liquidityPool;
  Darbi public darbi;
  UP public UPToken;
  UPController public UP_CONTROLLER;
  uint256 public allocationLP = 5; 
  uint256 public allocationRedeem = 5; 
  uint256 public slippageTolerance = 30; 

  IUniswapV2Router02 public unifiRouter;
  IStrategy.Rewards[] public rewards;
  uint256 private initRewardsPos = 0;

  modifier onlyRebalance() {
    require(hasRole(REBALANCE_ROLE, msg.sender), "Rebalancer: ONLY_REBALANCE");
    _;
  }

  modifier onlyAdmin() {
    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Rebalancer: ONLY_ADMIN");
    _;
  }

  constructor(
    address _WETH,
    address _UPAddress,
    address _UPController,
    address _Strategy,
    address _unifiRouter,
    address _unifiFactory,
    address _liquidityPool,
    address _darbi,
    address _fundsTarget
  ) Safe(_fundsTarget) {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    WETH = _WETH;
    setUPController(_UPController);
    strategy = IStrategy(_Strategy);
    UPToken = UP(payable(_UPAddress));
    unifiRouter = IUniswapV2Router02(_unifiRouter);
    unifiFactory = _unifiFactory;
    liquidityPool = IUnifiPair(payable(_liquidityPool));
    darbi = Darbi(payable(_darbi));
  }

  receive() external payable {}

  function claimAndBurn() internal {
    liquidityPool.claimUP(address(this));
    UPToken.justBurn(UPToken.balanceOf(address(this)));
  }

  function getControllerBalance() internal view returns (uint256) {
    return UP_CONTROLLER.getNativeBalance();
  }

  function rebalance() public whenNotPaused onlyRebalance {
    if (address(strategy) != address(0)) {
      _rebalanceWithStrategy();
    } else {
      _rebalanceWithoutStrategy();
    }
  }

  function _rebalanceWithStrategy() public whenNotPaused onlyRebalance {

    claimAndBurn();
    IStrategy.Rewards memory strategyRewards = strategy.checkRewards();
    saveReward(strategyRewards);
    strategy.gather();
    (bool successUpcTransfer, ) = address(UP_CONTROLLER).call{value: strategyRewards.rewardsAmount}(
      ""
    );
    require(successUpcTransfer, "Rebalancer: FAIL_SENDING_REWARDS_TO_UPC");
    darbi.forceArbitrage();
    (uint256 reservesUP, uint256 reservesETH) = UniswapHelper.getReserves(
      unifiFactory,
      address(UPToken),
      WETH
    );
    (, uint256 ethLpBalance) = getLiquidityPoolBalance(reservesUP, reservesETH);
    uint256 totalETH = getControllerBalance();
    uint256 targetRedeemAmount = (totalETH * allocationRedeem) / 100;
    uint256 targetLpAmount = (totalETH * allocationLP) / 100;
    uint256 targetStrategyAmount = totalETH - targetLpAmount - targetRedeemAmount;
    if (strategyRewards.depositedAmount < targetStrategyAmount) {
      uint256 amountToDeposit = targetStrategyAmount - strategyRewards.depositedAmount;
      UP_CONTROLLER.borrowNative(amountToDeposit, address(this));
      strategy.deposit{value: amountToDeposit}(amountToDeposit);
    } else if (strategyRewards.depositedAmount > targetStrategyAmount) {
      uint256 amountToWithdraw = strategyRewards.depositedAmount - targetStrategyAmount;
      strategy.withdraw(amountToWithdraw);
      UP_CONTROLLER.repay{value: amountToWithdraw}(0);
    }
 uint256 backedValue = UP_CONTROLLER.getVirtualPrice();
    uint256 marketValue = (reservesETH * 1e18) / reservesUP;
    // Step 5.1
    uint256 deviation = backedValue < marketValue
      ? (1e18 - ((backedValue * 1e18) / marketValue)) / 1e14
      : (1e18 - ((marketValue * 1e18) / backedValue)) / 1e14;
    if (deviation > slippageTolerance) return;
    if (ethLpBalance > targetLpAmount) {
      uint256 amountToBeWithdrawnFromLp = ethLpBalance - targetLpAmount;
      uint256 diffLpToRemove = (liquidityPool.totalSupply() * amountToBeWithdrawnFromLp) /
        reservesETH;
      if (diffLpToRemove > 0) {
        liquidityPool.approve(address(unifiRouter), diffLpToRemove);
        (uint256 amountToken, uint256 amountETH) = unifiRouter.removeLiquidityETH(
          address(UPToken),
          diffLpToRemove,
          0,
          0,
          address(this),
          block.timestamp + 150
        );
        UPToken.approve(address(UP_CONTROLLER), amountToken);
        UP_CONTROLLER.repay{value: amountETH}(amountToken);
      }
    } else if (ethLpBalance < targetLpAmount) {
      uint256 amountToWithdrawFromRedeem = targetLpAmount - ethLpBalance;
      if (amountToWithdrawFromRedeem == 0) return;
      UP_CONTROLLER.borrowNative(amountToWithdrawFromRedeem, address(this));
      uint256 ETHAmountToDeposit = address(this).balance;
      uint256 UPtoAddtoLP = (ETHAmountToDeposit * 1e18) / marketValue;
      if (UPtoAddtoLP == 0) return;
      UP_CONTROLLER.borrowUP(UPtoAddtoLP, address(this));
      UPToken.approve(address(unifiRouter), UPtoAddtoLP);
      unifiRouter.addLiquidityETH{value: ETHAmountToDeposit}(
        address(UPToken),
        UPtoAddtoLP,
        0,
        0,
        address(this),
        block.timestamp + 150
      );
    }
    darbi.refund();
  }

  function _rebalanceWithoutStrategy() internal {
    claimAndBurn();
    darbi.forceArbitrage();

    (uint256 reservesUP, uint256 reservesETH) = UniswapHelper.getReserves(
      unifiFactory,
      address(UPToken),
      WETH
    );
    uint256 backedValue = UP_CONTROLLER.getVirtualPrice();
    uint256 marketValue = (reservesETH * 1e18) / reservesUP;
    uint256 deviation = backedValue < marketValue
      ? (1e18 - ((backedValue * 1e18) / marketValue)) / 1e14
      : (1e18 - ((marketValue * 1e18) / backedValue)) / 1e14;
    if (deviation > slippageTolerance) return;

    (, uint256 ethLpBalance) = getLiquidityPoolBalance(reservesUP, reservesETH);

    uint256 actualRedeemAmount = (getControllerBalance() * allocationRedeem) / 100;
    uint256 actualEthLpAllocation = getControllerBalance() - actualRedeemAmount;

    if (ethLpBalance > actualEthLpAllocation) {
      uint256 amountToBeWithdrawnFromLp = ethLpBalance - actualEthLpAllocation;
      uint256 diffLpToRemove = (liquidityPool.totalSupply() * amountToBeWithdrawnFromLp) /
        reservesETH;

      if (diffLpToRemove > 0) {
        liquidityPool.approve(address(unifiRouter), diffLpToRemove);
        (uint256 amountToken, uint256 amountETH) = unifiRouter.removeLiquidityETH(
          address(UPToken),
          diffLpToRemove,
          0,
          0,
          address(this),
          block.timestamp + 150
        );

        UPToken.approve(address(UP_CONTROLLER), amountToken);
        UP_CONTROLLER.repay{value: amountETH}(amountToken);
      }
    } else if (ethLpBalance < actualEthLpAllocation) {
      uint256 amountToWithdrawFromRedeem = actualEthLpAllocation - ethLpBalance;
      if (amountToWithdrawFromRedeem == 0) return;

      UP_CONTROLLER.borrowNative(amountToWithdrawFromRedeem, address(this));
      uint256 ETHAmountToDeposit = address(this).balance;
      uint256 UPtoAddtoLP = (ETHAmountToDeposit * 1e18) / marketValue;
      if (UPtoAddtoLP == 0) return;
      UP_CONTROLLER.borrowUP(UPtoAddtoLP, address(this));
      UPToken.approve(address(unifiRouter), UPtoAddtoLP);
      unifiRouter.addLiquidityETH{value: ETHAmountToDeposit}(
        address(UPToken),
        UPtoAddtoLP,
        0,
        0,
        address(this),
        block.timestamp + 150
      );
    }

    darbi.refund();
  }

  function setStrategy(address newAddress) public onlyAdmin {
    strategy = IStrategy(newAddress);
  }

  function getLiquidityPoolBalance(uint256 reserves0, uint256 reserves1)
    public
    view
    returns (uint256, uint256)
  {
    uint256 lpBalance = liquidityPool.balanceOf(address(this));
    if (lpBalance == 0) {
      return (0, 0);
    }
    uint256 totalSupply = liquidityPool.totalSupply();
    uint256 amount0 = (lpBalance * reserves0) / totalSupply;
    uint256 amount1 = (lpBalance * reserves1) / totalSupply;
    return (amount0, amount1);
  }

  function setUPController(address newAddress) public onlyAdmin {
    UP_CONTROLLER = UPController(payable(newAddress));
  }

  function setDarbi(address newAddress) public onlyAdmin {
    darbi = Darbi(payable(newAddress));
  }

  function saveReward(IStrategy.Rewards memory reward) internal {
    if (getRewardsLength() == 10) {
      delete rewards[initRewardsPos];
      initRewardsPos += 1;
    }
    rewards.push(reward);
  }

  function getRewardsLength() public view returns (uint256) {
    return rewards.length - initRewardsPos;
  }

  function getReward(uint256 position) public view returns (IStrategy.Rewards memory) {
    return rewards[initRewardsPos + position];
  }

  function setAllocationLP(uint256 _allocationLP) public onlyAdmin returns (bool) {
    bool lessthan100 = allocationRedeem + _allocationLP <= 100;
    require(lessthan100, "Rebalancer: Allocation for Redeem and LP is over 100%");
    allocationLP = _allocationLP;
    return true;
  }

  function setAllocationRedeem(uint256 _allocationRedeem) public onlyAdmin returns (bool) {
    bool lessthan100 = allocationLP + _allocationRedeem <= 100;
    require(lessthan100, "Rebalancer: Allocation for Redeem and LP is over 100%");
    allocationRedeem = _allocationRedeem;
    return true;
  }

  function setSlippageTolerance(uint256 _slippageTolerance) public onlyAdmin returns (bool) {
    bool lessthan10000 = _slippageTolerance <= 10000;
    require(lessthan10000, "Rebalancer: Cannot Set Slippage Tolerance over 100%");
    slippageTolerance = _slippageTolerance;
    return true;
  }

  /// @notice Permissioned function to withdraw any native coins accidentally deposited to the Public Mint contract.
  function withdrawFunds() public onlyAdmin returns (bool) {
    return _withdrawFunds();
  }

  /// @notice Permissioned function to withdraw any tokens accidentally deposited to the Public Mint contract.
  function withdrawFundsERC20(address tokenAddress) public onlyAdmin returns (bool) {
    return _withdrawFundsERC20(tokenAddress);
  }

  /// @notice Permissioned function to pause UPToken Controller
  function pause() public onlyAdmin {
    _pause();
  }

  /// @notice Permissioned function to unpause UPToken Controller
  function unpause() public onlyAdmin {
    _unpause();
  }
}