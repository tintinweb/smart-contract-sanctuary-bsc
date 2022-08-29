/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// Dependency file: @openzeppelin/contracts/math/Math.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.7.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


// Dependency file: @openzeppelin/contracts/math/SafeMath.sol


// pragma solidity ^0.7.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}


// Dependency file: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol


// pragma solidity ^0.7.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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


// Dependency file: @openzeppelin/contracts-upgradeable/proxy/Initializable.sol


// solhint-disable-next-line compiler-version
// pragma solidity >=0.4.24 <0.8.0;

// import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
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
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}


// Dependency file: @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol


// pragma solidity >=0.6.0 <0.8.0;
// import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}


// Dependency file: @openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol


// pragma solidity ^0.7.0;

// import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
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
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}


// Dependency file: @openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol


// pragma solidity ^0.7.0;

// import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}


// Dependency file: @openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol


// pragma solidity ^0.7.0;
// import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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
    uint256[49] private __gap;
}


// Dependency file: contracts/Constants.sol


// pragma solidity 0.7.6;

library Constants {
    ////////// Oracle //////////

    int256 internal constant ORACLE_MINT_PRECISION = 100; // 1% deltaD

    ////////// Env Contracts //////////

    // BSC mainnet - Ellipsis: 3EPS Stable Swap
    address internal constant CURVE_3POOL_ADDRESS = 0x160CAed03795365F3A589f10C379FfA7d75d4E76;

    ////////// Epoch //////////

    uint256 internal constant EPOCH_CURRENT_LENGTH = 1 hours;

    // The number of epochs required to Withdraw a Deposit.
    uint32 internal constant EPOCH_REQUIRE_FOR_WITHDRAWALS = 6;

    ////////// Credit //////////

    // Number of new Dollars supply will be distribute to debt line
    uint256 internal constant CREDIT_DOLLAR_DISTRIBUTION_RATE = 40e18; // 40% new supply

    // The debt rates
    uint256 internal constant CREDIT_DEBT_OPTIMAL_RATE = 15e18; // 15%

    // The bonds demand rates
    uint256 internal constant CREDIT_BOND_DEMAND_HIGH_RATE = 10e18; // 10% remain bonds - demand increasing
    uint256 internal constant CREDIT_BOND_DEMAND_LOW_RATE = 50e18; // 50% remain bonds  - demand decreasing

    // The bonds emission rate
    uint256 internal constant CREDIT_BOND_EMISSION_WHEN_HIGH_DEBT_RATE = 0.5e18; // 0.5%
    uint256 internal constant CREDIT_BOND_EMISSION_WHEN_LOW_DEBT_RATE = 1e18; // 1%

    // The credit interest
    uint256 internal constant CREDIT_INTEREST_MEANING_RATE = 100e18; // 100%
    uint256 internal constant CREDIT_INTEREST_LOW_JUMP_RATE = 0.5e18; // 0.5%
    uint256 internal constant CREDIT_INTEREST_MEDIUM_JUMP_RATE = 1e18; // 1%
    uint256 internal constant CREDIT_INTEREST_HIGH_JUMP_RATE = 3e18; // 3%
    uint256 internal constant CREDIT_INTEREST_SUPER_JUMP_RATE = 6e18; // 6%

    ////////// Staking //////////

    // Shares balance growth 1/10000 per papers balance
    uint256 internal constant DAO_SHARES_GROWTH_PER_PAPER_RATE = 10000;

    // Papers balance per DDV
    uint256 internal constant DAO_PAPERS_PER_DDV_RATE = 2;
}


// Dependency file: contracts/interfaces/ICurve.sol


// pragma solidity 0.7.6;


interface ICurvePool {
    function A_precise() external view returns (uint256);

    function get_balances() external view returns (uint256[2] memory);

    function totalSupply() external view returns (uint256);

    function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount) external returns (uint256);

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_amount
    ) external returns (uint256);

    function balances(int128 i) external view returns (uint256);

    function fee() external view returns (uint256);

    function coins(uint256 i) external view returns (address);

    function get_virtual_price() external view returns (uint256);

    function calc_token_amount(uint256[2] calldata amounts, bool deposit) external view returns (uint256);

    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);

    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
}

interface ICurveZap {
    function add_liquidity(
        address _pool,
        uint256[4] memory _deposit_amounts,
        uint256 _min_mint_amount
    ) external returns (uint256);

    function calc_token_amount(
        address _pool,
        uint256[4] memory _amounts,
        bool _is_deposit
    ) external returns (uint256);
}

interface ICurvePoolR {
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy,
        address receiver
    ) external returns (uint256);

    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy,
        address receiver
    ) external returns (uint256);

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_amount,
        address receiver
    ) external returns (uint256);
}

interface ICurvePool2R {
    function add_liquidity(
        uint256[2] memory amounts,
        uint256 min_mint_amount,
        address receiver
    ) external returns (uint256);

    function remove_liquidity(
        uint256 _burn_amount,
        uint256[2] memory _min_amounts,
        address receiver
    ) external returns (uint256[2] calldata);

    function remove_liquidity_imbalance(
        uint256[2] memory _amounts,
        uint256 _max_burn_amount,
        address receiver
    ) external returns (uint256);
}

interface ICurvePool3R {
    function add_liquidity(
        uint256[3] memory amounts,
        uint256 min_mint_amount,
        address receiver
    ) external returns (uint256);

    function remove_liquidity(
        uint256 _burn_amount,
        uint256[3] memory _min_amounts,
        address receiver
    ) external returns (uint256[3] calldata);

    function remove_liquidity_imbalance(
        uint256[3] memory _amounts,
        uint256 _max_burn_amount,
        address receiver
    ) external returns (uint256);
}

interface ICurvePool4R {
    function add_liquidity(
        uint256[4] memory amounts,
        uint256 min_mint_amount,
        address receiver
    ) external returns (uint256);

    function remove_liquidity(
        uint256 _burn_amount,
        uint256[4] memory _min_amounts,
        address receiver
    ) external returns (uint256[4] calldata);

    function remove_liquidity_imbalance(
        uint256[4] memory _amounts,
        uint256 _max_burn_amount,
        address receiver
    ) external returns (uint256);
}

