/**
 *Submitted for verification at BscScan.com on 2023-01-17
*/

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
}

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

// File: @openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol


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
interface IERC20Permit {
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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

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

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: contracts/LegacyMatrixV2.sol


// Name: Legacy Stake Power Pack
// https://power.legacystake.com/

pragma solidity 0.8.16;





interface iLSTM {
    function User(address user) external returns (uint, uint, uint, address, address, bool);
    function idToAddress(uint) external returns (address);
    function totalUsers() external returns (uint);    
}

contract LegacyStakeMatrixV2 is Ownable {

    iLSTM LSTMV1;
    using Address for address;
    using SafeERC20 for IERC20;
    IERC20 public BUSD;
    IERC20 public LST;

    /* SETTINGS */
    uint256 public packPrice = 50;
    uint256 public _buyFee = 3;
    uint256 public daySeconds = 21600;
    uint256 private rewardMul = 40;
    uint256 private additionalMul = 100;
    uint256 private percentMul = 1000;
    uint256[10] public rewardMatrixByLevel = [1, 1, 1, 1, 1, 1, 2, 2, 4, 7]; // 21
    uint256[7] public rewardRefByLevel = [5, 1, 1, 2, 2, 2, 2]; // 15
    uint public stage;
    bool public _automatedBuy = true;

    /* PANCAKESWAP */
    IUniswapV2Router02 private uniswapV2Router;
    address[] public _path;

    /* WALLETS */
    address public leaderBoard;

    /* COUNTERS */
    uint256 public totalPacks;
    uint256 public totalUsers;
    uint256 public lockedLST;

    uint256 public mQueueIndex;
    uint256 public mCounter;
    address[] public mQueue;

    /* LISTS */
    struct Pack {
        address user;
        uint claimed;
        uint amount;
        uint multiplier;
        uint createdAt;
    }
    struct Users {
        uint id;
        uint refCount;
        uint refInMatrix;
        uint earnAsSponsor;
        uint earnInMatrix;
        uint[] positionsId;
        address[] positionsWallet;
        address invitedBy;
        address upperInMatrix;
        bool positioned;
    }


    mapping(address => Users) public User;
    mapping(uint => Pack) public Packs;
    mapping(address => uint256[]) public _packs;    
    mapping(address => uint) public addressToId;
    mapping(uint => address) public idToAddress;
    mapping(address => bool) whitelisted;

    /* EVENTS */
    event Register(address indexed user, address indexed invitedBy);
    event Upgrade(address indexed user, address indexed invitedBy);
    event BuyPack(address indexed user, uint packs, uint inAmount);
    event ClaimFromPacks(address indexed user, uint amount);

    modifier onlyEOA() {
        require(tx.origin == msg.sender, "Not EOA");
        _;
    }

    constructor() {

        address _user = msg.sender;
        totalUsers++;
        Users storage user = User[_user];
        user.upperInMatrix = _user;
        user.invitedBy = _user;
        user.positioned = true;
        user.id = totalUsers;
        whitelisted[_user] = true;

        addressToId[_user] = totalUsers;
        idToAddress[totalUsers] = _user;

        mCounter = 0;
        mQueue.push(_user);
        mQueueIndex = 0;

        stage = 0;
        lockedLST = 0;
        leaderBoard = msg.sender;

    }

    function setLSTMV1(address _contractAddress) public onlyOwner returns (bool status_) {
        LSTMV1 = iLSTM(_contractAddress);
        return true;
    }

    function setParams(address _token, address _busdAddress, address _router) public onlyOwner returns (bool) {
        BUSD = IERC20(_busdAddress);
        LST = IERC20(_token);
        uniswapV2Router = IUniswapV2Router02(_router); 
        while(_path.length != 0) _path.pop();
        _path.push(_busdAddress);
        _path.push(uniswapV2Router.WETH());
        _path.push(_token);
        return true;
    }

    function RegisterUser(address _invitedBy) public onlyEOA returns (bool) {
        address _user = msg.sender;
        Users storage user = User[_user];
        require(user.id == 0, "Already registered");

        (uint idV1,,,,,) = LSTMV1.User(_user);
        require(idV1 == 0, "Wallet registered in V1 - use Upgrade");

        totalUsers++;

        user.id = totalUsers;
        user.refCount = 0;
        user.invitedBy = _invitedBy;

        addressToId[_user] = totalUsers;
        idToAddress[totalUsers] = _user;

        Users storage r = User[_invitedBy];
        require(_user != _invitedBy && r.id > 0, "Invalid referral");
        r.refCount++;
        
        emit Register(_user, _invitedBy);

        buyPack(1);
        return true;
    }

    function UpgradeUser() public onlyEOA returns (bool) {
        address _user = msg.sender;
        Users storage user = User[_user];
        require(user.id == 0, "Already upgraded");

        totalUsers++;

        (uint _id,,,address _invitedBy,,) = LSTMV1.User(_user);
        require(_id > 0, "Unable to upgrade - missed in V1");
        
        Users storage r = User[_invitedBy];
        require(r.id > 0, "Unable to upgrade - sponsor not upgraded Yet");

        user.id = totalUsers;
        user.refCount = 0;
        user.invitedBy = _invitedBy;

        addressToId[_user] = totalUsers;
        idToAddress[totalUsers] = _user;
        
        r.refCount++;
        
        emit Upgrade(_user, _invitedBy);
        emit Register(_user, _invitedBy);

        buyPack(1);
        return true;
    }


    function buyPack(uint packs) public returns (bool) {
        address _buyer = msg.sender;
        require(addressToId[_buyer] > 0, "buyPack: User have to be registered first");
        require(stage > 0, "buyPack: Buying Disabled");
        require(packs > 0, "buyPack: Invalid packs amount");

        if(stage == 1) require(whitelisted[_buyer] == true, "Not whitelisted");
        uint packsPrice = (packPrice * 10 ** 18) * packs;

        uint256 currentBalance = LST.balanceOf(address(this));
        require((currentBalance - lockedLST) >= packsPrice * packs * 2, "Not Enough LST");

        uint256 currentBalanceBUSD = BUSD.balanceOf(_buyer);
        require(currentBalanceBUSD >= packsPrice, "Not enough BUSD");
        uint256 allowance = BUSD.allowance(_buyer, address(this));
        require(allowance >= packsPrice, "Not enough allowance");
        BUSD.safeTransferFrom(_buyer, address(this), packsPrice);

        Users storage user = User[_buyer];
        address sponsor = user.invitedBy;
        Users storage userSponsor = User[sponsor];
        if ((_packs[_buyer].length == 0) && (userSponsor.refInMatrix < 2)) {            
            userSponsor.refInMatrix++;
        }

        if ((userSponsor.positioned == false) && (userSponsor.refInMatrix == 2)) {
            userSponsor.positioned = true;
            userSponsor.upperInMatrix = mQueue[mQueueIndex];
            mQueue.push(sponsor);
            mCounter++;
            Users storage u = User[mQueue[mQueueIndex]];
            u.positionsId.push(addressToId[sponsor]);
            u.positionsWallet.push(sponsor);
            if (mCounter == 2) {
                mCounter = 0;
                mQueueIndex++;
            }            
        }

        if (_automatedBuy == true) {
            BUSD.safeApprove(address(uniswapV2Router), 0);
            BUSD.safeApprove(address(uniswapV2Router), packsPrice * 260/1000); // 26% or 13 BUSD
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                packsPrice * 260/1000,  // 26% or 13 BUSD
                0,
                _path,
                address(this),
                block.timestamp
            );
        }

        BUSD.safeTransfer(leaderBoard, packsPrice*200/10000); // 2% or 1 BUSD
       
        totalPacks++;
        Pack storage newPack = Packs[totalPacks];
        newPack.createdAt = block.timestamp;
        newPack.user = _buyer;
        _packs[_buyer].push(totalPacks);
        uint[] memory amounts = uniswapV2Router.getAmountsOut(packsPrice, _path);
        
        if (_buyFee > 0) {
            newPack.amount = (amounts[_path.length - 1] * 2) * (100 - _buyFee) / 100;
            lockedLST += newPack.amount;
        } else {
            newPack.amount = amounts[_path.length - 1] * 2;
            lockedLST += newPack.amount;
        }

        newPack.multiplier = packs;
        emit BuyPack(_buyer, packs, amounts[_path.length - 1] * 2);

        if (user.positioned == true) {
            distributeMatrix(_buyer, packs);
        } else {
            distributeMatrix(owner(), packs);
        }

        distributeRefPayment(_buyer, packs);

        return true;

    }

