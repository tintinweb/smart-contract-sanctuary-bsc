/**
 *Submitted for verification at BscScan.com on 2022-10-23
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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

error OnlyOwnerCanPerformThisAction();
error CannotAirdropRewardsFromARewardsExcludedAccount();
error AmountExceededReflection();
error InvalidAddress();
error AlreadyExcludedFromReward();
error AlreadyIncludedInReward();
error RecursiveSwap();
error InvalidTransferAmount();
error InvalidReflectionAmount();
error MaxAmountExceeded();
error TotalFeeExceeded();
error TradeNotOpen();

library Types {
    enum AddressConfig {
        NONE,
        ADMIN,
        MARKETING,
        SHIBBA
    }

    enum UintConfig {
        NONE,
        TOKEN_DECIMALS
    }

    enum StringConfig {
        NONE,
        TOKEN_NAME,
        TOKEN_SYMBOL
    }

    struct Config {
        mapping(AddressConfig => address) addresses;
        mapping(UintConfig => uint256) uints;
        mapping(StringConfig => string) strings;
    }

    struct State {
        mapping(address => uint256) _rOwned;
        mapping(address => uint256) _tOwned;
        mapping(address => bool) _isExcludedFromFee;
        mapping(address => bool) _isExcludedFromReward;
        mapping(address => mapping(address => uint256)) _allowances;
        address[] _excludedFromReward;
        uint256 MAX;
        uint256 _tTotal;
        uint256 _rTotal;
        uint256 _tFeeTotal;
        uint256 _tBurnTotal;
        uint256 _maxTaxFee;
        uint256 _taxToDeduct;
        uint256 _previousTaxToDeduct;
        uint256 _liquidityFee;
        uint256 _previousLiquidityFee;
        uint256 marketingPercent;
        uint256 rewardPercent;
        uint256 burnPercent;
        uint256 shibbaPercent;
        address swapV2Pair;
        uint256 collectedFee;
        uint256 numTokensToSendCollectedFee;
        IUniswapV2Router02 swapV2Router;
        bool inSwapAndLiquify;
        bool inSwap;
        bool isSwapAndLiquifyEnabled;
        bool isSendCollectedFeeEnabled;
        bool isTradeOpen;
        address routerAddress;
        uint256 MAXTxAmount;
        uint256 numTokensSellToAddToLiquidity;
        Config config;
    }
}

library App {
    using SafeMath for uint256;

    event AppInitialized(string appName);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    function initialize(Types.State storage state, address admin) internal {
        state.config.addresses[Types.AddressConfig.ADMIN] = admin;
        state.config.strings[Types.StringConfig.TOKEN_NAME] = "Froggies Token";
        state.config.strings[Types.StringConfig.TOKEN_SYMBOL] = "FRGST";
        state.config.uints[Types.UintConfig.TOKEN_DECIMALS] = 9;

        state.MAX = ~uint256(0);
        state._tTotal =
            100_000_000_000_000_000 *
            10**state.config.uints[Types.UintConfig.TOKEN_DECIMALS];
        state._rTotal = (state.MAX - (state.MAX % state._tTotal));
        state._rOwned[admin] = state._rTotal;

        state.marketingPercent = 200;
        state.rewardPercent = 300;
        state.burnPercent = 100;
        state.shibbaPercent = 200;
        state._liquidityFee = 200;

        state._taxToDeduct = state
            .marketingPercent
            .add(state.rewardPercent)
            .add(state.burnPercent)
            .add(state.shibbaPercent)
            .add(state._liquidityFee);

        state._previousTaxToDeduct = state._taxToDeduct;
        state._maxTaxFee = 1500;
        state.MAXTxAmount =
            1_000_000_000_000_000 *
            10**state.config.uints[Types.UintConfig.TOKEN_DECIMALS];
        state.numTokensSellToAddToLiquidity =
            10_000_000_000_000 *
            10**state.config.uints[Types.UintConfig.TOKEN_DECIMALS];
        state.numTokensToSendCollectedFee =
            20_000_000_000_000 *
            10**state.config.uints[Types.UintConfig.TOKEN_DECIMALS];

        state._isExcludedFromFee[admin] = true;
        state._isExcludedFromFee[address(this)] = true;

        emit AppInitialized(
            state.config.strings[Types.StringConfig.TOKEN_NAME]
        );
        emit Transfer(address(0), admin, state._tTotal);
    }
}

library Reflection {
    using SafeMath for uint256;

    event Approval(
        address indexed sender,
        address indexed spender,
        uint256 amount
    );
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event SwapAndLiquify(uint256 half, uint256 newBalance, uint256 otherHalf);

    function balanceOf(Types.State storage state, address account)
        internal
        view
        returns (uint256)
    {
        if (state._isExcludedFromReward[account]) return state._tOwned[account];
        return tokenFromReflection(state, state._rOwned[account]);
    }

    function tokenFromReflection(Types.State storage state, uint256 rAmount)
        internal
        view
        returns (uint256)
    {
        if (rAmount > state._rTotal) revert AmountExceededReflection();
        uint256 currentRate = _getRate(state);
        return rAmount.div(currentRate);
    }

    function reflectionFromToken(
        Types.State storage state,
        uint256 tAmount,
        bool deductTransferFee
    ) internal view returns (uint256) {
        if (tAmount > state._tTotal) revert InvalidReflectionAmount();
        if (!deductTransferFee) {
            (uint256 rAmount, , , , ) = _getValues(state, tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , ) = _getValues(state, tAmount);
            return rTransferAmount;
        }
    }

    function _getRate(Types.State storage state)
        internal
        view
        returns (uint256)
    {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply(state);
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply(Types.State storage state)
        internal
        view
        returns (uint256, uint256)
    {
        uint256 rSupply = state._rTotal;
        uint256 tSupply = state._tTotal;

        for (uint256 i = 0; i < state._excludedFromReward.length; i++) {
            if (
                state._rOwned[state._excludedFromReward[i]] > rSupply ||
                state._tOwned[state._excludedFromReward[i]] > tSupply
            ) return (state._rTotal, state._tTotal);

            rSupply = rSupply.sub(state._rOwned[state._excludedFromReward[i]]);
            tSupply = tSupply.sub(state._tOwned[state._excludedFromReward[i]]);
        }

        if (rSupply < state._rTotal.div(state._tTotal))
            return (state._rTotal, state._tTotal);

        return (rSupply, tSupply);
    }

    function addLiquidity(
        Types.State storage state,
        uint256 tokenAmount,
        uint256 bnbAmount
    ) internal {
        _approve(
            state,
            address(this),
            address(state.routerAddress),
            tokenAmount
        );

        state.swapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            state.config.addresses[Types.AddressConfig.ADMIN],
            block.timestamp
        );
    }

    function _approve(
        Types.State storage state,
        address owner,
        address spender,
        uint256 amount
    ) internal {
        if (owner == address(0)) revert InvalidAddress();
        if (spender == address(0)) revert InvalidAddress();

        state._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        Types.State storage state,
        address from,
        address to,
        uint256 amount
    ) internal {
        {
            if (from == address(0) || to == address(0)) revert InvalidAddress();
            if (amount <= 0) revert InvalidTransferAmount();

            if (
                from != state.config.addresses[Types.AddressConfig.ADMIN] &&
                to != state.config.addresses[Types.AddressConfig.ADMIN] &&
                !state.isTradeOpen
            ) revert TradeNotOpen();

            if (
                (from != state.config.addresses[Types.AddressConfig.ADMIN] &&
                    to != state.config.addresses[Types.AddressConfig.ADMIN]) &&
                (amount > state.MAXTxAmount)
            ) revert MaxAmountExceeded();
        }
        if (!state.inSwapAndLiquify && !state.inSwap) {
            {
                uint256 toSwapLiquidity = balanceOf(state, address(this)).sub(
                    state.collectedFee
                );

                if (
                    from != state.swapV2Pair &&
                    from != address(this) &&
                    from != state.routerAddress &&
                    toSwapLiquidity >= state.numTokensSellToAddToLiquidity &&
                    state.isSwapAndLiquifyEnabled
                ) {
                    toSwapLiquidity = state.numTokensSellToAddToLiquidity;
                    if (toSwapLiquidity > state.MAXTxAmount) {
                        toSwapLiquidity = state.MAXTxAmount;
                    }
                    swapAndLiquify(state, toSwapLiquidity);
                }
            }
            {
                if (
                    from != state.swapV2Pair &&
                    from != address(this) &&
                    from != state.routerAddress &&
                    state.collectedFee >= state.numTokensToSendCollectedFee &&
                    state.isSendCollectedFeeEnabled
                ) {
                    sendCollectedFee(state);
                }
            }
        }

        {
            bool takeFee = true;

            if (
                state._isExcludedFromFee[from] || state._isExcludedFromFee[to]
            ) {
                takeFee = false;
            }

            _tokenTransfer(state, from, to, amount, takeFee);
        }
    }

    function _tokenTransfer(
        Types.State storage state,
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) internal {
        if (!takeFee) removeAllFee(state);

        {
            bool isSenderExcludedFromReward = state._isExcludedFromReward[
                sender
            ];
            bool isRecipientExcludedFromReward = state._isExcludedFromReward[
                recipient
            ];

            if (isSenderExcludedFromReward && !isRecipientExcludedFromReward) {
                _transferFromExcluded(state, sender, recipient, amount);
            } else if (
                !isSenderExcludedFromReward && isRecipientExcludedFromReward
            ) {
                _transferToExcluded(state, sender, recipient, amount);
            } else if (
                isSenderExcludedFromReward && isRecipientExcludedFromReward
            ) {
                _transferBothExcluded(state, sender, recipient, amount);
            } else {
                _transferStandard(state, sender, recipient, amount);
            }
        }

        if (!takeFee) restoreAllFee(state);
    }

    function _transferFromExcluded(
        Types.State storage state,
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee
        ) = _getValues(state, tAmount);

        state._tOwned[sender] = state._tOwned[sender].sub(tAmount);
        state._rOwned[sender] = state._rOwned[sender].sub(rAmount);
        state._rOwned[recipient] = state._rOwned[recipient].add(
            rTransferAmount
        );
        _reflectFee(state, rFee, tFee, sender);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        Types.State storage state,
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee
        ) = _getValues(state, tAmount);

        state._rOwned[sender] = state._rOwned[sender].sub(rAmount);
        state._tOwned[recipient] = state._tOwned[recipient].add(
            tTransferAmount
        );
        state._rOwned[recipient] = state._rOwned[recipient].add(
            rTransferAmount
        );
        _reflectFee(state, rFee, tFee, sender);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        Types.State storage state,
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee
        ) = _getValues(state, tAmount);

        state._tOwned[sender] = state._tOwned[sender].sub(tAmount);
        state._rOwned[sender] = state._rOwned[sender].sub(rAmount);
        state._tOwned[recipient] = state._tOwned[recipient].add(
            tTransferAmount
        );
        state._rOwned[recipient] = state._rOwned[recipient].add(
            rTransferAmount
        );

        _reflectFee(state, rFee, tFee, sender);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferStandard(
        Types.State storage state,
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee
        ) = _getValues(state, tAmount);

        state._rOwned[sender] = state._rOwned[sender].sub(rAmount);
        state._rOwned[recipient] = state._rOwned[recipient].add(
            rTransferAmount
        );

        _reflectFee(state, rFee, tFee, sender);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _getValues(Types.State storage state, uint256 tAmount)
        internal
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(state, tAmount);

        uint256 currentRate = _getRate(state);

        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            currentRate
        );

        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);
    }

    function _getTValues(Types.State storage state, uint256 tAmount)
        private
        view
        returns (uint256, uint256)
    {
        uint256 tFee = calculateTaxFee(state, tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee);
    }

    function calculateTaxFee(Types.State storage state, uint256 _amount)
        internal
        view
        returns (uint256)
    {
        return _amount.mul(state._taxToDeduct).div(10**4);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
        return (rAmount, rTransferAmount, rFee);
    }

    function _reflectFee(
        Types.State storage state,
        uint256 rFee,
        uint256 tFee,
        address sender
    ) private {
        if (rFee <= 0 || tFee <= 0) return;
        state._tFeeTotal = state._tFeeTotal.add(tFee);

        uint256 OneFull = tFee.mul(100).div(state._taxToDeduct);

        {
            uint256 rewardFee = OneFull.mul(state.rewardPercent).div(1e2);
            state._rTotal = state._rTotal.sub(
                reflectionFromToken(state, rewardFee, false)
            );
        }
        {
            uint256 burnFee = OneFull.mul(state.burnPercent).div(1e2);
            state._tBurnTotal = state._tBurnTotal.add(burnFee);
            _transferInternal(state, sender, address(0), burnFee);
        }
        {
            uint256 liquidityFee = OneFull.mul(state._liquidityFee).div(1e2);
            _transferInternal(state, sender, address(this), liquidityFee);
        }
        {
            uint256 marketingFee = OneFull.mul(state.marketingPercent).div(1e2);
            uint256 shibbaFee = OneFull.mul(state.shibbaPercent).div(1e2);
            uint256 totalFeeToSwapForBNB = marketingFee + shibbaFee;
            _transferInternal(
                state,
                sender,
                address(this),
                totalFeeToSwapForBNB
            );
            state.collectedFee = state.collectedFee.add(totalFeeToSwapForBNB);
        }
    }

    function _transferInternal(
        Types.State storage state,
        address sender,
        address recipient,
        uint256 tAmount
    ) internal {
        state._rOwned[recipient] = state._rOwned[recipient].add(
            tAmount.mul(_getRate(state))
        );

        if (state._isExcludedFromReward[recipient])
            state._tOwned[recipient] = state._tOwned[recipient].add(tAmount);

        emit Transfer(sender, recipient, tAmount);
    }

    function _swapTokensForBNB(
        Types.State storage state,
        uint256 tokenAmount,
        address _receiver
    ) internal returns (uint256) {
        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = state.swapV2Router.WETH();

        _approve(
            state,
            address(this),
            address(state.swapV2Router),
            tokenAmount
        );

        state.swapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            _receiver,
            block.timestamp
        );

        return address(this).balance.sub(initialBalance);
    }

    function sendCollectedFee(Types.State storage state) internal {
        if (state.inSwapAndLiquify || state.inSwap) revert RecursiveSwap();

        state.inSwap = true;

        uint256 OneFull = (
            state.collectedFee.mul(100).div(
                state.shibbaPercent + state.marketingPercent
            )
        );
        uint256 marketingFee = OneFull.mul(state.marketingPercent).div(1e2);
        uint256 shibbaFee = OneFull.mul(state.shibbaPercent).div(1e2);

        _swapTokensForBNB(
            state,
            marketingFee,
            state.config.addresses[Types.AddressConfig.MARKETING]
        );

        _swapTokensForBNB(
            state,
            shibbaFee,
            state.config.addresses[Types.AddressConfig.SHIBBA]
        );

        state.collectedFee = 0;
        state.inSwap = false;
    }

    function swapAndLiquify(Types.State storage state, uint256 toSwapLiquidity)
        internal
    {
        if (state.inSwapAndLiquify || state.inSwap) revert RecursiveSwap();

        state.inSwapAndLiquify = true;

        uint256 halfTokensToSell = toSwapLiquidity.div(2);
        uint256 otherHalfTokensToAddToLiquidity = toSwapLiquidity.sub(
            halfTokensToSell
        );

        uint256 swappedBNBForLiquify = _swapTokensForBNB(
            state,
            halfTokensToSell,
            address(this)
        );

        addLiquidity(
            state,
            otherHalfTokensToAddToLiquidity,
            swappedBNBForLiquify
        );

        emit SwapAndLiquify(
            halfTokensToSell,
            swappedBNBForLiquify,
            otherHalfTokensToAddToLiquidity
        );
        state.inSwapAndLiquify = false;
    }

    function removeAllFee(Types.State storage state) internal {
        if (state._taxToDeduct == 0) return;
        state._previousTaxToDeduct = state._taxToDeduct;
        state._taxToDeduct = 0;
    }

    function restoreAllFee(Types.State storage state) internal {
        state._taxToDeduct = state._previousTaxToDeduct;
    }

    function calculateTaxToDeduct(Types.State storage state)
        internal
        view
        returns (uint256)
    {
        return
            state
                ._liquidityFee
                .add(state.marketingPercent)
                .add(state.shibbaPercent)
                .add(state.rewardPercent)
                .add(state.burnPercent);
    }

    function ensureMaxFeeCap(
        Types.State storage state,
        uint256 _currentFee,
        uint256 _newFee
    ) internal view {
        uint256 totalFee = state._taxToDeduct.add(_newFee);

        if (totalFee.sub(_currentFee) > state._maxTaxFee)
            revert TotalFeeExceeded();
    }
}

contract Token is IERC20 {
    using SafeMath for uint256;
    using App for Types.State;
    using Reflection for Types.State;
    using Types for Types.State;

    Types.State state;

    event IsTradeOpenSet(bool isTradeOpen);
    event IsSwapAndLiquifyEnabledSet(bool isEnabled);
    event IsSendCollectedFeeEnabledSet(bool isEnabled);
    event ExcludedFromReward(address indexed account);
    event IncludedInReward(address indexed account);
    event ExcludedFromFee(address indexed account);
    event IncludedInFee(address indexed account);
    event PancakePairSet(address indexed swapV2Pair);
    event PancakeRouterSet(address indexed routerAddress);
    event MarketingWalletSet(address indexed account);
    event ShibbaWalletSet(address indexed account);
    event AdminSet(address indexed account);
    event RewardsAirdropped(address indexed account, uint256 amount);
    event MaxTxAmountSet(uint256 maxTxAmount);
    event NumTokensSellToAddToLiquiditySet(uint256 tokenAmount);
    event NumTokensToSendCollectedFeeSet(uint256 tokenAmount);
    event LiquidityFeePercentSet(uint256 liquidityFee);
    event MarketingFeePercentSet(uint256 marketingPercent);
    event RewardFeePercentSet(uint256 rewardPercent);
    event BurnFeePercentSet(uint256 burnPercent);
    event ShibbaFeePercentSet(uint256 shibbaPercent);
    event IncreasedAllowance(
        address indexed sender,
        address indexed spender,
        uint256 amount
    );
    event DecreasedAllowance(
        address indexed sender,
        address indexed spender,
        uint256 amount
    );

    modifier onlyOwner() {
        if (msg.sender != state.config.addresses[Types.AddressConfig.ADMIN])
            revert OnlyOwnerCanPerformThisAction();
        _;
    }

    constructor(address admin) {
        state.initialize(admin);
    }

    receive() external payable {}

    function name() public view returns (string memory) {
        return state.config.strings[Types.StringConfig.TOKEN_NAME];
    }

    function symbol() public view returns (string memory) {
        return state.config.strings[Types.StringConfig.TOKEN_SYMBOL];
    }

    function decimals() public view returns (uint256) {
        return state.config.uints[Types.UintConfig.TOKEN_DECIMALS];
    }

    function totalSupply() public view returns (uint256) {
        return state._tTotal;
    }

    function balanceOf(address _account) public view returns (uint256) {
        return state.balanceOf(_account);
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {
        return state._allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount) public returns (bool) {
        state._approve(msg.sender, _spender, _amount);
        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue) public {
        state._approve(
            msg.sender,
            _spender,
            state._allowances[msg.sender][_spender].add(_addedValue)
        );
        emit IncreasedAllowance(msg.sender, _spender, _addedValue);
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue)
        public
    {
        state._approve(
            msg.sender,
            _spender,
            state._allowances[msg.sender][_spender].sub(_subtractedValue)
        );
        emit DecreasedAllowance(msg.sender, _spender, _subtractedValue);
    }

    function transfer(address _recipient, uint256 _amount)
        public
        returns (bool)
    {
        state._transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public returns (bool) {
        state._transfer(_sender, _recipient, _amount);
        state._approve(
            _sender,
            msg.sender,
            state._allowances[_sender][msg.sender].sub(_amount, "EX")
        );
        return true;
    }

    function accounts()
        external
        view
        returns (
            address admin,
            address marketing,
            address shibba,
            address router,
            address pair
        )
    {
        admin = state.config.addresses[Types.AddressConfig.ADMIN];
        marketing = state.config.addresses[Types.AddressConfig.MARKETING];
        shibba = state.config.addresses[Types.AddressConfig.SHIBBA];
        router = state.routerAddress;
        pair = state.swapV2Pair;
    }

    function stats()
        external
        view
        returns (
            uint256 numTokensToSendCollectedFee,
            uint256 numTokensSellToAddToLiquidity,
            uint256 maxTxAmount,
            bool isSwapAndLiquifyEnabled,
            bool isSendCollectedFeeEnabled
        )
    {
        numTokensToSendCollectedFee = state.numTokensToSendCollectedFee;
        numTokensSellToAddToLiquidity = state.numTokensSellToAddToLiquidity;
        maxTxAmount = state.MAXTxAmount;
        isSwapAndLiquifyEnabled = isSwapAndLiquifyEnabled;
        isSendCollectedFeeEnabled = isSendCollectedFeeEnabled;
    }

    function fees()
        external
        view
        returns (
            uint256 taxToDeduct,
            uint256 marketingPercent,
            uint256 shibbaPercent,
            uint256 rewardPercent,
            uint256 liquidityPercent,
            uint256 burnPercent,
            uint256 taxTotal,
            uint256 burnTotal,
            uint256 collectedFee
        )
    {
        collectedFee = state.collectedFee;
        taxToDeduct = state._taxToDeduct;
        taxTotal = state._tFeeTotal;
        burnTotal = state._tBurnTotal;
        marketingPercent = state.marketingPercent;
        shibbaPercent = state.shibbaPercent;
        rewardPercent = state.rewardPercent;
        liquidityPercent = state._liquidityFee;
        burnPercent = state.burnPercent;
    }

    function pancakePair() external view returns (address) {
        return state.swapV2Pair;
    }

    function isExcludedFromReward(address _account)
        external
        view
        returns (bool)
    {
        return state._isExcludedFromReward[_account];
    }

    function reflectionFromToken(uint256 _tAmount, bool _willDeductTransferFee)
        external
        view
        returns (uint256)
    {
        return state.reflectionFromToken(_tAmount, _willDeductTransferFee);
    }

    function tokenFromReflection(uint256 rAmount)
        external
        view
        returns (uint256)
    {
        return state.tokenFromReflection(rAmount);
    }

    function calculateTaxFee(uint256 _amount) external view returns (uint256) {
        return state.calculateTaxFee(_amount);
    }

    function airdrop(uint256 _tAmount) external {
        if (state._isExcludedFromReward[msg.sender])
            revert CannotAirdropRewardsFromARewardsExcludedAccount();

        (uint256 rAmount, , , , ) = state._getValues(_tAmount);
        state._rOwned[msg.sender] = state._rOwned[msg.sender].sub(rAmount);
        state._rTotal = state._rTotal.sub(rAmount);
        emit RewardsAirdropped(msg.sender, _tAmount);
    }

    function setAdmin(address _account) external onlyOwner {
        state.config.addresses[Types.AddressConfig.ADMIN] = _account;
        emit AdminSet(_account);
    }

    function excludeFromFee(address _account) public onlyOwner {
        state._isExcludedFromFee[_account] = true;
        emit ExcludedFromFee(_account);
    }

    function includeInFee(address _account) external onlyOwner {
        state._isExcludedFromFee[_account] = false;
        emit IncludedInFee(_account);
    }

    function setSwapAndLiquifyEnabled(bool _isEnabled) external onlyOwner {
        state.isSwapAndLiquifyEnabled = _isEnabled;
        emit IsSwapAndLiquifyEnabledSet(_isEnabled);
    }

    function setIsSendCollectedFeeEnabled(bool _isEnabled) external onlyOwner {
        state.isSendCollectedFeeEnabled = _isEnabled;
        emit IsSendCollectedFeeEnabledSet(_isEnabled);
    }

    function setPancakeAddress(
        address _routerAddress,
        bool _willCreateSwapPair,
        address _swapV2Pair
    ) external onlyOwner {
        IUniswapV2Router02 _swapV2Router = IUniswapV2Router02(_routerAddress);

        if (_willCreateSwapPair) {
            address swapV2Pair = IUniswapV2Factory(_swapV2Router.factory())
                .createPair(address(this), _swapV2Router.WETH());
            state.swapV2Pair = swapV2Pair;
        } else {
            state.swapV2Pair = _swapV2Pair;
        }
        state.swapV2Router = _swapV2Router;
        state.routerAddress = _routerAddress;
        excludeFromFee(state.swapV2Pair);
        excludeFromReward(state.swapV2Pair);
        excludeFromFee(_routerAddress);
        excludeFromReward(_routerAddress);
        emit PancakePairSet(state.swapV2Pair);
        emit PancakeRouterSet(_routerAddress);
    }

    function excludeFromReward(address _account) public onlyOwner {
        if (state._isExcludedFromReward[_account])
            revert AlreadyExcludedFromReward();

        if (state._rOwned[_account] > 0) {
            state._tOwned[_account] = state.tokenFromReflection(
                state._rOwned[_account]
            );
        }

        state._isExcludedFromReward[_account] = true;
        state._excludedFromReward.push(_account);

        emit ExcludedFromReward(_account);
    }

    function includeInReward(address _account) external onlyOwner {
        if (!state._isExcludedFromReward[_account]) {
            revert AlreadyIncludedInReward();
        }

        uint256 excludedLength = state._excludedFromReward.length;
        for (uint256 i = 0; i < excludedLength; i++) {
            if (state._excludedFromReward[i] == _account) {
                state._excludedFromReward[i] = state._excludedFromReward[
                    excludedLength - 1
                ];

                state._tOwned[_account] = 0;
                state._isExcludedFromReward[_account] = false;
                state._excludedFromReward.pop();
                break;
            }
        }
        emit IncludedInReward(_account);
    }

    function setMarketingWallet(address _account) external onlyOwner {
        state.config.addresses[Types.AddressConfig.MARKETING] = _account;
        excludeFromFee(_account);
        emit MarketingWalletSet(_account);
    }

    function setShibbaWallet(address _account) external onlyOwner {
        state.config.addresses[Types.AddressConfig.SHIBBA] = _account;
        excludeFromFee(_account);
        emit ShibbaWalletSet(_account);
    }

    function setMaxTxAmount(uint256 _maxTxAmount) external onlyOwner {
        state.MAXTxAmount = _maxTxAmount;
        emit MaxTxAmountSet(_maxTxAmount);
    }

    function setNumTokensSellToAddToLiquidity(uint256 _tokenAmount)
        external
        onlyOwner
    {
        state.numTokensSellToAddToLiquidity = _tokenAmount;
        emit NumTokensSellToAddToLiquiditySet(_tokenAmount);
    }

    function setNumTokensToSendCollectedFee(uint256 _tokenAmount)
        external
        onlyOwner
    {
        state.numTokensToSendCollectedFee = _tokenAmount;
        emit NumTokensToSendCollectedFeeSet(_tokenAmount);
    }

    function setLiquidityFeePercent(uint256 _liquidityFee) external onlyOwner {
        state.ensureMaxFeeCap(state._liquidityFee, _liquidityFee);
        state._liquidityFee = _liquidityFee;
        state._taxToDeduct = state.calculateTaxToDeduct();
        emit LiquidityFeePercentSet(_liquidityFee);
    }

    function setMarketingFeePercent(uint256 _marketingPercent)
        external
        onlyOwner
    {
        state.ensureMaxFeeCap(state.marketingPercent, _marketingPercent);
        state.marketingPercent = _marketingPercent;
        state._taxToDeduct = state.calculateTaxToDeduct();
        emit MarketingFeePercentSet(_marketingPercent);
    }

    function setRewardFeePercent(uint256 _rewardPercent) external onlyOwner {
        state.ensureMaxFeeCap(state.rewardPercent, _rewardPercent);
        state.rewardPercent = _rewardPercent;
        state._taxToDeduct = state.calculateTaxToDeduct();
        emit RewardFeePercentSet(_rewardPercent);
    }

    function setBurnFeePercent(uint256 _burnPercent) external onlyOwner {
        state.ensureMaxFeeCap(state.burnPercent, _burnPercent);
        state.burnPercent = _burnPercent;
        state._taxToDeduct = state.calculateTaxToDeduct();
        emit BurnFeePercentSet(_burnPercent);
    }

    function setShibbaFeePercent(uint256 _shibbaPercent) external onlyOwner {
        state.ensureMaxFeeCap(state.shibbaPercent, _shibbaPercent);
        state.shibbaPercent = _shibbaPercent;
        state._taxToDeduct = state.calculateTaxToDeduct();
        emit ShibbaFeePercentSet(_shibbaPercent);
    }

    function setIsTradeOpen(bool _isTradeOpen) external onlyOwner {
        state.isTradeOpen = _isTradeOpen;
        emit IsTradeOpenSet(_isTradeOpen);
    }
}

// error codes
// EX - ERC20: transfer amount exceeds allowance