interface I3Curve {
    function get_virtual_price() external view returns (uint256);
}

interface ICurveFactory {
    function get_coins(address _pool) external view returns (address[4] calldata);

    function get_underlying_coins(address _pool) external view returns (address[8] calldata);
}

interface ICurveCryptoFactory {
    function get_coins(address _pool) external view returns (address[8] calldata);
}

interface ICurvePoolC {
    function exchange(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);
}

interface ICurvePoolNoReturn {
    function exchange(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy
    ) external;

    function add_liquidity(uint256[3] memory amounts, uint256 min_mint_amount) external;

    function remove_liquidity(uint256 _burn_amount, uint256[3] memory _min_amounts) external;

    function remove_liquidity_imbalance(uint256[3] memory _amounts, uint256 _max_burn_amount) external;

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        uint256 i,
        uint256 min_amount
    ) external;
}

interface ICurvePoolNoReturn128 {
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_amount
    ) external;
}

interface IMeta3CurveOracle {
    function block_timestamp_last() external view returns (uint256);

    function get_price_cumulative_last() external view returns (uint256[2] memory);

    function get_balances() external view returns (uint256[2] memory);
}

interface IMeta3Curve {
    function A_precise() external view returns (uint256);

    function get_previous_balances() external view returns (uint256[2] memory);

    function get_virtual_price() external view returns (uint256);
}


// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol


// pragma solidity ^0.7.0;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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


// Dependency file: contracts/interfaces/IDollar.sol


// pragma solidity 0.7.6;


// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDollar is IERC20 {
    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    function mint(address account, uint256 amount) external;
}


// Dependency file: contracts/interfaces/IOracle.sol


// pragma solidity 0.7.6;


interface IOracle {
    function stepOracle() external returns (int256 deltaD);

    function ddv(address token, uint256 amount) external view returns (uint256);
}


// Dependency file: contracts/libraries/LibSafeMath32.sol

// pragma solidity 0.7.6;

library LibSafeMath32 {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint32 a, uint32 b) internal pure returns (bool, uint32) {
        uint32 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint32 a, uint32 b) internal pure returns (bool, uint32) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint32 a, uint32 b) internal pure returns (bool, uint32) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint32 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint32 a, uint32 b) internal pure returns (bool, uint32) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint32 a, uint32 b) internal pure returns (bool, uint32) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
    function add(uint32 a, uint32 b) internal pure returns (uint32) {
        uint32 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
    function sub(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b <= a, "SafeMath: subtraction overflow");
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
    function mul(uint32 a, uint32 b) internal pure returns (uint32) {
        if (a == 0) return 0;
        uint32 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b > 0, "SafeMath: division by zero");
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
    function mod(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b > 0, "SafeMath: modulo by zero");
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
        uint32 a,
        uint32 b,
        string memory errorMessage
    ) internal pure returns (uint32) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        uint32 a,
        uint32 b,
        string memory errorMessage
    ) internal pure returns (uint32) {
        require(b > 0, errorMessage);
        return a / b;
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
        uint32 a,
        uint32 b,
        string memory errorMessage
    ) internal pure returns (uint32) {
        require(b > 0, errorMessage);
        return a % b;
    }
}


// Dependency file: contracts/dao/1_Storage.sol


// pragma solidity 0.7.6;


// import "@openzeppelin/contracts/math/Math.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

// import "contracts/Constants.sol";
// import "contracts/interfaces/ICurve.sol";
// import "contracts/interfaces/IDollar.sol";
// import "contracts/interfaces/IOracle.sol";
// import "contracts/libraries/LibSafeMath32.sol";

