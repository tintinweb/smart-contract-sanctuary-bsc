/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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
}

/**
 *  SourceUnit: d:\Direct Projects\Atompad\Backend\atompad-V2\presale\contracts\extensions\PresaleInternal.sol
 */

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
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
     * ////IMPORTANT: The same issues {IERC20-approve} has related to transaction
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

/**
 *  SourceUnit: d:\Direct Projects\Atompad\Backend\atompad-V2\presale\contracts\extensions\PresaleInternal.sol
 */

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
}

/**
 *  SourceUnit: d:\Direct Projects\Atompad\Backend\atompad-V2\presale\contracts\extensions\PresaleInternal.sol
 */

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

////import "../IERC20.sol";
////import "../extensions/draft-IERC20Permit.sol";
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
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
        require(
            nonceAfter == nonceBefore + 1,
            "SafeERC20: permit did not succeed"
        );
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

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

/**
 *  SourceUnit: d:\Direct Projects\Atompad\Backend\atompad-V2\presale\contracts\extensions\PresaleInternal.sol
 */

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: UNLICENSED
////import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

pragma solidity 0.8.16;

library DataTypes {
    struct Metadata {
        string moduleType;
        uint256 version;
    }

    struct Token {
        address token;
        uint256 decimals;
    }

    struct Duration {
        uint256 start;
        uint256 end;
    }

    struct Vest {
        uint256 noOfVests;
        uint256 initialVestPercentage;
        //should be in 10**3
        uint256 percPerVest;
        uint256 durationPerVest;
        Duration duration;
    }

    struct Claim {
        uint256 reserved; // amount of bought wantToken
        //    uint released;     // amount of released wantToken, increases over time
        uint256 claimed; // amount of claimed wantToken, increases after claiming.
    }
}

/**
 *  SourceUnit: d:\Direct Projects\Atompad\Backend\atompad-V2\presale\contracts\extensions\PresaleInternal.sol
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
 *  SourceUnit: d:\Direct Projects\Atompad\Backend\atompad-V2\presale\contracts\extensions\PresaleInternal.sol
 */

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: UNLICENSED
pragma solidity 0.8.16;

////import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
////import {DataTypes} from "../../lib/DataTypes.sol";

contract PresaleStorage {
    DataTypes.Metadata public metadata;

    uint256 public fcfsPercentage;

    DataTypes.Token public investToken;

    DataTypes.Token public wantToken;

    // IERC20 public investToken;

    // IERC20 public wantToken;

    // uint256 public iDecimals;

    // uint256 public wDecimals;

    //should be in 10 ** 18
    uint256 public rate;

    uint256 public hardCap;

    uint256 public tokenSupply;

    uint256 public swapTotal;

    uint256 public claimedTotal;

    bool public claimOn;

    bool public swapOn;

    DataTypes.Duration public duration;

    DataTypes.Vest public vest;

    mapping(address => uint256) public swaps;
    mapping(address => DataTypes.Claim) public claims;
}

/**
 *  SourceUnit: d:\Direct Projects\Atompad\Backend\atompad-V2\presale\contracts\extensions\PresaleInternal.sol
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
 *  SourceUnit: d:\Direct Projects\Atompad\Backend\atompad-V2\presale\contracts\extensions\PresaleInternal.sol
 */

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

////import "../utils/Context.sol";

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

/**
 *  SourceUnit: d:\Direct Projects\Atompad\Backend\atompad-V2\presale\contracts\extensions\PresaleInternal.sol
 */

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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
 *  SourceUnit: d:\Direct Projects\Atompad\Backend\atompad-V2\presale\contracts\extensions\PresaleInternal.sol
 */

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: UNLICENSED
pragma solidity 0.8.16;

interface IStakepool {
    function allocPercentageOf(address _sender) external view returns (uint256);
}

/**
 *  SourceUnit: d:\Direct Projects\Atompad\Backend\atompad-V2\presale\contracts\extensions\PresaleInternal.sol
 */

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: UNLICENSED
pragma solidity 0.8.16;