    function distributeRefPayment(address _user, uint packsAmount) private {        
        address upperSponsor = _user;
        uint collectPayment = 0;
        for (uint i=0; i<7; i++) {
            Users storage u = User[upperSponsor];
            address payTo = u.invitedBy;
            uint payLevelAmount = rewardRefByLevel[i] * 10 ** 18  * packsAmount;

            if (payTo == owner()) {
                collectPayment += payLevelAmount;
            } else {
                uint level = i+1;
                if (u.refCount >= level) {
                    BUSD.safeTransfer(payTo, payLevelAmount);
                    u.earnAsSponsor += payLevelAmount;
                }
                else {
                    collectPayment += payLevelAmount;
                }
            }
            upperSponsor = payTo;
        }     
        if (collectPayment > 0) {
            BUSD.safeTransfer(owner(), collectPayment);
            Users storage u = User[owner()];
            u.earnAsSponsor += collectPayment;
        }
    }

    function distributeMatrix(address _user, uint packsAmount) private {        
        address upperSponsor = _user;
        uint collectPayment = 0;
        for (uint i=0; i<10; i++) {
            Users storage u = User[upperSponsor];
            address payTo = u.upperInMatrix;
            uint payLevelAmount = rewardMatrixByLevel[i] * 10 ** 18  * packsAmount;

            if (payTo == owner()) {
                collectPayment += payLevelAmount;
            } else {
                BUSD.safeTransfer(payTo, payLevelAmount);
                u.earnInMatrix += payLevelAmount;
            }
            upperSponsor = payTo;
        }     
        if (collectPayment > 0) {
            BUSD.safeTransfer(owner(), collectPayment);
            Users storage u = User[owner()];
            u.earnInMatrix += collectPayment;
        }
    }