contract DaoStorage is OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {
    ////////// Data Types //////////

    enum TransferMode {
        INTERNAL,
        EXTERNAL
    }

    ////////// Account Data //////////

    struct DepositInfo {
        // The amount of Tokens in the Deposit.
        uint256 amount;
        // The Dollar-denominated-value in the Deposit.
        uint256 ddv;
    }

    // WithdrawalInfo represents a Withdrawal in the Dao of a given Token at a given Epoch.
    struct WithdrawalInfo {
        // The amount of Tokens in the Withdrawal.
        uint256 amount;
        // The claimableEpoch when withdrawal can be claim.
        uint32 epoch;
    }

    // The AccountInfo level State stores all of the account's balances in the contract.
    struct AccountInfo {
        ////////// Credit info //////////

        // A account's debtSlots. Maps from Debt Slot index to Debt amount.
        mapping(uint256 => uint256) debtSlots;
        // An allowance mapping for Debts similar to that of the ERC-20 standard. Maps from spender address to allowance amount.
        mapping(address => uint256) debtAllowances;
        ////////// DAO info //////////

        // Balance of the account's normal papers.
        uint256 papers;
        // Balance of the account's normal shares.
        uint256 shares;
        // Balance of the account's normal claimed.
        uint256 claimed;
        // Balance DDV of account
        uint256 ddv;
        // Last epoch when account updated on DAO
        uint32 lastEpochUpdated;
        // A account's Deposits stored as a map from Token address to Balance.
        mapping(address => DepositInfo) deposits;
        // A account's Withdrawals from the DAO stored as a map from Token address to Season the Withdrawal becomes Claimable to Withdrawn amount of Tokens.
        mapping(address => WithdrawalInfo) withdrawals;
    }

    ////////// DAO Data //////////

    // DaoCreditInfo stores global Credit balances.
    struct DaoCreditInfo {
        // The number of bonds currently available for purchased.
        uint256 bonds;
        // The debt index; the total number of debts ever minted.
        uint256 debts;
        // The redeemed index; the total number of Debts that have ever been Redeemed.
        uint256 redeemed;
        // The redeemable index; the total number of Debts that have ever been Redeemable. Included previously Redeemed Dollars.
        uint256 redeemable;
        // The current bonding interest rate
        uint256 interest;
        // Total bond amount at the beginning of last epoch
        uint256 startBonds;
    }

    // DaoStakeInfo stores global level Stake balances.
    struct DaoStakeInfo {
        // The total amount of active Papers balance.
        uint256 papers;
        // The total amount of active Shares balance.
        uint256 shares;
    }

    // DaoBalanceInfo stores global Token level DAO balances.
    struct DaoBalanceInfo {
        // The total number of a given Token currently Deposited in the DAO.
        uint256 deposited;
        // The total number of a given Token currently Withdrawn From the DAO but not Claimed.
        uint256 withdrawn;
    }

    // DaoAssetInfo stores global DAO whitelisted assets which can be deposited to earn Dollar.
    struct DaoAssetInfo {
        // The Papers Per DDV that the Dao mints in exchange for Depositing this Token.
        // Whitelisted asset should have a greater than zero value
        uint256 papersPerDDV;
        // The Shares Per DDV that the Dao mints in exchange for Depositing this Token.
        uint256 sharesPerDDV;
    }

    ////////// Epoch Data //////////

    // EpochInfo stores global level Epoch balances.
    struct EpochInfo {
        // The current Epoch in Dollar Dao.
        uint32 current;
        // The timestamp of the start of the current Epoch.
        uint256 timestamp;
        // The timestamp of the DAO deployment rounded down to the nearest hour.
        uint256 start;
    }

    ////////// Market Data //////////

    struct DebtListing {
        address account;
        uint256 index;
        uint256 start;
        uint256 amount;
        uint24 pricePerDebt;
        uint256 maxHarvestableIndex;
        TransferMode mode;
    }

    struct DebtOrder {
        address account;
        uint24 pricePerDebt;
        uint256 maxPlaceInLine;
    }

    ////////// DAO Storages //////////

    // The number of Dollars distributed to the DAO that have not yet been Deposited as a result of the Earn function being called.
    uint256 public earnedDollar;

    // DAO staking info
    DaoStakeInfo public stakeInfo;

    // DAO credit info
    DaoCreditInfo public creditInfo;

    // DAO epoch info
    EpochInfo public epochInfo;

    // A mapping from Staker address to Account state.
    mapping(address => AccountInfo) public accountInfo;

    // A mapping from Token address to Dao Balance storage (amount deposited and withdrawn).
    mapping(address => DaoBalanceInfo) public daoBalances;

    // A mapping from Token address to Dao Asset storage.
    mapping(address => DaoAssetInfo) public daoAssets;

    ////////// Market Storages //////////

    // A mapping from the hash of a Debt Order to the amount of Pods that the Debt Order is still willing to buy.
    mapping(bytes32 => uint256) debtOrders;

    // A mapping from Slot Index to the hash of the Debt Listing.
    mapping(uint256 => bytes32) debtListings;

    ////////// Configurations //////////

    address public dollar;
    address public oracle;

    ////////// More Storages //////////

    // More storage will be added after this line later
}


// Dependency file: contracts/dao/2_Epoch.sol


// pragma solidity 0.7.6;


// import "contracts/dao/1_Storage.sol";

