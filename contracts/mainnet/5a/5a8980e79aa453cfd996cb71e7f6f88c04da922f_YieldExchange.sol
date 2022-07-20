/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

/** 
 *  SourceUnit: d:\projects\Aplicature\yieldexchanges\contracts\YieldExchange.sol
*/
            

///@notice This contract adds liquidity to Uniswap V2 pools using ETH or any ERC20 Token.
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: GPLv2

pragma solidity 0.8.9; 

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Pair {
    function token0() external pure returns (address);
    function totalSupply() external view returns (uint256);
    function token1() external pure returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        );

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}



/** 
 *  SourceUnit: d:\projects\Aplicature\yieldexchanges\contracts\YieldExchange.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [////IMPORTANT]
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
     * ////IMPORTANT: because control is transferred to `recipient`, care must be
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




/** 
 *  SourceUnit: d:\projects\Aplicature\yieldexchanges\contracts\YieldExchange.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
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
     * ////IMPORTANT: Beware that changing an allowance with this method brings the risk
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




/** 
 *  SourceUnit: d:\projects\Aplicature\yieldexchanges\contracts\YieldExchange.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
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




/** 
 *  SourceUnit: d:\projects\Aplicature\yieldexchanges\contracts\YieldExchange.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: GPLv2
pragma solidity 0.8.9; 

////import "./IUniswap.sol";

interface IRouterStrategy {
  function swapExactTokenToToken(address router, address[] memory path, uint256 amount) external returns(uint256);
  function addLiquidity(
    address router,
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    address to
  ) external returns (uint256 liquidity);
  function removeLiquidity(
    address router,
    address pool,
    uint256 amount,
    address toWhomToIssue
  ) external returns(uint256 amountA, uint256 amountB);
}



/** 
 *  SourceUnit: d:\projects\Aplicature\yieldexchanges\contracts\YieldExchange.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

////import "../IERC20.sol";
////import "../../../utils/Address.sol";

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




/** 
 *  SourceUnit: d:\projects\Aplicature\yieldexchanges\contracts\YieldExchange.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
}




/** 
 *  SourceUnit: d:\projects\Aplicature\yieldexchanges\contracts\YieldExchange.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

////import "../utils/Context.sol";

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
        _transferOwnership(_msgSender());
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
}


/** 
 *  SourceUnit: d:\projects\Aplicature\yieldexchanges\contracts\YieldExchange.sol
*/

///@notice This contract adds liquidity to Uniswap V2 pools using ETH or any ERC20 Token.
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: GPLv2
pragma solidity 0.8.9; 
////import "@openzeppelin/contracts/access/Ownable.sol";
////import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
////import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
////import "@openzeppelin/contracts/utils/Address.sol";
////import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

////import "./Interfaces/IUniswap.sol";
////import "./Interfaces/IRouterStrategy.sol";

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
}

