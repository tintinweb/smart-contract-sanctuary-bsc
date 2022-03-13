/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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

// File: @openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// File: @openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol


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
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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

// File: contracts/ITokenTimelock.sol


pragma solidity ^0.8.0;

interface ITokenTimelock {

    function initialize(address token_, address beneficiary_, uint256 releaseTime_) external;

    function token() external view returns (address);

    function beneficiary() external view returns (address);

    function releaseTime() external view returns (uint256);

    function release() external;

    }

// File: contracts/IPancake.sol


pragma solidity ^0.8.0;

interface IPancakeFactory {
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
interface IPancakePair {
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
interface IPancakeRouter01 {
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
interface IPancakeRouter02 is IPancakeRouter01 {
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

// File: @openzeppelin/contracts/proxy/utils/Initializable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

// File: contracts/TimeLock.sol


// OpenZeppelin Contracts v4.4.0 (token/ERC20/utils/TokenTimelock.sol)

pragma solidity ^0.8.0;




/**
 * @dev A token holder contract that will allow a beneficiary to extract the
 * tokens after a given release time.
 *
 * Useful for simple vesting schedules like "advisors get all of their tokens
 * after 1 year".
 */

contract TokenTimelock is Initializable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    // ERC20 basic token contract being held
    IERC20Upgradeable private _token;

    // beneficiary of tokens after they are released
    address private _beneficiary;

    // timestamp when token release is enabled
    uint256 private _releaseTime;

    function initialize(IERC20Upgradeable token_, address beneficiary_, uint256 releaseTime_) external initializer {
        require(releaseTime_ > block.timestamp, "TokenTimelock: release time is before current time");
        require(beneficiary_ != address(0), "TokenTimelock: beneficiary can't be the 0 address");
        _token = token_;
        _beneficiary = beneficiary_;
        _releaseTime = releaseTime_;
    }