//  ==========  External ////imports    ==========
// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
////import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
////import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
////import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

//  ==========  Internal ////imports    ==========
// import {PresaleStorage} from "../storage/PresaleStorage.sol";
////import {DataTypes} from "../../lib/DataTypes.sol";

contract PresaleControl is PresaleStorage, Ownable, Pausable, ReentrancyGuard {
    event Deposited(address indexed user, uint256 amount);

    function depositTokens(uint256 _amount) external payable onlyOwner {
        DataTypes.Token memory _token = wantToken;
        IERC20 _wantToken = IERC20(_token.token);
        /// do some checks
        require(_wantToken.balanceOf(msg.sender) >= _amount, "!amount");
        /// @dev set minimum amount of tokens for this presale
        require(
            _amount >= (10 * 10**_token.decimals),
            "min amount is 10 tokens"
        );
        /// transfer x amount of wantToken to presale
        _wantToken.transferFrom(msg.sender, address(this), _amount);

        /// set total supply
        tokenSupply += _amount;

        // rate = (tokenSupply / hardCap);
        emit Deposited(msg.sender, _amount);
    }

    function returnWantTokens() external onlyOwner {
        IERC20 _wantToken = IERC20(wantToken.token);
        //
        // do some checks
        require(_wantToken.balanceOf(address(this)) > 0, "!Amount");

        uint256 _remaining = _wantToken.balanceOf(address(this));

        _wantToken.transfer(msg.sender, _remaining);

        /// set total supply
        tokenSupply = 0;
    }

    function forwardInvestTokens() external onlyOwner {
        IERC20 _investToken = IERC20(investToken.token);
        //
        /// do some checks
        require(_investToken.balanceOf(address(this)) > 0, "!Amount");

        uint256 _invested = _investToken.balanceOf(address(this));

        _investToken.transfer(msg.sender, _invested);
    }

    function setEnableSwap(bool _flag) external onlyOwner {
        // do some checks
        swapOn = _flag;
    }

    function setHardCap(uint256 _cap) external onlyOwner {
        hardCap = _cap;
    }

    function setRate(uint256 _rate) external onlyOwner {
        rate = _rate;
    }

    function setVest(DataTypes.Duration memory _vestDuration)
        external
        onlyOwner
    {
        vest.duration = _vestDuration;
    }

    function setSaleTime(DataTypes.Duration memory _saleDuration)
        external
        onlyOwner
    {
        duration = _saleDuration;
    }

    function setVest(DataTypes.Vest memory _vest) external onlyOwner {
        vest = _vest;
    }

    function setEnableClaim(bool _flag) external onlyOwner {
        // do some checks
        claimOn = _flag;
    }

    function setInvestToken(DataTypes.Token memory _investToken)
        external
        onlyOwner
    {
        /// check this is a valid address
        require(_investToken.token != address(0));
        require(_investToken.decimals != 0);

        investToken = _investToken;
    }

    function setWantToken(DataTypes.Token memory _wantToken)
        external
        onlyOwner
    {
        /// check this is a valid address
        require(_wantToken.token != address(0));
        require(_wantToken.decimals != 0);

        wantToken = _wantToken;
    }

    function setFcfsPercentage(uint256 _fcfsPercentage) external onlyOwner {
        fcfsPercentage = _fcfsPercentage;
    }
}

/**
 *  SourceUnit: d:\Direct Projects\Atompad\Backend\atompad-V2\presale\contracts\extensions\PresaleInternal.sol
 */

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: UNLICENSED
pragma solidity 0.8.16;

//  ==========  External ////imports    ==========

// import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
////import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
//  ==========  Internal ////imports    ==========
// import {PresaleControl} from "./control/PresaleControl.sol";
////import {IStakepool} from "../interfaces/IStakepool.sol";

////import {DataTypes} from "../lib/DataTypes.sol";

