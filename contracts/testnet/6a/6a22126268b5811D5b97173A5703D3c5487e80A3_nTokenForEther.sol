/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// OpenZeppelin Contracts v4.4.1 (token/ERC777/IERC777.sol)

/**
 * @dev Interface of the ERC777Token standard as defined in the EIP.
 *
 * This contract uses the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 registry standard] to let
 * token holders and recipients react to token movements by using setting implementers
 * for the associated interfaces in said registry. See {IERC1820Registry} and
 * {ERC1820Implementer}.
 */
interface IERC777 {
    /**
     * @dev Emitted when `amount` tokens are created by `operator` and assigned to `to`.
     *
     * Note that some additional user `data` and `operatorData` can be logged in the event.
     */
    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    /**
     * @dev Emitted when `operator` destroys `amount` tokens from `account`.
     *
     * Note that some additional user `data` and `operatorData` can be logged in the event.
     */
    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    /**
     * @dev Emitted when `operator` is made operator for `tokenHolder`
     */
    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    /**
     * @dev Emitted when `operator` is revoked its operator status for `tokenHolder`
     */
    event RevokedOperator(address indexed operator, address indexed tokenHolder);

    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the smallest part of the token that is not divisible. This
     * means all token operations (creation, movement and destruction) must have
     * amounts that are a multiple of this number.
     *
     * For most token contracts, this value will equal 1.
     */
    function granularity() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by an account (`owner`).
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * If send or receive hooks are registered for the caller and `recipient`,
     * the corresponding functions will be called with `data` and empty
     * `operatorData`. See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits a {Sent} event.
     *
     * Requirements
     *
     * - the caller must have at least `amount` tokens.
     * - `recipient` cannot be the zero address.
     * - if `recipient` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function send(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev Destroys `amount` tokens from the caller's account, reducing the
     * total supply.
     *
     * If a send hook is registered for the caller, the corresponding function
     * will be called with `data` and empty `operatorData`. See {IERC777Sender}.
     *
     * Emits a {Burned} event.
     *
     * Requirements
     *
     * - the caller must have at least `amount` tokens.
     */
    function burn(uint256 amount, bytes calldata data) external;

    /**
     * @dev Returns true if an account is an operator of `tokenHolder`.
     * Operators can send and burn tokens on behalf of their owners. All
     * accounts are their own operator.
     *
     * See {operatorSend} and {operatorBurn}.
     */
    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);

    /**
     * @dev Make an account an operator of the caller.
     *
     * See {isOperatorFor}.
     *
     * Emits an {AuthorizedOperator} event.
     *
     * Requirements
     *
     * - `operator` cannot be calling address.
     */
    function authorizeOperator(address operator) external;

    /**
     * @dev Revoke an account's operator status for the caller.
     *
     * See {isOperatorFor} and {defaultOperators}.
     *
     * Emits a {RevokedOperator} event.
     *
     * Requirements
     *
     * - `operator` cannot be calling address.
     */
    function revokeOperator(address operator) external;