    /**
     * @return the token being held.
     */
    function token() public view returns (IERC20Upgradeable) {
        return _token;
    }

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    /**
     * @return the time when the tokens are released.
     */
    function releaseTime() public view returns (uint256) {
        return _releaseTime;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() external  {
        require(block.timestamp >= releaseTime(), "TokenTimelock: current time is before release time");

        uint256 amount = token().balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");

        token().safeTransfer(beneficiary(), amount);
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: contracts/TipsyCoin.sol


pragma solidity ^0.8.0;


// OpenZeppelin Contracts v4.3.2 (token/ERC20/ERC20.sol)









abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract to the not~ 0 address. 
     * Since we use proxies this constructor is never called, and we can use this lock to prevent someone taking over the base contract and causing confusion
     * (addresses etc) since this being set effectively disables the base contract
     */
    constructor() {
        _transferOwnership(address(~uint160(0)));
        //_transferOwnership(address(uint160(0)));
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
        _transferOwnership(address(0x000000000000000000000000000000000000dEaD));
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

    function initOwnership(address newOwner) internal virtual {
        require(_owner == address(0), "Ownable: owner already set");
        _owner = newOwner;
        emit OwnershipTransferred(address(0), newOwner);
    }

}

contract TipsyCoin is IERC20, IERC20Metadata, Ownable, Initializable {
    using Address for address;

    //--Public View Vars

    address public constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    uint256 public maxTxAmount;
    uint256 public _rTotal = 1e18;
    uint256 public buybackFundAmount = 400;
    uint256 public marketingCommunityAmount = 200;
    uint256 public reflexiveAmount = 400;
    mapping(address => bool) public whiteList;
    mapping(address => bool) public excludedFromFee;
    address public pancakeSwapRouter02;
    address public pancakePair;
    //launchTime will be a short random delay after liquidity is added to PCS
    //to discourage sniper bots from reading mempool and buying the second the addliquidity event is added to txpool
    uint public launchTime;
    uint256 public maxSupply;
    address public cexFund;
    address public charityFund;
    address public teamVestingFund;
    address public futureFund;
    address public communityEngagementFund;
    address public buyBackFund;
    address public marketingFund;
    address public lpLocker;

    //--Restricted View Vars

    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    IPancakeRouter02 internal pancakeV2Router;
    uint256 internal _feeTotal;
    address[] internal _tokenWETHPath;
    string private _name;
    string private _symbol;
    
    //--Events

    event SellFeeCollected(uint256 indexed tokensSwapped, uint256 indexed ethReceived);
    event FeesChanged(uint indexed buyBack, uint indexed marketing, uint indexed reflexive);
    event ExcludedFromFee(address indexed excludedAddress);
    event IncludedInFee(address indexed includedAddress);
    event IncludedInContractWhitelist(address indexed includedWhiteListedContract);
    event Burned(uint indexed oldSupply, uint indexed amount, uint indexed newSupply);
    event Reflex(uint indexed oldRFactor, uint indexed amount, uint indexed newRFactor);
    //event ExcludedFromContractWhitelist(address indexed excludedWhiteListedContract); -> removed the function associated with this event for safety
    
    //--Modifiers

    /**
     * @dev 
     * Provides some deterance to bots to prevent them from interacting with tipsy
     * Obviously we are aware that isContract() returns false during construction, so maxTxAmount, tax on transferFrom, and launchTime params also used as further deterance
     */
    modifier noBots(address recipient) {
        require(!recipient.isContract() || whiteList[recipient], "tipsyCoin: Bots and Contracts b&");
        _;
    }

    //--View Functions

    /**
     * @dev 
     * Gets the byte code for the timelock contract. Returns bytes
     */
    function getByteCodeTimelock() public pure returns (bytes memory) {
        bytes memory bytecode = type(TokenTimelock).creationCode;
        return bytecode;
    }
    /**
     * @dev 
     * tiny function to make checking a bunch of addresses arne't the 0 addy in the initializer
     */
    function addyChk(address _test) internal pure returns (bool)
    {
        return uint160(_test) != 0;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _realToReflex(_allowances[owner][spender]);
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
     * @dev Returns number of decimals, 18 is standard
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     * Return value in reflect space
     */
    function balanceOf(address account) public view returns (uint256) {
        //return _balances[account];
        return _rBalanceOf(account);
    }

    /**
     * @dev See {IERC20-totalSupply}
     * Returns in reflex space
     */
    function totalSupply() public view returns (uint256) {
        return _realToReflex(_totalSupply);
    }

    /**
     * @dev 
     * gets a new rTotal based on amount of tokens to be removed from supply
     */
    function getNewRate(uint _reflectAmount) public view returns (uint _adjusted)
    {   
        return totalSupply() * _rTotal / (totalSupply() - _reflectAmount);
        //return rTotalSupply() * 1e18 / (rTotalSupply() - _reflectAmount);
    }

    /**
     * @dev 
     * internal function to calculate reflect space balanceOf(account)
     */
    function _rBalanceOf(address account) internal view returns (uint256)
    {
        return _balances[account] * _rTotal / 1e18;
    }

    /**
     * @dev 
     * Multiplies real space token amount by the reflex factor (rTotal) to get reflex space tokens
     */
    function _realToReflex(uint _realSpaceTokens) public view returns (uint256 _reflexSpaceTokens)
    {
        return _realSpaceTokens * _rTotal / 1e18;
    }

    /**
     * @dev 
     * Divides reflex space token amount by the reflex factor (rTotal) to get real space tokens
     */
    function _reflexToReal(uint _reflexSpaceTokens) public view returns (uint256 _realSpaceTokens)
    {
    return _reflexSpaceTokens * 1e18 / _rTotal;
    }

    //--Mutative Functions

    /**
     * @dev 
     * Deploys the current byte code. Returns address of newly deployed contract
     */
    function deploy(bytes memory _code) internal returns (address addr)
    {
        assembly {
            addr:= create(0,add(_code,0x20), mload(_code))
        }
        require(addr != address(0), "tipsy: deploy failed");
        return addr;
    }
    
    constructor() payable {
    }

    function addLiquidity(uint256 _launchTime) payable public
    {
        //This is the "go time" function. Project can be deployed before this, and then this is called to add the LP and go live
        //Launch time papam is used to prevent trades happening before this time. Used to prevent sniperbots scanning txpool and buying the second this function is called
        require(msg.value > 200 ether, "Add more than 200 BNB ($100,000)!");
        require(_launchTime > block.timestamp + 100, "_launchTime too soon!");
        pancakePair = IPancakeFactory(pancakeV2Router.factory()).createPair(address(this), pancakeV2Router.WETH());
        require(_lockLiquidity(), "tipsy: liquidity lock failed");
        _approve(address(this), pancakeSwapRouter02, 50e9 * 10 ** decimals());
        whiteList[pancakePair] = true;
        pancakeV2Router.addLiquidityETH{value:address(this).balance}(
            address(this), 50e9 * 10 ** decimals(), 1, 1, lpLocker, block.timestamp);
        launchTime = _launchTime;
    }

    function _lockLiquidity() private returns (bool)
    {
        //Create timelock for 5 years
        ITokenTimelock(lpLocker).initialize(pancakePair, address(this), block.timestamp + 1825 days);
        return true;
    }


    function initialize(address owner_, address _pancakeSwapRouter02, address _cexFund, address _charityFund, address _marketingFund, address _communityEnagementFund, address _futureFund, address _teamVestingFund, address _buyBackFund) public initializer
    {      
        initOwnership(owner_);
        (lpLocker) = deploy(getByteCodeTimelock());
        require(addyChk(_cexFund) && addyChk(_charityFund) && addyChk(_marketingFund) && addyChk(_communityEnagementFund) && addyChk(_futureFund) && addyChk(_teamVestingFund) && addyChk(_buyBackFund), "tipsy: initialize address must be set");
        buyBackFund = _buyBackFund;
        cexFund = _cexFund; //7%
        charityFund = _charityFund; //3%
        marketingFund = _marketingFund; //19.7%
        communityEngagementFund = _communityEnagementFund; //4.8%
        futureFund = _futureFund; //5.5%
        teamVestingFund = _teamVestingFund; //10%
        buybackFundAmount = 400; //4% of sell
        marketingCommunityAmount = 200; //2% of sell
        reflexiveAmount = 400; //4% of sell
        _feeTotal = buybackFundAmount + marketingCommunityAmount + reflexiveAmount; //10% tax total    
        _name = "TipsyCoin";
        _symbol = "$tipsy";
        _mint(marketingFund, 19.7 * 1e9 * 10 ** decimals()); // 19.7%
        _mint(teamVestingFund, 10 * 1e9 * 10 ** decimals()); // 10%
        _mint(cexFund, 7 * 1e9 * 10 ** decimals()); //7%
        _mint(charityFund, 3 * 1e9 * 10 ** decimals()); //3%
        _mint(address(this), 50 * 1e9 * 10 ** decimals()); //Tokens to be added to LP. 50%
        _mint(communityEngagementFund, 4.8 * 1e9 * 10 ** decimals()); //4.8%
        _mint(futureFund, 5.5 * 1e9 * 10 ** decimals()); //5.5%
        maxSupply = 100e9 * 10 ** decimals(); //100 billion total
        require(maxSupply == _totalSupply, "tipsy: not all supply minted");
        maxTxAmount = _totalSupply / 200; //0.5% of initial max supply, doesn't decrease as tokens are burned or reflected (to keep number simple -> 500 Mill)
        _rTotal = 1e18; // reflection ratio starts at 1.0
        pancakeSwapRouter02 = _pancakeSwapRouter02;
        pancakeV2Router = IPancakeRouter02(pancakeSwapRouter02);
        whiteList[pancakeSwapRouter02] = true;
        excludedFromFee[pancakeSwapRouter02] = false;
        whiteList[address(this)] = excludedFromFee[address(this)] = true;
        whiteList[owner()] = excludedFromFee[owner()] = true;
        whiteList[cexFund] = excludedFromFee[cexFund] = true;
        whiteList[charityFund] = excludedFromFee[charityFund] = true;
        whiteList[teamVestingFund] = excludedFromFee[teamVestingFund] = true;
        whiteList[futureFund] = excludedFromFee[futureFund] = true;
        whiteList[communityEngagementFund] = excludedFromFee[communityEngagementFund] = true;
        whiteList[buyBackFund] = excludedFromFee[buyBackFund] = true;
        whiteList[marketingFund] = excludedFromFee[marketingFund] = true;
        _tokenWETHPath = new address[](2);
        _tokenWETHPath[0] = address(this);
        _tokenWETHPath[1] = pancakeV2Router.WETH();

    }

    /**
     * @dev 
     * Adjusts the fees between buyback, marketing, and reflexive rewards
     * Has a check to ensure the fees aren't increased beyond the initial 10% (in response to certik audit of safemoon)
     */
    function adjustFees(uint _buybackFundAmount, uint _marketingCommunityAmount, uint _reflexiveAmount) public onlyOwner
    {
        require(_buybackFundAmount + _marketingCommunityAmount + _reflexiveAmount <= _feeTotal, "tipsy: new feeTotal > initial feeTotal");
        buybackFundAmount = _buybackFundAmount;
        marketingCommunityAmount = _marketingCommunityAmount;
        reflexiveAmount = _reflexiveAmount;
        emit FeesChanged(buybackFundAmount, marketingCommunityAmount, reflexiveAmount);
    }

    /**
     * @dev 
     * excludes an address from the fee
     * also makes them immune to 0.5% maxTxAmount, too
     */
    function excludeFromFee(address _excluded) public onlyOwner
    {
        excludedFromFee[_excluded] = true;
        emit ExcludedFromFee(_excluded);
    }

    /**
     * @dev 
     * includes an address in the fee
     * also makes them subject to 0.5% maxTxAmount
     */
    function includeInFee(address _included) public onlyOwner
    {
        excludedFromFee[_included] = false;
        emit IncludedInFee(_included);
    }

    /**
     * @dev 
     * includes an address in the contract whitelist
     * non whitelisted contracts can't be the `recipient` of any tipsy tokens
     * non whitelisted contracts may still be the `sender` of tokens, in an attempt to reduce chances of tokens getting stranded 
     */
    function includeInWhitelist(address _included) public onlyOwner
    {
        whiteList[_included] = true;
        emit IncludedInContractWhitelist(_included);
    }

    /**
     * @dev Allows transfering of tokens from this contract if they get stuck or are sent to this contract by accident 
     * Mentioned in CertiK's Safemoon audit as being a good idea
     * Can also be used to retreive LP after 5 year timelock
     * This contract should never own extra tokens. Extra tipsy etc is held by other contracts
     */
        function salvage(IERC20 token) public onlyOwner
    {
        if (address(this).balance > 0) payable(owner()).transfer(address(this).balance);
        uint256 amount = token.balanceOf(address(this));
        if (amount > 0) token.transfer(owner(), amount);
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     * - the caller must have a balance of at least `amount`.
     * - if recipient is the 0 address, destroy the tokens and reflect
     * - if the recipient is the dead address, destroy the tokens and reduce total supply
     * - BuyBack contract uses transfer(0) and transfer(DEAD_ADDRESS), so there's value in keeping these accessable
     */
    function transfer(address recipient, uint256 amount) public noBots(recipient) returns (bool) {
        //Private function always handles reflex to real space, if available
        if (recipient == address(0))
        {
            //If recipient is 0 address, remove sender's tokens and use them for reflection
            _reflect(_msgSender(), amount);
            return true;
        }
        else if (recipient == DEAD_ADDRESS)
        {
            //If recipient is dead address, burn instead of reflect
            _burn(_msgSender(), amount);
            return true;
        }
        else
        {
        //Otherwise, do a normal transfer and emit a transferlog
        _transfer(_msgSender(), recipient, amount);
        _afterTokenTransfer(_msgSender(), recipient, amount);
        return true;
        }
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `amount` is in reflex space
     */
    function approve(address spender, uint256 amount) public noBots(spender) returns (bool) {
        //Private function always handles reflex to real space, if available
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _taxTransaction(address sender, uint amountIn, uint amountOut) private{
    transferNoEvent(sender, address(this), amountIn);
    _pancakeswapSell(amountIn);
    emit SellFeeCollected(amountIn, amountOut);
    }

    function _pancakeswapSell(uint amountIn) internal
    {
        _approve(address(this), pancakeSwapRouter02, amountIn * 100);
        uint256 _marketingAmount = amountIn * marketingCommunityAmount / (buybackFundAmount + marketingCommunityAmount);
        amountIn = amountIn - _marketingAmount;
        //Using swapExactTokensForTokens instead of swapExactTokensForTokensSupportingFeeOnTransferTokens should be OK here
        //Because there's no tax from (this) address, and swapExactTokensForTokens gives us a return value, where as Supporting doesn't
        pancakeV2Router.swapExactTokensForTokens(amountIn, 1, _tokenWETHPath, buyBackFund, block.timestamp);
        pancakeV2Router.swapExactTokensForTokens(_marketingAmount, 1, _tokenWETHPath, marketingFund, block.timestamp);
        //IERC20(_tokenWETHPath[1]).transfer(buyBackFund, amountOut * buybackFundAmount / (buybackFundAmount + _marketingCommunityAmount));
        //IERC20(_tokenWETHPath[1]).transfer(communityEngagementFund, amountOut * _marketingCommunityAmount / (buybackFundAmount + _marketingCommunityAmount));

    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     * Charge fee if sender isn't excluded from fees
     * This means when PCS drags tokens from user, they get taxed
     * If sender is excluded from fee, no tax and normal tx occurs
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public noBots(recipient) returns (bool) {
        if (!excludedFromFee[sender])
        {   
            uint _amountBuyBack = amount * buybackFundAmount / _feeTotal/10;
            uint _amountMarketing = amount * marketingCommunityAmount / _feeTotal/10;
            uint _amountReflexive = amount * reflexiveAmount / _feeTotal/10;

        if(_amountBuyBack + _amountMarketing > 0) 
        { 
            uint _minToLiquify = pancakeV2Router.getAmountsOut(_amountBuyBack + _amountMarketing, _tokenWETHPath)[1];
            if(_minToLiquify >= 1e9) _taxTransaction(sender, _amountBuyBack + _amountMarketing, _minToLiquify);
            else _burn(sender, _amountBuyBack + _amountMarketing);
        }

        amount = amount - _amountBuyBack - _amountMarketing - _amountReflexive;
        _transfer(sender, recipient, amount);

        if(_amountReflexive > 0)  _reflect(sender, _amountReflexive);

        }
        else
        {
        //Skip collecting fee if sender (person's tokens getting pulled) is excludedFromFee
        _transfer(sender, recipient, amount);
        }
        //Emit Transfer Event. _taxTransaction emits a seperate sell fee collected event, _reflect also emits a reflect ratio changed event
        _afterTokenTransfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(_realToReflex(currentAllowance) >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), _realToReflex(currentAllowance) - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _realToReflex(_allowances[_msgSender()][spender]) + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(_realToReflex(currentAllowance) >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, _realToReflex(currentAllowance) - subtractedValue);
        }
        return true;
    }

    /**
     * @dev 
     * sets a new rTotal based on amount of tokens to be removed from supply
     */
    function _setNewRate(uint _reflectAmount) internal returns (uint newRate)
    {
        _rTotal = getNewRate(_reflectAmount);
        return _rTotal;
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
     * - `sender` cannot be the zero address, use _mint instead
     * - `recipient` cannot be the zero address. Use _reflect instead
     * - `recipient` cannot be the DEAD address. Use _burn instead
     * - `sender` must have a reflect space balance of at least `amount`
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "tipsy: transfer from the zero address");
        require(recipient != address(0), "tipsy: transfer to the zero address, use _reflect");
        require(recipient != address(DEAD_ADDRESS), "tipsy: transfer to the DEAD_ADDRESS, use _burn");
        require(block.timestamp > launchTime + 6, "tipsy: token not tradable yet! Please wait");
        //require(amount > 0, "tipsy: transfer amount must be greater than zero"); Probably don't need to worry about this
        //If sender or recipient are immune from fee, don't use maxTxAmount
        //Usage of excludedFromFee means regular user to PCS enforces maxTxAmount
        if(!excludedFromFee[sender] && !excludedFromFee[recipient])
        {
            require(amount <= maxTxAmount, "tipsy: transfer amount exceeds maxTxAmount.");
        }
        uint256 realAmount = _reflexToReal(amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= realAmount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - realAmount;
        }
        _balances[recipient] += realAmount;

    }
    /* @dev
     * This is just to avoid some duplicated transfers that might look weird on BSCScan during taxed sells
     * i.e. during tax an event when Tipsy is transfered to (this) address, and then a second event from this address to PCS for the sell
     */
    function transferNoEvent(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        _transfer(sender, recipient, amount);

    }
    /* @dev emits the Transfer event log
     *
     */
    function _afterTokenTransfer(address sender, address recipient, uint amount) internal
    {
    emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * _mint is only called during genesis, so there's no need
     * to adjust real tokens into reflex space, as they are 1:1 at this time
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) private {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Burn} event with old supply, amount burned and new supply.
     * Amounts in reflex space
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        //Burn removes 'amount' of the total supply, but doesn't reflect rewards
        require(account != address(0), "ERC20: burn from the zero address");
        require(amount > 0, "tipsy: burn amount must be greater than zero");

        uint256 accountBalance = _balances[account];
        //Before continuing, convert amount into realspace
        uint256 _realAmount = _reflexToReal(amount);
        require(accountBalance >= _realAmount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - _realAmount;
            _balances[DEAD_ADDRESS] = _balances[DEAD_ADDRESS] + _realAmount;
        }
        _totalSupply -= _realAmount;
        emit Transfer(account, DEAD_ADDRESS, amount);
        emit Burned(totalSupply() + amount, amount, totalSupply());
    }

    /**
     * @dev Destroys `amount` tokens from `account`, but adjusts rTotal
     * so total supply is not reduced.
     *
     * Emits a {Reflect} event with old rTotal, amount reflected and new rTotal.
     * Amounts in reflex space
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    //Reflect removes 'amount' of the total supply, but reflect rewards by adjusting _rTotal so that _rTotalSupply() remains constant
    //Emits a reflex event that has the old _rTotal, the amount reflected, and the new _rTotal
    function _reflect(address account, uint256 amount) internal {
        
        require(account != address(0), "tipsy: reflect from the zero address");
        require(amount > 0, "tipsy: reflect amount must be greater than zero");
        //accountBalance is in real space
        uint256 accountBalance = _balances[account];
        //Before continuing, convert amount into real space
        uint256 _realAmount = _reflexToReal(amount);
        require(accountBalance >= _realAmount, "tipsy: reflect amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - _realAmount;
        }
        uint oldRFactor = _rTotal;
        _setNewRate(amount);
        _totalSupply -= _realAmount;
        emit Reflex(oldRFactor, amount, _rTotal);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
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
        _allowances[owner][spender] = _reflexToReal(amount);
        emit Approval(owner, spender, amount);
    }

    receive() external payable {}
}