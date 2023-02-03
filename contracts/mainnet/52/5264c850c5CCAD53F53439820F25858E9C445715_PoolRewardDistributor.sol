// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IMultipleRewardPool.sol";
import "./interfaces/ISingleRewardPool.sol";
import "./interfaces/IRouter.sol";
import "./interfaces/ISnacksBase.sol";

contract PoolRewardDistributor is Ownable, Pausable {
    using SafeERC20 for IERC20;
    
    uint256 private constant BASE_PERCENT = 10000;
    uint256 private constant SENIORAGE_FEE_PERCENT = 1000;
    uint256 private constant ZOINKS_APE_SWAP_POOL_PERCENT = 2308;
    uint256 private constant ZOINKS_BI_SWAP_POOL_PERCENT = 2308;
    uint256 private constant ZOINKS_PANCAKE_SWAP_POOL_PERCENT = 5384;
    uint256 private constant SNACKS_PANCAKE_SWAP_POOL_PERCENT = 6667;
    uint256 private constant SNACKS_SNACKS_POOL_PERCENT = 3333;
    uint256 private constant BTC_SNACKS_PANCAKE_SWAP_POOL_PERCENT = 5714;
    uint256 private constant BTC_SNACKS_SNACKS_POOL_PERCENT = 4286;
    uint256 private constant ETH_SNACKS_PANCAKE_SWAP_POOL_PERCENT = 5714;
    uint256 private constant ETH_SNACKS_SNACKS_POOL_PERCENT = 4286;
    
    address public immutable busd;
    address public immutable router;
    address public zoinks;
    address public snacks;
    address public btcSnacks;
    address public ethSnacks;
    address public apeSwapPool;
    address public biSwapPool;
    address public pancakeSwapPool;
    address public snacksPool;
    address public lunchBox;
    address public seniorage;
    address public authority;
    uint256 private _btcSnacksFeeAmountStored;
    uint256 private _ethSnacksFeeAmountStored;

    event BtcSnacksFeeAdded(uint256 indexed feeAmount);
    event EthSnacksFeeAdded(uint256 indexed feeAmount);
    
    modifier onlyAuthority {
        require(
            msg.sender == authority,
            "PoolRewardDistributor: caller is not authorised"
        );
        _;
    }

    modifier onlyBtcSnacks {
        require(
            msg.sender == btcSnacks,
            "PoolRewardDistributor: caller is not the BtcSnacks contract"
        );
        _;
    }
    
    modifier onlyEthSnacks {
        require(
            msg.sender == ethSnacks,
            "PoolRewardDistributor: caller is not the EthSnacks contract"
        );
        _;
    }

    /**
    * @param busd_ Binance-Peg BUSD token address.
    * @param router_ Router contract address (from PancakeSwap DEX).
    */
    constructor(
        address busd_,
        address router_
    ) {
        busd = busd_;
        router = router_;
        IERC20(busd_).approve(router_, type(uint256).max);
    }
    
    /**
    * @notice Configures the contract.
    * @dev Could be called by the owner in case of resetting addresses.
    * @param zoinks_ Zoinks token address.
    * @param snacks_ Snacks token address.
    * @param btcSnacks_ BtcSnacks token address.
    * @param ethSnacks_ EthSnacks token address.
    * @param apeSwapPool_ ApeSwapPool contract address.
    * @param biSwapPool_ BiSwapPool contract address.
    * @param pancakeSwapPool_ PancakeSwapPool contract address.
    * @param snacksPool_ SnacksPool contract address.
    * @param lunchBox_ LunchBox contract address.
    * @param seniorage_ Seniorage contract address.
    * @param authority_ Authorised address.
    */
    function configure(
        address zoinks_,
        address snacks_,
        address btcSnacks_,
        address ethSnacks_,
        address apeSwapPool_,
        address biSwapPool_,
        address pancakeSwapPool_,
        address snacksPool_,
        address lunchBox_,
        address seniorage_,
        address authority_
    )
        external
        onlyOwner
    {
        zoinks = zoinks_;
        snacks = snacks_;
        btcSnacks = btcSnacks_;
        ethSnacks = ethSnacks_;
        apeSwapPool = apeSwapPool_;
        biSwapPool = biSwapPool_;
        pancakeSwapPool = pancakeSwapPool_;
        snacksPool = snacksPool_;
        lunchBox = lunchBox_;
        seniorage = seniorage_;
        authority = authority_;
        if (IERC20(zoinks_).allowance(address(this), snacks_) == 0) {
            IERC20(zoinks_).approve(snacks_, type(uint256).max);
        }
    }

    /**
    * @notice Triggers stopped state.
    * @dev Could be called by the owner in case of resetting addresses.
    */
    function pause() external onlyOwner {
        _pause();
    }

    /**
    * @notice Returns to normal state.
    * @dev Could be called by the owner in case of resetting addresses.
    */
    function unpause() external onlyOwner {
        _unpause();
    }
    
    /**
    * @notice Notifies the contract about the incoming fee in BtcSnacks token.
    * @dev The `distributeFee()` function in the BtcSnacks contract must be called before
    * the `distributeFee()` function in the Snacks contract.
    * @param feeAmount_ Fee amount.
    */
    function notifyBtcSnacksFeeAmount(uint256 feeAmount_) external onlyBtcSnacks {
        _btcSnacksFeeAmountStored += feeAmount_;
        emit BtcSnacksFeeAdded(feeAmount_);
    }
    
    /**
    * @notice Notifies the contract about the incoming fee in EthSnacks token.
    * @dev The `distributeFee()` function in the EthSnacks contract must be called before
    * the `distributeFee()` function in the Snacks contract.
    * @param feeAmount_ Fee amount.
    */
    function notifyEthSnacksFeeAmount(uint256 feeAmount_) external onlyEthSnacks {
        _ethSnacksFeeAmountStored += feeAmount_;
        emit EthSnacksFeeAdded(feeAmount_);
    }

    /**
    * @notice Distributes rewards on pools and notifies them.
    * @dev Called by the authorised address once every 12 hours.
    * @param zoinksAmountOutMin_ Minimum expected amount of Zoinks token 
    * to be received after the exchange 90% of the total balance of Binance-Peg BUSD token.
    */
    function distributeRewards(uint256 zoinksAmountOutMin_) external whenNotPaused onlyAuthority {
        uint256 reward;
        uint256 seniorageFeeAmount;
        uint256 distributionAmount;
        uint256 zoinksBalance = IERC20(zoinks).balanceOf(address(this));
        if (zoinksBalance != 0) {
            address zoinksAddress = zoinks;
            // 10% of the balance goes to the Seniorage contract.
            seniorageFeeAmount = zoinksBalance * SENIORAGE_FEE_PERCENT / BASE_PERCENT;
            IERC20(zoinksAddress).safeTransfer(seniorage, seniorageFeeAmount);
            distributionAmount = zoinksBalance - seniorageFeeAmount;
            // 23.08% of the distribution amount goes to the ApeSwapPool contract.
            reward = distributionAmount * ZOINKS_APE_SWAP_POOL_PERCENT / BASE_PERCENT;
            IERC20(zoinksAddress).safeTransfer(apeSwapPool, reward);
            ISingleRewardPool(apeSwapPool).notifyRewardAmount(reward);
            // 23.08% of the distribution amount goes to the BiSwapPool contract.
            reward = distributionAmount * ZOINKS_BI_SWAP_POOL_PERCENT / BASE_PERCENT;
            IERC20(zoinksAddress).safeTransfer(biSwapPool, reward);
            ISingleRewardPool(biSwapPool).notifyRewardAmount(reward);
            // 53.84% of the distribution amount goes to the PancakeSwapPool contract.
            reward = distributionAmount * ZOINKS_PANCAKE_SWAP_POOL_PERCENT / BASE_PERCENT;
            IERC20(zoinksAddress).safeTransfer(pancakeSwapPool, reward);
            IMultipleRewardPool(pancakeSwapPool).notifyRewardAmount(zoinksAddress, reward);
        }
        uint256 snacksBalance = IERC20(snacks).balanceOf(address(this));
        if (snacksBalance != 0) {
            address snacksAddress = snacks;
            // 10% of the balance goes to the Seniorage contract.
            seniorageFeeAmount = snacksBalance * SENIORAGE_FEE_PERCENT / BASE_PERCENT;
            IERC20(snacksAddress).safeTransfer(seniorage, seniorageFeeAmount);
            distributionAmount = snacksBalance - seniorageFeeAmount;
            // 66.67% of the distribution amount goes to the PancakeSwapPool contract.
            reward = distributionAmount * SNACKS_PANCAKE_SWAP_POOL_PERCENT / BASE_PERCENT;
            IERC20(snacksAddress).safeTransfer(pancakeSwapPool, reward);
            IMultipleRewardPool(pancakeSwapPool).notifyRewardAmount(snacksAddress, reward);
            // 33.33% of the distribution amount goes to the SnacksPool contract.
            reward = distributionAmount * SNACKS_SNACKS_POOL_PERCENT / BASE_PERCENT;
            IERC20(snacksAddress).safeTransfer(snacksPool, reward);
            IMultipleRewardPool(snacksPool).notifyRewardAmount(snacksAddress, reward);
        }
        uint256 btcSnacksFeeAmountStored = _btcSnacksFeeAmountStored;
        uint256 btcSnacksBalance = IERC20(btcSnacks).balanceOf(address(this)) - btcSnacksFeeAmountStored;
        if (btcSnacksBalance != 0) {
            address btcSnacksAddress = btcSnacks;
            // 10% of the balance goes to the Seniorage contract.
            seniorageFeeAmount = btcSnacksBalance * SENIORAGE_FEE_PERCENT / BASE_PERCENT;
            IERC20(btcSnacksAddress).safeTransfer(seniorage, seniorageFeeAmount);
            distributionAmount = btcSnacksBalance - seniorageFeeAmount;
            // 57.14% of the distribution amount goes to the PancakeSwapPool contract.
            reward = distributionAmount * BTC_SNACKS_PANCAKE_SWAP_POOL_PERCENT / BASE_PERCENT;
            IERC20(btcSnacksAddress).safeTransfer(pancakeSwapPool, reward);
            IMultipleRewardPool(pancakeSwapPool).notifyRewardAmount(btcSnacksAddress, reward);
            // 42.86% of the distribution amount goes to the SnacksPool contract.
            reward = distributionAmount * BTC_SNACKS_SNACKS_POOL_PERCENT / BASE_PERCENT;
            IERC20(btcSnacksAddress).safeTransfer(snacksPool, reward + btcSnacksFeeAmountStored);
            IMultipleRewardPool(snacksPool).notifyRewardAmount(btcSnacksAddress, reward + btcSnacksFeeAmountStored);
            _btcSnacksFeeAmountStored = 0;
        }
        uint256 ethSnacksFeeAmountStored = _ethSnacksFeeAmountStored;
        uint256 ethSnacksBalance = IERC20(ethSnacks).balanceOf(address(this)) - ethSnacksFeeAmountStored; 
        if (ethSnacksBalance != 0) {
            address ethSnacksAddress = ethSnacks;
            // 10% of the balance goes to the Seniorage contract.
            seniorageFeeAmount = ethSnacksBalance * SENIORAGE_FEE_PERCENT / BASE_PERCENT;
            IERC20(ethSnacksAddress).safeTransfer(seniorage, seniorageFeeAmount);
            distributionAmount = ethSnacksBalance - seniorageFeeAmount;
            // 57.14% of the distribution amount goes to the PancakeSwapPool contract.
            reward = distributionAmount * ETH_SNACKS_PANCAKE_SWAP_POOL_PERCENT / BASE_PERCENT;
            IERC20(ethSnacksAddress).safeTransfer(pancakeSwapPool, reward);
            IMultipleRewardPool(pancakeSwapPool).notifyRewardAmount(ethSnacksAddress, reward);
            // 42.86% of the distribution amount goes to the SnacksPool contract.
            reward = distributionAmount * ETH_SNACKS_SNACKS_POOL_PERCENT / BASE_PERCENT;
            IERC20(ethSnacksAddress).safeTransfer(snacksPool, reward + ethSnacksFeeAmountStored);
            IMultipleRewardPool(snacksPool).notifyRewardAmount(ethSnacksAddress, reward + ethSnacksFeeAmountStored);
            _ethSnacksFeeAmountStored = 0;
        }
        uint256 busdBalance = IERC20(busd).balanceOf(address(this));
        if (busdBalance != 0) {
            // 10% of the balance goes to the Seniorage contract.
            seniorageFeeAmount = busdBalance * SENIORAGE_FEE_PERCENT / BASE_PERCENT;
            IERC20(busd).safeTransfer(seniorage, seniorageFeeAmount);
            // Exchange 100% of the distribution amount on Zoinks tokens.
            distributionAmount = busdBalance - seniorageFeeAmount;
            address[] memory path = new address[](2);
            path[0] = busd;
            path[1] = zoinks;
            uint256[] memory amounts = IRouter(router).swapExactTokensForTokens(
                distributionAmount,
                zoinksAmountOutMin_,
                path,
                address(this),
                block.timestamp
            );
            uint256 snacksAmount = ISnacksBase(snacks).mintWithPayTokenAmount(amounts[1]);
            IERC20(snacks).safeTransfer(lunchBox, snacksAmount);
            ISingleRewardPool(lunchBox).notifyRewardAmount(snacksAmount);
        }
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

/**
* @title Interface that can be used to interact with multiple reward pool contracts.
*/
interface IMultipleRewardPool {
    function notifyRewardAmount(
        address rewardToken,
        uint256 reward
    )
        external;
    function stake(uint256 amount) external;
    function getReward() external;
    function getBalance(address user) external view returns (uint256);
    function getTotalSupply() external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

/** 
* @title Interface that can be used to interact with router contracts.
*/
interface IRouter {
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
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        returns (uint256[] memory amounts);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) 
        external 
        returns (uint256 amountA, uint256 amountB);
    function factory() external view returns (address);
    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountOut);
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountIn);
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

/**
* @title Interface that can be used to interact with single reward pool contracts.
*/
interface ISingleRewardPool {
    function notifyRewardAmount(uint256 reward) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

/**
* @title Interface that can be used to interact with Snacks/BtcSnacks/EthSnacks contracts.
*/
interface ISnacksBase {
    function mintWithBuyTokenAmount(uint256 buyTokenAmount) external returns (uint256);
    function mintWithPayTokenAmount(uint256 payTokenAmount) external returns (uint256);
    function isExcludedHolder(address account) external view returns (bool);
    function redeem(uint256 buyTokenAmount) external returns (uint256);
    function adjustmentFactor() external view returns (uint256);
    function sufficientBuyTokenAmountOnMint(
        uint256 buyTokenAmount
    ) 
        external 
        view
        returns (bool);
    function sufficientPayTokenAmountOnMint(
        uint256 payTokenAmount
    )
        external
        view
        returns (bool);
    function sufficientBuyTokenAmountOnRedeem(
        uint256 buyTokenAmount
    )
        external
        view
        returns (bool);
}