contract DaoEpoch is DaoStorage {
    using SafeMath for uint256;

    event Advanced(uint256 indexed epoch, uint256 indexed timestamp);
    event NewSupply(uint32 indexed epoch, uint256 toBonding, uint256 toStaking);
    event NewBonds(uint32 indexed epoch, uint256 bonds);
    event NewInterestRate(
        uint32 indexed epoch,
        uint256 debtRate,
        uint256 bondDemand,
        uint256 oldInterest,
        uint256 newInterest
    );

    // Advance to the next epoch
    function advance() external whenNotPaused nonReentrant {
        require(epochTime() > epochInfo.current, "Epoch: still current epoch");

        epochInfo.timestamp = block.timestamp;
        epochInfo.current = epochInfo.current + 1;

        // Check and update oracle
        int256 deltaD = IOracle(oracle).stepOracle();

        // Calculate new supply and debts
        stepSupply(deltaD);

        emit Advanced(epochInfo.current, epochInfo.timestamp);
    }

    function epochTime() public view returns (uint32) {
        // Epoch has not start yet
        if (block.timestamp < epochInfo.start) return 0;

        return uint32((block.timestamp - epochInfo.start) / Constants.EPOCH_CURRENT_LENGTH);
    }

    // Check deltaD, mint new Dollars and issues new debts
    function stepSupply(int256 deltaD) internal {
        if (deltaD > 0) {
            rewardDollars(uint256(deltaD));
        }

        stepCredit(deltaD);
    }

    function rewardDollars(uint256 newSupply) internal {
        IDollar(dollar).mint(address(this), newSupply);

        uint256 newRedeemable;

        // If debts are greater than redeemable, we need to distribute dollars into debts repay
        if (creditInfo.redeemable < creditInfo.debts) {
            uint256 notRedeemable = creditInfo.debts - creditInfo.redeemable;
            newRedeemable = newSupply.mul(Constants.CREDIT_DOLLAR_DISTRIBUTION_RATE).div(100e18);
            newRedeemable = newRedeemable > notRedeemable ? notRedeemable : newRedeemable;

            // Update DAO credit state
            creditInfo.redeemable = creditInfo.redeemable.add(newRedeemable);

            // Adjust new supply
            newSupply = newSupply.sub(newRedeemable);
        }

        // Reward supply to DAO
        earnedDollar = earnedDollar.add(newSupply);

        emit NewSupply(epochInfo.current, newRedeemable, newSupply);
    }

    function stepCredit(int256 deltaD) internal {
        uint256 dollarSupply = IERC20(dollar).totalSupply();
        if (dollarSupply == 0) return;

        // DebtRate = (DebtsTotal - DebtsRedeemable) / DollarSupply
        uint256 debtRate = creditInfo.debts.sub(creditInfo.redeemable).mul(100e18).div(dollarSupply);
        if (debtRate == 0) return;

        // DeltaBondDemand = EpochStartBonds - EpochEndBonds
        uint256 deltaBondDemand = creditInfo.startBonds.sub(creditInfo.bonds);
        // BondDemand = DeltaBondDemand / EpochStartBonds
        uint256 bondDemand = deltaBondDemand.mul(100e18).div(creditInfo.startBonds);

        if (deltaD < 0) {
            setBondInterestBelowPeg(deltaD, debtRate, bondDemand);
        } else if (deltaD > 0) {
            setBondInterestAbovePeg(deltaD, debtRate, bondDemand);
        }

        // Snapshot epoch start bonds amount
        creditInfo.startBonds = creditInfo.bonds;

        emit NewBonds(epochInfo.current, creditInfo.bonds);
    }

    function setBondInterestAbovePeg(
        int256 deltaD,
        uint256 debtRate,
        uint256 bondDemand
    ) internal {
        if (debtRate < Constants.CREDIT_DEBT_OPTIMAL_RATE) {
            // low debt rate
            if (bondDemand < Constants.CREDIT_BOND_DEMAND_HIGH_RATE) {
                // high bond demand
                if (creditInfo.interest > Constants.CREDIT_INTEREST_MEANING_RATE) {
                    updateCreditInterest(false, debtRate, bondDemand, Constants.CREDIT_INTEREST_SUPER_JUMP_RATE);
                } else {
                    updateCreditInterest(false, debtRate, bondDemand, Constants.CREDIT_INTEREST_HIGH_JUMP_RATE);
                }
            } else if (bondDemand >= Constants.CREDIT_BOND_DEMAND_LOW_RATE) {
                // low bond demand
                if (creditInfo.interest > Constants.CREDIT_INTEREST_MEANING_RATE) {
                    updateCreditInterest(false, debtRate, bondDemand, Constants.CREDIT_INTEREST_HIGH_JUMP_RATE);
                } else {
                    updateCreditInterest(false, debtRate, bondDemand, Constants.CREDIT_INTEREST_MEDIUM_JUMP_RATE);
                }
            } else {
                // steady bond demand
                if (creditInfo.interest > Constants.CREDIT_INTEREST_MEANING_RATE) {
                    updateCreditInterest(false, debtRate, bondDemand, Constants.CREDIT_INTEREST_SUPER_JUMP_RATE);
                } else {
                    updateCreditInterest(false, debtRate, bondDemand, Constants.CREDIT_INTEREST_HIGH_JUMP_RATE);
                }
            }

            creditInfo.bonds = uint256(deltaD).mul(Constants.CREDIT_BOND_EMISSION_WHEN_LOW_DEBT_RATE).div(100e18);
        } else if (debtRate > Constants.CREDIT_DEBT_OPTIMAL_RATE) {
            // high debt rate
            if (bondDemand < Constants.CREDIT_BOND_DEMAND_HIGH_RATE) {
                // high bond demand
                if (creditInfo.interest > Constants.CREDIT_INTEREST_MEANING_RATE) {
                    updateCreditInterest(false, debtRate, bondDemand, Constants.CREDIT_INTEREST_SUPER_JUMP_RATE);
                } else {
                    updateCreditInterest(false, debtRate, bondDemand, Constants.CREDIT_INTEREST_HIGH_JUMP_RATE);
                }
            } else if (bondDemand >= Constants.CREDIT_BOND_DEMAND_LOW_RATE) {
                // low bond demand
                if (creditInfo.interest > Constants.CREDIT_INTEREST_MEANING_RATE) {
                    updateCreditInterest(false, debtRate, bondDemand, Constants.CREDIT_INTEREST_MEDIUM_JUMP_RATE);
                }
            } else {
                // steady bond demand
                if (creditInfo.interest > Constants.CREDIT_INTEREST_MEANING_RATE) {
                    updateCreditInterest(false, debtRate, bondDemand, Constants.CREDIT_INTEREST_HIGH_JUMP_RATE);
                } else {
                    updateCreditInterest(false, debtRate, bondDemand, Constants.CREDIT_INTEREST_MEDIUM_JUMP_RATE);
                }
            }

            creditInfo.bonds = uint256(deltaD).mul(Constants.CREDIT_BOND_EMISSION_WHEN_HIGH_DEBT_RATE).div(100e18);
        }
    }

    function setBondInterestBelowPeg(
        int256 deltaD,
        uint256 debtRate,
        uint256 bondDemand
    ) internal {
        creditInfo.bonds = uint256(-deltaD);

        if (debtRate < Constants.CREDIT_DEBT_OPTIMAL_RATE) {
            // low debt rate
            if (bondDemand < Constants.CREDIT_BOND_DEMAND_HIGH_RATE) {
                // high bonds demand
                if (creditInfo.interest > Constants.CREDIT_INTEREST_MEANING_RATE) {
                    updateCreditInterest(false, debtRate, bondDemand, Constants.CREDIT_INTEREST_LOW_JUMP_RATE);
                }
            } else if (bondDemand >= Constants.CREDIT_BOND_DEMAND_LOW_RATE) {
                // low bonds demand
                if (creditInfo.interest > Constants.CREDIT_INTEREST_MEANING_RATE) {
                    updateCreditInterest(true, debtRate, bondDemand, Constants.CREDIT_INTEREST_MEDIUM_JUMP_RATE);
                } else {
                    updateCreditInterest(true, debtRate, bondDemand, Constants.CREDIT_INTEREST_HIGH_JUMP_RATE);
                }
            } else {
                // steady bonds demand
                if (creditInfo.interest > Constants.CREDIT_INTEREST_MEANING_RATE) {
                    updateCreditInterest(true, debtRate, bondDemand, Constants.CREDIT_INTEREST_LOW_JUMP_RATE);
                } else {
                    updateCreditInterest(true, debtRate, bondDemand, Constants.CREDIT_INTEREST_MEDIUM_JUMP_RATE);
                }
            }
        } else if (debtRate > Constants.CREDIT_DEBT_OPTIMAL_RATE) {
            // high debt rate
            if (bondDemand < Constants.CREDIT_BOND_DEMAND_HIGH_RATE) {
                // high bonds demand
                if (creditInfo.interest > Constants.CREDIT_INTEREST_MEANING_RATE) {
                    updateCreditInterest(false, debtRate, bondDemand, Constants.CREDIT_INTEREST_LOW_JUMP_RATE);
                }
            } else if (bondDemand >= Constants.CREDIT_BOND_DEMAND_LOW_RATE) {
                // low bonds demand
                if (creditInfo.interest > Constants.CREDIT_INTEREST_MEANING_RATE) {
                    updateCreditInterest(true, debtRate, bondDemand, Constants.CREDIT_INTEREST_MEDIUM_JUMP_RATE);
                } else {
                    updateCreditInterest(true, debtRate, bondDemand, Constants.CREDIT_INTEREST_HIGH_JUMP_RATE);
                }
            } else {
                // steady bonds demand
                if (creditInfo.interest > Constants.CREDIT_INTEREST_MEANING_RATE) {
                    updateCreditInterest(true, debtRate, bondDemand, Constants.CREDIT_INTEREST_LOW_JUMP_RATE);
                } else {
                    updateCreditInterest(true, debtRate, bondDemand, Constants.CREDIT_INTEREST_MEDIUM_JUMP_RATE);
                }
            }
        }
    }

    function updateCreditInterest(
        bool increasing,
        uint256 debtRate,
        uint256 bondDemand,
        uint256 jumRate
    ) internal {
        if (increasing) {
            uint256 oldInterest = creditInfo.interest;

            creditInfo.interest = creditInfo.interest.add(jumRate);

            emit NewInterestRate(epochInfo.current, debtRate, bondDemand, oldInterest, creditInfo.interest);
        } else {
            uint256 oldInterest = creditInfo.interest;

            creditInfo.interest = creditInfo.interest > jumRate ? creditInfo.interest.sub(jumRate) : 0;

            emit NewInterestRate(epochInfo.current, debtRate, bondDemand, oldInterest, creditInfo.interest);
        }
    }
}