interface INoMintRewardPool {
    function stake(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function getReward() external;
    function exit() external;
    function lpToken() external returns (address);
}


interface IExchangeStorage {
    function getFactoryByName(string calldata) external returns (address);
    function getRouterByName(string calldata) external returns (address);
}


contract YieldExchange is ReentrancyGuard, Ownable {
    using Address for address;
    using SafeERC20 for IERC20;

    address public wrappedNativeToken;
    address public exchangeLibrary;
    address public exchangeStorage;
    mapping(address => IRouterStrategy) public routerStrategy;

    struct TokenTrade {
		address[] routers;
		address[][] paths;
    }

    struct LiquidityTrade {
        TokenTrade token0;
        TokenTrade token1;
    }

    struct AddLiquidityTrade {
        LiquidityTrade liquidityTrade;
        uint256 token0Amount;
        uint256 token1Amount;
    }

    constructor(address _wrappedNativeToken, address _exchangeLibrary, address _exchangeStorage) {
        wrappedNativeToken = _wrappedNativeToken;
        exchangeLibrary = _exchangeLibrary;
        exchangeStorage = _exchangeStorage;
    }

    function setStrategy(address router, IRouterStrategy strategy) external {
        routerStrategy[router] = strategy;
    }

    function addLiquidity(
        address _toWhomToIssue,
        address _fromTokenAddress,
        address _toPairAddress,
        address _poolRouter,
        address _poolFactory,
        uint256 _amount,
        uint256 _minPoolTokens,
        AddLiquidityTrade calldata _trade
    ) external payable returns (uint256) {
        return addLiquidity(
            _toWhomToIssue,
            _fromTokenAddress,
            IUniswapV2Pair(_toPairAddress).token0(),
            IUniswapV2Pair(_toPairAddress).token1(),
            _poolRouter,
            _poolFactory,
            _amount,
            _minPoolTokens,
            _trade
        );
    }

    /**
    @notice This function is used to invest in given Uniswap V2 pair through ETH/ERC20 Tokens
    @param _FromTokenContractAddress The ERC20 token used for investment (address(0x00) if ether)
    @param _ToUnipoolToken0 The Uniswap V2 pair token0 address
    @param _ToUnipoolToken1 The Uniswap V2 pair token1 address
    @param _amount The amount of fromToken to invest
    @param _minPoolTokens Reverts if less tokens received than this
    @return Amount of LP bought
     */
    function addLiquidity(
        address _toWhomToIssue,
        address _FromTokenContractAddress,
        address _ToUnipoolToken0,
        address _ToUnipoolToken1,
        address _poolRouter,
        address _poolFactory,
        uint256 _amount,
        uint256 _minPoolTokens,
        AddLiquidityTrade calldata _trade
    ) public payable nonReentrant returns (uint256) {
        uint256 toInvest;
        if (_FromTokenContractAddress == address(0)) {
            require(msg.value > 0, "Error: ETH not sent");
            toInvest = msg.value;
        } else {
            require(msg.value == 0, "Error: ETH sent");
            require(_amount > 0, "Error: Invalid ERC amount");
            IERC20(_FromTokenContractAddress).safeTransferFrom(
                msg.sender,
                address(this),
                _amount
            );
            toInvest = _amount;
        }

        if (
            _trade.liquidityTrade.token0.paths[0].length == 0 &&
            _trade.liquidityTrade.token1.paths[0].length == 0
        ) {
            return addLiquidityDefaultPath(
                _toWhomToIssue,
                _FromTokenContractAddress,
                _ToUnipoolToken0,
                _ToUnipoolToken1,
                IUniswapV2Router02(_poolRouter),
                IUniswapV2Factory(_poolFactory),
                _amount,
                _minPoolTokens
            );
        } else {
            return addLiquidityWithPath(
                _toWhomToIssue,
                _ToUnipoolToken0,
                _ToUnipoolToken1,
                _poolRouter,
                toInvest,
                _trade
            );
        }
    }

    function addLiquidityWithPath(
        address _toWhomToIssue,
        address _ToUnipoolToken0,
        address _ToUnipoolToken1,
        address _poolRouter,
        uint256 _amount,
        AddLiquidityTrade calldata _trades
    ) public returns(uint256) {
        uint256 token0Bought = swapTokenToTokenWithPath(
            _trades.liquidityTrade.token0,
            _trades.token0Amount == 0 ? _amount / 2 : _trades.token0Amount
        );
        uint256 token1Bought = swapTokenToTokenWithPath(
            _trades.liquidityTrade.token1,
            _trades.token1Amount == 0 ? _amount / 2 : _trades.token1Amount
        );

        return depositToPool(
            _toWhomToIssue,
            _ToUnipoolToken0,
            _ToUnipoolToken1,
            token0Bought,
            token1Bought,
            _poolRouter
        );
    }

    function addLiquidityDefaultPath(
        address _toWhomToIssue,
        address _FromTokenContractAddress,
        address _ToUnipoolToken0,
        address _ToUnipoolToken1,
        IUniswapV2Router02 _poolRouter,
        IUniswapV2Factory _poolFactory,
        uint256 _amount,
        uint256 _minPoolTokens
    ) public returns(uint256) {
        uint256 LPBought = findPathAndDepositToPool(
            _toWhomToIssue,
            _FromTokenContractAddress,
            _ToUnipoolToken0,
            _ToUnipoolToken1,
            _amount,
            _poolFactory,
            _poolRouter
        );
        require(LPBought >= _minPoolTokens, "ERR: High Slippage");
        return LPBought;
    }

    function findPathAndDepositToPool(
        address _toWhomToIssue,
        address _FromTokenContractAddress,
        address _ToUnipoolToken0,
        address _ToUnipoolToken1,
        uint256 _amount,
        IUniswapV2Factory uniswapFactory,
        IUniswapV2Router02 uniswapRouter
    ) internal returns (uint256) {
        address intermediate = getIntermediate(
            _FromTokenContractAddress,
            _amount,
            _ToUnipoolToken0,
            _ToUnipoolToken1,
            uniswapFactory,
            uniswapRouter
        );

        // swap to intermediate
        uint256 interAmt = _token2Token(
            _FromTokenContractAddress,
            intermediate,
            _amount
        );

        // divide to swap in amounts
        uint256 token0Bought;
        uint256 token1Bought;

        if (intermediate == _ToUnipoolToken0) {
            token1Bought = _token2Token(
                intermediate,
                _ToUnipoolToken1,
                interAmt / 2
            );
            token0Bought = interAmt / 2;
        } else {
            token0Bought = _token2Token(
                intermediate,
                _ToUnipoolToken0,
                interAmt / 2
            );
            token1Bought = interAmt / 2;
        }

        return depositToPool(
            _toWhomToIssue,
            _ToUnipoolToken0,
            _ToUnipoolToken1,
            token0Bought,
            token1Bought,
            address(uniswapRouter)
        );
    }

    function getIntermediate(
        address _FromTokenContractAddress,
        uint256 _amount,
        address _ToUnipoolToken0,
        address _ToUnipoolToken1,
        IUniswapV2Factory uniswapFactory,
        IUniswapV2Router02 uniswapRouter
    ) public view returns (address) {
        // set from to wrappedNativeToken for eth input
        if (_FromTokenContractAddress == address(0)) {
            _FromTokenContractAddress = wrappedNativeToken;
        }

        if (_FromTokenContractAddress == _ToUnipoolToken0) {
            return _ToUnipoolToken0;
        } else if (_FromTokenContractAddress == _ToUnipoolToken1) {
            return _ToUnipoolToken1;
        } else if(_ToUnipoolToken0 == wrappedNativeToken || _ToUnipoolToken1 == wrappedNativeToken) {
            return wrappedNativeToken;  
        } else {
            IUniswapV2Pair pair = IUniswapV2Pair(
                uniswapFactory.getPair(
                    _ToUnipoolToken0,
                    _ToUnipoolToken1
                )
            );
            (uint256 res0, uint256 res1, ) = pair.getReserves();

            uint256 ratio;
            bool isToken0Numerator;
            if (res0 >= res1) {
                ratio = res0 / res1;
                isToken0Numerator = true;
            } else {
                ratio = res1 / res0;
            }

            //find outputs on swap
            uint256 output0 = _calculateSwapOutput(
                _FromTokenContractAddress,
                _amount,
                _ToUnipoolToken0,
                uniswapFactory,
                uniswapRouter
            );
            uint256 output1 = _calculateSwapOutput(
                _FromTokenContractAddress,
                _amount,
                _ToUnipoolToken1,
                uniswapFactory,
                uniswapRouter
            );

            if (isToken0Numerator) {
                if (output1 * ratio >= output0) return _ToUnipoolToken1;
                else return _ToUnipoolToken0;
            } else {
                if (output0 * ratio >= output1) return _ToUnipoolToken0;
                else return _ToUnipoolToken1;
            }
        }
    }

    function _calculateSwapOutput(
        address _from,
        uint256 _amt,
        address _to,
        IUniswapV2Factory uniswapFactory,
        IUniswapV2Router02 uniswapRouter
    ) internal view returns (uint256) {
        // check output via tokenA -> tokenB
        address pairA = uniswapFactory.getPair(_from, _to);

        uint256 amtA;
        if (pairA != address(0)) {
            address[] memory pathA = new address[](2);
            pathA[0] = _from;
            pathA[1] = _to;

            amtA = uniswapRouter.getAmountsOut(_amt, pathA)[1];
        }

        uint256 amtB;
        // check output via tokenA -> wrappedNativeToken -> tokenB
        if ((_from != wrappedNativeToken) && _to != wrappedNativeToken) {
            address[] memory pathB = new address[](3);
            pathB[0] = _from;
            pathB[1] = wrappedNativeToken;
            pathB[2] = _to;

            amtB = uniswapRouter.getAmountsOut(_amt, pathB)[2];
        }

        if (amtA >= amtB) {
            return amtA;
        } else {
            return amtB;
        }
    }

    function depositToPool(
        address _toWhomToIssue,
        address _ToUnipoolToken0,
        address _ToUnipoolToken1,
        uint256 token0Bought,
        uint256 token1Bought,
        address _poolRouter
    ) internal returns (uint256) {
        IRouterStrategy strategy = routerStrategy[_poolRouter];

        IERC20(_ToUnipoolToken0).transfer(address(strategy), token0Bought);
        IERC20(_ToUnipoolToken1).transfer(address(strategy), token1Bought);

        return strategy.addLiquidity(
            _poolRouter,
            _ToUnipoolToken0,
            _ToUnipoolToken1,
            token0Bought,
            token1Bought,
            _toWhomToIssue
        );
    }

    /**
    @notice This function is used to yzapout of given Uniswap pair in ETH/ERC20 Tokens
    @param _toToken The ERC20 token to yzapout in (address(0x00) if ether)
    @param _poolAddress The uniswap pair address to yzapout from
    @param _amount The amount of LP
    @return the amount of eth/tokens received after yzapout
     */
    function removeLiquidity(
        address payable _toWhomToIssue,
        address _toToken,
        address _poolAddress,
        address _poolRouter,
        uint256 _amount,
        uint256 _minTokensRec,
        LiquidityTrade calldata _trade
    ) public nonReentrant returns(uint256) {
        IERC20(_poolAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );

        if (_trade.token0.paths[0].length == 0 && _trade.token1.paths[0].length == 0) {
            return removeLiquidityDefaultPath(
                _poolAddress,
                _poolRouter,
                _toToken,
                _toWhomToIssue,
                _amount,
                _minTokensRec
            );
        } else {
            return removeLiquidityWithPath(
                _poolAddress,
                _poolRouter,
                _toToken,
                _toWhomToIssue,
                _amount,
                _trade
            );
        }
    }

    function removeLiquidityDefaultPath(
        address _pool,
        address _poolRouter,
        address _toToken,
        address payable _toWhomToIssue,
        uint256 _amount,
        uint256 _minTokensRec
    ) public returns(uint256 tokenBought) {
        (uint256 amountA, uint256 amountB) = removeLiquidity(_pool, _poolRouter, _amount);

        address token0 = IUniswapV2Pair(_pool).token0();
        address token1 = IUniswapV2Pair(_pool).token1();

        tokenBought = _token2Token(token0, _toToken, amountA);
        tokenBought += _token2Token(token1, _toToken, amountB);

        require(tokenBought >= _minTokensRec, "High slippage");

        if (_toToken == address(0)) {
            Address.sendValue(_toWhomToIssue, tokenBought);
        } else {
            IERC20(_toToken).safeTransfer(
                _toWhomToIssue,
                tokenBought
            );
        }

        return tokenBought;
    }

    function removeLiquidityWithPath(
        address _pool,
        address _poolRouter,
        address _toToken,
        address payable _toWhomToIssue,
        uint256 _amount,
        LiquidityTrade calldata _trade
    ) public returns(uint256 tokenBought) {
        (uint256 amountA, uint256 amountB) = removeLiquidity(_pool, _poolRouter, _amount);

        tokenBought = swapTokenToTokenWithPath(_trade.token0, amountA);
        tokenBought += swapTokenToTokenWithPath(_trade.token1, amountB);

        IERC20(_toToken).safeTransfer(_toWhomToIssue, tokenBought);

        return tokenBought;
    }

    function removeLiquidity(
        address _pool,
        address _poolRouter,
        uint256 _amount
    ) internal returns(uint256, uint256) {
        IRouterStrategy strategy = routerStrategy[_poolRouter];
        IERC20(_pool).transfer(
            address(strategy),
            _amount
        );

        return strategy.removeLiquidity(
            _poolRouter,
            _pool,
            _amount,
            address(this)
        );
    }

    /**
    @notice This function is used to swap ETH/ERC20 <> ETH/ERC20
    @param _FromTokenContractAddress The token address to swap from. (0x00 for ETH)
    @param _ToTokenContractAddress The token address to swap to. (0x00 for ETH)
    @param tokens2Trade The amount of tokens to swap
    @return tokenBought The quantity of tokens bought
    */
    function _token2Token(
        address _FromTokenContractAddress,
        address _ToTokenContractAddress,
        uint256 tokens2Trade
    ) internal returns (uint256 tokenBought) {
        bool status;
        bytes memory result;
        (status, result) = exchangeLibrary.delegatecall(abi.encodeWithSignature(
            "convertTokenToToken(address,address,address,address,uint256,uint256)",  
            exchangeStorage, address(this), _FromTokenContractAddress, _ToTokenContractAddress, tokens2Trade, 1
        ));
        require(status, "convertTokenToToken call failed");
        return abi.decode(result, (uint256));
    }

    function swapTokenToTokenWithPath(TokenTrade calldata _trade, uint256 _amount) internal returns(uint256) {
        for (uint256 i = 0; i < _trade.routers.length; i++) {
            IRouterStrategy strategy = routerStrategy[_trade.routers[i]];
            IERC20(_trade.paths[i][0]).transfer(address(strategy), _amount);
            _amount = strategy.swapExactTokenToToken(_trade.routers[i], _trade.paths[i], _amount);
        }
        return _amount;
    }

    function changeExchangeLibraryAndStorage(address _exchangeLibrary, address _exchangeStorage) public onlyOwner {
        exchangeLibrary = _exchangeLibrary;
        exchangeStorage = _exchangeStorage;
    }

    function inCaseTokengetsStuck(IERC20 _token) public onlyOwner {
        uint256 balance = _token.balanceOf(address(this));
        _token.safeTransfer(owner(), balance);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    receive() external payable {
        require(msg.sender != tx.origin, "Do not send ETH directly");
    }
}