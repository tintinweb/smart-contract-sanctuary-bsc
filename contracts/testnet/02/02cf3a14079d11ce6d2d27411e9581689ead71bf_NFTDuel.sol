/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// Sources flattened with hardhat v2.9.3 https://hardhat.org

// File @openzeppelin/contracts-upgradeable/utils/math/[email protected]


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


// File @openzeppelin/contracts-upgradeable/utils/[email protected]


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


// File @openzeppelin/contracts-upgradeable/proxy/utils/[email protected]


// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

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
        bool isTopLevelCall = _setInitializedVersion(1);
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
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
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
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}


// File @openzeppelin/contracts-upgradeable/utils/[email protected]


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


// File @openzeppelin/contracts-upgradeable/access/[email protected]


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}


// File contracts/NFTDUEL/BNFT.sol

pragma solidity ^0.8.0;
interface BNFT {
    function mint(address to_, uint256 countNFTs_) external returns (uint256, uint256);
    function burnAdmin(uint256 tokenId) external;
    function TransferFromAdmin(uint256 tokenId, address to) external;
}


// File @openzeppelin/contracts/utils/[email protected]


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

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


// File contracts/NFTDUEL/IERC20.sol

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;

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
     function withdraw(uint) external;
    function deposit() payable external;
    function mint(address recipient, uint256 amount) external returns(bool);
}


// File contracts/NFTDUEL/NFTDUELStorage.sol

pragma solidity ^0.8.0;
contract NFTDUELStorage {
  using SafeMathUpgradeable for uint256;
   address admin;
   //league e.g bronze 2 => 2 and so on
   mapping(string => uint256) dailyRewardMultiplyer;

   struct League {
    uint256 seriesId;
    uint256 startTime;
    uint256 endTime;
   }

   mapping (uint256=>League) season;
   //user struct
   struct User{
     string league;
     uint256 points;
     uint256 missionCount;
     uint256 chests;
     uint256[] chestRewards;
     uint256 fuel;
     uint256 wins;
    uint256 loses;
    uint256 draws;
   }

   mapping (address => mapping(uint256 => uint256)) public _userDailyBattles;
   uint256 internal gameStartTime;

   mapping (address=> uint256[]) public _userDuelIds;

   // user address => user detail
   mapping(address => User) public users;
   Counters.Counter _leagueId;
   Counters.Counter _duelId;
   struct Deul{
       address winner;
       address loser;
       uint256 leagueId;
    //    string league;
       address user;
       address oponent;
       uint256 duelTime;
       uint256 duelEndTime;
       bool isDraw;
   }
   mapping (uint256=>Deul) public _deulDetail;

   mapping (address=> bool) public userInDuel;

   mapping (uint256=>string) leagues;
   // how much points must be deducted or added 
   mapping (string=> uint256) points;
   mapping (string=> uint256) public minimumStakeAmount;
   mapping (string=> uint256) public fuelConsume;
  
   //for duel token
   IERC20 duelToken;
   // for rare nft
   BNFT nft;
   uint256 averageDuelValue; //average duel value
   uint256 upAverage; // 20 % up avrage value
   uint256 downAverage; // 20% down average value

   uint256 dailyMaxChest;
   uint256 missionToGetOneChest;
   uint256 missionCountToday;

   uint256[] public rewards;  

   uint256 seed; 
}


// File contracts/NFTDUEL/NFTDUEL.sol