// Dependency file: contracts/dao/3_Credit.sol


// pragma solidity 0.7.6;


// import "contracts/dao/2_Epoch.sol";

contract DaoCredit is DaoEpoch {
    using SafeMath for uint256;
    using LibSafeMath32 for uint32;

    event BondPurchased(address indexed account, uint256 index, uint256 dollars, uint256 debts);
    event BondRedeemed(address indexed account, uint256[] slots, uint256 dollars);

    function purchaseBondFor(address purchaser, uint256 amount) internal whenNotPaused nonReentrant {
        amount = Math.min(creditInfo.bonds, amount);

        // Burn Dollar
        IDollar(dollar).burn(amount);

        // Decrease available bonds
        creditInfo.bonds = creditInfo.bonds.sub(amount);

        // Calculate debts
        uint256 debts = amount.add(amount.mul(creditInfo.interest).div(100e18));

        // Save account slots
        accountInfo[purchaser].debtSlots[creditInfo.debts] = debts;

        // Increase DAO debts
        creditInfo.debts = creditInfo.debts.add(debts);

        emit BondPurchased(purchaser, creditInfo.debts, amount, debts);
    }

    function redeemBondFor(address redeemer, uint256[] memory slots) internal whenNotPaused nonReentrant {
        uint256 dollarRedeemed;

        // Process slots
        for (uint256 i; i < slots.length; ++i) {
            require(slots[i] < creditInfo.redeemable, "Credit: slot not redeemable");
            uint256 redeemed = redeemSlot(redeemer, slots[i]);
            dollarRedeemed = dollarRedeemed.add(redeemed);
        }

        // Increase credit redeemed balance
        creditInfo.redeemed = creditInfo.redeemed.add(dollarRedeemed);

        // Transfer dollars to redeemer
        IDollar(dollar).transfer(redeemer, dollarRedeemed);

        emit BondRedeemed(redeemer, slots, dollarRedeemed);
    }

    function redeemSlot(address account, uint256 slotId) private returns (uint256 redeemableDebts) {
        uint256 debts = accountInfo[account].debtSlots[slotId];

        // Do nothing with empty slot
        if (debts <= 0) return 0;

        // Decrease redeemable debts
        redeemableDebts = creditInfo.redeemable.sub(slotId);

        // Clear account debt slot
        delete accountInfo[account].debtSlots[slotId];

        if (redeemableDebts >= debts) return debts;
        accountInfo[account].debtSlots[slotId.add(redeemableDebts)] = debts.sub(redeemableDebts);
    }
}


// Dependency file: contracts/dao/4_Market.sol


// pragma solidity 0.7.6;


// import "contracts/dao/3_Credit.sol";