contract Presale is PresaleControl {
    /**

        Setup the contract

        Admin setup:
        1- Setup stakepool
        2- Set initializer vars


        User setup:
        1- Stake atompad in stakepool
        2- Swap allocation
        3- Claim tokens



        1- Replaced getReleasedPecentage() with getReleasedPercentageFromCalculation()
        2- Updated getReleasedPercentageFromCalculation() to be more readable
        3- Addition of want token decimals
        4- Added a routine to calculate the want token getTokenAmount() based on amount invested and rate
        5- Used inheritance to reduce code duplication
        6- PresaleInternal and PresaleControl inherits from this contract which is base
        7- getAllocPercentage() in now virtual function, this means child contracts can override its implementation


     */
    using SafeERC20 for IERC20;

    event Swapped(address indexed user, uint256 amount);

    event Claimed(address indexed user, uint256 amount);

    modifier claimEnabled() {
        require(claimOn == true, "Claiming is not enabled!");
        _;
    }
    modifier swapEnabled() {
        require(swapOn == true, "Swapping is not enabled!");
        _;
    }
    modifier onProgress() {
        require(
            block.timestamp < duration.end && block.timestamp >= duration.start,
            "presale not in progress"
        );
        _;
    }
    modifier whenFinished() {
        require(block.timestamp > duration.end, "presale is not finished");
        _;
    }

    // constructor
    constructor(
        DataTypes.Metadata memory _metadata,
        uint256 _rate,
        uint256 _hardCap,
        DataTypes.Token memory _investToken,
        DataTypes.Token memory _wantToken,
        DataTypes.Duration memory _saleDuration,
        DataTypes.Vest memory _vest
    ) {
        metadata = _metadata;
        vest = _vest;
        rate = _rate;
        hardCap = _hardCap;
        duration = _saleDuration;
        investToken = _investToken;
        wantToken = _wantToken;
        swapOn = true;
    }

    // receive function (if exists)

    // fallback function (if exists)

    // external

    function swap(uint256 _amount)
        external
        nonReentrant
        whenNotPaused
        onProgress
        swapEnabled
    {
        uint256 _perc = allocPercentageOf(msg.sender);

        uint256 _swapTotalAfter = swapTotal + _amount;

        DataTypes.Token memory _investToken = investToken;

        require(_perc > 0, "Presale: No allocation");

        require(
            _swapTotalAfter / (10**(_investToken.decimals)) < hardCap,
            "Presale: Hard cap reached"
        );

        _swap(msg.sender, _amount, _perc, _investToken.decimals);

        IERC20(investToken.token).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );

        emit Swapped(msg.sender, _amount);
    }

    function swapClaim()
        external
        payable
        nonReentrant
        claimEnabled
        whenFinished
        whenNotPaused
        returns (bool)
    {
        // do some checks

        /// private call
        _swapClaim(msg.sender);

        /// defaults we finished no error!
        return true;
    }

    // public
    function getTokenAmount(uint256 _amount) public view returns (uint256) {
        uint256 iDecimals = investToken.decimals;
        uint256 wDecimals = wantToken.decimals;

        if (iDecimals != wDecimals) {
            _amount = _amount / 10**(iDecimals);
            _amount = _amount * 10**(wDecimals);
        }

        return (_amount * rate) / (10**18);
    }

    function getReleasedPercentage() public view returns (uint256 _perc) {
        //initialVestPercentage + percPerVest * noOfVests should not exceed 100
        DataTypes.Vest memory _vest = vest;
        uint256 _startVest = _vest.duration.start;
        uint256 _time = block.timestamp;

        if (_vest.initialVestPercentage >= 100) return 100 * (10**3);

        if (_time <= _startVest) return 0;

        for (uint256 i = 0; i < _vest.noOfVests; i++) {
            if (_time > _startVest + (i * (_vest.durationPerVest)))
                //percPerVest will be in 10**3
                _perc = (_vest.initialVestPercentage + i) * (_vest.percPerVest);
        }

        if (_time > _vest.duration.end) return 100 * (10**3);
        return _perc;
    }

    function getUserAllocated(address _wallet) external view returns (uint256) {
        uint256 _iDecimals = investToken.decimals;
        /// retrieve absolute amount of remaining allocation for this;
        uint256 _perc = allocPercentageOf(_wallet);

        /// retrieve basic allocation
        uint256 _allocate = (hardCap * _perc);

        if (_iDecimals > 6) _allocate = _allocate * (10**(_iDecimals - 6));

        /// check to avoid < 0 error
        if (_allocate <= swaps[_wallet]) return 0;

        /// returns remaining allocation
        return (_allocate - swaps[_wallet]);
    }

    function getUserClaim(address _user)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 _free = getReleasedPercentage();

        uint256 _released = (claims[_user].reserved * _free) / (100 * (10**3));

        return (claims[_user].reserved, _released, claims[_user].claimed);
    }

    // internal

    // private
    function _swap(
        address _from,
        uint256 _amount,
        uint256 _perc,
        uint256 _iDecimals
    ) private {
        uint256 _allocation = (hardCap * _perc);

        if (_iDecimals > 6) _allocation = _allocation * (10**(_iDecimals - 6));
        if (_iDecimals < 6) _allocation = _allocation / (10**(_iDecimals));

        uint256 _swapped = swaps[_from];
        uint256 _remaining = _allocation - _swapped;

        require(_remaining >= _amount, "Presale: Insufficient allocation");

        swaps[_from] += _amount;

        claims[_from].reserved += getTokenAmount(_amount);

        swapTotal += _amount;
    }

    function _swapClaim(address _from) private {
        uint256 _free = getReleasedPercentage();

        /// extra check1 to avoid overspending
        if (_free > 100 * (10**3)) _free = 100 * (10**3);

        /// calculate the claims released
        uint256 _released = (claims[_from].reserved * _free) / (100 * (10**3));

        /// check if the released > claimed
        require(claims[_from].claimed < _released, "!nothing to claim");

        /// calculate the amount to be claimed
        uint256 _amount = _released - claims[_from].claimed;

        /// sum totalizer claimedTotal
        claimedTotal += _amount;

        /// set total supply
        tokenSupply -= _amount;

        // set the field claims.claimed
        claims[_from].claimed += _amount;

        /// extra check2 to avoid overspending
        if (claims[_from].claimed > claims[_from].reserved) {
            // we are overspending here!!! revert
            claims[_from].claimed -= _amount;
        } else {
            // transfer tokens to the investor
            IERC20(wantToken.token).safeTransfer(_from, _amount);
        }

        // do some other things
        //  !!
        emit Claimed(msg.sender, _amount);
    }

    function allocPercentageOf(address _sender)
        public
        view
        virtual
        returns (uint256)
    {}
}