    function claimPacks() public returns (bool) {
        address _buyer = msg.sender;
        require(addressToId[_buyer] > 0, "claimPacks: User have to be registered first");
        require(_packs[_buyer].length > 0, "claimPacks: No packs bought");
        uint currentTime = block.timestamp;
        uint _toTransfer = 0;
        for(uint i=0; i<_packs[_buyer].length; i++) {
            Pack storage packItem = Packs[_packs[_buyer][i]];
            uint availableQuarterPercent = (currentTime - packItem.createdAt) / rewardMul * additionalMul / daySeconds; 
            if (availableQuarterPercent >= percentMul) availableQuarterPercent = percentMul;
            uint availableToClaim = (packItem.amount * availableQuarterPercent / percentMul) - packItem.claimed;
            packItem.claimed += availableToClaim;
            _toTransfer += availableToClaim;
        }
        require(_toTransfer > 0, "claimPacks: Nothing to claim");
        uint256 currentBalance = LST.balanceOf(address(this));
        require(currentBalance > _toTransfer, "claimPacks: Balance exceed amount to claim");
        if (_toTransfer > 0) {
            lockedLST -= _toTransfer;
            LST.safeTransfer(_buyer, _toTransfer);
            emit ClaimFromPacks(_buyer, _toTransfer);
        }
        return true;
    }

    function claimOnePack(uint packID) public returns (bool) {
        address _buyer = msg.sender;
        require(addressToId[_buyer] > 0, "claimPacks: User have to be registered first");
        require(_packs[_buyer].length > 0, "claimPacks: No packs bought");
        uint currentTime = block.timestamp;
        uint _toTransfer = 0;
        
        Pack storage packItem = Packs[packID];
        require(packItem.user == _buyer, "claimPacks: Invalid User pack ID");
        uint availableQuarterPercent = (currentTime - packItem.createdAt) / rewardMul * additionalMul / daySeconds; 
        if (availableQuarterPercent >= percentMul) availableQuarterPercent = percentMul;
        uint availableToClaim = (packItem.amount * availableQuarterPercent / percentMul) - packItem.claimed;
        packItem.claimed += availableToClaim;
        _toTransfer += availableToClaim;
        
        require(_toTransfer > 0, "claimPacks: Nothing to claim");
        uint256 currentBalance = LST.balanceOf(address(this));
        require(currentBalance > _toTransfer, "claimPacks: Balance exceed amount to claim");
        if (_toTransfer > 0) {
            lockedLST -= _toTransfer;
            LST.safeTransfer(_buyer, _toTransfer);
            emit ClaimFromPacks(_buyer, _toTransfer);
        }
        return true;
    }

