/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

// File: @openzeppelin/contracts/utils/Context.sol

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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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

// File: contracts/omeav4.sol


pragma solidity ^0.8.9;



error ContractIsPaused();
error Deposit404();
error DepositIsLocked();
error LowContractBalance();
error OwnerError();
error ZeroAddress();
error ZeroDeposit();

contract OMEA is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint24 public constant WITHDRAW_PERIOD = 30 days; // 30 days
    uint24 private constant REWARD_PERIOD = 1 hours;
    // REFERRER REWARDS
    uint16 private constant REFERRER_REWARD_1 = 800; // 800 : 8 %. 10000 : 100 %
    uint16 private constant REFERRER_REWARD_2 = 900; // 900 : 9 %. 10000 : 100 %
    uint16 private constant REFERRER_REWARD_3 = 1000; // 1000 : 10 %. 10000 : 100 %
    // HPR (Hourly Percentage Rate)
    uint16 private constant HPR_5 = 350; // 350 : 3.50 %. 10000 : 100 %
    uint16 private constant HPR_4 = 300; // 300 : 3.00 %. 10000 : 100 %
    uint16 private constant HPR_3 = 250; // 250 : 2.50 %. 10000 : 100 %
    uint16 private constant HPR_2 = 200; // 200 : 2.00 %. 10000 : 100 %
    uint16 private constant HPR_1 = 150; // 150 : 1.50 %. 10000 : 100 %
    // FEEs
    uint8 public constant DEV_FEE = 200; // 200 : 2 %. 10000 : 100 %
    uint8 public constant MARKETING_FEE = 200; // 200 : 2 %. 10000 : 100 %
    uint8 public constant PRINCIPAL_FEE = 100; // 100 : 1%. 10000 : 100 %

    address public immutable i_BUSD_CONTRACT;

    address private devWallet;
    address private marketingWallet;

    uint256 public totalInvestors;
    uint256 public totalRewardsDistributed;
    uint256 public totalDepoists;

    bool private _isLaunched;

    mapping(address => Deposit[]) private _depositsHistory;
    mapping(address => Investor) public investors;
    mapping(address => bool) private _isActiveInvestor;
    mapping(address => Bonus[]) private _bonusHistory;

    /*************************************************/
    /******************** STRUCTS ********************/
    /*************************************************/

    struct Bonus {
        uint256 amount;
        uint256 createdDate;
    }
    struct Deposit {
        uint256 index; // deposit index
        address depositor; // address of wallet
        uint256 amount; // amount deposited
        uint256 lockPeriod;
        bool status; // if deposit amount is withdraw => false
    }

    struct Investor {
        address account; // wallet address of investor
        address referrer; // wallet referrer of investor
        uint256 totalInvested; // sum of all deposits
        uint256 lastCalculatedBlock; // timestamp for last time when rewards were updated
        uint256 claimableAmount; // pending rewards to be claimed
        uint256 claimedAmount; // claimed amount
        uint256 referAmount; // amount generated from referrals
        uint256 referrals; // number of referrals
        uint256 bonus; // amount of bonuses
    }

    /*************************************************/
    /******************** EVENTS ********************/
    /*************************************************/

    event Deposited(address indexed investor, uint256 amount);

    /*************************************************/
    /******************* FUNCTIONS *******************/
    /*************************************************/

    function deposit(uint256 _amount, address _referrer) external {
        if (!_isLaunched) revert ContractIsPaused();
        if (_amount < 1) revert ZeroDeposit();

        IERC20(i_BUSD_CONTRACT).safeTransferFrom(
            _msgSender(),
            address(this),
            _amount
        );

        // DevFee
        uint256 _developerFee = (_amount * DEV_FEE) / 10000;
        IERC20(i_BUSD_CONTRACT).safeTransfer(devWallet, _developerFee);

        // Marketing Fee
        uint256 _marketingFee = (_amount * MARKETING_FEE) / 10000;
        IERC20(i_BUSD_CONTRACT).safeTransfer(marketingWallet, _marketingFee);

        uint256 _depositAmount = _amount - (_developerFee + _marketingFee);
        uint256 deposits = _depositsHistory[_msgSender()].length;

        Deposit memory _deposit = Deposit({
            index: deposits,
            depositor: _msgSender(),
            amount: _depositAmount,
            lockPeriod: block.timestamp + WITHDRAW_PERIOD,
            status: true
        });
        _depositsHistory[_msgSender()].push(_deposit);

        if (_referrer == _msgSender()) _referrer = address(0);
        bool isActiveInvestor_ = _isActiveInvestor[_msgSender()];

        if (!isActiveInvestor_) {
            investors[_msgSender()] = Investor({
                account: _msgSender(),
                lastCalculatedBlock: block.timestamp,
                referrer: _referrer,
                totalInvested: _depositAmount,
                claimableAmount: 0,
                claimedAmount: 0,
                referAmount: 0,
                referrals: 0,
                bonus: 0
            });

            totalInvestors += 1;
            _isActiveInvestor[_msgSender()] = true;
        } else {
            Investor memory investor_ = investors[_msgSender()];

            uint256 _totalInvested = investor_.totalInvested + _depositAmount;
            investor_ = _updateInvestorRewards(investor_);
            investor_.totalInvested = _totalInvested;
            investors[_msgSender()] = investor_;
        }

        Investor memory _investor = investors[_msgSender()];
        if (_investor.referrer == address(0x0) && _referrer != address(0x0)) {
            _investor.referrer = _referrer;

            Investor memory referrer_ = investors[_referrer];
            uint256 _totalReferrals = referrer_.referrals + 1;

            referrer_.referrals = _totalReferrals;

            uint256 _referrerAmount = _calculateReferralRewards(
                _amount,
                _totalReferrals
            );
            referrer_.referAmount += _referrerAmount;

            IERC20(i_BUSD_CONTRACT).safeTransfer(_referrer, _referrerAmount);
        }

        totalDepoists += _amount;

        emit Deposited(_msgSender(), _amount);
    }

    /**
     * @dev calculates claimable rewards and send to  _msgSender()
     */
    function claimAllReward() external nonReentrant {
        if (_depositsHistory[_msgSender()].length == 0) revert Deposit404();

        Investor memory investor_ = investors[_msgSender()];

        investor_ = _updateInvestorRewards(investor_);

        uint256 allClaimables = investor_.claimableAmount;

        uint256 sendBalance = allClaimables;
        if (getBalance() < allClaimables) {
            sendBalance = getBalance();
        }
        investor_.claimableAmount = allClaimables - sendBalance;
        investor_.claimedAmount = sendBalance;

        investors[_msgSender()] = investor_;

        IERC20(i_BUSD_CONTRACT).safeTransfer(_msgSender(), sendBalance);

        totalRewardsDistributed += sendBalance;
    }

    /**
     * @dev calculates claimable rewards and send capital invested
     */
    function withdrawCapital(uint256 _depositIndex) external nonReentrant {
        uint256 _totalDeposits = _depositsHistory[_msgSender()].length - 1;

        if (_totalDeposits < _depositIndex) revert Deposit404();

        Deposit memory _deposit = _depositsHistory[_msgSender()][_depositIndex];

        if (!_deposit.status) revert Deposit404();
        if (_deposit.lockPeriod < block.timestamp) revert DepositIsLocked();
        if (_deposit.depositor != _msgSender()) revert OwnerError();

        Investor memory investor_ = investors[_msgSender()];

        investor_ = _updateInvestorRewards(investor_);

        uint256 depositCapital = _deposit.amount;

        if (depositCapital > getBalance()) revert LowContractBalance();

        investor_.totalInvested -= depositCapital;

        //  if withdraws all amount remove bonuses
        if (investor_.totalInvested == 0) {
            delete _bonusHistory[_msgSender()];
            investor_.bonus = 0;
        }

        investors[_msgSender()] = investor_;
        _deposit.status = false;
        _depositsHistory[_msgSender()][_depositIndex] = _deposit;

        uint256 _principalFee = (depositCapital * PRINCIPAL_FEE) / 10000;
        depositCapital -= _principalFee;

        // transfer capital to the user
        IERC20(i_BUSD_CONTRACT).safeTransfer(_msgSender(), depositCapital);
    }

    /*************************************************/
    /*************** PRIVATE FUNCTIONS ***************/
    /*************************************************/
    /**
     * @dev  checks if address is contract.
     */
    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    /**
     * @dev  calculates and udpate claimables for _investor.
     */
    function _updateInvestorRewards(Investor memory investor_)
        private
        view
        returns (Investor memory)
    {
        (
            uint256 claimables,
            uint256 lastCalculatedBlock
        ) = _calculateClaimableAmount(investor_);

        investor_.claimableAmount += claimables;
        investor_.lastCalculatedBlock = lastCalculatedBlock;

        return investor_;
    }

    /**
     * @dev  calculates claimable amount for _investor.
     */
    function _calculateClaimableAmount(Investor memory _investor)
        private
        view
        returns (uint256 claimables, uint256 lastCalculatedBlock)
    {
        uint256 hoursInSec = block.timestamp - _investor.lastCalculatedBlock;
        uint256 _totalLocked = _investor.totalInvested + _investor.bonus;

        uint256 tokensPerHour = (_totalLocked * getHPR(_totalLocked)) / 10000;
        uint256 hoursSinceLastCheck = hoursInSec / REWARD_PERIOD;

        claimables = (tokensPerHour * hoursSinceLastCheck);
        lastCalculatedBlock = block.timestamp;
    }

    /**
     * @dev  calculate referral rewards for given _deposit and number of _referrals count
     */
    function _calculateReferralRewards(uint256 _deposit, uint256 _referrals)
        private
        pure
        returns (uint256)
    {
        return (_deposit * getReferralBPs(_referrals)) / 10000;
    }

    /*************************************************/
    /**************** ADMIN FUNCTIONS ****************/
    /*************************************************/

    function addBonus(address _account, uint256 _amount) external onlyOwner {
        require(_isActiveInvestor[_account], "No investor 404");

        Bonus memory bonus = Bonus({
            amount: _amount,
            createdDate: block.timestamp
        });

        _bonusHistory[_account].push(bonus);

        Investor memory _investor = investors[_account];
        _investor = _updateInvestorRewards(_investor);

        _investor.bonus += _amount;
        investors[_account] = _investor;
    }

    function launchContract() external onlyOwner {
        _isLaunched = true;
    }

    /**
     * @dev updates dev wallet address
     */
    function resetDevWallet(address _devWallet) external onlyOwner {
        if (_devWallet == address(0x0)) revert ZeroAddress();
        devWallet = _devWallet;
    }

    /**
     * @dev updates marketing wallet address
     */
    function resetMarketingWallet(address _marketingWallet) external onlyOwner {
        if (_marketingWallet == address(0x0)) revert ZeroAddress();
        marketingWallet = _marketingWallet;
    }

    /*************************************************/
    /**************** VIEW FUNCTIONS ****************/
    /************************************************/

    /**
     * @dev returns BUSD balance of contract.
     */
    function getBalance() public view returns (uint256) {
        return IERC20(i_BUSD_CONTRACT).balanceOf(address(this));
    }

    /**
     * @dev returns amount of pending rewards for _account
     */
    function getClaimableAmount(address _account)
        public
        view
        returns (uint256)
    {
        Investor memory _investor = investors[_account];
        (uint256 claimables, ) = _calculateClaimableAmount(_investor);
        return
            (claimables + _investor.claimableAmount) - _investor.claimedAmount;
    }

    /**
     * @dev returns percentage (in bps) for number of referrals
     */
    function getReferralBPs(uint256 _referrals) public pure returns (uint16) {
        if (_referrals == 0) return 0;
        if (_referrals <= 10) return REFERRER_REWARD_1;
        if (_referrals <= 30) return REFERRER_REWARD_2;
        return REFERRER_REWARD_3;
    }

    /**
     * @dev returns Hourly Percentage Rate (in bps) for _investment. _investment should be in wei
     */
    function getHPR(uint256 _investment) public pure returns (uint16) {
        if (_investment < 1) return 0;
        if (_investment < 101 * 1e18) return HPR_1;
        if (_investment < 101 * 1e18) return HPR_2;
        if (_investment < 101 * 1e18) return HPR_3;
        if (_investment < 101 * 1e18) return HPR_4;
        return HPR_5;
    }

    /**
     * @dev returns all deposits of _account
     */
    function depositsOf(address _account)
        external
        view
        returns (Deposit[] memory)
    {
        return _depositsHistory[_account];
    }

    /**
     * @dev returns all bonuses of _account
     */
    function bonusOf(address _account) external view returns (Bonus[] memory) {
        return _bonusHistory[_account];
    }

    /**
     * @dev returns status of contract i.e open for depoists
     */
    function isLaunched() external view returns (bool) {
        return _isLaunched;
    }

    /*************************************************/
    /****************** CONSTRUCTOR ******************/
    /*************************************************/
    constructor(
        address _devWallet,
        address _marketingWallet,
        address _busdContract
    ) {
        if (
            !isContract(_busdContract) ||
            _devWallet == address(0x0) ||
            _marketingWallet == address(0x0)
        ) revert ZeroAddress();

        devWallet = _devWallet;
        marketingWallet = _marketingWallet;
        i_BUSD_CONTRACT = _busdContract;
    }
}