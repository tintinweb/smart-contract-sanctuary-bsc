// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0-rc.2) (proxy/utils/Initializable.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0-rc.2) (utils/Address.sol)

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

pragma solidity >=0.5.0;

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

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Locker is ReentrancyGuard {
    struct SLockDescriptor {
        address tokenAddress;
        address owner;
        string name;
        uint256 amount;
        bool vest;
        uint256 unlockAt;
        string vestUnit;
        uint256 vestPeriod;
        uint16 vestPercentage;
    }

    struct SLocker {
        address lockerAddress;
        address tokenAddress;
        address owner;
        string name;
        uint256 createdAt;
        uint256 amount;
        uint256 currentAmountLocked;
        uint256 releasedAmount;
        bool vest;
        uint256 unlockAt; // if vest, first time
        bool claimed; // for vest, fully claimed
        string vestUnit; // Days | Weeks | Months | Years
        uint256 vestPeriod;
        uint16 vestPercentage; // 100.00
        uint16 vestUnlockedPercentage; // 100.00
        uint256 vestFullyUnlocksAt;
        uint16 vestClaimedPercentage; // 100.00
    }

    event ChangedName(string previousName, string name);
    event ChangedDuration(uint256 previousDuration, uint256 duration);
    event ChangedAmount(uint256 previousAmount, uint256 amount);
    event ChangedOwner(address previousOwner, address owner);
    event Claimed(uint256 amount);

    SLocker private locker;
    address private factory;

    bytes32 public constant Hours = keccak256(abi.encodePacked("Hours"));
    bytes32 public constant Days = keccak256(abi.encodePacked("Days"));
    bytes32 public constant Weeks = keccak256(abi.encodePacked("Weeks"));
    bytes32 public constant Months = keccak256(abi.encodePacked("Months"));
    bytes32 public constant Years = keccak256(abi.encodePacked("Years"));

    uint16 public constant PERCENTAGE_PRECISION = 10000;

    modifier onlyOwner() {
        require(locker.owner == msg.sender, "permissions denied");
        _;
    }

    constructor() {
        factory = msg.sender;
    }

    function lock(SLockDescriptor memory lockDescriptor) external nonReentrant {
        require(factory == msg.sender);
        factory = address(0);

        address tokenAddress = lockDescriptor.tokenAddress;
        address owner = lockDescriptor.owner;
        string memory name = lockDescriptor.name;
        uint256 amount = lockDescriptor.amount;
        bool vest = lockDescriptor.vest;
        uint256 unlockAt = lockDescriptor.unlockAt;
        string memory vestUnit = lockDescriptor.vestUnit;
        uint256 vestPeriod = lockDescriptor.vestPeriod;
        uint16 vestPercentage = lockDescriptor.vestPercentage;

        require(
            IERC20Metadata(tokenAddress).balanceOf(address(this)) == amount,
            "invalid amount was transferred to locker"
        );

        require(tokenAddress != address(0), "invalid token address");
        require(owner != address(0), "invalid owner address");
        require(amount > 0, "invalid amount");

        if (vest) {
            require(unlockAt > block.timestamp, "should unlock in future");
            require(getVestUnitPeriod(vestUnit) > 0, "invalid vest unit");
            require(vestPeriod > 0, "invalid vest period");
            require(
                vestPercentage > 0 &&
                    vestPercentage <= PERCENTAGE_PRECISION / 2,
                "invalid vest percentage"
            );
        }

        address lockerAddress = address(this);

        locker = SLocker({
            lockerAddress: lockerAddress,
            tokenAddress: tokenAddress,
            owner: owner,
            name: name,
            createdAt: block.timestamp,
            amount: amount,
            currentAmountLocked: amount,
            releasedAmount: 0,
            vest: vest,
            unlockAt: unlockAt,
            claimed: false,
            vestUnit: vestUnit,
            vestPeriod: vestPeriod,
            vestPercentage: vestPercentage,
            vestUnlockedPercentage: 0,
            vestFullyUnlocksAt: vest
                ? getVestFullyUnlocksAt(
                    unlockAt,
                    vestPeriod,
                    vestUnit,
                    vestPercentage
                )
                : 0,
            vestClaimedPercentage: 0
        });
    }

    function getInfo4()
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 period = getVestPeriodDuration();
        uint256 duration = getVestDuration() + period;
        uint256 totalPeriods = duration / period;

        return (period, duration, totalPeriods);
    }

    function getInfo3() public view returns (SLocker memory) {
        SLocker memory info = locker;

        if (locker.vest) {
            info.vestUnlockedPercentage = 10;
        } else {
            info.currentAmountLocked = locker.unlockAt > block.timestamp
                ? locker.amount
                : 0;
        }

        return info;
    }

    function getInfo2() public view returns (SLocker memory) {
        SLocker memory info = locker;

        if (locker.vest) {
            info.vestUnlockedPercentage = getVestUnlockedPercentage();
        } else {
            info.currentAmountLocked = locker.unlockAt > block.timestamp
                ? locker.amount
                : 0;
        }

        return info;
    }

    function getInfo() public view returns (SLocker memory) {
        SLocker memory info = locker;

        if (locker.vest) {
            info.vestUnlockedPercentage = getVestUnlockedPercentage();

            info.currentAmountLocked =
                locker.amount -
                ((locker.amount * info.vestUnlockedPercentage) /
                    PERCENTAGE_PRECISION);
        } else {
            info.currentAmountLocked = locker.unlockAt > block.timestamp
                ? locker.amount
                : 0;
        }

        return info;
    }

    function getVestUnlockedPercentage() public view returns (uint16) {
        if (block.timestamp < locker.unlockAt) return 0;
        if (block.timestamp > locker.vestFullyUnlocksAt)
            return PERCENTAGE_PRECISION;

        uint256 period = getVestPeriodDuration();
        uint256 duration = getVestDuration() + period;
        uint256 totalPeriods = duration / period;

        uint16 vestUnlockedPercentage = uint16(
            ((((block.timestamp - locker.unlockAt) + period) / period) *
                PERCENTAGE_PRECISION) / totalPeriods
        );

        return
            vestUnlockedPercentage > PERCENTAGE_PRECISION
                ? PERCENTAGE_PRECISION
                : vestUnlockedPercentage;
    }

    function getVestFullyUnlocksAt(
        uint256 unlockAt,
        uint256 vestPeriod,
        string memory vestUnit,
        uint256 vestPercentage
    ) public pure returns (uint256) {
        uint256 periodDuration = vestPeriod * getVestUnitPeriod(vestUnit);

        return
            unlockAt +
            (((periodDuration * PERCENTAGE_PRECISION) / vestPercentage) -
                periodDuration);
    }

    function getVestPeriodDuration() public view returns (uint256) {
        return locker.vestPeriod * getVestUnitPeriod(locker.vestUnit);
    }

    function getVestDuration() public view returns (uint256) {
        return locker.vestFullyUnlocksAt - locker.unlockAt;
    }

    function getLocker() public view returns (SLocker memory) {
        return locker;
    }

    function getVestUnitPeriod(string memory unit)
        public
        pure
        returns (uint256)
    {
        bytes32 byteUnit = keccak256(abi.encodePacked(unit));

        if (byteUnit == Hours) return 1 hours;
        if (byteUnit == Days) return 1 days;
        if (byteUnit == Weeks) return 1 weeks;
        if (byteUnit == Months) return 4 weeks;
        if (byteUnit == Years) return 365 days;

        return 0;
    }

    function rename(string calldata name) external onlyOwner nonReentrant {
        string memory previousName = locker.name;
        locker.name = name;
        emit ChangedName(previousName, name);
    }

    function extendDuration(uint256 unlockAt) external onlyOwner nonReentrant {
        require(
            locker.unlockAt > block.timestamp,
            "cannot extend duration once unlocked"
        );
        uint256 previousUnlockAt = locker.unlockAt;
        require(
            unlockAt > previousUnlockAt,
            "can extend only after the current unlock date"
        );

        locker.unlockAt = unlockAt;

        if (locker.vest) {
            locker.vestFullyUnlocksAt = getVestFullyUnlocksAt(
                unlockAt,
                locker.vestPeriod,
                locker.vestUnit,
                locker.vestPercentage
            );
        }

        emit ChangedDuration(previousUnlockAt, unlockAt);
    }

    function extendAmount(uint256 amount) external onlyOwner nonReentrant {
        require(
            locker.unlockAt > block.timestamp,
            "cannot extend amount once unlocked"
        );
        uint256 previousAmount = locker.amount;

        uint256 recipientBalanceBefore = IERC20Metadata(locker.tokenAddress)
            .balanceOf(address(this));

        require(
            IERC20Metadata(locker.tokenAddress).transferFrom(
                msg.sender,
                address(this),
                amount - previousAmount
            ),
            "transfer failed"
        );

        uint256 actualAmount = IERC20Metadata(locker.tokenAddress).balanceOf(
            address(this)
        ) - recipientBalanceBefore;

        require(actualAmount > 0, "no amount was transferred");

        locker.amount += actualAmount;

        emit ChangedAmount(previousAmount, actualAmount);
    }

    function transferOwnership(address owner) external onlyOwner nonReentrant {
        locker.owner = owner;
        emit ChangedOwner(msg.sender, owner);
    }

    function claim() external onlyOwner nonReentrant {
        require(!locker.claimed, "already claimed");

        uint256 currentAmountUnlocked = locker.amount -
            getInfo().currentAmountLocked;

        require(
            currentAmountUnlocked > locker.releasedAmount,
            "there are no claimable tokens"
        );

        uint256 claimableAmount = currentAmountUnlocked - locker.releasedAmount;

        locker.releasedAmount += claimableAmount;

        if (locker.vest) {
            locker.vestClaimedPercentage = uint16(
                (currentAmountUnlocked * PERCENTAGE_PRECISION) / locker.amount
            );

            locker.claimed =
                locker.vestClaimedPercentage >= PERCENTAGE_PRECISION;
        } else {
            locker.claimed = true;
        }

        require(
            IERC20Metadata(locker.tokenAddress).transfer(
                locker.owner,
                claimableAmount
            ),
            "transfer failed"
        );

        emit Claimed(claimableAmount);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "./locker.sol";

contract LockerFactory is Initializable {
    struct AddressInfo {
        uint8 decimals;
        uint256 totalSupply;
        bool pair;
        string tokenName;
        string tokenSymbol;
        string pairToken1Name;
        address pairToken1Address;
        string pairToken2Name;
        address pairToken2Address;
        address pairDexAddress;
    }

    struct Token {
        address tokenAddress;
        uint8 decimals;
        uint256 totalSupply;
        bool pair;
        string pairToken1Name;
        address pairToken1Address;
        string pairToken2Name;
        address pairToken2Address;
        address pairDexAddress;
        string tokenName;
        string tokenSymbol;
        uint256 totalAmountLocked;
        uint256 currentAmountLocked;
        Locker[] lockerAddresses;
    }

    Locker[] public lockers;
    address[] public tokens;
    address[] public lpTokens;
    mapping(address => Locker[]) public lockersByToken;
    bool locking;

    event Locked(
        address tokenAddress,
        address lockerAddress,
        uint256 amount,
        bool vest
    );

    function initialize() external initializer {}

    function lock(Locker.SLockDescriptor memory lockDescriptor) external {
        if (locking) return;

        locking = true;

        Locker locker = new Locker();

        uint256 lockerBalanceBefore = IERC20Metadata(
            lockDescriptor.tokenAddress
        ).balanceOf(address(locker));

        require(
            IERC20Metadata(lockDescriptor.tokenAddress).transferFrom(
                msg.sender,
                address(locker),
                lockDescriptor.amount
            ),
            "transfer failed"
        );

        uint256 transferredAmount = IERC20Metadata(lockDescriptor.tokenAddress)
            .balanceOf(address(locker)) - lockerBalanceBefore;

        lockDescriptor.amount = transferredAmount;

        locker.lock(lockDescriptor);

        if (lockersByToken[lockDescriptor.tokenAddress].length == 0) {
            address factory = getFactoryAddress(lockDescriptor.tokenAddress);

            address[] storage ntokens = factory == address(0)
                ? tokens
                : lpTokens;

            ntokens.push(lockDescriptor.tokenAddress);
        }

        lockers.push(locker);
        lockersByToken[lockDescriptor.tokenAddress].push(locker);

        emit Locked(
            lockDescriptor.tokenAddress,
            address(locker),
            lockDescriptor.amount,
            lockDescriptor.vest
        );

        locking = false;
    }

    function getFactoryAddress(address token) public view returns (address) {
        address possibleFactory;
        try IUniswapV2Pair(token).factory() returns (address factory) {
            possibleFactory = factory;
        } catch {}

        if (possibleFactory == address(0)) return address(0);

        address possiblePair;
        try
            IUniswapV2Factory(possibleFactory).getPair(
                IUniswapV2Pair(token).token0(),
                IUniswapV2Pair(token).token1()
            )
        returns (address pair) {
            possiblePair = pair;
        } catch {}

        if (possiblePair != token) return address(0);

        return possiblePair == token ? possibleFactory : address(0);
    }

    function getAddressInfo(address token)
        public
        view
        returns (AddressInfo memory)
    {
        address factory = getFactoryAddress(token);

        if (factory != address(0)) {
            address token0 = IUniswapV2Pair(token).token0();
            address token1 = IUniswapV2Pair(token).token1();

            return
                AddressInfo({
                    decimals: IUniswapV2Pair(token).decimals(),
                    totalSupply: IUniswapV2Pair(token).totalSupply(),
                    pair: true,
                    tokenName: "",
                    tokenSymbol: "",
                    pairToken1Name: IERC20Metadata(token0).name(),
                    pairToken1Address: token0,
                    pairToken2Name: IERC20Metadata(token1).name(),
                    pairToken2Address: token1,
                    pairDexAddress: factory
                });
        }

        return
            AddressInfo({
                decimals: IERC20Metadata(token).decimals(),
                totalSupply: IERC20Metadata(token).totalSupply(),
                pair: false,
                tokenName: IERC20Metadata(token).name(),
                tokenSymbol: IERC20Metadata(token).symbol(),
                pairToken1Name: "",
                pairToken1Address: address(0),
                pairToken2Name: "",
                pairToken2Address: address(0),
                pairDexAddress: address(0)
            });
    }

    function getToken(address tokenAddress)
        public
        view
        returns (Token memory token, Locker.SLocker[] memory tokenLockers)
    {
        Locker[] memory lockerAddresses = lockersByToken[tokenAddress];

        tokenLockers = new Locker.SLocker[](lockerAddresses.length);

        uint256 totalAmountLocked = 0;
        uint256 currentAmountLocked = 0;

        for (uint256 i = 0; i < lockerAddresses.length; ++i) {
            Locker.SLocker memory locker = lockerAddresses[i].getInfo();

            tokenLockers[i] = locker;

            totalAmountLocked += locker.amount;
            currentAmountLocked += locker.currentAmountLocked;
        }

        AddressInfo memory addressInfo = getAddressInfo(tokenAddress);

        token = Token({
            tokenAddress: tokenAddress,
            decimals: addressInfo.decimals,
            totalSupply: addressInfo.totalSupply,
            pair: addressInfo.pair,
            pairToken1Name: addressInfo.pairToken1Name,
            pairToken1Address: addressInfo.pairToken1Address,
            pairToken2Name: addressInfo.pairToken2Name,
            pairToken2Address: addressInfo.pairToken2Address,
            pairDexAddress: addressInfo.pairDexAddress,
            tokenName: addressInfo.tokenName,
            tokenSymbol: addressInfo.tokenSymbol,
            totalAmountLocked: totalAmountLocked,
            currentAmountLocked: currentAmountLocked,
            lockerAddresses: lockerAddresses
        });
    }

    function getLocker(address lockerAddress)
        external
        view
        returns (Token memory token, Locker.SLocker[] memory tokenLockers)
    {
        return getToken(Locker(lockerAddress).getLocker().tokenAddress);
    }

    function getTokens(
        bool lp,
        uint256 page,
        uint256 pageSize,
        address token
    ) external view returns (Token[] memory pageTokens, uint256 total) {
        address[] memory ntokens = lp ? lpTokens : tokens;

        total = ntokens.length;

        if (token != address(0)) {
            if (lockersByToken[token].length == 0) return (pageTokens, total);

            (Token memory tokenInfo, ) = getToken(token);

            pageTokens = new Token[](1);
            pageTokens[0] = tokenInfo;

            return (pageTokens, total);
        }

        uint256 startIndex = page * pageSize;

        if (ntokens.length < startIndex) return (pageTokens, total);

        uint256 length = ntokens.length > (startIndex + pageSize)
            ? pageSize
            : ntokens.length - startIndex;

        pageTokens = new Token[](length);

        for (uint256 i = 0; i < length; ++i) {
            (Token memory tokenInfo, ) = getToken(ntokens[startIndex + i]);
            pageTokens[i] = tokenInfo;
        }

        return (pageTokens, total);
    }

    function getLockerByIndex(uint256 index) external view returns (Locker) {
        return lockers[index];
    }
}