contract CreditMarket is DaoCredit {
    using SafeMath for uint256;
    using LibSafeMath32 for uint32;

    event SlotTransfer(address indexed from, address indexed to, uint256 indexed id, uint256 debts);
    event DebtApproval(address indexed owner, address indexed spender, uint256 debts);
    event DebtListingCreated(
        address indexed account,
        uint256 index,
        uint256 start,
        uint256 amount,
        uint24 pricePerDebt,
        uint256 maxHarvestableIndex,
        TransferMode mode
    );
    event DebtListingFilled(address indexed from, address indexed to, uint256 index, uint256 start, uint256 amount);
    event DebtListingCancelled(address indexed account, uint256 index);

    event DebtOrderCreated(
        address indexed account,
        bytes32 id,
        uint256 amount,
        uint24 pricePerDebt,
        uint256 maxPlaceInLine
    );
    event DebtOrderFilled(
        address indexed from,
        address indexed to,
        bytes32 id,
        uint256 index,
        uint256 start,
        uint256 amount
    );
    event DebtOrderCancelled(address indexed account, bytes32 id);

    function allowanceDebts(address owner, address spender) public view returns (uint256) {
        return accountInfo[owner].debtAllowances[spender];
    }

    function createDebtListing(
        uint256 index,
        uint256 start,
        uint256 amount,
        uint24 pricePerDebt,
        uint256 maxHarvestableIndex,
        TransferMode mode
    ) external payable {
        _createDebtListing(index, start, amount, pricePerDebt, maxHarvestableIndex, mode);
    }

    function fillDebtListing(DebtListing calldata l, uint256 dollarAmount) external payable {
        IERC20(dollar).transferFrom(msg.sender, l.account, dollarAmount);
        _fillListing(l, dollarAmount);
    }

    function cancelDebtListing(uint256 index) external payable {
        _cancelDebtListing(msg.sender, index);
    }

    function createDebtOrder(
        uint256 dollarAmount,
        uint24 pricePerPod,
        uint256 maxPlaceInLine
    ) external payable returns (bytes32 id) {
        IERC20(dollar).transferFrom(msg.sender, address(this), dollarAmount);
        return _createDebtOrder(dollarAmount, pricePerPod, maxPlaceInLine);
    }

    function fillDebtOrder(
        DebtOrder calldata o,
        uint256 index,
        uint256 start,
        uint256 amount
    ) external payable {
        _fillDebtOrder(o, index, start, amount);
    }

    // Cancel
    function cancelDebtOrder(uint24 pricePerPod, uint256 maxPlaceInLine) external payable {
        _cancelDebtOrder(pricePerPod, maxPlaceInLine);
    }

    function debtOrder(
        address account,
        uint24 pricePerDebt,
        uint256 maxPlaceInLine
    ) external view returns (uint256) {
        return debtOrders[createOrderId(account, pricePerDebt, maxPlaceInLine)];
    }

    function _transferSlot(
        address from,
        address to,
        uint256 index,
        uint256 start,
        uint256 amount
    ) internal {
        require(from != to, "Credit: cannot transfer debts to oneself");

        insertSlot(to, index.add(start), amount);
        removeSlot(from, index, start, amount.add(start));

        emit SlotTransfer(from, to, index.add(start), amount);
    }

    function insertSlot(
        address account,
        uint256 id,
        uint256 amount
    ) internal {
        accountInfo[account].debtSlots[id] = amount;
    }

    function removeSlot(
        address account,
        uint256 id,
        uint256 start,
        uint256 end
    ) internal {
        uint256 amount = accountInfo[account].debtSlots[id];
        if (start == 0) delete accountInfo[account].debtSlots[id];
        else accountInfo[account].debtSlots[id] = start;
        if (end != amount) accountInfo[account].debtSlots[id.add(end)] = amount.sub(end);
    }

    function decrementAllowanceDebts(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = allowanceDebts(owner, spender);
        setAllowanceDebts(owner, spender, currentAllowance.sub(amount, "Credit: insufficient approval"));
    }

    function setAllowanceDebts(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        accountInfo[owner].debtAllowances[spender] = amount;
    }

    ////////// Listings //////////

    function _createDebtListing(
        uint256 index,
        uint256 start,
        uint256 amount,
        uint24 pricePerDebt,
        uint256 maxHarvestableIndex,
        TransferMode mode
    ) internal {
        uint256 slotSize = accountInfo[msg.sender].debtSlots[index];
        require(slotSize >= start.add(amount) && amount > 0, "Market: invalid slot/amount");
        require(pricePerDebt > 0, "Market: debt price must be greater than 0");
        require(creditInfo.redeemable <= maxHarvestableIndex, "Market: expired");

        if (debtListings[index] != bytes32(0)) _cancelDebtListing(msg.sender, index);

        debtListings[index] = hashListing(start, amount, pricePerDebt, maxHarvestableIndex, mode);

        emit DebtListingCreated(msg.sender, index, start, amount, pricePerDebt, maxHarvestableIndex, mode);
    }

    function _fillListing(DebtListing calldata l, uint256 dollarAmount) internal {
        bytes32 lHash = hashListing(l.start, l.amount, l.pricePerDebt, l.maxHarvestableIndex, l.mode);
        require(debtListings[l.index] == lHash, "Market: listing does not exist");
        uint256 slotSize = accountInfo[l.account].debtSlots[l.index];
        require(slotSize >= (l.start + l.amount) && l.amount > 0, "Market: invalid plot/amount");
        require(creditInfo.redeemable <= l.maxHarvestableIndex, "Market: listing has expired");

        uint256 amount = dollarAmount.mul(1e18).div(l.pricePerDebt);
        amount = roundAmount(l, amount);

        __fillListing(msg.sender, l, amount);

        _transferSlot(l.account, msg.sender, l.index, l.start, amount);
    }

    function __fillListing(
        address to,
        DebtListing calldata l,
        uint256 amount
    ) private {
        // Note: If l.amount < amount, the function roundAmount will revert
        if (l.amount > amount)
            debtListings[l.index.add(amount).add(l.start)] = hashListing(
                0,
                l.amount.sub(amount),
                l.pricePerDebt,
                l.maxHarvestableIndex,
                l.mode
            );

        emit DebtListingFilled(l.account, to, l.index, l.start, amount);

        delete debtListings[l.index];
    }

    function _cancelDebtListing(address account, uint256 index) internal {
        require(accountInfo[account].debtSlots[index] > 0, "Market: listing not owned by sender");
        delete debtListings[index];
        emit DebtListingCancelled(account, index);
    }

    function roundAmount(DebtListing calldata l, uint256 amount) private pure returns (uint256) {
        uint256 remainingAmount = l.amount.sub(amount, "Market: not enough debts in Listing");
        if (remainingAmount < (1000000 / l.pricePerDebt)) amount = l.amount;
        return amount;
    }

    function hashListing(
        uint256 start,
        uint256 amount,
        uint24 pricePerDebt,
        uint256 maxHarvestableIndex,
        TransferMode mode
    ) internal pure returns (bytes32 lHash) {
        lHash = keccak256(
            abi.encodePacked(start, amount, pricePerDebt, maxHarvestableIndex, mode == TransferMode.EXTERNAL)
        );
    }

    ////////// Orders //////////

    function _createDebtOrder(
        uint256 dollarAmount,
        uint24 pricePerDebt,
        uint256 maxPlaceInLine
    ) internal returns (bytes32 id) {
        require(0 < pricePerDebt, "Market: debt price must be greater than 0");
        uint256 amount = (dollarAmount * 1e18) / pricePerDebt;

        return __createDebtOrder(amount, pricePerDebt, maxPlaceInLine);
    }

    function __createDebtOrder(
        uint256 amount,
        uint24 pricePerDebt,
        uint256 maxPlaceInLine
    ) internal returns (bytes32 id) {
        require(amount > 0, "Market: order amount must be > 0");

        id = createOrderId(msg.sender, pricePerDebt, maxPlaceInLine);

        if (debtOrders[id] > 0) _cancelDebtOrder(pricePerDebt, maxPlaceInLine);

        debtOrders[id] = amount;

        emit DebtOrderCreated(msg.sender, id, amount, pricePerDebt, maxPlaceInLine);
    }

    function _fillDebtOrder(
        DebtOrder calldata o,
        uint256 index,
        uint256 start,
        uint256 amount
    ) internal {
        bytes32 id = createOrderId(o.account, o.pricePerDebt, o.maxPlaceInLine);
        debtOrders[id] = debtOrders[id].sub(amount);
        require(accountInfo[msg.sender].debtSlots[index] >= (start + amount), "Market: invalid slot");
        uint256 placeInLineEndPlot = index + start + amount - creditInfo.redeemable;
        require(placeInLineEndPlot <= o.maxPlaceInLine, "Market: slot too far in line");
        uint256 costInDollars = (o.pricePerDebt * amount) / 1e18;

        IERC20(dollar).transfer(msg.sender, costInDollars);

        if (debtListings[index] != bytes32(0)) {
            _cancelDebtListing(msg.sender, index);
        }
        _transferSlot(msg.sender, o.account, index, start, amount);
        if (debtOrders[id] == 0) {
            delete debtOrders[id];
        }
        emit DebtOrderFilled(msg.sender, o.account, id, index, start, amount);
    }

    function _cancelDebtOrder(uint24 pricePerDebt, uint256 maxPlaceInLine) internal {
        bytes32 id = createOrderId(msg.sender, pricePerDebt, maxPlaceInLine);
        uint256 amountDollars = (pricePerDebt * debtOrders[id]) / 1000000;

        // Transfer Dollars
        IERC20(dollar).transfer(msg.sender, amountDollars);

        delete debtOrders[id];

        emit DebtOrderCancelled(msg.sender, id);
    }

    function createOrderId(
        address account,
        uint24 pricePerDebt,
        uint256 maxPlaceInLine
    ) internal pure returns (bytes32 id) {
        id = keccak256(abi.encodePacked(account, pricePerDebt, maxPlaceInLine));
    }
}


