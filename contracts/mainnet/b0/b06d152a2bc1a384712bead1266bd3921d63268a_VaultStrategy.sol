/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;



// Part: IFarm

interface IFarm {
    function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256);
    
    function pendingShare(uint256 _pid, address _user) external view returns (uint256);

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function emergencyWithdraw(uint256 _pid) external;
}

// Part: IStrategyManager

interface IStrategyManager {
    function operators(address addr) external returns (bool);

    function performanceFee() external returns (uint256);

    function performanceFeeBountyPct() external returns (uint256);

    function stakedTokens(uint256 pid, address user) external view returns (uint256);
}

// Part: IUniswapV2Pair

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

// Part: IUniswapV2Router01

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

// Part: openzeppelin/[email protected]/Address

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

// Part: openzeppelin/[email protected]/Context

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

// Part: openzeppelin/[email protected]/IERC20

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

// Part: openzeppelin/[email protected]/ReentrancyGuard

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

// Part: IUniswapV2Router02

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

// Part: IWNATIVE

interface IWNATIVE is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}

// Part: openzeppelin/[email protected]/Ownable

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

// Part: openzeppelin/[email protected]/Pausable

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

// Part: openzeppelin/[email protected]/SafeERC20

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

// File: VaultStrategy.sol

contract VaultStrategy is Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    //*=============== User Defined Complex Types ===============*//
    
    struct BurnTokenInfo {
        IERC20 token; //Token Address
        uint256 weight; //Token Weight
        address burnAddress; //Address to send burn tokens to
    }

    //*=============== State Variables. ===============*//

    //Pool variables.
    IStrategyManager public strategyManager; // address of the StrategyManager staking contract.
    IFarm public masterChef; // address of the farm staking contract
    uint256 public pid; // pid of pool in the farm staking contract

    //Token variables.
    IERC20 public stakeToken; // token staked on the underlying farm
    IERC20 public token0; // first token of the lp (or 0 if it's a single token)
    IERC20 public token1; // second token of the lp (or 0 if it's a single token)
    IERC20 public earnToken; // reward token paid by the underlying farm
    address[] public extraEarnTokens; // some underlying farms can give rewards in multiple tokens

    //Swap variables.
    IUniswapV2Router02 public swapRouter; // router used for swapping tokens.
    address public WNATIVE; // address of the network's native currency.
    mapping(address => mapping(address => address[])) public swapPath; // paths for swapping 2 given tokens.

    //Burn token state variables. List storage along with 
    BurnTokenInfo[] public burnTokens;
    uint256 public totalBurnTokenWghts;

    //Shares variables.
    uint256 public sharesTotal = 0;
    
    //Vault status variables.
    bool public initialized;
    bool public emergencyWithdrawn;

    //*=============== ADDED VARIABLES. ===============*//
    struct UserShareInfo {
        uint256 shares;
        uint256 vestedShares;
        uint256 lastDepositTime;
    }
    mapping(address => UserShareInfo) public userShares;
    mapping(address => bool) public excludedAddresses;


    address public taxWallet;
    uint256 public baselineTaxRate = 0;
    uint256 public earlyWithdrawTaxRate = 0;
    uint256 public depositVestingDuration = 7 days;

    uint256 public constant MAX_DEPOSIT_VESTING_TIME = 14 days;
    uint256 public constant MAX_BASELINE_TAX_RATE = 1_000;
    uint256 public constant MAX_EARLYWITHDRAW_TAX_RATE = 2_000;
    uint256 public constant BASIS_POINTS_DENOM = 10_000;

    //*=============== Events. ===============*//

    event Initialize();
    event Farm();
    event Pause();
    event Unpause();
    event EmergencyWithdraw();
    event TokenToEarn(address token);
    event WrapNative();
    event EarlyWithdrawTaxPaid(address indexed user, uint256 _amount);
    event WithdrawTaxPaid(address indexed user, uint256 _amount);

    //*=============== Modifiers. ===============*//

    modifier onlyOperator() { 
        require(strategyManager.operators(msg.sender), "Error VaultStrategy: onlyOperator, NOT_ALLOWED");
        _;
    }

    //*=============== Constructor/Initializer. ===============*//

    function initialize(
        uint256 _pid,
        bool _isLpToken,
        address[6] calldata _addresses,
        address[] calldata _earnToToken0Path,
        address[] calldata _earnToToken1Path,
        address[] calldata _token0ToEarnPath,
        address[] calldata _token1ToEarnPath
    ) external onlyOwner {
        require(!initialized, 'Error: Already initialized');
        initialized = true;

        //State variable initialization.
        strategyManager = IStrategyManager(_addresses[0]);
        stakeToken = IERC20(_addresses[1]);
        earnToken = IERC20(_addresses[2]);
        masterChef = IFarm(_addresses[3]);
        swapRouter = IUniswapV2Router02(_addresses[4]);
        WNATIVE = _addresses[5];
        pid = _pid;

        //Set paths for swapping between tokens.
        if (_isLpToken) {
            token0 = IERC20(IUniswapV2Pair(_addresses[1]).token0());
            token1 = IERC20(IUniswapV2Pair(_addresses[1]).token1());

            _setSwapPath(address(earnToken), address(token0), _earnToToken0Path);
            _setSwapPath(address(earnToken), address(token1), _earnToToken1Path);

            _setSwapPath(address(token0), address(earnToken), _token0ToEarnPath);
            _setSwapPath(address(token1), address(earnToken), _token1ToEarnPath);
        } else {
            _setSwapPath(address(earnToken), address(stakeToken), _earnToToken0Path);
            _setSwapPath(address(stakeToken), address(earnToken), _token0ToEarnPath);
        }
        
        emit Initialize();
    }

    //*=============== Functions. ===============*//

    //Default receive function. Handles native token pools.
    receive() external payable {}

    //Pause/Unpause functions.
    function pause() external virtual onlyOperator {
        _pause();
        emit Pause();
    } 

    function unpause() external virtual onlyOperator {
        require(!emergencyWithdrawn, 'unpause: CANNOT_UNPAUSE_AFTER_EMERGENCY_WITHDRAW');
        _unpause();
        emit Unpause();
    }

    //Wrap native tokens if present.
    function wrapNative() public virtual {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            IWNATIVE(WNATIVE).deposit{value: balance}();
            emit WrapNative();
        }
    }

    //Farm functions.
    function _farmDeposit(uint256 amount) internal {
        stakeToken.safeIncreaseAllowance(address(masterChef), amount);
        masterChef.deposit(pid, amount);
    }

    function _farmWithdraw(uint256 amount) internal {
        masterChef.withdraw(pid, amount);
    }

    function _farmEmergencyWithdraw() internal {
        masterChef.emergencyWithdraw(pid);
    }

    function _totalStaked() internal view returns (uint256 amount) {
        (amount, ) = masterChef.userInfo(pid, address(this));
    }

    function totalStakeTokens() public view virtual returns (uint256) {
        return _totalStaked() + stakeToken.balanceOf(address(this));
    }

    function _farm() internal virtual { 
        uint256 depositAmount = stakeToken.balanceOf(address(this));
        _farmDeposit(depositAmount);
    }

    function _farmHarvest() internal virtual {
        _farmDeposit(0);
    }

    function farm() external virtual nonReentrant whenNotPaused {
        _farm();
        emit Farm();
    }

    function emergencyWithdraw() external virtual onlyOperator {
        if (!paused()) { _pause(); }
        emergencyWithdrawn = true;
        _farmEmergencyWithdraw();
        emit EmergencyWithdraw();
    }

    function getVestedShares(address _user) public view returns(uint256 vestedAmount) {
        UserShareInfo memory user = userShares[_user];
        //Perform calculations if user has deposited - Otherwise return 0.
        if (user.lastDepositTime != 0) {
            //Calculate the new vested amount applicable for baseline tax.
            uint256 timeElapsed = block.timestamp - user.lastDepositTime;
            vestedAmount = ((user.shares*timeElapsed)/depositVestingDuration) + user.vestedShares;
            if (vestedAmount > user.shares) {vestedAmount = user.shares;}
        }
    }

    //Functions to interact with farm. {deposit, withdraw, earn}

    //Deposit - funds are put in this contract before this is called.
    function deposit(
        uint256 _depositAmount,
        address _recipient
    ) external virtual onlyOwner nonReentrant whenNotPaused returns (uint256) {
        UserShareInfo storage user = userShares[_recipient];

        //Calculate totalStakedTokens and deposit into farm.
        uint256 totalStakedBefore = totalStakeTokens() - _depositAmount;
        _farm(); 
        uint256 totalStakedAfter = totalStakeTokens();

        //Adjusts for deposit fees on the underlying farm and token transfer taxes.
        _depositAmount = totalStakedAfter - totalStakedBefore;

        //Calculates and returns the sharesAdded variable..
        uint256 sharesAdded = _depositAmount;
        if (totalStakedBefore > 0 && sharesTotal > 0) {
            sharesAdded = (_depositAmount * sharesTotal) / totalStakedBefore;
        }
        sharesTotal = sharesTotal + sharesAdded;

        //Update User Shares struct.
        user.vestedShares = getVestedShares(_recipient);
        user.lastDepositTime = block.timestamp;
        user.shares = user.shares + sharesAdded;

        return sharesAdded;
    }

    function withdraw(
        uint256 _withdrawAmount,
        address _user
    ) external virtual onlyOwner nonReentrant returns (uint256) {
        UserShareInfo storage user = userShares[_user];

        uint256 totalStakedOnFarm = _totalStaked();
        uint256 totalStake = totalStakeTokens();

        //Set max amount of Tokens to withdraw.
        uint256 maxAmount = userStakedTokens(_user);
        if (_withdrawAmount > maxAmount) { _withdrawAmount = maxAmount; }
        
        //Convert shares to amounts.
        uint256 sharesRemoved = (_withdrawAmount * sharesTotal - 1) / totalStake + 1;
        if (sharesRemoved > sharesTotal) { sharesRemoved = sharesTotal; }
        if (sharesRemoved > user.shares) { sharesRemoved = user.shares; }
        sharesTotal = sharesTotal - sharesRemoved;
        
        //Withdraw
        if (totalStakedOnFarm > 0) { _farmWithdraw(_withdrawAmount); }

        //Catch transfer fees & insufficient balance.
        uint256 stakeBalance = stakeToken.balanceOf(address(this));
        if (_withdrawAmount > stakeBalance) { _withdrawAmount = stakeBalance; }
        if (_withdrawAmount > totalStake) { _withdrawAmount = totalStake; }

        sharesRemoved = _handleWithdrawalTaxes(
            _user,
            _withdrawAmount,
            sharesRemoved
        );

        return sharesRemoved;
    }

    function _handleWithdrawalTaxes(
        address _user,
        uint256 _withdrawAmount,
        uint256 _sharesRemoved
    ) internal returns(uint256) {
        UserShareInfo storage user = userShares[_user];

        //----------------------------------------------------------------------------
        //Tax withdrawals.

        //Set the vested withdrawal amount. (Before user.amount is updated and lastDepositTime is updated)
        user.vestedShares = getVestedShares(_user);
        user.lastDepositTime = block.timestamp;
        user.shares = user.shares - _sharesRemoved;

        //If the user has withdrawn tokens and it is not excluded from paying taxes.
        if (_withdrawAmount > 0 && !excludedAddresses[_user]) {

            //Calculate the number of vested shares withdrawn.
            uint256 vestedSharesWithdrawn = _sharesRemoved > user.vestedShares ? user.vestedShares : _sharesRemoved;

            //Initialise variables.
            uint256 earlyWithdrawalTaxedAmount;
            uint256 baselineTaxedAmount;
            uint256 taxableShares;
            uint256 taxedShares;

            //If withdrawn more amount then vested then apply higher tax.
            if (_sharesRemoved > user.vestedShares && earlyWithdrawTaxRate > 0) {
                //Get taxable shares as the extra shares removed.
                taxableShares = _sharesRemoved - user.vestedShares;

                //Find percentage of these shares which have been taxed.
                taxedShares = (taxableShares*earlyWithdrawTaxRate)/BASIS_POINTS_DENOM;

                //Convert taxed shares to tokens and transfer to tax wallet.
                earlyWithdrawalTaxedAmount = (_withdrawAmount*taxedShares)/_sharesRemoved;
                stakeToken.safeTransfer(taxWallet, earlyWithdrawalTaxedAmount);
                emit EarlyWithdrawTaxPaid(_user ,earlyWithdrawalTaxedAmount);
            }

            //Deduct tax free shares variable.
            user.vestedShares = user.vestedShares - vestedSharesWithdrawn;

            //Apply baseline tax rate.
            if (baselineTaxRate > 0) {

                //If no early tax rate then apply baseline tax to all shares removed.
                taxableShares = earlyWithdrawTaxRate > 0 ? vestedSharesWithdrawn : _sharesRemoved;

                //Find percentage of these shares that have been taxed.
                taxedShares = (taxableShares*baselineTaxRate)/BASIS_POINTS_DENOM;

                //Convert taxed shares to tokens.
                baselineTaxedAmount = (_withdrawAmount*taxedShares)/_sharesRemoved;

                //Bound baseline taxed amount to be safe.
                if (baselineTaxedAmount > _withdrawAmount - earlyWithdrawalTaxedAmount) {
                    baselineTaxedAmount = _withdrawAmount - earlyWithdrawalTaxedAmount;
                }

                //Transfer taxed tokens.
                stakeToken.safeTransfer(taxWallet, baselineTaxedAmount);
                emit WithdrawTaxPaid(_user, baselineTaxedAmount);
            }

            //Update withdrawal amount.
            _withdrawAmount = _withdrawAmount - earlyWithdrawalTaxedAmount - baselineTaxedAmount;
        }

        //Safe transfer tokens.
        stakeToken.safeTransfer(_user, _withdrawAmount);

        //Added for if we allow rebate pools.
        return _sharesRemoved;
    }

    function earn(
        address _bountyHunter
    ) external virtual onlyOwner returns (uint256 bountyReward) {
        if (paused()) { return 0; }

        //Log tokens before harvest.
        uint256 earnAmountBefore = earnToken.balanceOf(address(this));

        //Harvest and convert all tokens to those earnt.
        _farmHarvest();
        if (address(earnToken) == WNATIVE) { wrapNative(); }
        for (uint256 i; i < extraEarnTokens.length; i++) {
            if (extraEarnTokens[i]==WNATIVE) { wrapNative(); }
            tokenToEarn(extraEarnTokens[i]);
        }

        //Calculate full amount harvested.
        uint256 harvestAmount = earnToken.balanceOf(address(this)) - earnAmountBefore;

        //If there has been any harvested then calculate the fees to distribute.
        if (harvestAmount > 0) {
            bountyReward = _distributeFees(harvestAmount, _bountyHunter);
        }

        //Reasses the amount earnt.
        uint256 earnAmount = earnToken.balanceOf(address(this));

        //Perform single stake strategy...
        if (address(token0) == address(0)) {
            //If the stake and earn token are different the swap between the two.
            if (stakeToken != earnToken) {
                _safeSwap(earnAmount, address(earnToken), address(stakeToken), address(this), false);
            }
            _farm();
            return bountyReward;
        }

        //Perform LP stake strategy...
        if (token0 != earnToken) {
            _safeSwap(earnAmount / 2, address(earnToken), address(token0), address(this), false);
        }
        if (token1 != earnToken) {
            _safeSwap(earnAmount / 2, address(earnToken), address(token1), address(this), false);
        }

        //Add liquidiy it the chosen amount is >0. - This is where we can have leftover bits.
        uint256 token0Amt = token0.balanceOf(address(this));
        uint256 token1Amt = token1.balanceOf(address(this));
        if (token0Amt > 0 && token1Amt > 0) {
            token0.safeIncreaseAllowance(address(swapRouter), token0Amt);
            token1.safeIncreaseAllowance(address(swapRouter), token1Amt);
            swapRouter.addLiquidity(
                address(token0),
                address(token1),
                token0Amt,
                token1Amt,
                0,
                0,
                address(this),
                block.timestamp
            );
        }

        //Deposit tokens and return the bountyReward.
        _farm();
        return bountyReward;
    }

    //Burn token manipulation functions.
    function addBurnToken(
        address _token, 
        uint256 _weight, 
        address _burnAddress,
        address[] calldata _earnToBurnPath,
        address[] calldata _burnToEarnPath
    ) external onlyOwner {
        //Add token to storage and update the associated state variables.
        burnTokens.push(BurnTokenInfo({token: IERC20(_token), weight: _weight, burnAddress: _burnAddress}));
        totalBurnTokenWghts += _weight;

        //Add the swap token paths.
        _setSwapPath(address(earnToken), address(_token), _earnToBurnPath);
        _setSwapPath(address(_token), address(earnToken), _burnToEarnPath);
    }

    function removeBurnToken(
        uint256 _index
    ) external onlyOwner {
        require(burnTokens.length > 0, "Error: No elements to remove.");
        require(burnTokens.length >= (_index+1), "Error: Index out of range."); 
        totalBurnTokenWghts -= burnTokens[_index].weight;
        burnTokens[_index] = burnTokens[burnTokens.length-1];
        burnTokens.pop();
    }

    function setBurnToken(
        address _token, 
        uint256 _weight,
        address _burnAddress,
        uint256 _index
    ) external onlyOwner {
        require(burnTokens.length >= (_index+1), "Error: Index out of range."); 
        totalBurnTokenWghts -= burnTokens[_index].weight;
        burnTokens[_index] = BurnTokenInfo({token: IERC20(_token), weight: _weight, burnAddress: _burnAddress});
        totalBurnTokenWghts += _weight;
    }

    function setSwapRouter(
        address _router
    ) external virtual onlyOwner {
        swapRouter = IUniswapV2Router02(_router);
    }

    function setExtraEarnTokens(
        address[] calldata _extraEarnTokens
    ) external virtual onlyOwner {
        require(_extraEarnTokens.length <= 5, "Error: Extra tokens set cap excluded");
        extraEarnTokens = _extraEarnTokens;
    }

    //swapPath manipulation functions.
    function _setSwapPath(
        address _token0,
        address _token1,
        address[] memory _path
    ) internal virtual {
        require(_path.length > 1, "Error: Path is not long enough.");
        require(_path[0]==_token0 && _path[_path.length-1]==_token1, "Error: Endpoints of path are incorrect.");
        swapPath[_token0][_token1] = _path;
    }

    function setSwapPath(
        address _token0,
        address _token1,
        address[] calldata _path
    ) external virtual onlyOwner {
        _setSwapPath(_token0, _token1, _path);
    }

    function removeSwapPath(
        address _token0,
        address _token1
    ) external virtual onlyOwner {
        delete swapPath[_token0][_token1];
    }

    //safeSwap function which increases the allowance & supports fees on transferring tokens.
    function _safeSwap(
        uint256 _amountIn,
        address _pathIn,
        address _pathOut,
        address _to,
        bool _ignoreErrors
    ) internal virtual {

        //Only need to check path length as all other checks are either done through _setSwapPath or the enclosing function.	
        address[] memory path = swapPath[_pathIn][_pathOut];
        if ((_amountIn>0) && (path.length>1)) {
            IERC20(path[0]).safeIncreaseAllowance(address(swapRouter), _amountIn);
            if (_ignoreErrors) {
                try
                    swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(_amountIn, 0, path, _to, block.timestamp+40)
                {} catch {}
            } else {
                swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(_amountIn, 0, path, _to, block.timestamp+40);
            }
        }
    }
    
    //Swap token to earn - used for extraEarnTokens & can be called externally to convert dust to earnedToken.
    function tokenToEarn(
        address _token
    ) public virtual nonReentrant whenNotPaused {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        //Check conditions on the path starting point not being either of the pool tokens.
        if (amount > 0 && _token != address(earnToken) && _token != address(stakeToken)) {            
            _safeSwap(amount, _token, address(earnToken), address(this), true);
            emit TokenToEarn(_token);
        }
    }

    function _distributeFees(
        uint256 _amount, 
        address _bountyHunter
    ) internal virtual returns (uint256 bountyReward) { 
        uint256 performanceFee = (_amount * strategyManager.performanceFee()) / 10_000; //[0%, 5%]
        uint256 bountyRewardPct = _bountyHunter == address(0) ? 0 : strategyManager.performanceFeeBountyPct(); //[0%, 100%]]
        bountyReward = (performanceFee * bountyRewardPct) / 10_000;
        uint256 platformFee = performanceFee - bountyReward;

        //If no tokens to burn then send all to the bountyHunter.
        if (burnTokens.length == 0) {
            bountyReward = _bountyHunter == address(0) ? 0 : performanceFee;
            platformFee = 0;
        }

        //Transfer the bounty reward to the bountyHunter.
        if (bountyReward > 0) {
            earnToken.safeTransfer(_bountyHunter, bountyReward);
        }

        //Burn the platformPerformanceFee tokens.
        if (platformFee > 0) {
            _burnEarnTokens(platformFee);
        }

        return bountyReward;
    }

    function _burnEarnTokens(
        uint256 _amount
    ) internal virtual {
        if (totalBurnTokenWghts == 0 || _amount==0) { return; }
        uint256 burnAmount;
        for (uint i=0; i<burnTokens.length; i++) {

            //Extract burn token info.
            BurnTokenInfo memory burnToken = burnTokens[i];
            burnAmount = (_amount * burnToken.weight) / totalBurnTokenWghts;

            //Either send or swap the burn token to the associated burn address.
            if (burnAmount>0) { 
                if (burnToken.token == earnToken) {
                    earnToken.safeTransfer(burnToken.burnAddress, burnAmount);
                } else {
                    _safeSwap(burnAmount, address(earnToken), address(burnToken.token), burnToken.burnAddress, true);
                }
            }
            
        }
    }

    //*=============== Extra Test Functions ===============*//
    function numBurnTokens() public view returns(uint256 length) {
        length = burnTokens.length;
    }

    //*=============== ADDED FUNCTIONS. ===============*//

    function setBaselineTaxRate(uint256 _baselineTaxRate) external onlyOperator {
        require(_baselineTaxRate <= MAX_BASELINE_TAX_RATE, "Error: baseline tax rate too high.");
        baselineTaxRate = _baselineTaxRate;
    }

    function setEarlyWithdrawTaxRate(uint256 _earlyWithdrawTaxRate) external onlyOperator {
        require(_earlyWithdrawTaxRate <= MAX_EARLYWITHDRAW_TAX_RATE, "Error: baseline tax rate too high.");
        earlyWithdrawTaxRate = _earlyWithdrawTaxRate;
    }

    function setDepositVestingDuration(uint256 _depositVestingDuration) external onlyOperator {
        require(_depositVestingDuration <= MAX_DEPOSIT_VESTING_TIME, "Error: baseline tax rate too high.");
        depositVestingDuration = _depositVestingDuration;
    }

    function setTaxWallet(address _taxWallet) external onlyOperator {
        taxWallet = _taxWallet;
    }

    function sharesToTokens(uint256 _amount) public view returns(uint256) {
        return sharesTotal > 0 ? ( _amount *  totalStakeTokens()) / sharesTotal : 0; 
    }

    function userStakedTokens(address _user) public view returns (uint256) {
        return sharesToTokens(userShares[_user].shares);
    }

    function userVestedTokens(address _user) external view returns (uint256) {
        return sharesToTokens(getVestedShares(_user));
    }

    function pendingVaultRewards() external view returns (uint256) {
        return masterChef.pendingShare(pid, address(this));
    }

    function pendingUserRewards(address _user) external view returns (uint256) {
        return sharesTotal > 0 ? (userShares[_user].shares *  masterChef.pendingShare(pid, address(this))) / sharesTotal : 0;
    }

    function setExcludedAddress(address _account, bool _isExcluded) external onlyOperator {
        excludedAddresses[_account] = _isExcluded;
    }

    function setStrategyManager(address _strategyManager) external onlyOperator {
        strategyManager = IStrategyManager(_strategyManager);
    }

}