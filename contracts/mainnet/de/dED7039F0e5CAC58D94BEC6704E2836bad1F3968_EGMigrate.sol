// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

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
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
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
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
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
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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

/*

 _______   _______ .___  ___.  __    _______ .______        ___   .___________. _______ 
|   ____| /  _____||   \/   | |  |  /  _____||   _  \      /   \  |           ||   ____|
|  |__   |  |  __  |  \  /  | |  | |  |  __  |  |_)  |    /  ^  \ `---|  |----`|  |__   
|   __|  |  | |_ | |  |\/|  | |  | |  | |_ | |      /    /  /_\  \    |  |     |   __|  
|  |____ |  |__| | |  |  |  | |  | |  |__| | |  |\  \   /  _____  \   |  |     |  |____ 
|_______| \______| |__|  |__| |__|  \______| | _| `._\_/__/     \__\  |__|     |_______|
                                                                                          

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./OwnableUpgradeable.sol";

contract EGMigrate is OwnableUpgradeable {
    struct MigrationToken {
        uint256 index; // index of the source token
        address targetToken; // target token address
        uint256 rate; // migration ratio
        address devAddress; // the address to send the source tokens that are received from holders
        uint256 amountOfMigratedSourceToken; // total amount of migrated source tokens
        uint256 amountOfMigratedTargetToken; // total amount of migrated target tokens
        uint256 numberOfMigrators; // total number of migrators
        bool isPresent; // is this token present as a supported migration token
        bool enabled; // is migration enabled for this token
    }

    struct Migration {
        uint256 migrationId;
        address toAddress;
        uint256 timestamp;
        uint256 amountOfSourceToken;
        uint256 amountOfTargetToken;
    }

    /**
     * @dev counter for source tokens
     **/
    uint256 public sourceTokenCounter;

    /**
     * @dev mapping of source token address to migration
     **/
    mapping(address => MigrationToken) public migrationTokens;
    /**
     * @dev mapping of source token index to source token address
     **/
    mapping(uint256 => address) public sourceTokenIndices;

    /**
     * @dev counter for all migrations
     **/
    uint256 public migrationCounter;
    /**
     * @dev mapping of source token address to mapping of user address to array of Migrations
     **/
    mapping(address => mapping(address => Migration[])) private _userMigrations;

    /**
     * @param sourceToken source token address
     * @param targetToken target token address
     * @param rate rate of migration
     * @param devAddress the address to send the source tokens to
     *
     * @dev Emitted when add migration token
     **/
    event AddMigrationToken(
        address indexed sourceToken,
        address indexed targetToken,
        uint256 rate,
        address indexed devAddress
    );
    /**
     * @param token source token address
     * @param status status of migration
     *
     * @dev Emitted when set migration token status
     **/
    event SetStatusOfMigrationToken(address indexed token, bool status);
    /**
     * @param sourceToken source token address
     * @param targetToken target token address
     * @param rate rate of migration
     * @param devAddress the address to send the source tokens to
     *
     * @dev Emitted when add update migration token info
     **/
    event UpdateMigrationTokenInfo(
        address indexed sourceToken,
        address indexed targetToken,
        uint256 rate,
        address indexed devAddress
    );
    /**
     * @param fromAddress migrator wallet address
     * @param toAddress address to send the new tokens to holder
     * @param sourceToken source token address
     * @param amountOfSourceToken amount of source token address
     * @param targetToken target token
     * @param amountOfTargetToken amount of target token
     * @dev Emitted when migrate token
     **/
    event Migrate(
        address indexed fromAddress,
        address toAddress,
        address indexed sourceToken,
        uint256 amountOfSourceToken,
        address indexed targetToken,
        uint256 amountOfTargetToken
    );
    /**
     * @param sourceToken source token address
     * @param toAddress wallet address to return the source tokens to
     * @param amount amount of source token
     * @dev Emitted when return unused tokens back to dev team
     **/
    event TokensReturned(
        address indexed sourceToken,
        address indexed toAddress,
        uint256 amount
    );

    /**
     * @dev function that can be invoked at most once
     * @dev Initializes the contract setting the deployer as the initial owner.
     **/
    function initialize() external initializer {
        __Ownable_init();
    }

    /**
     * @param sourceToken source token address
     * @param targetToken target token address
     * @param rate migration ratio
     * @param devAddress the address to send the source tokens to

     * @dev add migration token
     **/
    function addMigrationToken(
        address sourceToken,
        address targetToken,
        uint256 rate,
        address devAddress
    ) external onlyOwner {
        require(
            sourceToken != address(0),
            "EGMigrate: source token address is zero"
        );
        require(
            !migrationTokens[sourceToken].isPresent,
            "EGMigrate: source token already exists"
        );
        require(
            targetToken != address(0),
            "EGMigrate: target token address is zero"
        );
        require(
            sourceToken != targetToken,
            "EGMigrate: sourceToken is the same as tragetToken"
        );
        require(0 < rate, "EGMigrate: rate is zero");

        MigrationToken memory migrationToken = MigrationToken({
            index: sourceTokenCounter,
            targetToken: targetToken,
            rate: rate,
            devAddress: devAddress,
            amountOfMigratedSourceToken: 0,
            amountOfMigratedTargetToken: 0,
            numberOfMigrators: 0,
            isPresent: true,
            enabled: true
        });

        migrationTokens[sourceToken] = migrationToken;
        sourceTokenIndices[sourceTokenCounter] = sourceToken;
        sourceTokenCounter = sourceTokenCounter + 1;

        emit AddMigrationToken(sourceToken, targetToken, rate, devAddress);
    }

    /**
     * @param sourceToken source token address
     * @param status status of migration

     * @dev enable migration token
     **/
    function setStatusOfMigrationToken(address sourceToken, bool status)
        external
        onlyOwner
    {
        require(
            migrationTokens[sourceToken].isPresent,
            "EGMigrate: source token does not exist"
        );

        migrationTokens[sourceToken].enabled = status;

        emit SetStatusOfMigrationToken(sourceToken, status);
    }

    /**
     * @param sourceToken source token address
     * @param targetToken target token address
     * @param rate migration ratio
     * @param devAddress the address to send the source tokens to

     * @dev update migration token info
     **/
    function updateMigrationTokenInfo(
        address sourceToken,
        address targetToken,
        uint256 rate,
        address devAddress
    ) external onlyOwner {
        require(
            migrationTokens[sourceToken].isPresent,
            "EGMigrate: source token does not exist"
        );
        require(
            targetToken != address(0),
            "EGMigrate: target token address is zero"
        );
        require(
            sourceToken != targetToken,
            "EGMigrate: sourceToken is the same as tragetToken"
        );
        require(0 < rate, "EGMigrate: rate is zero");

        migrationTokens[sourceToken].targetToken = targetToken;
        migrationTokens[sourceToken].devAddress = devAddress;
        migrationTokens[sourceToken].rate = rate;

        emit UpdateMigrationTokenInfo(
            sourceToken,
            targetToken,
            rate,
            devAddress
        );
    }

    /**
     * @param token source token address
     * @param toAddress address to send the new tokens to holder
     * @param amount amount of source tokens to migrate
     *
     * @dev migrate token
     **/
    function migrate(
        address token,
        address toAddress,
        uint256 amount
    ) external {
        require(
            migrationTokens[token].isPresent,
            "EGMigrate: source token does not exist"
        );
        require(
            migrationTokens[token].enabled,
            "EGMigrate: migration is disabled for this token"
        );
        require(
            toAddress != address(0),
            "EGMigrate: transfer to the zero address is not allowed"
        );
        require(0 < amount, "EGMigrate: amount is zero");

        MigrationToken storage migrationToken = migrationTokens[token];

        require(
            amount <= IERC20(token).balanceOf(_msgSender()),
            "EGMigrate: insufficient balance of source token in holder wallet"
        );
        require(
            amount <= IERC20(token).allowance(_msgSender(), address(this)),
            "EGMigrate: holder has insufficient approved allowance for source token"
        );

        uint256 migrationAmount = (amount *
            (10**IERC20Metadata(migrationToken.targetToken).decimals())) /
            (10**IERC20Metadata(token).decimals()) /
            (migrationToken.rate);

        require(
            migrationAmount <
                IERC20(migrationToken.targetToken).balanceOf(address(this)),
            "EGMigrate: insufficient balance of target token"
        );

        IERC20(token).transferFrom(
            _msgSender(),
            migrationToken.devAddress,
            amount
        );
        migrationToken.amountOfMigratedSourceToken =
            migrationToken.amountOfMigratedSourceToken +
            amount;

        IERC20(migrationToken.targetToken).transfer(toAddress, migrationAmount);
        migrationToken.amountOfMigratedTargetToken =
            migrationToken.amountOfMigratedTargetToken +
            migrationAmount;

        Migration[] storage userTxns = _userMigrations[token][_msgSender()];
        if (userTxns.length == 0) {
            migrationToken.numberOfMigrators =
                migrationToken.numberOfMigrators +
                1;
        }

        userTxns.push(
            Migration({
                migrationId: migrationCounter,
                toAddress: toAddress,
                timestamp: block.timestamp,
                amountOfSourceToken: amount,
                amountOfTargetToken: migrationAmount
            })
        );
        _userMigrations[token][_msgSender()] = userTxns;

        migrationCounter = migrationCounter + 1;

        emit Migrate(
            _msgSender(),
            toAddress,
            token,
            amount,
            migrationToken.targetToken,
            migrationAmount
        );
    }

    /**
     * @param sourceToken source token address
     * @param userAddress address of user
     *
     * @dev get total number of user migrations
     */
    function userMigrationsLength(address sourceToken, address userAddress)
        external
        view
        returns (uint256)
    {
        return _userMigrations[sourceToken][userAddress].length;
    }

    /**
     * @param sourceToken source token address
     * @param userAddress address of user
     * @param index index of user migration
     *
     * @dev get user migration log with index
     */
    function userMigration(
        address sourceToken,
        address userAddress,
        uint256 index
    )
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        Migration storage txn = _userMigrations[sourceToken][userAddress][
            index
        ];

        return (
            txn.migrationId,
            txn.timestamp,
            txn.amountOfSourceToken,
            txn.amountOfTargetToken
        );
    }

    /**
     * @param token source token address
     * @param toAddress wallet address to return the source tokens to
     * @param amount amount of source token
     *
     * @dev return unused tokens back to dev team
     */
     function returnTokens(
        address token,
        address toAddress,
        uint256 amount
    ) external onlyOwner {
        require(amount > 0, "EGMigrate: Amount should be greater than zero");
        require(
            toAddress != address(0),
            "ERC20: transfer to the zero address is not allowed"
        );
        require(
            migrationTokens[token].isPresent,
            "ERC20: source token does not exist"
        );
        require(
                IERC20(migrationTokens[token].targetToken).balanceOf(
                    address(this)
                ) >= amount,
            "EGMigrate: Target token balance in contract is insufficient"
        );

        MigrationToken storage migrationToken = migrationTokens[token];
        IERC20(migrationToken.targetToken).transfer(toAddress, amount);

        emit TokensReturned(migrationToken.targetToken, toAddress, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}