// Dependency file: contracts/dao/5_Stake.sol


// pragma solidity 0.7.6;


// import "contracts/dao/4_Market.sol";

contract DaoStake is CreditMarket {
    using SafeMath for uint256;
    using LibSafeMath32 for uint32;

    // Emit when user deposit whitelisted tokens
    event Deposited(address indexed depositor, address indexed token, uint256 indexed amount, uint32 epoch);

    // Emit when user collect earned dollars and update balances
    event Collected(address indexed depositor, uint256 indexed amount, uint32 epoch);

    // Emit when user request to withdraw whitelisted tokens
    event WithdrawRequested(
        address indexed depositor,
        address indexed token,
        uint256 indexed amount,
        uint32 currentEpoch,
        uint32 claimableEpoch
    );

    // Emit when user claim withdrawable whitelisted tokens
    event WithdrawClaimed(address indexed depositor, address indexed token, uint256 indexed amount, uint32 epoch);

    // UserGrownShares = NumberOfEpochPassed * UserPapers / DAO_SHARES_GROWTH_PER_PAPER_RATE
    function balanceOfGrownShares(address account) public view returns (uint256) {
        uint256 epochPassed = epochInfo.current - accountInfo[account].lastEpochUpdated;
        return epochPassed.mul(accountInfo[account].papers).div(Constants.DAO_SHARES_GROWTH_PER_PAPER_RATE);
    }

    // userSharesBalance = userShares + userGrownShares
    function balanceOfShares(address account) public view returns (uint256) {
        return accountInfo[account].shares.add(balanceOfGrownShares(account));
    }

    // UserEarnedDollars = (UserGrownShares + UserShares) * DaoEarnedDollars / DaoTotalShares - UserClaimed
    function balanceOfEarnedDollars(address account) public view returns (uint256) {
        uint256 currentShares = balanceOfShares(account);
        uint256 earnedWithShares = earnedDollar.mul(currentShares).div(stakeInfo.shares);

        uint256 earnedAfterClaimed = earnedWithShares > accountInfo[account].claimed
            ? earnedWithShares.sub(accountInfo[account].claimed)
            : 0;
        return earnedAfterClaimed;
    }

    // Return user deposits balances
    function balanceOfDeposits(address account, address token) public view returns (DepositInfo memory) {
        return accountInfo[account].deposits[token];
    }

    // Return user withdrawal balances
    function balanceOfWithdrawals(address account, address token) public view returns (WithdrawalInfo memory) {
        return accountInfo[account].withdrawals[token];
    }

    // Collect earned Dollars and transfer to msg.sender
    // Update depositor shares & papers balance
    //  - Increase shares balance by grown shares
    //  - Increase papers balance by earned dollars
    function collectFor(address depositor) internal whenNotPaused nonReentrant {
        uint256 earnedDollars = balanceOfEarnedDollars(depositor);
        if (earnedDollars == 0) return;

        uint256 grownShares = balanceOfGrownShares(depositor);
        uint256 grownPapers = earnedDollars.mul(Constants.DAO_PAPERS_PER_DDV_RATE);

        // Decrease total earned dollars
        earnedDollar = earnedDollar.sub(earnedDollars);

        // Increase DAO papers and shares
        stakeInfo.shares = stakeInfo.shares.add(grownShares);
        stakeInfo.papers = stakeInfo.papers.add(grownPapers);

        // Increase depositor shares, papers and claimed
        accountInfo[depositor].shares = accountInfo[depositor].shares.add(grownShares);
        accountInfo[depositor].papers = accountInfo[depositor].papers.add(grownPapers);
        accountInfo[depositor].claimed = accountInfo[depositor].claimed.add(earnedDollars);

        // Update depositor last interaction epoch
        accountInfo[depositor].lastEpochUpdated = epochInfo.current;

        // Transfer Dollars to msg.sender
        IERC20(dollar).transfer(msg.sender, earnedDollars);

        // Emit Collected event
        emit Collected(depositor, earnedDollars, epochInfo.current);
    }

    function depositFor(
        address depositor,
        address token,
        uint256 amount
    ) internal whenNotPaused nonReentrant {
        uint256 ddvValue = IOracle(oracle).ddv(token, amount);

        // Update DAO whitelisted token balance
        daoBalances[token].deposited = daoBalances[token].deposited.add(amount);

        // Calculate papers and shares value
        uint256 papersAmount = daoAssets[token].papersPerDDV.mul(ddvValue).div(1e18);
        uint256 sharesAmount = daoAssets[token].sharesPerDDV.mul(ddvValue).div(1e18);

        // Update DAO papers and shares balance
        stakeInfo.papers = stakeInfo.papers.add(papersAmount);
        stakeInfo.shares = stakeInfo.shares.add(sharesAmount);

        // Update depositor papers and shares balance
        accountInfo[depositor].papers = accountInfo[depositor].papers.add(papersAmount);
        accountInfo[depositor].shares = accountInfo[depositor].shares.add(sharesAmount);

        // Update account token balance
        accountInfo[depositor].ddv = accountInfo[depositor].ddv.add(ddvValue);
        accountInfo[depositor].deposits[token].amount = accountInfo[depositor].deposits[token].amount.add(amount);
        accountInfo[depositor].deposits[token].ddv = accountInfo[depositor].deposits[token].ddv.add(ddvValue);

        // Init account last epoch if not
        accountInfo[depositor].lastEpochUpdated = accountInfo[depositor].lastEpochUpdated == 0
            ? epochInfo.current
            : accountInfo[depositor].lastEpochUpdated;

        // Transfer token into DAO address
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        // Emit event
        emit Deposited(depositor, token, amount, epochInfo.current);
    }

    // User request to withdraw token
    function requestWithdraw(address token, uint256 amount) internal whenNotPaused nonReentrant {
        require(accountInfo[msg.sender].deposits[token].amount >= amount, "Stake: insufficient stake balance");

        // Decrease DAO whitelisted token balance
        daoBalances[token].deposited = daoBalances[token].deposited.sub(amount);

        // DDV value of amount of withdraw
        uint256 withdrawDdvValue = amount.mul(accountInfo[msg.sender].deposits[token].ddv).div(
            accountInfo[msg.sender].ddv
        );

        // UserBurnPapers = WithdrawDdvValue * UserPapers * WithdrawTokenPapersPerDDV / UserDdv
        uint256 burnPapers = withdrawDdvValue.mul(daoAssets[token].papersPerDDV).div(1e18);
        // UserBurnShares = WithdrawDdvValue * UserShares * WithdrawTokenSharesPerDDV / UserDdv
        uint256 burnShares = withdrawDdvValue.mul(daoAssets[token].sharesPerDDV).div(1e18);

        // Decrease papers and shares balance
        stakeInfo.papers = stakeInfo.papers.sub(burnPapers);
        stakeInfo.shares = stakeInfo.shares.sub(burnShares);
        accountInfo[msg.sender].papers = accountInfo[msg.sender].papers.sub(burnPapers);
        accountInfo[msg.sender].shares = accountInfo[msg.sender].shares.sub(burnShares);

        // Decrease account deposit balance
        accountInfo[msg.sender].deposits[token].amount = accountInfo[msg.sender].deposits[token].amount.sub(amount);
        accountInfo[msg.sender].deposits[token].ddv = accountInfo[msg.sender].deposits[token].ddv.sub(withdrawDdvValue);

        accountInfo[msg.sender].withdrawals[token].amount = accountInfo[msg.sender].withdrawals[token].amount.add(
            amount
        );
        accountInfo[msg.sender].withdrawals[token].epoch = epochInfo.current.add(
            Constants.EPOCH_REQUIRE_FOR_WITHDRAWALS
        );

        emit WithdrawRequested(
            msg.sender,
            token,
            amount,
            epochInfo.current,
            epochInfo.current.add(Constants.EPOCH_REQUIRE_FOR_WITHDRAWALS)
        );
    }

    // User Claim withdrawal
    function claimWithdraw(address token) internal whenNotPaused nonReentrant {
        require(accountInfo[msg.sender].withdrawals[token].amount > 0, "Stake: nothing to claim");
        require(accountInfo[msg.sender].withdrawals[token].epoch <= epochInfo.current, "Stake: pending claim");

        // Transfer token to user
        IERC20(token).transfer(msg.sender, accountInfo[msg.sender].withdrawals[token].amount);

        emit WithdrawClaimed(msg.sender, token, accountInfo[msg.sender].withdrawals[token].amount, epochInfo.current);

        delete accountInfo[msg.sender].withdrawals[token];
    }
}