    /**
     * @dev Returns the list of default operators. These accounts are operators
     * for all token holders, even if {authorizeOperator} was never called on
     * them.
     *
     * This list is immutable, but individual holders may revoke these via
     * {revokeOperator}, in which case {isOperatorFor} will return false.
     */
    function defaultOperators() external view returns (address[] memory);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient`. The caller must
     * be an operator of `sender`.
     *
     * If send or receive hooks are registered for `sender` and `recipient`,
     * the corresponding functions will be called with `data` and
     * `operatorData`. See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits a {Sent} event.
     *
     * Requirements
     *
     * - `sender` cannot be the zero address.
     * - `sender` must have at least `amount` tokens.
     * - the caller must be an operator for `sender`.
     * - `recipient` cannot be the zero address.
     * - if `recipient` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the total supply.
     * The caller must be an operator of `account`.
     *
     * If a send hook is registered for `account`, the corresponding function
     * will be called with `data` and `operatorData`. See {IERC777Sender}.
     *
     * Emits a {Burned} event.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     * - the caller must be an operator for `account`.
     */
    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );
}

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC777/ERC777.sol)

// OpenZeppelin Contracts v4.4.1 (token/ERC777/IERC777Recipient.sol)

/**
 * @dev Interface of the ERC777TokensRecipient standard as defined in the EIP.
 *
 * Accounts can be notified of {IERC777} tokens being sent to them by having a
 * contract implement this interface (contract holders can be their own
 * implementer) and registering it on the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 global registry].
 *
 * See {IERC1820Registry} and {ERC1820Implementer}.
 */
interface IERC777Recipient {
    /**
     * @dev Called by an {IERC777} token contract whenever tokens are being
     * moved or created into a registered account (`to`). The type of operation
     * is conveyed by `from` being the zero address or not.
     *
     * This call occurs _after_ the token contract's state is updated, so
     * {IERC777-balanceOf}, etc., can be used to query the post-operation state.
     *
     * This function may revert to prevent the operation from being executed.
     */
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}

// OpenZeppelin Contracts v4.4.1 (token/ERC777/IERC777Sender.sol)

/**
 * @dev Interface of the ERC777TokensSender standard as defined in the EIP.
 *
 * {IERC777} Token holders can be notified of operations performed on their
 * tokens by having a contract implement this interface (contract holders can be
 * their own implementer) and registering it on the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 global registry].
 *
 * See {IERC1820Registry} and {ERC1820Implementer}.
 */
interface IERC777Sender {
    /**
     * @dev Called by an {IERC777} token contract whenever a registered holder's
     * (`from`) tokens are about to be moved or destroyed. The type of operation
     * is conveyed by `to` being the zero address or not.
     *
     * This call occurs _before_ the token contract's state is updated, so
     * {IERC777-balanceOf}, etc., can be used to query the pre-operation state.
     *
     * This function may revert to prevent the operation from being executed.
     */
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC1820Registry.sol)

/**
 * @dev Interface of the global ERC1820 Registry, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1820[EIP]. Accounts may register
 * implementers for interfaces in this registry, as well as query support.
 *
 * Implementers may be shared by multiple accounts, and can also implement more
 * than a single interface for each account. Contracts can implement interfaces
 * for themselves, but externally-owned accounts (EOA) must delegate this to a
 * contract.
 *
 * {IERC165} interfaces can also be queried via the registry.
 *
 * For an in-depth explanation and source code analysis, see the EIP text.
 */
interface IERC1820Registry {
    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);

    /**
     * @dev Sets `newManager` as the manager for `account`. A manager of an
     * account is able to set interface implementers for it.
     *
     * By default, each account is its own manager. Passing a value of `0x0` in
     * `newManager` will reset the manager to this initial state.
     *
     * Emits a {ManagerChanged} event.
     *
     * Requirements:
     *
     * - the caller must be the current manager for `account`.
     */
    function setManager(address account, address newManager) external;

    /**
     * @dev Returns the manager for `account`.
     *
     * See {setManager}.
     */
    function getManager(address account) external view returns (address);

    /**
     * @dev Sets the `implementer` contract as ``account``'s implementer for
     * `interfaceHash`.
     *
     * `account` being the zero address is an alias for the caller's address.
     * The zero address can also be used in `implementer` to remove an old one.
     *
     * See {interfaceHash} to learn how these are created.
     *
     * Emits an {InterfaceImplementerSet} event.
     *
     * Requirements:
     *
     * - the caller must be the current manager for `account`.
     * - `interfaceHash` must not be an {IERC165} interface id (i.e. it must not
     * end in 28 zeroes).
     * - `implementer` must implement {IERC1820Implementer} and return true when
     * queried for support, unless `implementer` is the caller. See
     * {IERC1820Implementer-canImplementInterfaceForAddress}.
     */
    function setInterfaceImplementer(
        address account,
        bytes32 _interfaceHash,
        address implementer
    ) external;

    /**
     * @dev Returns the implementer of `interfaceHash` for `account`. If no such
     * implementer is registered, returns the zero address.
     *
     * If `interfaceHash` is an {IERC165} interface id (i.e. it ends with 28
     * zeroes), `account` will be queried for support of it.
     *
     * `account` being the zero address is an alias for the caller's address.
     */
    function getInterfaceImplementer(address account, bytes32 _interfaceHash) external view returns (address);

    /**
     * @dev Returns the interface hash for an `interfaceName`, as defined in the
     * corresponding
     * https://eips.ethereum.org/EIPS/eip-1820#interface-name[section of the EIP].
     */
    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);

    /**
     * @notice Updates the cache with whether the contract implements an ERC165 interface or not.
     * @param account Address of the contract for which to update the cache.
     * @param interfaceId ERC165 interface for which to update the cache.
     */
    function updateERC165Cache(address account, bytes4 interfaceId) external;

    /**
     * @notice Checks whether a contract implements an ERC165 interface or not.
     * If the result is not cached a direct lookup on the contract address is performed.
     * If the result is not cached or the cached value is out-of-date, the cache MUST be updated manually by calling
     * {updateERC165Cache} with the contract address.
     * @param account Address of the contract to check.
     * @param interfaceId ERC165 interface to check.
     * @return True if `account` implements `interfaceId`, false otherwise.
     */
    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);

    /**
     * @notice Checks whether a contract implements an ERC165 interface or not without using nor updating the cache.
     * @param account Address of the contract to check.
     * @param interfaceId ERC165 interface to check.
     * @return True if `account` implements `interfaceId`, false otherwise.
     */
    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev Implementation of the {IERC777} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * Support for ERC20 is included in this contract, as specified by the EIP: both
 * the ERC777 and ERC20 interfaces can be safely used when interacting with it.
 * Both {IERC777-Sent} and {IERC20-Transfer} events are emitted on token
 * movements.
 *
 * Additionally, the {IERC777-granularity} value is hard-coded to `1`, meaning that there
 * are no special restrictions in the amount of tokens that created, moved, or
 * destroyed. This makes integration with ERC20 applications seamless.
 */
contract ERC777 is Context, IERC777, IERC20 {
    using Address for address;

    IERC1820Registry internal constant _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    mapping(address => uint256) private _balances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    bytes32 private constant _TOKENS_SENDER_INTERFACE_HASH = keccak256("ERC777TokensSender");
    bytes32 private constant _TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");

    // This isn't ever read from - it's only used to respond to the defaultOperators query.
    address[] private _defaultOperatorsArray;

    // Immutable, but accounts may revoke them (tracked in __revokedDefaultOperators).
    mapping(address => bool) private _defaultOperators;

    // For each account, a mapping of its operators and revoked default operators.
    mapping(address => mapping(address => bool)) private _operators;
    mapping(address => mapping(address => bool)) private _revokedDefaultOperators;

    // ERC20-allowances
    mapping(address => mapping(address => uint256)) private _allowances;

    /**
     * @dev `defaultOperators` may be an empty array.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        address[] memory defaultOperators_
    ) {
        _name = name_;
        _symbol = symbol_;

        _defaultOperatorsArray = defaultOperators_;
        for (uint256 i = 0; i < defaultOperators_.length; i++) {
            _defaultOperators[defaultOperators_[i]] = true;
        }

        // register interfaces
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777Token"), address(this));
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC20Token"), address(this));
    }

    /**
     * @dev See {IERC777-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC777-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {ERC20-decimals}.
     *
     * Always returns 18, as per the
     * [ERC777 EIP](https://eips.ethereum.org/EIPS/eip-777#backward-compatibility).
     */
    function decimals() public pure virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC777-granularity}.
     *
     * This implementation always returns `1`.
     */
    function granularity() public view virtual override returns (uint256) {
        return 1;
    }

    /**
     * @dev See {IERC777-totalSupply}.
     */
    function totalSupply() public view virtual override(IERC20, IERC777) returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the amount of tokens owned by an account (`tokenHolder`).
     */
    function balanceOf(address tokenHolder) public view virtual override(IERC20, IERC777) returns (uint256) {
        return _balances[tokenHolder];
    }

    /**
     * @dev See {IERC777-send}.
     *
     * Also emits a {IERC20-Transfer} event for ERC20 compatibility.
     */
    function send(
        address recipient,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        _send(_msgSender(), recipient, amount, data, "", true);
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Unlike `send`, `recipient` is _not_ required to implement the {IERC777Recipient}
     * interface if it is a contract.
     *
     * Also emits a {Sent} event.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _send(_msgSender(), recipient, amount, "", "", false);
        return true;
    }

    /**
     * @dev See {IERC777-burn}.
     *
     * Also emits a {IERC20-Transfer} event for ERC20 compatibility.
     */
    function burn(uint256 amount, bytes memory data) public virtual override {
        _burn(_msgSender(), amount, data, "");
    }

    /**
     * @dev See {IERC777-isOperatorFor}.
     */
    function isOperatorFor(address operator, address tokenHolder) public view virtual override returns (bool) {
        return
            operator == tokenHolder ||
            (_defaultOperators[operator] && !_revokedDefaultOperators[tokenHolder][operator]) ||
            _operators[tokenHolder][operator];
    }

    function isDefaultOperator(address operator) public view virtual returns (bool) {
        return _defaultOperators[operator];
    }

    /**
     * @dev See {IERC777-authorizeOperator}.
     */
    function authorizeOperator(address operator) public virtual override {
        require(_msgSender() != operator, "ERC777: authorizing self as operator");

        if (_defaultOperators[operator]) {
            delete _revokedDefaultOperators[_msgSender()][operator];
        } else {
            _operators[_msgSender()][operator] = true;
        }

        emit AuthorizedOperator(operator, _msgSender());
    }

    /**
     * @dev See {IERC777-revokeOperator}.
     */
    function revokeOperator(address operator) public virtual override {
        require(operator != _msgSender(), "ERC777: revoking self as operator");

        if (_defaultOperators[operator]) {
            _revokedDefaultOperators[_msgSender()][operator] = true;
        } else {
            delete _operators[_msgSender()][operator];
        }

        emit RevokedOperator(operator, _msgSender());
    }

    /**
     * @dev See {IERC777-defaultOperators}.
     */
    function defaultOperators() public view virtual override returns (address[] memory) {
        return _defaultOperatorsArray;
    }

    /**
     * @dev See {IERC777-operatorSend}.
     *
     * Emits {Sent} and {IERC20-Transfer} events.
     */
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) public virtual override {
        require(isOperatorFor(_msgSender(), sender), "ERC777: caller is not an operator for holder");
        _send(sender, recipient, amount, data, operatorData, true);
    }

    /**
     * @dev See {IERC777-operatorBurn}.
     *
     * Emits {Burned} and {IERC20-Transfer} events.
     */
    function operatorBurn(
        address account,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) public virtual override {
        require(isOperatorFor(_msgSender(), account), "ERC777: caller is not an operator for holder");
        _burn(account, amount, data, operatorData);
    }

    function operatorMint(
        address account,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) public virtual {
        require(isDefaultOperator(_msgSender()), "ERC777: caller is not an default operator");
        _mint(account, amount, data, operatorData);
    }

    /**
     * @dev See {IERC20-allowance}.
     *
     * Note that operator and allowance concepts are orthogonal: operators may
     * not have allowance, and accounts with allowance may not be operators
     * themselves.
     */
    function allowance(address holder, address spender) public view virtual override returns (uint256) {
        return _allowances[holder][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Note that accounts cannot have allowance issued by their operators.
     */
    function approve(address spender, uint256 value) public virtual override returns (bool) {
        address holder = _msgSender();
        _approve(holder, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Note that operator and allowance concepts are orthogonal: operators cannot
     * call `transferFrom` (unless they have allowance), and accounts with
     * allowance cannot call `operatorSend` (unless they are operators).
     *
     * Emits {Sent}, {IERC20-Transfer} and {IERC20-Approval} events.
     */
    function transferFrom(
        address holder,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(holder, spender, amount);
        _send(holder, recipient, amount, "", "", false);
        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * If a send hook is registered for `account`, the corresponding function
     * will be called with `operator`, `data` and `operatorData`.
     *
     * See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits {Minted} and {IERC20-Transfer} events.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - if `account` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */

    function _mint(
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) internal virtual {
        _mint(account, amount, userData, operatorData, true);
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * If `requireReceptionAck` is set to true, and if a send hook is
     * registered for `account`, the corresponding function will be called with
     * `operator`, `data` and `operatorData`.
     *
     * See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits {Minted} and {IERC20-Transfer} events.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - if `account` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function _mint(
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) internal virtual {
        require(account != address(0), "ERC777: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, amount);

        // Update state variables
        _totalSupply += amount;
        _balances[account] += amount;

        _callTokensReceived(operator, address(0), account, amount, userData, operatorData, requireReceptionAck);

        emit Minted(operator, account, amount, userData, operatorData);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Send tokens
     * @param from address token holder address
     * @param to address recipient address
     * @param amount uint256 amount of tokens to transfer
     * @param userData bytes extra information provided by the token holder (if any)
     * @param operatorData bytes extra information provided by the operator (if any)
     * @param requireReceptionAck if true, contract recipients are required to implement ERC777TokensRecipient
     */
    function _send(
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) internal virtual {
        require(from != address(0), "ERC777: transfer from the zero address");
        require(to != address(0), "ERC777: transfer to the zero address");

        address operator = _msgSender();

        _callTokensToSend(operator, from, to, amount, userData, operatorData);

        _move(operator, from, to, amount, userData, operatorData);

        _callTokensReceived(operator, from, to, amount, userData, operatorData, requireReceptionAck);
    }

    /**
     * @dev Burn tokens
     * @param from address token holder address
     * @param amount uint256 amount of tokens to burn
     * @param data bytes extra information provided by the token holder
     * @param operatorData bytes extra information provided by the operator (if any)
     */

    function _burn(
        address from,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) internal virtual {
        require(from != address(0), "ERC777: burn from the zero address");

        address operator = _msgSender();

        _callTokensToSend(operator, from, address(0), amount, data, operatorData);

        _beforeTokenTransfer(operator, from, address(0), amount);

        // Update state variables
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC777: burn amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _totalSupply -= amount;

        emit Burned(operator, from, amount, data, operatorData);
        emit Transfer(from, address(0), amount);
    }

    function _move(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) private {
        _beforeTokenTransfer(operator, from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC777: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Sent(operator, from, to, amount, userData, operatorData);
        emit Transfer(from, to, amount);
    }

    /**
     * @dev See {ERC20-_approve}.
     *
     * Note that accounts cannot have allowance issued by their operators.
     */
    function _approve(
        address holder,
        address spender,
        uint256 value
    ) internal virtual {
        require(holder != address(0), "ERC777: approve from the zero address");
        require(spender != address(0), "ERC777: approve to the zero address");

        _allowances[holder][spender] = value;
        emit Approval(holder, spender, value);
    }

    /**
     * @dev Call from.tokensToSend() if the interface is registered
     * @param operator address operator requesting the transfer
     * @param from address token holder address
     * @param to address recipient address
     * @param amount uint256 amount of tokens to transfer
     * @param userData bytes extra information provided by the token holder (if any)
     * @param operatorData bytes extra information provided by the operator (if any)
     */
    function _callTokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) private {
        address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(from, _TOKENS_SENDER_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Sender(implementer).tokensToSend(operator, from, to, amount, userData, operatorData);
        }
    }

    /**
     * @dev Call to.tokensReceived() if the interface is registered. Reverts if the recipient is a contract but
     * tokensReceived() was not registered for the recipient
     * @param operator address operator requesting the transfer
     * @param from address token holder address
     * @param to address recipient address
     * @param amount uint256 amount of tokens to transfer
     * @param userData bytes extra information provided by the token holder (if any)
     * @param operatorData bytes extra information provided by the operator (if any)
     * @param requireReceptionAck if true, contract recipients are required to implement ERC777TokensRecipient
     */
    function _callTokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) private {
        address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(to, _TOKENS_RECIPIENT_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Recipient(implementer).tokensReceived(operator, from, to, amount, userData, operatorData);
        } else if (requireReceptionAck) {
            require(!to.isContract(), "ERC777: token recipient contract has no implementer for ERC777TokensRecipient");
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC777: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes
     * calls to {send}, {transfer}, {operatorSend}, minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-ERC20Permit.sol)

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

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

// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC20Permit is ERC777, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    /**
     * @dev In previous versions `_PERMIT_TYPEHASH` was declared as `immutable`.
     * However, to ensure consistency with the upgradeable transpiler, we will continue
     * to reserve a slot.
     * @custom:oz-renamed-from _PERMIT_TYPEHASH
     */
    // solhint-disable-next-line var-name-mixedcase
    bytes32 private _PERMIT_TYPEHASH_DEPRECATED_SLOT;

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {}

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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

interface IBridged {
    /*
     * @note amount is in wad with 18 deciamls
     */
    function bridgeMint(address account, uint256 amount) external;

    function bridgeBurn(address account, uint256 amount) external;
}

interface InToken {
    function getUnderlying() external view returns (address);

    function getPriceId() external view returns (uint32);

    function getTotalReserves() external view returns (uint256);

    function getCash() external view returns (uint256);

    function getTotalBorrows() external view returns (uint256);

    function getReserveFactor() external view returns (uint256);

    function balanceOfUnderlying(address owner) external view returns (uint256);

    function redeemByStrategy(
        uint256 redeemTokensIn,
        uint256 redeemAmountIn,
        address redeemer,
        bytes memory data
    ) external;

    function borrowByStrategy(
        uint256 borrowAmount,
        address borrower,
        bytes memory data
    ) external;

    function borrowBalance(address account) external view returns (uint256);

    function burnDebtFor(address sender, uint256 amount) external;

    function bridgeDeposits(address account) external view returns (uint256);

    function bridgeBorrows(address account) external view returns (uint256);
}

interface IInterestRateModel {
    /**
     * @notice Calculates the current borrow interest rate per block
     * @param cash The total amount of cash the market has
     * @param borrows The total amount of borrows the market has outstanding
     * @param reserves The total amount of reserves the market has
     * @return The borrow rate per block (as a percentage, and scaled by 1e18)
     */
    function getBorrowRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) external view returns (uint256);

    /**
     * @notice Calculates the current supply interest rate per block
     * @param cash The total amount of cash the market has
     * @param borrows The total amount of borrows the market has outstanding
     * @param reserves The total amount of reserves the market has
     * @param reserveFactorMantissa The current reserve factor the market has
     * @return The supply rate per block (as a percentage, and scaled by 1e18)
     */
    function getSupplyRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveFactorMantissa
    ) external view returns (uint256);
}

interface INaviOracle {
    function isBridged(uint32 id) external view returns (bool);

    function hasBridgedData(uint32 id) external view returns (bool);

    function isnToken(uint32 id) external view returns (bool);

    function hasPriceFeed(uint32 id) external view returns (bool);

    function tokenAddress(uint32 id) external view returns (address);

    function daoAddress(uint32 id) external view returns (address);

    function price(uint32 id) external view returns (uint256);

    function tokenExtra(uint32 id) external view returns (string memory);

    function maxId() external view returns (uint32);

    function idByTokenAddress(address token) external view returns (uint32);
}

interface InTokenForEther {
    function compensateFee(
        address from,
        address to,
        uint256 amount
    ) external;
}

interface IStrategy {
    function borrowCallback(bytes memory data) external;

    function redeemCallback(bytes memory data, uint256 redeemAmount) external;

    function farmWithdrawCallback(
        bytes memory data,
        uint256 amount0,
        uint256 amount1
    ) external;

    //NFT, etc.
    function otherWithdrawCallback(
        bytes memory callbackData,
        bytes memory withdrawData
    ) external;
}

interface IMarginGroup {
    //amount in USD
    function hasEnoughMargin(address from, uint256 amount)
        external
        view
        returns (bool);

    function balanceUpdated(uint8, address from) external;
}

/**
 * @dev Just a common part of all contracts implementing IMarginable.
 **/
abstract contract NaviMarginable {
    IMarginGroup internal _parent;

    function getParent() external view returns (address) {
        return address(_parent);
    }

    modifier onlyParent() {
        if (address(_parent) != msg.sender) return;
        _;
    }
    uint256 internal _LTV;

    function getLTV() external view returns (uint256) {
        return _LTV;
    }

    constructor(uint256 ltv, address parent) {
        _LTV = ltv;
        _parent = IMarginGroup(parent);
    }

    function setParent(address controllerContract) external onlyParent {
        _parent = IMarginGroup(controllerContract);
    }

    event LTVUpdated(uint256 oldValue, uint256 newValue);
}

/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/**
 * @title Fixed point WAD math contract (minimized version)
 * @notice Implements the fixed point arithmetic operations for WAD numbers (18 decimals)
 * @dev Wad functions have a [w] prefix: wmul, wdiv.
 * @author https://github.com/dapphub/ds-math
 **/

contract DSMathMin {
    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;

    //rounds to zero if x*y < WAD / 2
    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = ((x * y) + WAD / 2) / WAD;
    }

    //rounds to zero if x*y < WAD / 2
    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = ((x * WAD) + y / 2) / y;
    }
}

interface IFlashLoanBorrower {
    function execute(uint256 amountOwed) external;
}

/**
 * @title A contract for storing a token, redeeming, borrowing and repaying a loan
 * @notice Value stored in a token can be bridged to some other chain
 * @dev A modernized version of Compound protocol cToken. We handle variations between ERC20,
 * ERC777 and ETH underlying in nTokenImplementors.sol
 **/

abstract contract nToken is
    Ownable,
    ERC777,
    ERC20Permit,
    ReentrancyGuard,
    DSMathMin,
    IBridged,
    InToken,
    NaviMarginable
{
    using SafeERC20 for IERC20;
    address public immutable _bridgeContract;
    modifier onlyBridge() {
        require(
            _bridgeContract == msg.sender,
            "nToken: caller is not an bridge"
        );
        _;
    }

    IInterestRateModel private _interestRateModel; //Model which tells what the current interest rate should be
    INaviOracle public immutable _oracle;
    uint256 private _accrualBlockNumber; //Block number that interest was last accrued at
    /**
     * @dev Accumulator of the total earned interest rate since the opening of the market
     */
    uint256 private _borrowIndex;
    uint32 private _id; //Undurlying token id
    /**
     * @notice Container for borrow balance information
     * @member principal Total balance (with accrued interest), after applying the most recent balance-changing action
     * @member interestIndex Global borrowIndex as of the most recent balance-changing action
     */
    struct BorrowSnapshot {
        uint256 principal;
        uint256 interestIndex;
    }
    /**
     * @dev Mapping of account addresses to outstanding borrow balances
     */
    mapping(address => BorrowSnapshot) private _accountBorrows;
    uint256 internal _totalReserves; //Total amount of reserves of the underlying held in this market
    uint256 private _totalBorrows; //Total amount of outstanding borrows of the underlying in this market
    uint256 private _reserveFactor; //Fraction of interest currently set aside for reserves
    uint8 private bridgeBorrowsPaused;
    uint256 private _flashLoanFeeRate;
    //state of bridge borrows can be either 0=allowed, 1=close bridge deposits only or 2=paused
    //this is used as a security measure to protect other chains of the protocol from misbehavior on this chain
    mapping(address => uint256) public override bridgeDeposits;
    mapping(address => uint256) public override bridgeBorrows;
    //you can inspect all strategies in controller contract (parent of a parent)
    mapping(address => mapping(address => bool)) private _strategyAllowances;
    mapping(address => uint32) private _nonces; // to exclude transaction signature reuse
    uint256 public toWadFactor; //factor for converting underlying amount to wad(deciamls=18). defaults to 1.

    function getNounce(address addr) external view returns (uint32) {
        return _nonces[addr];
    }

    /**
     * @notice Event emitted when interest is accrued
     */
    event AccrueInterest(
        uint256 cashPrior,
        uint256 interestAccumulated,
        uint256 borrowIndex,
        uint256 totalBorrows
    );
    /**
     * @notice Event emitted when tokens are redeemed
     */
    event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);
    /**
     * @notice Event emitted when underlying is borrowed
     */
    event Borrow(
        address borrower,
        uint256 borrowAmount,
        uint256 accountBorrows,
        uint256 totalBorrows
    );

    /**
     * @notice Event emitted when a borrow is repaid
     */
    event RepayBorrow(
        address payer,
        address borrower,
        uint256 repayAmount,
        uint256 accountBorrows,
        uint256 totalBorrows
    );

    /**
     * @notice Event emitted when a account is liquidated
     */
    event LiquidateAccount(
        address liquidator,
        address borrower,
        uint256 seizedBorrows,
        uint256 seizedTokens
    );
    /**
     * @notice Event emitted when interestRateModel is changed
     */
    event NewInterestRateModel(
        IInterestRateModel oldInterestRateModel,
        IInterestRateModel newInterestRateModel
    );

    /**
     * @notice Event emitted when the reserve factor is changed
     */
    event NewReserveFactor(uint256 oldValue, uint256 newValue);

    /**
     * @notice Event emitted when the reserves are added
     */
    event ReservesAdded(
        address benefactor,
        uint256 addAmount,
        uint256 newTotalReserves
    );

    /**
     * @notice Event emitted when the reserves are reduced either by claiming debt or burning
     */
    event ReservesReduced(
        address beneficiary,
        uint256 reduceAmount,
        uint256 newTotalReserves
    );

    //event FlashLoanRateUpdated(uint256 oldValue, uint256 newValue);

    constructor(
        uint32 id,
        string memory name,
        string memory symbol,
        uint256 ltv,
        address bridgeContract,
        address parentContract,
        address interestRateModel_,
        address oracle
    )
        ERC777(name, symbol, new address[](0))
        ERC20Permit(name)
        Ownable()
        NaviMarginable(ltv, parentContract)
    {
        _id = id;
        toWadFactor = 1;
        _bridgeContract = bridgeContract;
        _interestRateModel = IInterestRateModel(interestRateModel_);
        _oracle = INaviOracle(oracle);
        _accrualBlockNumber = block.number;
        _borrowIndex = 1 ether;
        _reserveFactor = 0.25 ether;
        _flashLoanFeeRate = 0.001 ether; //0.1%
        _ERC1820_REGISTRY.setInterfaceImplementer(
            address(this),
            keccak256("NaviBridged"),
            address(this)
        );
        _ERC1820_REGISTRY.setInterfaceImplementer(
            address(this),
            keccak256("NaviToken"),
            address(this)
        );
    }

    function interestRateModel() external view returns (address) {
        return address(_interestRateModel);
    }

    function getPriceId() external view override returns (uint32) {
        return _id;
    }

    function getTotalReserves()
        external
        view
        virtual
        override
        returns (uint256)
    {
        return _totalReserves;
    }

    function getFlashLoanFeeRate() external view returns (uint256) {
        return _flashLoanFeeRate;
    }

    function setFlashLoanFeeRate(uint256 rate) external onlyOwner {
        require(rate <= 0.01 ether, "rate must be <= 1%");
        //emit FlashLoanRateUpdated(_flashLoanFeeRate, rate);
        _flashLoanFeeRate = rate;
    }

    function setBridgeBorrowsStatus(uint8 status) external onlyParent {
        bridgeBorrowsPaused = status; //0=allowed 1=closeOnly 2=paused
    }

    //you can inspect and authorize strategies through controller contract (parent of a parent)
    function authorizeStrategy(
        address strategy,
        address signatory,
        bool authorize
    ) external onlyParent {
        _strategyAllowances[signatory][strategy] = authorize;
    }

    function authorizeStrategy(address strategy, bool authorize) external {
        _strategyAllowances[msg.sender][strategy] = authorize;
    }

    //strategy must be authorized both by DAO (address(0)) and end user (signatory)
    function isAuthorized(address strategy, address signatory)
        public
        view
        returns (bool)
    {
        return
            _strategyAllowances[address(0)][strategy] &&
            _strategyAllowances[signatory][strategy];
    }

    //liquidation of unfunded account called by the controller
    function seizeAccount(address account, address seizeTo)
        external
        onlyParent
    {
        if (bridgeBorrows[account] > 0) {
            bridgeBorrows[seizeTo] += bridgeBorrows[account];
            delete bridgeBorrows[account];
        }
        uint256 borrows = 0;
        if (_accountBorrows[account].principal > 0) {
            accrueInterest();
            borrows = borrowBalance(account);
            _accountBorrows[seizeTo].interestIndex = _borrowIndex;
            _accountBorrows[seizeTo].principal =
                borrowBalance(seizeTo) +
                borrows;
            delete _accountBorrows[account];
        }
        if (bridgeDeposits[account] > 0) {
            bridgeDeposits[seizeTo] += bridgeDeposits[account];
            delete bridgeDeposits[account];
        }
        uint256 balance = balanceOf(account);
        if (balance > 0) super._send(account, seizeTo, balance, "", "", false);
        if (balance > 0 || borrows > 0)
            emit LiquidateAccount(seizeTo, account, borrows, balance);
    }

    function addReservesInternal(uint256 addAmount) internal nonReentrant {
        // totalReserves + actualAddAmount
        /*
         * We call doTransferIn for the caller and the addAmount
         *  Note: The nToken must handle variations between ERC-20 and ETH underlying.
         *  On success, the nToken holds an additional addAmount of cash.
         *  doTransferIn reverts if anything goes wrong, since we can't be sure if side effects occurred.
         *  it returns the amount actually transferred, in case of a fee.
         */

        uint256 actualAddAmount = doTransferIn(msg.sender, addAmount);

        // Store reserves[n+1] = reserves[n] + actualAddAmount
        _totalReserves = _totalReserves + actualAddAmount;

        emit ReservesAdded(msg.sender, actualAddAmount, _totalReserves);
    }

    function setInterestRateModel(address model) external onlyOwner {
        emit NewInterestRateModel(
            _interestRateModel,
            IInterestRateModel(model)
        );
        _interestRateModel = IInterestRateModel(model);
    }

    function setLTV(uint256 ltv) external onlyOwner {
        require(ltv <= 1 ether, "Loan to value ratio must be <= 100%");
        emit LTVUpdated(_LTV, ltv);
        _LTV = ltv;
    }

    function setReserveFactor(uint256 reserveFactor) external onlyOwner {
        require(reserveFactor <= 0.3 ether, "reserveFactor must be <= 30%");
        require(reserveFactor >= 0.01 ether, "reserveFactor must be >= 1%");
        accrueInterest();
        uint256 oldReserveFactor = _reserveFactor;
        _reserveFactor = reserveFactor;
        emit NewReserveFactor(oldReserveFactor, reserveFactor);
    }

    function getReserveFactor() external view returns (uint256) {
        return _reserveFactor;
    }

    function _send(
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) internal override {
        accrueInterest();
        super._send(
            from,
            to,
            amount,
            userData,
            operatorData,
            requireReceptionAck
        );
        require(
            _parent.hasEnoughMargin(from, 0),
            "nToken: Not enough margin for transfer"
        );
    }

    //Bridge borrows are pausable. We reduce position size when possible to avoid arithmetic overflow
    //amount here is in WAD, must be converted to underlying decimals
    function bridgeBurn(address account, uint256 amount)
        external
        override
        onlyBridge
    {
        amount = amount / toWadFactor;
        require(
            bridgeBorrowsPaused != 2,
            "Bridge borrows are paused at the moment"
        );
        require(
            bridgeBorrowsPaused == 0 || bridgeDeposits[account] >= amount,
            "You can only close bridge deposit at the moment"
        );
        if (bridgeDeposits[account] >= amount)
            bridgeDeposits[account] -= amount;
        else bridgeBorrows[account] += amount;
        require(_parent.hasEnoughMargin(account, 0), "Not enough margin");
    }

    function bridgeMint(address account, uint256 amount)
        external
        override
        onlyBridge
    {
        amount = amount / toWadFactor;
        if (bridgeBorrows[account] >= amount) bridgeBorrows[account] -= amount;
        else bridgeDeposits[account] += amount;
    }

    function burnDebtFor(address sender, uint256 amount)
        external
        virtual
        override
        nonReentrant
    {
        require(amount > 0, "amount must be > 0");

        uint256 amountUnderlying = wdiv(amount, _oracle.price(_id));

        require(
            getCashPrior() >= amountUnderlying,
            "Protocol has insufficient cash"
        );

        require(
            _totalReserves >= amountUnderlying,
            "Protocol has insufficient reserves"
        );

        uint256 totalReservesNew = _totalReserves - amountUnderlying;
        //Transfering debtToken to this and burning it
        SafeERC20.safeTransferFrom(
            IERC20(_oracle.tokenAddress(2)),
            msg.sender,
            address(this),
            amount
        );
        IERC777(_oracle.tokenAddress(2)).burn(amount, "");

        //Repaing amount burned
        doTransferOut(sender, amountUnderlying);
        _totalReserves = totalReservesNew;
        emit ReservesReduced(sender, amountUnderlying, totalReservesNew);
    }

    function balanceOfUnderlying(address owner)
        public
        view
        override
        returns (uint256)
    {
        if (balanceOf(owner) == 0) return 0;
        return wmul(exchangeRateInternal(), balanceOf(owner));
    }

    /**
     * @dev Performs a transfer in, reverting upon failure. Returns the amount
     * actually transferred to the protocol, in case of a fee.
     * This may revert due to insufficient balance or insufficient allowance.
     */
    function doTransferIn(address from, uint256 amount)
        internal
        virtual
        returns (uint256);

    /**
     * @dev Performs a transfer out, ideally returning an explanatory error code upon failure tather than reverting.
     *  If caller has not called checked protocol's balance, may revert due to insufficient cash held in the contract.
     *  If caller has checked protocol's balance, and verified it is >= amount,
     *  this should not revert in normal conditions.
     */
    function doTransferOut(address to, uint256 amount) internal virtual;

    /**
     * @notice Gets balance of this contract in terms of the underlying
     * @dev This excludes the value of the current message, if any
     * @return () The quantity of underlying owned by this contract
     */
    function getCashPrior() internal view virtual returns (uint256);

    function getCash() external view virtual override returns (uint256);

    /**
     * @notice Calculates the exchange rate from the underlying to the CToken
     * @dev This function does not accrue interest before calculating the exchange rate
     * @return (calculated exchange rate scaled by 1e18)
     */
    function exchangeRateInternal() internal view returns (uint256) {
        if (totalSupply() == 0) {
            /*
             * If there are no tokens minted:
             *  return initialExchangeRate
             */
            return (1 ether);
        } else {
            /*
             * Otherwise:
             *  return (totalCash + totalBorrows - totalReserves) / totalSupply
             */
            uint256 totalCash = getCashPrior();
            return
                wdiv(totalCash + _totalBorrows - _totalReserves, totalSupply());
        }
    }

    /**
     * @notice Returns the current total borrows plus accrued interest
     * @return (uint) The total borrows with interest
     */

    function getTotalBorrows() external view override returns (uint256) {
        return _totalBorrows;
    }

    /**
     * @notice Return the borrow balance of account based on stored data
     * @param account The address whose balance should be calculated
     * @return (the calculated balance)
     */
    function borrowBalance(address account)
        public
        view
        override
        returns (uint256)
    {
        /* Note: we do not assert that the market is up to date */

        /* Get borrowBalance and borrowIndex */
        BorrowSnapshot storage borrowSnapshot = _accountBorrows[account];

        /*
         * Rather than failing the calculation with a division by 0, we immediately return 0 in this case.
         */
        if (borrowSnapshot.interestIndex == 0) {
            return 0;
        }

        /* Calculate new borrow balance using the interest index:
         *  recentBorrowBalance = borrower.borrowBalance * market.borrowIndex / borrower.borrowIndex
         */
        uint256 principalTimesIndex = wmul(
            borrowSnapshot.principal,
            _borrowIndex
        );
        uint256 result = wdiv(
            principalTimesIndex,
            borrowSnapshot.interestIndex
        );
        return result;
    }

    /**
     * @notice Applies accrued interest to total borrows and reserves
     * @dev This calculates interest accrued from the last checkpointed block
     *   up to the current block and writes new checkpoint to storage.
     */
    function accrueInterest() public {
        /* Remember the initial block number */
        uint256 currentBlockNumber = block.number;
        uint256 accrualBlockNumberPrior = _accrualBlockNumber;

        /* Short-circuit accumulating 0 interest */
        if (accrualBlockNumberPrior == currentBlockNumber) return;

        /* Read the previous values out of storage */
        uint256 cashPrior = getCashPrior();

        /* Calculate the current borrow interest rate */
        uint256 borrowRate = _interestRateModel.getBorrowRate(
            cashPrior,
            _totalBorrows,
            _totalReserves
        );

        /* Calculate the number of blocks elapsed since the last accrual */
        uint256 blockDelta = (currentBlockNumber - accrualBlockNumberPrior);

        /*
         * Calculate the interest accumulated into borrows and reserves and the new index:
         *  simpleInterestFactor = borrowRate * blockDelta
         *  interestAccumulated = simpleInterestFactor * totalBorrows
         *  totalBorrowsNew = interestAccumulated + totalBorrows
         *  totalReservesNew = interestAccumulated * reserveFactor + totalReserves
         *  borrowIndexNew = simpleInterestFactor * borrowIndex + borrowIndex
         */

        uint256 simpleInterestFactor = wmul(borrowRate, blockDelta);
        uint256 interestAccumulated = wmul(simpleInterestFactor, _totalBorrows);
        _totalBorrows = (interestAccumulated + _totalBorrows);
        _totalReserves = (wmul(_reserveFactor, interestAccumulated) +
            _totalReserves);
        _borrowIndex = (wmul(simpleInterestFactor, _borrowIndex) +
            _borrowIndex);

        /* We write the previously calculated values into storage */
        _accrualBlockNumber = currentBlockNumber;

        /* We emit an AccrueInterest event */
        emit AccrueInterest(
            cashPrior,
            interestAccumulated,
            _borrowIndex,
            _totalBorrows
        );
    }

    /**
     * @notice Sender supplies assets into the market and receives nTokens in exchange
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param mintAmount The amount of the underlying asset to supply
     */
    function mintInternal(address minter, uint256 mintAmount)
        internal
        nonReentrant
    {
        accrueInterest();
        // mintPrivate emits the actual Mint event if successful and logs on errors, so we don't need to
        mintPrivate(minter, minter, mintAmount);
    }

    /**
     * @notice User supplies assets into the market and receives nTokens in exchange
     * @dev Assumes interest has already been accrued up to the current block
     * @param minter The address of the account which is supplying the assets
     * @param mintAmount The amount of the underlying asset to supply
     * @return (uint) the actual mint amount.
     */
    function mintPrivate(
        address minter,
        address payer,
        uint256 mintAmount
    ) private returns (uint256) {
        uint256 exchangeRate = exchangeRateInternal();

        /*
         *  We call `doTransferIn` for the minter and the mintAmount.
         *  Note: The nToken must handle variations between ERC-20 and ETH underlying.
         *  `doTransferIn` reverts if anything goes wrong, since we can't be sure if
         *  side-effects occurred. The function returns the amount actually transferred,
         *  in case of a fee. On success, the nToken holds an additional `actualMintAmount`
         *  of cash.
         */
        uint256 actualMintAmount = doTransferIn(payer, mintAmount);

        /*
         * We get the current exchange rate and calculate the number of nTokens to be minted:
         *  mintTokens = actualMintAmount / exchangeRate
         */

        uint256 mintTokens = wdiv(actualMintAmount, exchangeRate);

        /*
         *  totalSupplyNew = totalSupply + mintTokens
         *  accountTokensNew = accountTokens[minter] + mintTokens
         */

        _mint(minter, mintTokens, "", "", false);

        /* We call the defense hook */
        // unused function
        _parent.balanceUpdated(0, minter);

        return (actualMintAmount);
    }

    /**
     * @notice Sender redeems nTokens in exchange for the underlying asset
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param redeemTokens The number of nTokens to redeem into underlying
     */
    function redeem(uint256 redeemTokens) external nonReentrant {
        accrueInterest();
        // redeemPrivate emits redeem-specific logs on errors, so we don't need to
        redeemPrivate(msg.sender, msg.sender, redeemTokens, 0, false);
    }

    /**
     * @notice Sender redeems nTokens in exchange for a specified amount of underlying asset
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param redeemAmount The amount of underlying to receive from redeeming nTokens
     */
    function redeemUnderlying(uint256 redeemAmount) external nonReentrant {
        accrueInterest();
        // redeemPrivate emits redeem-specific logs on errors, so we don't need to
        redeemPrivate(msg.sender, msg.sender, 0, redeemAmount, false);
    }

    function redeemByStrategy(
        uint256 redeemTokensIn,
        uint256 redeemAmountIn,
        address redeemer,
        bytes memory data
    ) external override nonReentrant {
        require(
            isAuthorized(msg.sender, redeemer),
            "You are not a registered strategy"
        );
        accrueInterest();
        redeemAmountIn = redeemPrivate(
            redeemer,
            msg.sender,
            redeemTokensIn,
            redeemAmountIn,
            true
        );
        IStrategy(msg.sender).redeemCallback(data, redeemAmountIn);
        require(
            _parent.hasEnoughMargin(redeemer, 0),
            "Not enough margin after the redeem"
        );
    }

    /**
     * @notice User redeems nTokens in exchange for the underlying asset
     * @dev Assumes interest has already been accrued up to the current block
     * @param redeemer The address of the account which is redeeming the tokens
     * @param redeemTokens The number of nTokens to redeem into underlying (only one of redeemTokensIn or redeemAmountIn may be non-zero)
     * @param redeemAmount The number of underlying tokens to receive from redeeming nTokens (only one of redeemTokensIn or redeemAmountIn may be non-zero)
     * @return uint Redeemed amount (redeemAmountIn)
     */

    function redeemPrivate(
        address redeemer,
        address recipient,
        uint256 redeemTokens,
        uint256 redeemAmount,
        bool skipMarginCheck
    ) private returns (uint256) {
        require(
            redeemTokens == 0 || redeemAmount == 0,
            "one of redeemTokensIn or redeemAmountIn must be zero"
        );

        /* exchangeRate = invoke Exchange Rate () */
        uint256 exchangeRate = exchangeRateInternal();
        /* If redeemTokensIn > 0: */
        if (redeemTokens > 0) {
            /*
             * We calculate the exchange rate and the amount of underlying to be redeemed:
             *  redeemTokens = redeemTokensIn
             *  redeemAmount = redeemTokensIn x exchangeRateCurrent
             */
            redeemAmount = wmul(exchangeRate, redeemTokens);
        } else {
            /*
             * We get the current exchange rate and calculate the amount to be redeemed:
             *  redeemTokens = redeemAmountIn / exchangeRate
             *  redeemAmount = redeemAmountIn
             */

            redeemTokens = wdiv(redeemAmount, exchangeRate);
        }

        /*
         * We calculate the new total supply and redeemer balance, checking for underflow:
         *  totalSupplyNew = totalSupply - redeemTokens
         *  accountTokensNew = accountTokens[redeemer] - redeemTokens
         */

        /* Fail gracefully if protocol has insufficient cash */
        require(
            getCashPrior() >= redeemAmount,
            "Protocol has insufficient cash"
        );

        if (redeemTokens == 0 && redeemAmount > 0) {
            revert("redeemTokens are zero");
        }

        /*
         * We invoke doTransferOut for the redeemer and the redeemAmount.
         *  Note: The nToken must handle variations between ERC-20 and ETH underlying.
         *  On success, the nToken has redeemAmount less of cash.
         *  doTransferOut reverts if anything goes wrong, since we can't be sure if side effects occurred.
         */
        _burn(redeemer, redeemTokens, "", "");

        /* Fail if redeem not allowed */
        require(
            skipMarginCheck || _parent.hasEnoughMargin(redeemer, 0),
            "Not enough margin to redeem"
        );

        doTransferOut(recipient, redeemAmount);

        /* We emit a Transfer event, and a Redeem event */
        emit Redeem(redeemer, redeemAmount, redeemTokens);
        _parent.balanceUpdated(1, redeemer);

        return (redeemAmount);
    }

    function flashLoan(uint256 amount) external nonReentrant {
        uint256 feePaid = wmul(amount, _flashLoanFeeRate);
        uint256 balanceBefore = getCashPrior();
        // ERC20 and ERC777 are transfered by ERC20.transfer(to, amount) method
        // Ether is transfered by payable(to).transfer(amount), so borrower must implement "receive()" hook
        doTransferOut(msg.sender, amount);
        IFlashLoanBorrower(msg.sender).execute(amount + feePaid);
        // Borrower must return transfered amount + fee in this callback using the same way mentioned above
        // Otherwise we revert the whole thing
        require(getCashPrior() >= balanceBefore + feePaid, "failed payback");
        _totalReserves += feePaid;
    }

    function borrowBySig(
        uint256 borrowAmount,
        uint256 feeAmount,
        uint32 nonce,
        uint256 expiry,
        bytes32 schema,
        InTokenForEther feeCompensator,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant {
        require(borrowAmount > 0, "borrowAmount must be > 0");
        require(block.timestamp <= expiry, "Signature expired");
        bytes32 data = keccak256(
            abi.encodePacked(
                borrowAmount,
                feeAmount,
                address(this),
                nonce,
                expiry
            )
        );
        data = keccak256(abi.encodePacked(schema, data));
        address signatory = ecrecover(data, v, r, s);
        require(signatory != address(0), "Invalid signature");
        require(nonce > _nonces[signatory], "Invalid nonce");
        _nonces[signatory] = nonce;
        accrueInterest();
        borrowPrivate(signatory, signatory, borrowAmount, false);
        feeCompensator.compensateFee(signatory, msg.sender, feeAmount);
    }

    function borrowByStrategy(
        uint256 borrowAmount,
        address borrower,
        bytes memory data
    ) external override nonReentrant {
        require(
            isAuthorized(msg.sender, borrower),
            "You are not a registered strategy"
        );
        accrueInterest();
        //We are most likely executing leverage operation here, so we do the following:
        //1. send requested money to strategy without margin check(it will likely fail);
        //2. call a callback function of strategy contract:
        //2.1. strategy does whatever with this money, but margin hopefully becomes ok
        //3. after return, check if margin is ok now and revert the whole thing if not
        borrowPrivate(borrower, msg.sender, borrowAmount, true);
        IStrategy(msg.sender).borrowCallback(data);
        require(
            _parent.hasEnoughMargin(borrower, 0),
            "Not enough margin after the borrow"
        );
    }

    /**
     * @notice Sender borrows assets from the protocol to their own address
     * @param borrowAmount The amount of the underlying asset to borrow
     */
    function borrow(uint256 borrowAmount) external nonReentrant {
        accrueInterest();
        // borrowPrivate emits borrow-specific logs on errors, so we don't need to
        borrowPrivate(msg.sender, msg.sender, borrowAmount, false);
    }

    /**
     * @notice Users borrow assets from the protocol to their own address
     * @param borrowAmount The amount of the underlying asset to borrow
     */

    function borrowPrivate(
        address borrower,
        address recipient,
        uint256 borrowAmount,
        bool skipMarginCheck
    ) private {
        /* Fail gracefully if protocol has insufficient underlying cash */
        require(
            getCashPrior() >= borrowAmount,
            "Protocol has insufficient cash"
        );

        /*
         * We calculate the new borrower and total borrow balances, failing on overflow:
         *  accountBorrowsNew = accountBorrows + borrowAmount
         *  totalBorrowsNew = totalBorrows + borrowAmount
         */
        uint256 accountBorrowsNew = (borrowBalance(borrower) + borrowAmount);

        /* We write the previously calculated values into storage */
        _accountBorrows[borrower].principal = accountBorrowsNew;
        _accountBorrows[borrower].interestIndex = _borrowIndex;

        /* Fail if borrow not allowed */
        require(
            skipMarginCheck || _parent.hasEnoughMargin(borrower, 0),
            "Not enough margin to borrow"
        );

        /*
         * We invoke doTransferOut for the borrower and the borrowAmount.
         *  Note: The nToken must handle variations between ERC-20 and ETH underlying.
         *  On success, the nToken borrowAmount less of cash.
         *  doTransferOut reverts if anything goes wrong, since we can't be sure if side effects occurred.
         */
        doTransferOut(recipient, borrowAmount);

        _totalBorrows = (_totalBorrows + borrowAmount);

        /* We emit a Borrow event */
        emit Borrow(borrower, borrowAmount, accountBorrowsNew, _totalBorrows);

        /* We call the defense hook */
        // unused function
        _parent.balanceUpdated(2, borrower);
    }

    /**
     * @notice Sender repays their own borrow
     * @param repayAmount The amount to repay
     */
    function repayBorrowInternal(address payer, uint256 repayAmount)
        internal
        nonReentrant
    {
        accrueInterest();
        // repayBorrowPrivate emits repay-borrow-specific logs on errors, so we don't need to
        repayBorrowPrivate(payer, msg.sender, repayAmount);
    }

    /**
     * @notice Sender repays a borrow belonging to borrower
     * @param borrower the account with the debt being payed off
     * @param repayAmount The amount to repay
     */
    function repayBorrowBehalfInternal(
        address payer,
        address borrower,
        uint256 repayAmount
    ) internal nonReentrant {
        accrueInterest();
        // repayBorrowPrivate emits repay-borrow-specific logs on errors, so we don't need to
        repayBorrowPrivate(payer, borrower, repayAmount);
    }

    /**
     * @notice Borrows are repaid by another user (possibly the borrower).
     * @param payer the account paying off the borrow
     * @param borrower the account with the debt being payed off
     * @param repayAmount the amount of undelrying tokens being returned
     */
    function repayBorrowPrivate(
        address payer,
        address borrower,
        uint256 repayAmount
    ) private {
        /* Fail if repayBorrow not allowed */

        /* Verify market's block number equals current block number */

        /* We remember the original borrowerIndex for verification purposes */
        //uint256 borrowerIndex = _accountBorrows[borrower].interestIndex;

        /* We fetch the amount the borrower owes, with accumulated interest */
        uint256 accountBorrows = borrowBalance(borrower);

        /* If repayAmount == -1, repayAmount = accountBorrows */
        if (repayAmount == type(uint256).max) {
            repayAmount = accountBorrows;
        }

        require(
            accountBorrows >= repayAmount,
            "You are trying to repay more than you borrowed"
        );

        /*
         * We call doTransferIn for the payer and the repayAmount
         *  Note: The nToken must handle variations between ERC-20 and ETH underlying.
         *  On success, the nToken holds an additional repayAmount of cash.
         *  doTransferIn reverts if anything goes wrong, since we can't be sure if side effects occurred.
         *   it returns the amount actually transferred, in case of a fee.
         */
        uint256 actualRepayAmount = doTransferIn(payer, repayAmount);

        /*
         * We calculate the new borrower and total borrow balances, failing on underflow:
         *  accountBorrowsNew = accountBorrows - actualRepayAmount
         *  totalBorrowsNew = totalBorrows - actualRepayAmount
         */
        uint256 accountBorrowsNew = (accountBorrows - actualRepayAmount);

        /* We write the previously calculated values into storage */
        _accountBorrows[borrower].principal = accountBorrowsNew;
        _accountBorrows[borrower].interestIndex = _borrowIndex;
        _totalBorrows = (_totalBorrows - actualRepayAmount);

        /* We emit a RepayBorrow event */
        emit RepayBorrow(
            payer,
            borrower,
            actualRepayAmount,
            accountBorrowsNew,
            _totalBorrows
        );

        /* We call the defense hook */
        // unused function
        _parent.balanceUpdated(3, borrower);
    }

    function payInternal(
        address from,
        address to,
        uint256 amount
    ) internal nonReentrant {
        accrueInterest();
        if (balanceOfUnderlying(from) > amount)
            redeemPrivate(from, to, 0, amount, false);
        else borrowPrivate(from, to, amount, false);
    }

    /**
     * @notice nToken can credit itself, so account can be either net borrower(deposits=0) or net depositer(borrows=0)
     */
    function netPosition(address account, uint32) public view returns (int256) {
        uint256 deposits = balanceOfUnderlying(account) +
            bridgeDeposits[account];
        uint256 borrows = borrowBalance(account) + bridgeBorrows[account];
        uint256 price = _oracle.price(_id);
        if (borrows == deposits) return 0;
        if (borrows < deposits)
            return int256(wmul(wmul(deposits - borrows, price), _LTV));
        return -int256(wdiv(wmul(borrows - deposits, price), _LTV));
    }
}

/**
 * @title nTokenForEther
 * @dev Network native token recipient with compensation capabilities
 */

contract nTokenForEther is nToken, InTokenForEther {
    uint256 public immutable maxFeeImmutable; // for funds safety, this strict restraint must be immutable!
    uint256 private _maxFeeMutable; // current limit that can be updated

    event FeeCompensated(address from, address to, uint256 amount);
    event NewCompensatorAuthorized(address compensator);
    event CompensatorRemoved(address compensator);
    event MaxFeeUpdated(uint256 oldValue, uint256 newValue);

    constructor(
        uint32 id,
        string memory name,
        string memory symbol,
        uint256 ltv,
        address bridgeContract,
        address controllerContract,
        address interestRateModel,
        address oracle,
        uint256 maxFeeImmutable_
    )
        nToken(
            id,
            name,
            symbol,
            ltv,
            bridgeContract,
            controllerContract,
            interestRateModel,
            oracle
        )
    {
        maxFeeImmutable = maxFeeImmutable_;
        _maxFeeMutable = maxFeeImmutable_;
    }

    function getUnderlying() external pure override returns (address) {
        return address(0);
    }

    function getMaxFee() external view returns (uint256) {
        return _maxFeeMutable;
    }

    function setMaxFee(uint256 value) external onlyOwner {
        require(
            value <= maxFeeImmutable,
            "nTokenForEther::setMaxFee: value to big"
        );
        emit MaxFeeUpdated(_maxFeeMutable, value);
        _maxFeeMutable = value;
    }

    /**
     * @notice Strategies authorized by users can pay small amounts of ether on behalf of this users
     * to compensate network fees to transaction propagator
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param from User who authorized strategy to compensate fees
     * @param to propagater of transaction to strategy contract (=msg.sender)
     * @param amount The amount of the fee to compensate
     */

    function compensateFee(
        address from,
        address to,
        uint256 amount
    ) external override {
        require(
            isAuthorized(msg.sender, from) ||
                msg.sender == _bridgeContract ||
                msg.sender == address(this),
            "nTokenForEther::compensateFee: this contract is not authorized to compensate fees"
        );
        require(
            amount <= _maxFeeMutable,
            "nTokenForEther::compensateFee: compensation too big"
        );
        payInternal(from, to, amount);
        emit FeeCompensated(from, to, amount);
    }

    function addReserves(uint256 amount) external payable {
        addReservesInternal(amount);
    }

    /**
     * @notice Sender supplies assets into the market and receives nTokens in exchange
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param mintAmount The amount of the underlying asset to supply
     */
    function mint(uint256 mintAmount) external payable {
        mintInternal(msg.sender, mintAmount);
    }

    /**
     * @notice Sender repays their own borrow
     * @param repayAmount The amount to repay
     */
    function repayBorrow(uint256 repayAmount) external payable {
        repayBorrowInternal(msg.sender, repayAmount);
    }

    /**
     * @notice Sender repays a borrow belonging to some other borrower
     * @param borrower the account with the debt being payed off
     * @param repayAmount The amount to repay
     */
    function repayBorrowBehalf(address borrower, uint256 repayAmount)
        external
        payable
    {
        repayBorrowBehalfInternal(msg.sender, borrower, repayAmount);
    }

    /**
     * @notice A public function to sweep accidental ERC-20 transfers to this contract.
     * Tokens are sent to owner
     * @param token The address of the ERC-20 token to sweep
     */
    function sweepToken(IERC20 token) external {
        token.transfer(owner(), token.balanceOf(address(this)));
    }

    /**
     * @notice Gets balance of this contract in terms of the underlying
     * @dev This excludes the value of the current message, if any
     * @return The quantity of underlying tokens owned by this contract
     */
    function getCashPrior() internal view override returns (uint256) {
        return address(this).balance - msg.value;
    }

    function getCash() external view override returns (uint256) {
        return address(this).balance;
    }

    /**
     * @notice Perform the actual transfer in, which is a no-op
     * @param from Address sending the Ether
     * @param amount Amount of Ether being sent
     * @return The actual amount of Ether transferred
     */
    function doTransferIn(address from, uint256 amount)
        internal
        override
        returns (uint256)
    {
        // Sanity checks
        require(msg.sender == from, "sender mismatch");
        require(msg.value == amount, "value mismatch");
        return amount;
    }

    function doTransferOut(address to, uint256 amount) internal override {
        // Send the Ether, with minimal gas and revert on failure
        // This assumes reciever is an account not a smart contract
        // Or a smart contract with "receive () payable {}" method
        payable(to).transfer(amount);
    }
}