    function getClaimAmount() public view returns (uint) {
        address _buyer = msg.sender;
        uint currentTime = block.timestamp;
        uint _toTransfer = 0;
        for(uint i=0; i<_packs[_buyer].length; i++) {
            Pack memory packItem = Packs[_packs[_buyer][i]];
            uint availableQuarterPercent = (currentTime - packItem.createdAt) / rewardMul * additionalMul / daySeconds; 
            if (availableQuarterPercent >= percentMul) availableQuarterPercent = percentMul;
            uint availableToClaim = (packItem.amount * availableQuarterPercent / percentMul) - packItem.claimed;
            _toTransfer += availableToClaim;
        }
        return _toTransfer;
    }

    function getUserPackClaimAmount(uint userPackID) public view returns (uint) {
        address _buyer = msg.sender;
        uint currentTime = block.timestamp;
        uint _toTransfer = 0;
        Pack memory packItem = Packs[_packs[_buyer][userPackID]];
        uint availableQuarterPercent = (currentTime - packItem.createdAt) / rewardMul * additionalMul / daySeconds; 
            if (availableQuarterPercent >= percentMul) availableQuarterPercent = percentMul;
            uint availableToClaim = (packItem.amount * availableQuarterPercent / percentMul) - packItem.claimed;
        _toTransfer += availableToClaim;
        return _toTransfer;
    }

    function getPackClaimAmount(uint packID) public view returns (uint) {
        uint currentTime = block.timestamp;
        uint _toTransfer = 0;
        Pack memory packItem = Packs[packID];
        uint availableQuarterPercent = (currentTime - packItem.createdAt) / rewardMul * additionalMul / daySeconds; 
        if (availableQuarterPercent >= percentMul) availableQuarterPercent = percentMul;
        uint availableToClaim = (packItem.amount * availableQuarterPercent / percentMul) - packItem.claimed;
        _toTransfer += availableToClaim;        
        return _toTransfer;
    }

    function getUserData(address _user) public view 
        returns (
            uint[] memory userPacks,
            address upperInMatrix, 
            uint[] memory positionsId, 
            address[] memory positionsWallet
        ) {
        Users memory user = User[_user];
        return (_packs[_user], user.upperInMatrix, user.positionsId, user.positionsWallet);
    }

    function modifyWhitelist(address[] memory _list) public onlyOwner returns(uint count) {
        uint _count = 0;
        for (uint256 i = 0; i < _list.length; i++) {
            if(whitelisted[_list[i]] != true){
                whitelisted[_list[i]] = true;
                _count++;
            }
        }
        return _count;
    }

    function setSwapPath(address[] memory newPath) public onlyOwner returns (bool) {
        while(_path.length != 0) _path.pop();
        for(uint i = 0; i < newPath.length; i++) {
            _path.push(newPath[i]);
        }
        return true;
    }

    function setRewardParams(uint _reward, uint _additional, uint _percentMul) public onlyOwner returns (bool) {
        rewardMul = _reward;
        additionalMul = _additional;
        percentMul = _percentMul;
        return true;
    }

    function setStage(uint _stage) public onlyOwner returns (bool) {
        stage = _stage;
        return true;
    }

    function setAutomatedBuy(bool _status) public onlyOwner returns (bool) {
        _automatedBuy = _status;
        return true;
    }    

    function setDaySeconds(uint _seconds) public onlyOwner returns (bool) {
        daySeconds = _seconds;
        return true;
    }

    function setLeaderBoard(address _leaderBoard) public onlyOwner returns (bool) {
        leaderBoard = _leaderBoard;
        return true;
    }

    function withdrawTokensFromBalance(address _token) public onlyOwner {
        require(_token != address(0), "withdrawTokensFromBalance: Token is the zero address");
        IERC20 withdrawToken = IERC20(_token);
        uint256 tokenBalance = withdrawToken.balanceOf(address(this));
        if(tokenBalance > 0) withdrawToken.safeTransfer(msg.sender, tokenBalance);
    }

    function recoveryFunds() public onlyOwner {
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }

    function renounceOwnership() public virtual onlyOwner override {
        revert("disabled");
    }

    receive() external payable {}

}