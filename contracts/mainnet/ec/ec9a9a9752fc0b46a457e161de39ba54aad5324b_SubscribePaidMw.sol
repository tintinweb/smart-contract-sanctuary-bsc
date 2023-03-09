// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import { Initializable } from "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

/// @notice Adapted from Solmate's Auth.sol with initializer replacing the constructor.

/// @notice Provides a flexible and updatable auth pattern which is completely separate from application logic.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/auth/Auth.sol)
/// @author Modified from Dappsys (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)
abstract contract Auth is Initializable {
    event OwnerUpdated(address indexed user, address indexed newOwner);

    event AuthorityUpdated(address indexed user, Authority indexed newAuthority);

    address public owner;

    Authority public authority;

    function __Auth_Init(address _owner, Authority _authority) internal onlyInitializing {
        owner = _owner;
        authority = _authority;

        emit OwnerUpdated(msg.sender, _owner);
        emit AuthorityUpdated(msg.sender, _authority);
    }

    modifier requiresAuth() virtual {
        require(isAuthorized(msg.sender, msg.sig), "UNAUTHORIZED");

        _;
    }

    function isAuthorized(address user, bytes4 functionSig) internal view virtual returns (bool) {
        Authority auth = authority; // Memoizing authority saves us a warm SLOAD, around 100 gas.

        // Checking if the caller is the owner only after calling the authority saves gas in most cases, but be
        // aware that this makes protected functions uncallable even to the owner if the authority is out of order.
        return (address(auth) != address(0) && auth.canCall(user, address(this), functionSig)) || user == owner;
    }

    function setAuthority(Authority newAuthority) public virtual {
        // We check if the caller is the owner first because we want to ensure they can
        // always swap out the authority even if it's reverting or using up a lot of gas.
        require(msg.sender == owner || authority.canCall(msg.sender, address(this), msg.sig), "UNAUTHORIZED");

        authority = newAuthority;

        emit AuthorityUpdated(msg.sender, newAuthority);
    }

    function setOwner(address newOwner) public virtual requiresAuth {
        owner = newOwner;

        emit OwnerUpdated(msg.sender, newOwner);
    }
}

/// @notice A generic interface for a contract which provides authorization data to an Auth instance.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/auth/Auth.sol)
/// @author Modified from Dappsys (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)
interface Authority {
    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import { Initializable } from "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

/// @notice Adapted from Solmate's ERC721.sol with initializer replacing the constructor.

/// @notice Modern, minimalist, and gas efficient ERC-721 implementation.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721 is Initializable {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /*//////////////////////////////////////////////////////////////
                         METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    function tokenURI(uint256 id) public view virtual returns (string memory);

    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) internal _ownerOf;

    mapping(address => uint256) internal _balanceOf;

    function ownerOf(uint256 id) public view virtual returns (address owner) {
        require((owner = _ownerOf[id]) != address(0), "NOT_MINTED");
    }

    function balanceOf(address owner) public view virtual returns (uint256) {
        require(owner != address(0), "ZERO_ADDRESS");

        return _balanceOf[owner];
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 APPROVAL STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    function __ERC721_Init(string calldata _name, string calldata _symbol)
        internal
        onlyInitializing
    {
        name = _name;
        symbol = _symbol;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 id) public virtual {
        address owner = _ownerOf[id];

        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");

        getApproved[id] = spender;

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        require(from == _ownerOf[id], "WRONG_FROM");

        require(to != address(0), "INVALID_RECIPIENT");

        require(
            msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id],
            "NOT_AUTHORIZED"
        );

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            _balanceOf[from]--;

            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        if (to.code.length != 0)
            require(
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                    ERC721TokenReceiver.onERC721Received.selector,
                "UNSAFE_RECIPIENT"
            );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual {
        transferFrom(from, to, id);

        if (to.code.length != 0)
            require(
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
                    ERC721TokenReceiver.onERC721Received.selector,
                "UNSAFE_RECIPIENT"
            );
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 id) internal virtual {
        require(to != address(0), "INVALID_RECIPIENT");

        require(_ownerOf[id] == address(0), "ALREADY_MINTED");

        // Counter overflow is incredibly unrealistic.
        unchecked {
            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = _ownerOf[id];

        require(owner != address(0), "NOT_MINTED");

        // Ownership check above ensures no underflow.
        unchecked {
            _balanceOf[owner]--;
        }

        delete _ownerOf[id];

        delete getApproved[id];

        emit Transfer(owner, address(0), id);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL SAFE MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        if (to.code.length != 0)
            require(
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "") ==
                    ERC721TokenReceiver.onERC721Received.selector,
                "UNSAFE_RECIPIENT"
            );
    }

    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {
        _mint(to, id);

        if (to.code.length != 0)
            require(
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==
                    ERC721TokenReceiver.onERC721Received.selector,
                "UNSAFE_RECIPIENT"
            );
    }
}

