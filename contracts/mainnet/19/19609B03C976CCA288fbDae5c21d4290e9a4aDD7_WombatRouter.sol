// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

import '../interfaces/IPool.sol';
import '../interfaces/IWombatRouter.sol';

interface IWNative {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}

/**
 * @title WombatRouter
 * @notice Allows routing on different wombat pools
 * @dev Owner is allowed and required to approve token spending by pools via approveSpendingByPool function.
 * With great thanks to the uniswap team for your contribution to the opensource community
 * reference: https://github.com/Uniswap/v2-periphery/blob/master/contracts/UniswapV2Router02.sol
 */
contract WombatRouter is Ownable, IWombatRouter {
    using SafeERC20 for IERC20;

    // WBNB (mainnet): 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    // WBNB (testnet): 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
    IWNative public immutable wNative;

    constructor(IWNative _wNative) {
        wNative = _wNative;
    }

    receive() external payable {
        require(msg.sender == address(wNative));
    }

    /// @notice approve spending of router tokens by pool
    /// @param tokens array of tokens to be approved
    /// @param pool to be approved to spend
    /// @dev needs to be done after asset deployment for router to be able to support the tokens
    function approveSpendingByPool(address[] calldata tokens, address pool) external onlyOwner {
        for (uint256 i; i < tokens.length; ++i) {
            IERC20(tokens[i]).safeApprove(pool, 0);
            IERC20(tokens[i]).safeApprove(pool, type(uint256).max);
        }
    }

    function addLiquidityNative(
        IPool pool,
        uint256 minimumLiquidity,
        address to,
        uint256 deadline,
        bool shouldStake
    ) external payable override returns (uint256 liquidity) {
        wNative.deposit{value: msg.value}();
        return pool.deposit(address(wNative), msg.value, minimumLiquidity, to, deadline, shouldStake);
    }

    function removeLiquidityNative(
        IPool pool,
        uint256 liquidity,
        uint256 minimumAmount,
        address to,
        uint256 deadline
    ) external override returns (uint256 amount) {
        address asset = pool.addressOfAsset(address(wNative));
        IERC20(asset).transferFrom(address(msg.sender), address(this), liquidity);

        amount = pool.withdraw(address(wNative), liquidity, minimumAmount, address(this), deadline);
        wNative.withdraw(amount);
        _safeTransferNative(to, amount);
    }

    function removeLiquidityFromOtherAssetAsNative(
        IPool pool,
        address fromToken,
        uint256 liquidity,
        uint256 minimumAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 amount) {
        address asset = pool.addressOfAsset(fromToken);
        IERC20(asset).transferFrom(address(msg.sender), address(this), liquidity);

        amount = pool.withdrawFromOtherAsset(
            fromToken,
            address(wNative),
            liquidity,
            minimumAmount,
            address(this),
            deadline
        );
        wNative.withdraw(amount);
        _safeTransferNative(to, amount);
    }

    /// @notice Swaps an exact amount of input tokens for as many output tokens as possible, along the route determined by the path
    /// @param tokenPath An array of token addresses. path.length must be >= 2.
    /// @param tokenPath The first element of the path is the input token, the last element is the output token.
    /// @param poolPath An array of pool addresses. The pools where the pathTokens are contained in order.
    /// @param amountIn the amount in
    /// @param minimumamountOut the minimum amount to get for user
    /// @param to the user to send the tokens to
    /// @param deadline the deadline to respect
    /// @return amountOut received by user
    function swapExactTokensForTokens(
        address[] calldata tokenPath,
        address[] calldata poolPath,
        uint256 amountIn,
        uint256 minimumamountOut,
        address to,
        uint256 deadline
    ) external override returns (uint256 amountOut) {
        require(deadline >= block.timestamp, 'expired');
        require(tokenPath.length >= 2, 'invalid token path');
        require(poolPath.length == tokenPath.length - 1, 'invalid pool path');

        // get from token from users
        IERC20(tokenPath[0]).safeTransferFrom(address(msg.sender), address(this), amountIn);

        amountOut = _swap(tokenPath, poolPath, amountIn, to);
        require(amountOut >= minimumamountOut, 'amountOut too low');
    }

    function swapExactNativeForTokens(
        address[] calldata tokenPath,
        address[] calldata poolPath,
        uint256 minimumamountOut,
        address to,
        uint256 deadline
    ) external payable override returns (uint256 amountOut) {
        require(tokenPath[0] == address(wNative), 'the first address should be wrapped token');
        require(deadline >= block.timestamp, 'expired');
        require(poolPath.length == tokenPath.length - 1, 'invalid pool path');

        // get wrapped tokens
        wNative.deposit{value: msg.value}();

        amountOut = _swap(tokenPath, poolPath, msg.value, to);
        require(amountOut >= minimumamountOut, 'amountOut too low');
    }

    function swapExactTokensForNative(
        address[] calldata tokenPath,
        address[] calldata poolPath,
        uint256 amountIn,
        uint256 minimumamountOut,
        address to,
        uint256 deadline
    ) external override returns (uint256 amountOut) {
        require(tokenPath[tokenPath.length - 1] == address(wNative), 'the last address should be wrapped token');
        require(deadline >= block.timestamp, 'expired');
        require(poolPath.length == tokenPath.length - 1, 'invalid pool path');

        // get from token from users
        IERC20(tokenPath[0]).safeTransferFrom(address(msg.sender), address(this), amountIn);

        amountOut = _swap(tokenPath, poolPath, amountIn, address(this));
        require(amountOut >= minimumamountOut, 'amountOut too low');

        wNative.withdraw(amountOut);
        _safeTransferNative(to, amountOut);
    }

    /// @notice Private function to swap alone the token path
    /// @dev Assumes router has initial amountIn in balance.
    /// Assumes tokens being swapped have been approve via the approveSpendingByPool function
    /// @param tokenPath An array of token addresses. path.length must be >= 2.
    /// @param tokenPath The first element of the path is the input token, the last element is the output token.
    /// @param poolPath An array of pool addresses. The pools where the pathTokens are contained in order.
    /// @param amountIn the amount in
    /// @param to the user to send the tokens to
    /// @return amountOut received by user
    function _swap(
        address[] calldata tokenPath,
        address[] calldata poolPath,
        uint256 amountIn,
        address to
    ) internal returns (uint256 amountOut) {
        // next from amount, starts with amountIn in arg
        uint256 nextamountIn = amountIn;

        // first n - 1 swaps
        for (uint256 i; i < poolPath.length - 1; ++i) {
            // make the swap with the correct arguments
            (amountOut, ) = IPool(poolPath[i]).swap(
                tokenPath[i],
                tokenPath[i + 1],
                nextamountIn,
                0, // minimum amount received is ensured on calling function
                address(this),
                type(uint256).max // deadline is ensured on calling function
            );
            nextamountIn = amountOut;
        }

        // last swap
        uint256 i = poolPath.length - 1;
        (amountOut, ) = IPool(poolPath[i]).swap(
            tokenPath[i],
            tokenPath[i + 1],
            nextamountIn,
            0, // minimum amount received is ensured on calling function
            to,
            type(uint256).max // deadline is ensured on calling function
        );
    }

    /**
     * @notice Given an input asset amount and an array of token addresses, calculates the
     * maximum output token amount (accounting for fees and slippage).
     * @param tokenPath The token swap path
     * @param poolPath The token pool path
     * @param amountIn The from amount
     * @return amountOut The potential final amount user would receive
     */
    function getAmountOut(
        address[] calldata tokenPath,
        address[] calldata poolPath,
        int256 amountIn
    ) external view override returns (uint256 amountOut, uint256[] memory haircuts) {
        require(tokenPath.length >= 2, 'invalid token path');
        require(poolPath.length == tokenPath.length - 1, 'invalid pool path');

        // next from amount, starts with amountIn in arg
        int256 nextamountIn = amountIn;
        haircuts = new uint256[](poolPath.length);

        for (uint256 i; i < poolPath.length; ++i) {
            // make the swap with the correct arguments
            (amountOut, haircuts[i]) = IPool(poolPath[i]).quotePotentialSwap(
                tokenPath[i],
                tokenPath[i + 1],
                nextamountIn
            );
            nextamountIn = int256(amountOut);
        }
    }

    /**
     * @notice Returns the minimum input asset amount required to buy the given output asset amount
     * (accounting for fees and slippage)
     * Note: This function should be used as estimation only. The actual swap amount might
     * be different due to precision error (the error is typically under 1e-6)
     * @param tokenPath The token swap path
     * @param poolPath The token pool path
     * @param amountOut The to amount
     * @return amountIn The potential final amount user would receive
     */
    function getAmountIn(
        address[] calldata tokenPath,
        address[] calldata poolPath,
        uint256 amountOut
    ) external view override returns (uint256 amountIn, uint256[] memory haircuts) {
        require(tokenPath.length >= 2, 'invalid token path');
        require(poolPath.length == tokenPath.length - 1, 'invalid pool path');

        // next from amount, starts with amountIn in arg
        int256 nextAmountOut = int256(amountOut);
        haircuts = new uint256[](poolPath.length);

        for (uint256 i = poolPath.length; i > 0; --i) {
            (amountIn, haircuts[i - 1]) = IPool(poolPath[i - 1]).quoteAmountIn(
                tokenPath[i - 1],
                tokenPath[i],
                nextAmountOut
            );
            nextAmountOut = int256(amountIn);
        }
    }

    function _safeTransferNative(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, '_safeTransferNative fails');
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.5;

interface IPool {
    function getTokens() external view returns (address[] memory);

    function addressOfAsset(address token) external view returns (address);

    function deposit(
        address token,
        uint256 amount,
        uint256 minimumLiquidity,
        address to,
        uint256 deadline,
        bool shouldStake
    ) external returns (uint256 liquidity);

    function withdraw(
        address token,
        uint256 liquidity,
        uint256 minimumAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 amount);

    function withdrawFromOtherAsset(
        address fromToken,
        address toToken,
        uint256 liquidity,
        uint256 minimumAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 amount);

    function swap(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minimumToAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 actualToAmount, uint256 haircut);

    function quotePotentialDeposit(address token, uint256 amount)
        external
        view
        returns (uint256 liquidity, uint256 reward);

    function quotePotentialSwap(
        address fromToken,
        address toToken,
        int256 fromAmount
    ) external view returns (uint256 potentialOutcome, uint256 haircut);

    function quotePotentialWithdraw(address token, uint256 liquidity)
        external
        view
        returns (uint256 amount, uint256 fee);

    function quoteAmountIn(
        address fromToken,
        address toToken,
        int256 toAmount
    ) external view returns (uint256 amountIn, uint256 haircut);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.5;

import './IPool.sol';

interface IWombatRouter {
    function getAmountOut(
        address[] calldata tokenPath,
        address[] calldata poolPath,
        int256 amountIn
    ) external view returns (uint256 amountOut, uint256[] memory haircuts);

    /**
     * @notice Returns the minimum input asset amount required to buy the given output asset amount
     * (accounting for fees and slippage)
     * Note: This function should be used as estimation only. The actual swap amount might
     * be different due to precision error (the error is typically under 1e-6)
     */
    function getAmountIn(
        address[] calldata tokenPath,
        address[] calldata poolPath,
        uint256 amountOut
    ) external view returns (uint256 amountIn, uint256[] memory haircuts);

    function swapExactTokensForTokens(
        address[] calldata tokenPath,
        address[] calldata poolPath,
        uint256 fromAmount,
        uint256 minimumToAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 amountOut);

    function swapExactNativeForTokens(
        address[] calldata tokenPath, // the first address should be WBNB
        address[] calldata poolPath,
        uint256 minimumamountOut,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountOut);

    function swapExactTokensForNative(
        address[] calldata tokenPath, // the last address should be WBNB
        address[] calldata poolPath,
        uint256 amountIn,
        uint256 minimumamountOut,
        address to,
        uint256 deadline
    ) external returns (uint256 amountOut);

    function addLiquidityNative(
        IPool pool,
        uint256 minimumLiquidity,
        address to,
        uint256 deadline,
        bool shouldStake
    ) external payable returns (uint256 liquidity);

    function removeLiquidityNative(
        IPool pool,
        uint256 liquidity,
        uint256 minimumAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 amount);

    function removeLiquidityFromOtherAssetAsNative(
        IPool pool,
        address fromToken,
        uint256 liquidity,
        uint256 minimumAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 amount);
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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