pragma solidity ^0.8.0;
contract NFTDuel is OwnableUpgradeable, NFTDUELStorage {
using Counters for Counters.Counter;
using SafeMathUpgradeable for uint256;

   function initialize() public virtual initializer {
		
		__Ownable_init();
       
      admin = msg.sender;
		
	}
   function setAdmin(address _admin) onlyOwner public {
       admin = _admin;
   } 


   modifier onlyAdmin() {
       require(admin == msg.sender);
       _;
   }

   function init( address _nft, address _deulToken) onlyOwner public {
       seed = 478959347695;
       nft = BNFT(_nft);
       duelToken = IERC20(_deulToken);

   }

    //to set leagues daily multiplyer
   function setLeaguesDailyMultiplyer(string[] memory _leagues, uint256[] memory multiplyer ) onlyOwner public {
       require(_leagues.length == multiplyer.length, "invalid data");
       for (uint256 index = 0; index < _leagues.length; index++) {
          
           dailyRewardMultiplyer[leagues[index]] = multiplyer[index];
       }
   }

   function setDailyMaxChest(uint256 _dailyMaxChest) onlyOwner public {
       dailyMaxChest = _dailyMaxChest;
   }

   function setMissionCountToday(uint256 _missionCountToday) onlyOwner public {
       missionCountToday = _missionCountToday;
   }

   function setMissionToGetOneChest(uint256 _missionToGetOneChest) onlyOwner public {
       missionToGetOneChest = _missionToGetOneChest;
   }

   function startSeason(uint256 seriesId, uint256 startTime, uint256 endTime) onlyOwner public {
    require(season[_leagueId.current()].endTime < block.timestamp, "season on going");
    _leagueId.increment();

    season[_leagueId.current()] = League(seriesId, startTime, endTime);

   }

   function leaguesDefinition(uint256 start, uint256 end, string memory league, uint256 point) onlyOwner public {
       points[league] = point;
       for (uint256 index = start; index <= end; index++) {
           leagues[index] = league;
       }
   }
   
   //update user leagues data
   function updateUserData(address[] memory addresses, User[] memory _users) onlyOwner public {
       require(addresses.length == _users.length, "invalid data");
       for (uint256 index = 0; index < addresses.length; index++) {
           users[addresses[index]] = _users[index];
       }
   }

  function calculateWinnerLeaguePoints(address winner, address loser) internal {
      users[winner].points = users[winner].points + points[users[loser].league];
      if(points[users[loser].league] > users[loser].points){
          users[loser].points = 0;
      } else {
          users[loser].points = users[loser].points - points[users[loser].league];
      }
      
  }

  function getTodayBattleRecord(address _add) public view returns(uint256) {
    uint256 daysDiff = block.timestamp.sub(gameStartTime).div(1 days);
    return _userDailyBattles[_add][daysDiff];
  }

  function setGameStartTime(uint256 time) onlyOwner public {
    gameStartTime = time;
  }

  /**
@notice function to calculate league
 @param user user address 
 Note only aadmin can call this function
 */

  function leagueCalculation(address user) internal {
      User storage tempUser = users[user];
      tempUser.league = leagues[tempUser.points];
  }

   /**
@notice function to update end of duel of league and calculate duel points
 @param duelId on goin leagueId
 @param winner challenger 
 @param loser other player
 Note only aadmin can call this function
 */
  function duelEnded(uint256 duelId, address winner, address loser, string memory league, uint256 lp, bool isDraw) onlyAdmin public {
   
    require(_deulDetail[duelId].user == winner || _deulDetail[duelId].oponent == winner || isDraw, "winner not belong to duel");
    require(_deulDetail[duelId].user == loser || _deulDetail[duelId].oponent == loser || isDraw, "loser not belong to duel");
    _deulDetail[duelId] = Deul(winner, loser, _deulDetail[duelId].leagueId, _deulDetail[duelId].user, _deulDetail[duelId].oponent, _deulDetail[duelId].duelTime, block.timestamp, isDraw);
    users[_deulDetail[duelId].user].league = league;
    users[_deulDetail[duelId].user].points = lp;
    if(_deulDetail[duelId].user == winner){
        users[_deulDetail[duelId].user].wins++;
    }else if(isDraw){
         users[_deulDetail[duelId].user].draws++;

    } else {
         users[_deulDetail[duelId].user].loses++;
    }

    uint256 daysDiff = block.timestamp.sub(gameStartTime).div(1 days);
    _userDailyBattles[_deulDetail[duelId].user][daysDiff]++;
    userInDuel[_deulDetail[duelId].user] = false;
  }

  function getUserInduel(address _userAddress) public view returns(bool,address,uint256){
    uint256 lastDuelId = _userDuelIds[_userAddress].length > 0 ? _userDuelIds[_userAddress][_userDuelIds[_userAddress].length - 1] : 0;
    return (userInDuel[_userAddress], _deulDetail[lastDuelId].oponent, lastDuelId);
  }

   /**
@notice function to update start of duel
 @param _user challenger 
 @param oponent other player
 Note only aadmin can call this function
 */

  function duelStarted(uint256 _duelId,  address _user, address oponent) onlyAdmin public {
    uint256 lastDuelId = _userDuelIds[_user].length > 0 ? _userDuelIds[_user][_userDuelIds[_user].length - 1] : 0;
    require(!userInDuel[_user] && ((_duelId == lastDuelId || !userInDuel[oponent]) || oponent == address(0x0)), "on of players already in duel");
    require(users[_user].fuel >= fuelConsume[users[_user].league], "user does not have enough fuel" );
    if( _deulDetail[_duelId].duelTime > 0){
        require( _deulDetail[_duelId].oponent == _user, "not valid duel");
    } else {
    _deulDetail[_duelId] = Deul(address(0x0), address(0x0),0, _user, oponent, block.timestamp, 0, false);
        
    }
    users[_user].fuel -=fuelConsume[users[_user].league];
    userInDuel[_user] = true;
    _userDuelIds[_user].push(_duelId);
  }

  function getUserDuelId(address _user) public view returns(uint256[] memory) {
       return _userDuelIds[_user];
  }

  function updateUserDailyMission(address user, uint256 mission) onlyAdmin public {
      users[user].missionCount = mission;
  }

  function updateUsersDailyMission(address[] memory user, uint256[] memory mission) onlyAdmin public {
   
    require(user.length == mission.length, "invalid data");
    for (uint256 index = 0; index < user.length; index++) {
        users[user[index]].missionCount = mission[index];
    }
  }

  function setAverageValue(uint256 value) onlyOwner public {
      averageDuelValue = value;
      upAverage = averageDuelValue + (averageDuelValue * 20) / 100;
      downAverage = averageDuelValue - (averageDuelValue * 20) / 100;
  }


    function userClaimChests() public {
        require(users[msg.sender].missionCount > 0, "not applicable");
        User memory tempUser= users[msg.sender];
        users[msg.sender].missionCount = 0;
        uint256 userClaimable;
        
        uint256 rand = seed;
        if(tempUser.missionCount == missionCountToday){
            userClaimable = dailyMaxChest + dailyRewardMultiplyer[tempUser.league];
            users[msg.sender].chests = userClaimable;
            
        }else {
            userClaimable = tempUser.missionCount.div(missionToGetOneChest) + dailyRewardMultiplyer[tempUser.league];
        }
        for (uint256 index = 0; index < userClaimable; index++) {
             uint256 indexReward = uint256(keccak256(abi.encodePacked(block.coinbase, rand, msg.sender, block.timestamp))).mod(10);
            users[msg.sender].chestRewards.push(rewards[indexReward]);
        }
        
    }

    function userOpenChest() public {
        require(users[msg.sender].chestRewards.length > 0, "not applicable");
        uint256[] memory tempChestRewards = users[msg.sender].chestRewards;
        // delete users[msg.sender].chestRewards;
        uint256 tokenToMint = 0;
        uint256 nftToMint = 0;
        for (uint256 index = 0; index < tempChestRewards.length; index++) {
            if(tempChestRewards[index] == 0){
                nftToMint++;
            }else {
                tokenToMint += tempChestRewards[index];
            }
        }
        if(nftToMint > 0) nft.mint(msg.sender, nftToMint);
        if(tokenToMint > 0) duelToken.mint(msg.sender, tokenToMint);
    }
 

    function rewardArray() onlyOwner public {
       
        uint256 rand = seed;
        uint256 nftCounter;
        for (uint256 index = 0; index < 10; index++) {
            uint256 choose = uint256(keccak256(abi.encodePacked(block.coinbase, rand, msg.sender, index))).mod(2);
            if(choose != 0){
                uint256 choose2 = uint256(keccak256(abi.encodePacked(block.coinbase, rand, msg.sender, index))).mod(2);
                if(choose2 != 0 || nftCounter >=3){
                    rewards[index] = upAverage;
                }else {
                    rewards[index] = downAverage;
                }
            }else {
                rewards[index] = choose;
                nftCounter++;
            }
        }
    }


    function buyFuel() public payable {
        require(msg.sender == tx.origin, "invalid sender");
        uint256 amount =  calculateFuelAmount(msg.sender);
        uint256 deposit = msg.value;
        require(deposit >= amount, "not enough amount");
        
        users[msg.sender].fuel += deposit;
        emit FuelBought(msg.sender, amount);
    }



    function calculateFuelAmount(address _add) public view returns(uint256) {
        User storage tempUser =  users[_add];
        uint256 minimumAmount = minimumStakeAmount[tempUser.league];
        if(minimumAmount > tempUser.fuel){
            return minimumAmount - tempUser.fuel;
        } else {
            return 0;
        }
    }

    function setMinimumFuelAmount(string[] memory _leagues, uint256[] memory _minimumAmount, uint256[] memory minimumFuel) onlyOwner public {

        for (uint256 index = 0; index < _leagues.length; index++) {
            minimumStakeAmount[_leagues[index]] = _minimumAmount[index];
            fuelConsume[_leagues[index]] = minimumFuel[index];
        }
    }

     function withdraw() public onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }


    receive() external payable {}
    fallback() external payable {}

    event FuelBought(address from, uint256 amount);
    

}