/**
 *  SourceUnit: d:\Direct Projects\Atompad\Backend\atompad-V2\presale\contracts\extensions\PresaleInternal.sol
 */

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: UNLICENSED
pragma solidity 0.8.16;

////import {IStakepool} from "../interfaces/IStakepool.sol";

////import {Presale} from "../core/Presale.sol";

////import {DataTypes} from "../lib/DataTypes.sol";

/**
    This is contract works as a extension for the presale on Binance Smart Chain.
 */
contract PresaleInternal is Presale {
    constructor(
        address _stakepool,
        DataTypes.Metadata memory _metadata,
        uint256 _rate,
        uint256 _hardCap,
        DataTypes.Token memory _investToken,
        DataTypes.Token memory _wantToken,
        DataTypes.Duration memory _saleDuration,
        DataTypes.Vest memory _vest
    )
        Presale(
            _metadata,
            _rate,
            _hardCap,
            _investToken,
            _wantToken,
            _saleDuration,
            _vest
        )
    {
        stakepool = IStakepool(_stakepool);
    }

    IStakepool public stakepool;

    function allocPercentageOf(address _sender)
        public
        view
        override
        returns (uint256)
    {
        //  retrieve allocPercentage() from StakePool.sol
        uint256 _allocPerc = stakepool.allocPercentageOf(_sender);
        return _allocPerc;
    }

    function setStakepool(address _stakepool) external onlyOwner {
        stakepool = IStakepool(_stakepool);
    }
}