// Dependency file: contracts/dao/6_Governance.sol


// pragma solidity 0.7.6;


// import "contracts/dao/5_Stake.sol";

contract Governance is DaoStake {
    function initialize(
        address _dollar,
        address _oracle,
        uint256 _epochStart,
        uint256 _creditStartInterest
    ) external initializer {
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();

        dollar = _dollar;
        oracle = _oracle;
        epochInfo.start = _epochStart;
        creditInfo.interest = _creditStartInterest;
    }

    ////////// Governance functions //////////

    function updateDaoAsset(
        address token,
        uint256 _papersPerDDV,
        uint256 _sharesPerDDV
    ) external onlyOwner {
        daoAssets[token].papersPerDDV = _papersPerDDV;
        daoAssets[token].sharesPerDDV = _sharesPerDDV;
    }
}


// Root file: contracts/dao/7_TheDao.sol


pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

// import "contracts/dao/6_Governance.sol";

contract TheDao is Governance {
    ////////// Staking functions //////////

    // @dev User deposit Dollars
    function deposit(address token, uint256 amount) external {
        depositFor(msg.sender, token, amount);
    }

    // @dev User request withdraw
    function withdraw(address token, uint256 amount) external {
        requestWithdraw(token, amount);
    }

    // @dev User claim withdraw
    function claim(address token) external {
        claimWithdraw(token);
    }

    // @dev User collect Dollars
    function collect() external {
        collectFor(msg.sender);
    }

    ////////// Credit functions //////////

    // @dev User purchase bonds
    function purchase(uint256 amount) external {
        purchaseBondFor(msg.sender, amount);
    }

    // @dev User redeem bonds
    function redeem(uint256[] memory slots) external {
        redeemBondFor(msg.sender, slots);
    }
}