/// @notice A generic interface for a contract which properly accepts ERC721 tokens.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import { Auth, Authority } from "./Auth.sol";
import { Initializable } from "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

/// @notice Adapted from Solmate's RolesAuthority.sol using Auth's initializer instead of constructor.

/// @notice Role based Authority that supports up to 256 roles.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/auth/authorities/RolesAuthority.sol)
/// @author Modified from Dappsys (https://github.com/dapphub/ds-roles/blob/master/src/roles.sol)
contract RolesAuthority is Initializable, Auth, Authority {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event UserRoleUpdated(address indexed user, uint8 indexed role, bool enabled);

    event PublicCapabilityUpdated(address indexed target, bytes4 indexed functionSig, bool enabled);

    event RoleCapabilityUpdated(uint8 indexed role, address indexed target, bytes4 indexed functionSig, bool enabled);

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner, Authority _authority) initializer {
        Auth.__Auth_Init(_owner, _authority);
    }

    /*//////////////////////////////////////////////////////////////
                            ROLE/USER STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => bytes32) public getUserRoles;

    mapping(address => mapping(bytes4 => bool)) public isCapabilityPublic;

    mapping(address => mapping(bytes4 => bytes32)) public getRolesWithCapability;

    function doesUserHaveRole(address user, uint8 role) public view virtual returns (bool) {
        return (uint256(getUserRoles[user]) >> role) & 1 != 0;
    }

    function doesRoleHaveCapability(
        uint8 role,
        address target,
        bytes4 functionSig
    ) public view virtual returns (bool) {
        return (uint256(getRolesWithCapability[target][functionSig]) >> role) & 1 != 0;
    }

    /*//////////////////////////////////////////////////////////////
                           AUTHORIZATION LOGIC
    //////////////////////////////////////////////////////////////*/

    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) public view virtual override returns (bool) {
        return
            isCapabilityPublic[target][functionSig] ||
            bytes32(0) != getUserRoles[user] & getRolesWithCapability[target][functionSig];
    }

    /*//////////////////////////////////////////////////////////////
                   ROLE CAPABILITY CONFIGURATION LOGIC
    //////////////////////////////////////////////////////////////*/

    function setPublicCapability(
        address target,
        bytes4 functionSig,
        bool enabled
    ) public virtual requiresAuth {
        isCapabilityPublic[target][functionSig] = enabled;

        emit PublicCapabilityUpdated(target, functionSig, enabled);
    }

    function setRoleCapability(
        uint8 role,
        address target,
        bytes4 functionSig,
        bool enabled
    ) public virtual requiresAuth {
        if (enabled) {
            getRolesWithCapability[target][functionSig] |= bytes32(1 << role);
        } else {
            getRolesWithCapability[target][functionSig] &= ~bytes32(1 << role);
        }

        emit RoleCapabilityUpdated(role, target, functionSig, enabled);
    }

    /*//////////////////////////////////////////////////////////////
                       USER ROLE ASSIGNMENT LOGIC
    //////////////////////////////////////////////////////////////*/

    function setUserRole(
        address user,
        uint8 role,
        bool enabled
    ) public virtual requiresAuth {
        if (enabled) {
            getUserRoles[user] |= bytes32(1 << role);
        } else {
            getUserRoles[user] &= ~bytes32(1 << role);
        }

        emit UserRoleUpdated(user, role, enabled);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { RolesAuthority } from "../dependencies/solmate/RolesAuthority.sol";

import { ICyberEngineEvents } from "../interfaces/ICyberEngineEvents.sol";

import { DataTypes } from "../libraries/DataTypes.sol";

interface ICyberEngine is ICyberEngineEvents {
    /**
     * @notice Initializes the CyberEngine.
     *
     * @param _owner Owner to set for CyberEngine.
     * @param _rolesAuthority RolesAuthority address to manage access control
     */
    function initialize(address _owner, RolesAuthority _rolesAuthority)
        external;

    /**
     * @notice Allows the profile middleware.
     *
     * @param mw The middleware address.
     * @param allowed The allowance state.
     */
    function allowProfileMw(address mw, bool allowed) external;

    /**
     * @notice Allows the subscriber middleware.
     *
     * @param mw The middleware address.
     * @param allowed The allowance state.
     */
    function allowSubscribeMw(address mw, bool allowed) external;

    /**
     * @notice Allows the essence middleware.
     *
     * @param mw The middleware address.
     * @param allowed The allowance state.
     */
    function allowEssenceMw(address mw, bool allowed) external;

    /**
     * @notice Creates a new namespace.
     *
     * @param params The namespace params:
     *  name: The namespace name.
     *  symbol: The namespace symbol.
     *  owner: The namespace owner.
     * @return profileProxy The profile proxy address.
     * @return subBeacon The Subscribe beacon address.
     * @return essBeacon The Essence beacon address.
     */
    function createNamespace(DataTypes.CreateNamespaceParams calldata params)
        external
        returns (
            address profileProxy,
            address subBeacon,
            address essBeacon
        );

    /**
     * @notice Upgrade SubscribeNFT to new version by namespace.
     *
     * @param newImpl The new SubscribeNFT implementation address.
     * @param namespace The namespace to upgrade.
     */
    function upgradeSubscribeNFT(address newImpl, address namespace) external;

    /**
     * @notice Upgrade EssenceNFT to new version by namespace.
     *
     * @param newImpl The new EssenceNFT implementation address.
     * @param namespace The namespace to upgrade.
     */
    function upgradeEssenceNFT(address newImpl, address namespace) external;

    /**
     * @notice Upgrade ProfileNFT to new version.
     *
     * @param newImpl The new ProfileNFT implementation address.
     * @param namespace The namespace to upgrade.
     */
    function upgradeProfileNFT(address newImpl, address namespace) external;

    /**
     * @notice Sets the profile middleware.
     *
     * @param namespace The namespace address.
     * @param mw The middleware address.
     * @param data The middleware data.
     * @dev the profile middleware needs to be allowed first.
     */
    function setProfileMw(
        address namespace,
        address mw,
        bytes calldata data
    ) external;

    /**
     * @notice Gets the profile name by the namespace.
     *
     * @param namespace The namespace address.
     * @return string The profile name.
     */
    function getNameByNamespace(address namespace)
        external
        view
        returns (string memory);

    /**
     * @notice Gets the profile middleware by the namespace.
     *
     * @param namespace The namespace address.
     * @return address The middleware name.
     */
    function getProfileMwByNamespace(address namespace)
        external
        view
        returns (address);

    /**
     * @notice Checks if the essence middleware is allowed.
     *
     * @param mw The middleware address.
     * @return bool The allowance state.
     */
    function isEssenceMwAllowed(address mw) external view returns (bool);

    /**
     * @notice Checks if the subscriber middleware is allowed.
     *
     * @param mw The middleware address.
     * @return bool The allowance state.
     */
    function isSubscribeMwAllowed(address mw) external view returns (bool);

    /**
     * @notice Checks if the profile middleware is allowed.
     *
     * @param mw The middleware address.
     * @return bool The allowance state.
     */
    function isProfileMwAllowed(address mw) external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { DataTypes } from "../libraries/DataTypes.sol";

interface ICyberEngineEvents {
    /**
     * @notice Emiited when the engine is initialized
     *
     * @param owner The address of the engine owner.
     * @param rolesAuthority The address of the role authority.
     */
    event Initialize(address indexed owner, address indexed rolesAuthority);

    /**
     * @notice Emitted when a profile middleware has been allowed.
     *
     * @param mw The middleware address.
     * @param preAllowed The previously allow state.
     * @param newAllowed The newly set allow state.
     */
    event AllowProfileMw(
        address indexed mw,
        bool indexed preAllowed,
        bool indexed newAllowed
    );

    /**
     * @notice Emitted when a profile middleware has been set.
     *
     * @param namespace The namespace address.
     * @param mw The middleware address.
     * @param returnData The profile middeware data.
     */
    event SetProfileMw(address indexed namespace, address mw, bytes returnData);

    /**
     * @notice Emitted when a subscription middleware has been allowed.
     *
     * @param mw The middleware address.
     * @param preAllowed The previously allow state.
     * @param newAllowed The newly set allow state.
     */
    event AllowSubscribeMw(
        address indexed mw,
        bool indexed preAllowed,
        bool indexed newAllowed
    );

    /**
     * @notice Emitted when a essence middleware has been allowed.
     *
     * @param mw The middleware address.
     * @param preAllowed The previously allow state.
     * @param newAllowed The newly set allow state.
     */
    event AllowEssenceMw(
        address indexed mw,
        bool indexed preAllowed,
        bool indexed newAllowed
    );

    /**
     * @notice Emitted when a namespace has been created
     *
     * @param namespace The namespace address.
     * @param name The namespace name.
     * @param symbol The namespace symbol.
     */
    event CreateNamespace(
        address indexed namespace,
        string name,
        string symbol
    );
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

interface ISubscribeMiddleware {
    /**
     * @notice Sets subscribe related data for middleware.
     *
     * @param profileId The profile id that owns this middleware.
     * @param data Extra data to set.
     */
    function setSubscribeMwData(uint256 profileId, bytes calldata data)
        external
        returns (bytes memory);

    /**
     * @notice Process that runs before the subscribeNFT mint happens.
     *
     * @param profileId The profile Id.
     * @param subscriber The subscriber address.
     * @param subscribeNFT The subscribe nft address.
     * @param data Extra data to process.
     */
    function preProcess(
        uint256 profileId,
        address subscriber,
        address subscribeNFT,
        bytes calldata data
    ) external;

    /**
     * @notice Process that runs after the subscribeNFT mint happens.
     *
     * @param profileId The profile Id.
     * @param subscriber The subscriber address.
     * @param subscribeNFT The subscribe nft address.
     * @param data Extra data to process.
     */
    function postProcess(
        uint256 profileId,
        address subscriber,
        address subscribeNFT,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { ITreasuryEvents } from "../interfaces/ITreasuryEvents.sol";

interface ITreasury is ITreasuryEvents {
    /**
     * @notice Gets the treasury address.
     *
     * @return address The treasury address.
     */
    function getTreasuryAddress() external view returns (address);

    /**
     * @notice Gets the treasury fee. The percentage is calculated as: treasuryFee/_MAX_BPS.
     *
     * @return address The treasury fee.
     */
    function getTreasuryFee() external view returns (uint256);

    /**
     * @notice Checks if the currency is allowed.
     *
     * @return bool The status of allowance for the currency.
     */
    function isCurrencyAllowed(address currency) external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { DataTypes } from "../libraries/DataTypes.sol";

interface ITreasuryEvents {
    /**
     * @notice Emitted when a currency has been allowed.
     *
     * @param currency The ERC20 token contract address.
     * @param preAllowed The previously allow state.
     * @param newAllowed The newly set allow state.
     */
    event AllowCurrency(
        address indexed currency,
        bool indexed preAllowed,
        bool indexed newAllowed
    );

    /**
     * @notice Emitted when a new treasuryAddress has been set.
     *
     * @param preTreasuryAddress The previous treasuryAddress.
     * @param treasuryAddress The new treasuryAddress.
     */
    event SetTreasuryAddress(
        address indexed preTreasuryAddress,
        address indexed treasuryAddress
    );

    /**
     * @notice Emitted when a new treasuryFee has been set.
     *
     * @param preTreasuryFee The previous treasuryFee.
     * @param treasuryFee The new treasuryFee.
     */
    event SetTreasuryFee(
        uint16 indexed preTreasuryFee,
        uint16 indexed treasuryFee
    );
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

library Constants {
    // Access Control for CyberEngine
    uint8 internal constant _ENGINE_GOV_ROLE = 1;
    bytes4 internal constant _AUTHORIZE_UPGRADE =
        bytes4(keccak256(bytes("_authorizeUpgrade(address)")));

    // EIP712 TypeHash
    bytes32 internal constant _PERMIT_TYPEHASH =
        keccak256(
            "permit(address spender,uint256 tokenId,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _CREATE_PROFILE_TYPEHASH =
        keccak256(
            "createProfile(address to,string handle,string avatar,string metadata,address operator,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _CREATE_PROFILE_ORACLE_TYPEHASH =
        keccak256(
            "createProfileOracle(address to,string handle,string avatar,string metadata,address operator,uint256 nonce,uint256 deadline,uint80 roundId)"
        );
    bytes32 internal constant _SUBSCRIBE_TYPEHASH =
        keccak256(
            "subscribeWithSig(uint256[] profileIds,bytes[] preDatas,bytes[] postDatas,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _COLLECT_TYPEHASH =
        keccak256(
            "collectWithSig(address collector,uint256 profileId,uint256 essenceId,bytes data,bytes postDatas,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _REGISTER_ESSENCE_TYPEHASH =
        keccak256(
            "registerEssenceWithSig(uint256 profileId,string name,string symbol,string essenceTokenURI,address essenceMw,bool transferable,bytes initData,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _SET_METADATA_TYPEHASH =
        keccak256(
            "setMetadataWithSig(uint256 profileId,string metadata,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _SET_OPERATOR_APPROVAL_TYPEHASH =
        keccak256(
            "setOperatorApprovalWithSig(uint256 profileId,address operator,bool approved,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _SET_SUBSCRIBE_DATA_TYPEHASH =
        keccak256(
            "setSubscribeDataWithSig(uint256 profileId,string tokenURI,address mw,bytes data,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _SET_ESSENCE_DATA_TYPEHASH =
        keccak256(
            "setEssenceDataWithSig(uint256 profileId,uint256 essenceId,string tokenURI,address mw,bytes data,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _SET_AVATAR_TYPEHASH =
        keccak256(
            "setAvatarWithSig(uint256 profileId,string avatar,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _SET_PRIMARY_PROFILE_TYPEHASH =
        keccak256(
            "setPrimaryProfileWithSig(uint256 profileId,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _CLAIM_BOX_TYPEHASH =
        keccak256("claimBox(address to,uint256 nonce,uint256 deadline)");
    bytes32 internal constant _CLAIM_GRAND_TYPEHASH =
        keccak256("claimGrand(address to,uint256 nonce,uint256 deadline)");
    bytes32 internal constant _CLAIM_TYPEHASH =
        keccak256(
            "claim(string profileId,address to,address currency,uint256 amount,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _CLAIM721_TYPEHASH =
        keccak256(
            "claim(string profileId,address to,address currency,uint256 tokenId,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _CLAIM1155_TYPEHASH =
        keccak256(
            "claim(string profileId,address to,address currency,uint256 tokenId,uint256 amount,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _CLAIM_PROFILE_TYPEHASH =
        keccak256(
            "claimProfile(address to,string handle,string avatar,string metadata,address operator,uint256 nonce,uint256 deadline)"
        );

    // Parameters
    uint8 internal constant _MAX_HANDLE_LENGTH = 20;
    uint8 internal constant _MAX_NAME_LENGTH = 20;
    uint8 internal constant _MAX_SYMBOL_LENGTH = 20;
    uint16 internal constant _MAX_URI_LENGTH = 2000;
    uint16 internal constant _MAX_BPS = 10000;

    // Access Control for UpgradeableBeacon
    bytes4 internal constant _BEACON_UPGRADE_TO =
        bytes4(keccak256(bytes("upgradeTo(address)")));

    // Subscribe NFT
    string internal constant _SUBSCRIBE_NFT_NAME_SUFFIX = "_subscriber";
    string internal constant _SUBSCRIBE_NFT_SYMBOL_SUFFIX = "_SUB";
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

library DataTypes {
    struct EIP712Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
    }

    struct CreateProfileParams {
        address to;
        string handle;
        string avatar;
        string metadata;
        address operator;
    }

    struct CreateProfilePostProcessData {
        uint256 tokenID;
        bytes32 handleHash;
        address profileMw;
    }

    struct CreateNamespaceParams {
        string name;
        string symbol;
        address owner;
        ComputedAddresses addrs;
    }

    struct RegisterEssenceParams {
        uint256 profileId;
        string name;
        string symbol;
        string essenceTokenURI;
        address essenceMw;
        bool transferable;
        bool deployAtRegister;
    }

    struct SubscribeParams {
        uint256[] profileIds;
    }

    struct CollectParams {
        address collector;
        uint256 profileId;
        uint256 essenceId;
    }

    struct RegisterEssenceData {
        uint256 profileId;
        string name;
        string symbol;
        string essenceTokenURI;
        bytes initData;
        address essenceMw;
        bool transferable;
        bool deployAtRegister;
        address essBeacon;
    }

    struct SubscribeData {
        address sender;
        uint256[] profileIds;
        bytes[] preDatas;
        bytes[] postDatas;
        address subBeacon;
        address engine;
    }

    struct CollectData {
        address collector;
        uint256 profileId;
        uint256 essenceId;
        bytes preData;
        bytes postData;
        address essBeacon;
        address engine;
    }

    struct ProfileStruct {
        string handle;
        string avatar;
        uint256 essenceCount;
    }

    struct SubscribeStruct {
        string tokenURI;
        address subscribeNFT;
        address subscribeMw;
    }

    struct EssenceStruct {
        address essenceNFT;
        address essenceMw;
        string name;
        string symbol;
        string tokenURI;
        bool transferable;
    }

    struct NamespaceStruct {
        address profileMw;
        string name;
    }

    struct ConstructTokenURIParams {
        uint256 tokenId;
        string handle;
        uint256 subscribers;
    }

    struct ComputedAddresses {
        address profileProxy;
        address profileFactory;
        address subscribeFactory;
        address essenceFactory;
    }

    struct ProfileDeployParameters {
        address engine;
        address subBeacon;
        address essenceBeacon;
    }

    struct SubscribeDeployParameters {
        address profileProxy;
    }

    struct EssenceDeployParameters {
        address profileProxy;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { ITreasury } from "../../interfaces/ITreasury.sol";

abstract contract FeeMw {
    /*//////////////////////////////////////////////////////////////
                              STATES
    //////////////////////////////////////////////////////////////*/
    address public immutable TREASURY; // solhint-disable-line

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address treasury) {
        require(treasury != address(0), "ZERO_TREASURY_ADDRESS");
        TREASURY = treasury;
    }

    /*//////////////////////////////////////////////////////////////
                              INTERNAL
    //////////////////////////////////////////////////////////////*/

    function _currencyAllowed(address currency) internal view returns (bool) {
        return ITreasury(TREASURY).isCurrencyAllowed(currency);
    }

    function _treasuryAddress() internal view returns (address) {
        return ITreasury(TREASURY).getTreasuryAddress();
    }

    function _treasuryFee() internal view returns (uint256) {
        return ITreasury(TREASURY).getTreasuryFee();
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { IERC20 } from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import { ERC721 } from "../../dependencies/solmate/ERC721.sol";
import { SafeERC20 } from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

import { ISubscribeMiddleware } from "../../interfaces/ISubscribeMiddleware.sol";
import { ICyberEngine } from "../../interfaces/ICyberEngine.sol";

import { Constants } from "../../libraries/Constants.sol";

import { FeeMw } from "../base/FeeMw.sol";

/**
 * @title  Subscribe Paid Middleware
 * @author CyberConnect
 * @notice This contract is a middleware to only allow users to subscribe when they pay a certain fee to the profile owner.
 */
contract SubscribePaidMw is ISubscribeMiddleware, FeeMw {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                              MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyValidNamespace() {
        require(_namespace == msg.sender, "ONLY_VALID_NAMESPACE");
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                EVENT
    //////////////////////////////////////////////////////////////*/

    event SubscribePaidMwSet(
        address indexed namespace,
        uint256 indexed profileId,
        uint256 indexed amount,
        address recipient,
        address currency,
        bool nftRequired,
        address nftAddress
    );

    /*//////////////////////////////////////////////////////////////
                               STATES
    //////////////////////////////////////////////////////////////*/

    struct PaidSubscribeData {
        uint256 amount;
        address recipient;
        address currency;
        bool nftRequired;
        address nftAddress;
    }

    mapping(uint256 => PaidSubscribeData) internal _paidSubscribeData;
    address internal _namespace;

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address treasury, address namespace) FeeMw(treasury) {
        _namespace = namespace;
    }

    /*//////////////////////////////////////////////////////////////
                              EXTERNAL
    //////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc ISubscribeMiddleware
     * @notice Stores the parameters for setting up the paid subscribe middleware, checks if the amount, recipient, and
     * currency is valid and approved, and whether a special NFT is needed to subscribe
     */
    function setSubscribeMwData(uint256 profileId, bytes calldata data)
        external
        override
        onlyValidNamespace
        returns (bytes memory)
    {
        (
            uint256 amount,
            address recipient,
            address currency,
            bool nftRequired,
            address nftAddress
        ) = abi.decode(data, (uint256, address, address, bool, address));

        require(amount != 0, "INVALID_AMOUNT");
        require(recipient != address(0), "INVALID_ADDRESS");
        require(_currencyAllowed(currency), "CURRENCY_NOT_ALLOWED");

        _paidSubscribeData[profileId].amount = amount;
        _paidSubscribeData[profileId].recipient = recipient;
        _paidSubscribeData[profileId].currency = currency;
        _paidSubscribeData[profileId].nftRequired = nftRequired;
        _paidSubscribeData[profileId].nftAddress = nftAddress;

        emit SubscribePaidMwSet(
            _namespace,
            profileId,
            amount,
            recipient,
            currency,
            nftRequired,
            nftAddress
        );
        return new bytes(0);
    }

    /**
     * @inheritdoc ISubscribeMiddleware
     * @notice Checks if the subscriber has the required NFT, then transfers the amount required from the subscriber to the treasury
     */
    function preProcess(
        uint256 profileId,
        address subscriber,
        address,
        bytes calldata
    ) external override onlyValidNamespace {
        address currency = _paidSubscribeData[profileId].currency;
        uint256 amount = _paidSubscribeData[profileId].amount;
        uint256 treasuryCollected = (amount * _treasuryFee()) /
            Constants._MAX_BPS;
        uint256 actualPaid = amount - treasuryCollected;

        if (_paidSubscribeData[profileId].nftRequired) {
            require(
                ERC721(_paidSubscribeData[profileId].nftAddress).balanceOf(
                    subscriber
                ) > 0,
                "NO_REQUIRED_NFT"
            );
        }

        IERC20(currency).safeTransferFrom(
            subscriber,
            _paidSubscribeData[profileId].recipient,
            actualPaid
        );

        if (treasuryCollected > 0) {
            IERC20(currency).safeTransferFrom(
                subscriber,
                _treasuryAddress(),
                treasuryCollected
            );
        }
    }

    /// @inheritdoc ISubscribeMiddleware
    function postProcess(
        uint256,
        address,
        address,
        bytes calldata
    ) external {
        // do nothing
    }
}