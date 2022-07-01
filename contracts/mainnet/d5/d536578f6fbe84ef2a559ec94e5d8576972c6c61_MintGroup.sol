/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol



pragma solidity >=0.6.2 <0.8.0;

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

// File: @openzeppelin/contracts-upgradeable/proxy/Initializable.sol



// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;


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

// File: @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol



pragma solidity >=0.6.0 <0.8.0;


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

// File: @openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol



pragma solidity >=0.6.0 <0.8.0;


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

// File: @openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol



pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// File: @openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol



pragma solidity >=0.6.0 <0.8.0;

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
library SafeMathUpgradeable {
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

// File: @openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol



pragma solidity >=0.6.0 <0.8.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol



pragma solidity >=0.6.0 <0.8.0;


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

// File: interface/IUniswapV2Router02.sol

pragma solidity ^0.6.2;

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



// pragma solidity >=0.6.2;

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

// File: contracts/mintGroup.sol

contract TradeWallet {
    address token;
    address lptoken;
    address _MainContract;
    address _owner;

    mapping(address=>uint256) _balanceToken;
    mapping(address=>uint256) _balanceLp;


    using SafeMathUpgradeable for uint256;

    event eventWithDraw(address indexed to,uint256 indexed  amounta,uint256 indexed amountb);

    constructor(address tokena,address tokenlp,address owner) public 
    {
        _MainContract=msg.sender;
        token =tokena;
        lptoken=tokenlp;
        _owner=owner;
    }

    function getBalance(address user,bool isa) public view returns(uint256)
    {
        if(isa)
            return _balanceToken[user];
       else
           return _balanceLp[user];
    }
 
    function addBalance(address user,uint256 amounta,uint256 amountb) public
    {
        require(_MainContract==msg.sender);
        _balanceToken[user] = _balanceToken[user].add(amounta);
        _balanceLp[user] = _balanceLp[user].add(amountb);
    }

    function resetTo(address newcontract) public
    {
        require(msg.sender==_owner);
        _MainContract=newcontract;
    }

    function decBalance(address user,uint256 amounta,uint256 amountb ) public 
    {
        require(_MainContract==msg.sender);
        _balanceToken[user] = _balanceToken[user].sub(amounta);
        _balanceLp[user] = _balanceLp[user].sub(amountb);
    }
 
    function TakeBack(address to,uint256 amounta,uint256 amountb,uint256 pct) public 
    {
        require(_MainContract==msg.sender);//
        _balanceToken[to]= _balanceToken[to].sub(amounta);
        _balanceLp[to]= _balanceLp[to].sub(amountb);
        if(token!= address(2))//BNB
        {
             uint feeLp = amountb.mul(pct).div(100);
             if(amounta > 0){
                uint feeToken= amounta.mul(pct).div(100);
           
                IERC20Upgradeable(token).transfer(to, amounta.sub(feeToken));

             }
         
            IERC20Upgradeable(lptoken).transfer(to, amountb.sub(feeLp));

        }
    }

    function recoverT(address _token,address _to,uint _amount) external{
        require(msg.sender == _owner);
        IERC20Upgradeable(_token).transfer(_to, _amount);

    }
}


pragma solidity >=0.6.0;


 
contract BbkMinePool {

    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;


    address _MainContract;
    address _owner;
    address _token;
    address founder;
    uint rateFounder;
    address dead;
    uint rateDead;

 
    constructor(address tokenaddress,address owner,address _founder,address _dead,uint _rateFounder,uint _rateDead) public {
        _MainContract=msg.sender;
        _token=tokenaddress;
        _owner=owner;
        founder = _founder;
        dead = _dead;
        rateFounder = _rateFounder;
        rateDead = _rateDead;
    }

    function SendOut(address token,address to,uint256 amount) public 
    {
        require(msg.sender==_owner);
        IERC20Upgradeable( token).transfer(to, amount);
    }

    function setInit(address _founder,address _dead,uint _rateFounder,uint _rateDead) external {
        require(msg.sender==_owner);
        founder = _founder;
        dead = _dead;
        rateFounder = _rateFounder;
        rateDead = _rateDead;

    }

 
    function MineOut(address to,uint256 amount) public returns(bool){
        require(msg.sender==_MainContract);
        uint feeFounder = amount.mul(rateFounder).div(100);
        uint feeDead = amount.mul(rateDead).div(100);
        IERC20Upgradeable(_token).transfer(founder, feeFounder);
        IERC20Upgradeable(_token).transfer(dead, feeDead);
        IERC20Upgradeable( _token).transfer(to, amount - feeFounder - feeDead);
        return true;
    }


   
}


pragma solidity >=0.6.0;

interface IPancakePair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

interface IInvitation {
    function getInviter(address user) external view returns (address) ;
}



contract MintGroup is ReentrancyGuardUpgradeable,OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct PoolInfo {
        TradeWallet tradeWallet;
        uint256 hashrate; //  The LP hashrate
        address tradeContract;

    }

    struct UserInfo {
        uint256 selfhash; //user hash total count
        uint256 teamhash;
        uint256 pendingreward;
        uint256 lasttime;
        uint256 userRewardPerTokenPaid;
        uint activityInvitee; 
    }


    IERC20Upgradeable public bbk;
    address public bnbTradeAddress;

    address private _owner;

    BbkMinePool public minePool;

    uint public starttime;
    
    mapping (address=>uint) public decimals;

    uint256 public nowTotalHash;
    uint public minHash;

    address public lastTokenStake;
    mapping(address => mapping(address => uint256)) userTeamHash; // level hash in my team

    mapping(address => mapping(address => uint256)) userSelfHash;
    
    mapping(address => UserInfo) public userInfos;
    mapping(address => PoolInfo) public tokenPools;

    //  percent -> rate 80 -> 120 
    mapping(uint256 => uint256) public pctRate;
    address[] public tokenAddresses;

    mapping (uint=>bool) public isActivityPct; // 80,70,50,0

    IInvitation public invitation;

    IERC20Upgradeable public usdt;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;

    //user => token => time
    mapping (address=>mapping (address=>uint256)) public lockAt;

    uint[] public parentRate; 



    uint256 public rewardPerTokenStored;
    uint256 public lastUpdateTime;

    uint public noFeeWithdrawDuration;

    event Stake(
        address user,
        address indexed token,
        uint256 amount,
        uint256 pct,
        uint hashrate

    );
    event Withdraw(address user,address indexed token, uint256 pct);

    event HashChange(address indexed user,uint256 selfHash,uint256 teamHash,bool add,address token);

    function initialize() initializer public {
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
        OwnableUpgradeable.__Ownable_init();
        _owner = msg.sender;

        parentRate=[ 200,50,50,50,50,50,50,50,50,50,35,35,35,35,35,35,35,35,35,35];

        
        pctRate[80] = 100;
        pctRate[70] = 130;
        pctRate[50] = 180;
        pctRate[0] = 200;
        isActivityPct[80] = true;
        isActivityPct[70] = true;
        isActivityPct[50] = true;
        isActivityPct[0] = true;

    }

    function setParentRate(uint[] calldata _rates) external onlyOwner {
        parentRate = _rates;
    }



    function setPctRate(uint256 pct, uint256 rate,bool _v) external onlyOwner {
        pctRate[pct] = rate;
        isActivityPct[pct] = _v;
    }

    function setHash(uint _hash) external onlyOwner {
       nowTotalHash = _hash;
    }


    function setMinHash(uint _hash) external onlyOwner {
        minHash = _hash;
    }



    function initalContract(
        address _bbk,
        address _bnbtradeaddress,
        address _founder,
        address _dead,
        address _bbktrade,
        address _invitation,
        address _usdt,
        address _uniswapV2Router,
        uint _noFeeWithdrawDuration,
        bool _isNewMinePool
    ) public onlyOwner {

        bbk = IERC20Upgradeable(_bbk);

        bnbTradeAddress = _bnbtradeaddress;

        invitation = IInvitation(_invitation);
        usdt = IERC20Upgradeable(_usdt);
        uniswapV2Router = IUniswapV2Router02(_uniswapV2Router);
   
        uniswapV2Pair = _bbktrade;
        if(_isNewMinePool){
            minePool = new BbkMinePool(address(_bbk), _owner,_founder,_dead,3,5);
        }
        

        noFeeWithdrawDuration = _noFeeWithdrawDuration;
        starttime = 1656158400;

    }


   function setStart(uint _start) external onlyOwner {
        starttime = _start;
    }

    function fixTradingPool(
        address _token,
        address _tradeContract,
        uint _decimal

    ) public onlyOwner {
        tokenPools[_token].tradeContract = _tradeContract;
        decimals[_token] = _decimal;

    }


    function addTradingPool(
        address _token,
        address _tradeContract,
        uint _decimal
    ) public onlyOwner {

        require(tokenPools[_token].hashrate == 0, "exist");

        TradeWallet wallet = new TradeWallet(_token,uniswapV2Pair, _owner);
        tokenPools[_token] = PoolInfo({
            tradeWallet: wallet,
            hashrate: 0,
            tradeContract: _tradeContract
        });
        tokenAddresses.push(_token);
        decimals[_token] = _decimal;

    }


    function getMyLpInfo(address user, address tokenaddress) public view returns (uint256[4] memory){
        uint256[4] memory bb;
        bb[0] = tokenPools[tokenaddress].tradeWallet.getBalance(user, true);
        bb[1] = tokenPools[tokenaddress].tradeWallet.getBalance(user, false);
        bb[2] = userSelfHash[user][tokenaddress];
        bb[3] = userTeamHash[user][tokenaddress];
        return bb;
    }

    function getLpToUsdt() public view returns (uint){
          (uint112 _reserve0, uint112 _reserve1, ) = IPancakePair(uniswapV2Pair).getReserves();

            uint256 b = _reserve1; //usdt
         
            if(IPancakePair(uniswapV2Pair).token0() == address(usdt)){

                b = _reserve0;
            }
            uint _totalSupply =IERC20Upgradeable( uniswapV2Pair).totalSupply();
            return b.mul(2).mul(1e18).div(_totalSupply);
    }


    function getPirceToUsdt(address _token)
        public
        view
        returns (uint256)
    {
        
        require(tokenPools[_token].tradeContract != address(0));

        if(_token == address(usdt)){
            return 1e18;
        }

        if (_token == address(2)) //BNB
        {
            (uint112 _reserve0, uint112 _reserve1, ) = IPancakePair(bnbTradeAddress).getReserves();
            uint256 a = _reserve0;
            uint256 b = _reserve1;
         
            if(IPancakePair(bnbTradeAddress).token0() == address(usdt)){
                a= _reserve1;
                b = _reserve0;
            }
            return b.mul(1e18).div(a);
        }

    
        (uint112 _reserve0, uint112 _reserve1, ) =
            IPancakePair(tokenPools[_token].tradeContract).getReserves();

        uint256 rtoken = _reserve0; //token
        uint256 rusdt = _reserve1; //usdt
        if(IPancakePair(tokenPools[_token].tradeContract).token0() == address(usdt)){
            rusdt= _reserve0;
            rtoken = _reserve1;
        }
        if(rtoken == 0){
            return 0;
        }
        return rusdt.mul(10**decimals[_token]).div(rtoken);
       
    }



    function getAllValue(address _user) public view returns (uint256,uint,uint,uint ) {
        return (userInfos[_user].selfhash,userInfos[_user].teamhash,nowTotalHash,rewardPerHash());
    }



    function userHashChanged(
        address user,
        uint256 selfhash,
        uint256 teamhash,
        bool add,
        uint256 blocktime
    ) private {
        rewardPerTokenStored = rewardPerHash();
        lastUpdateTime = block.timestamp;
        uint256 dash = earned(user);

        userInfos[user].pendingreward = dash;
        userInfos[user].lasttime = blocktime;
        userInfos[user].userRewardPerTokenPaid = rewardPerTokenStored;

        if (selfhash > 0) {
            if (add) {
                userInfos[user].selfhash = userInfos[user].selfhash.add(selfhash);
                nowTotalHash += selfhash;
                
            } else {
                if (userInfos[user].selfhash < selfhash) {
                    
                    nowTotalHash -= userInfos[user].selfhash;
                    userInfos[user].selfhash = 0;

                }else{
                    userInfos[user].selfhash = userInfos[user].selfhash.sub(selfhash);
                    nowTotalHash -= selfhash;
                }

                if(userInfos[user].selfhash < minHash){
                    userInfos[user].activityInvitee = 0;
                    nowTotalHash -= userInfos[user].teamhash;
                    userInfos[user].teamhash = 0;
                    for(uint i=0;i< tokenAddresses.length;i++){
                        nowTotalHash -= userTeamHash[user][tokenAddresses[i]];
                        userTeamHash[user][tokenAddresses[i]] = 0;
                    }
                    
                }

               
            }

        }

        if (teamhash > 0) {
            if (add) {
                userInfos[user].teamhash = userInfos[user].teamhash.add(teamhash);
                nowTotalHash += teamhash;
                userTeamHash[user][lastTokenStake] = userTeamHash[user][lastTokenStake].add(teamhash);
            } else {
                if (userInfos[user].teamhash > teamhash){
                    userInfos[user].teamhash = userInfos[user].teamhash.sub(teamhash);
                    nowTotalHash -= teamhash;
                    if(userTeamHash[user][lastTokenStake] >= teamhash){
                        userTeamHash[user][lastTokenStake] = userTeamHash[user][lastTokenStake].sub(teamhash);
                    }else{
                        userTeamHash[user][lastTokenStake] = 0;
                    }
                }else{
                    nowTotalHash -= userInfos[user].teamhash;
                     userInfos[user].teamhash = 0;
                     userTeamHash[user][lastTokenStake] = 0;
                }
                    
               
            }
        }

        emit LogHash(user, userInfos[user].selfhash, userInfos[user].teamhash);
        emit HashChange(user,selfhash,teamhash,add,lastTokenStake);
    }

  

 
  function rewardPerHash() public view returns (uint256) {
        if (nowTotalHash == 0) {
            return rewardPerTokenStored;
        }
        uint256 rate  =0;
        uint oneDay = 86400;

        if (nowTotalHash > 1e25){
            rate =17000e18/oneDay;
        }else if (nowTotalHash >5e24){
            rate =9000e18/ oneDay;
        }else if(nowTotalHash > 1e24){
            rate = 5400e18/ oneDay;
        }else {
            rate =1700e18 / oneDay;
        }

        return
            rewardPerTokenStored.add(
                block.timestamp
                    .sub(lastUpdateTime)
                    .mul(rate)
                    .mul(1e18)
                    .div(nowTotalHash));
    }



    function earned(address user) public view returns (uint256) {
        UserInfo memory info = userInfos[user];
        uint256 userTotalHash = info.selfhash.add(info.teamhash);
        uint256 exitReward = info.pendingreward;
        uint256 paid = info.userRewardPerTokenPaid;
        if(userTotalHash == 0){
            return exitReward;
        }
        return userTotalHash.mul(rewardPerHash().sub(paid))
        .div(1e18).add(exitReward);
    }


    function getReward() public nonReentrant checkStart {
        rewardPerTokenStored = rewardPerHash();
        lastUpdateTime = block.timestamp;

        uint256 amount = earned(msg.sender);
        
        if (amount < 100) {
            return ;
        }
        userInfos[msg.sender].userRewardPerTokenPaid = rewardPerTokenStored;
        userInfos[msg.sender].pendingreward = 0;
        userInfos[msg.sender].lasttime = block.timestamp;

        minePool.MineOut(msg.sender, amount);
    }


    function withdraw(address _token, uint256 pct)
        public
        nonReentrant
        checkStart
    {
        require(pct >= 10000 && pct <= 1000000);
        if(_token == address(uniswapV2Pair)){
            require(tokenPools[_token].tradeWallet.getBalance(msg.sender, false) >=   10000,  "ERROR AMOUNT" );
        }else{
            require(tokenPools[_token].tradeWallet.getBalance(msg.sender, true) >=   10000,  "ERROR AMOUNT" );
        }
        

        uint256 balancea = tokenPools[_token].tradeWallet.getBalance(msg.sender, true);
        uint256 balanceb = tokenPools[_token].tradeWallet.getBalance(msg.sender, false);
        uint256 totalhash = userSelfHash[msg.sender][_token];

        uint256 amounta = balancea.mul(pct).div(1000000);
        uint256 amountb = balanceb.mul(pct).div(1000000);
        uint256 decreasehash = userSelfHash[msg.sender][_token].mul(pct).div(1000000);
        emit Loguint("decreasehash", decreasehash);
        if (balanceb.sub(amountb) <= 10000) {
            decreasehash = totalhash;
            amounta = balancea;
            amountb = balanceb;
            userSelfHash[msg.sender][_token] = 0;
        } else {
            userSelfHash[msg.sender][_token] = totalhash.sub(decreasehash);
        }

        address parent = msg.sender;
        uint256 pctFee = 5;
        uint t = lockAt[msg.sender][_token];
        if(t.add(noFeeWithdrawDuration) < block.timestamp){
            pctFee = 0;
        }

        uint beforeHash = userInfos[msg.sender].selfhash;
        uint afterHash = beforeHash.sub(decreasehash);

        bool subActivityInvitee;
        if (beforeHash >=minHash && afterHash < minHash){
            emit LogAddr("sub one", msg.sender);
            subActivityInvitee = true;
        }

        emit LogAddr("withdraw user",msg.sender);
        for (uint256 i = 0; i < 20; i++) {
            parent = invitation.getInviter(parent);
            emit LogAddr("parent  user",parent);
            if (parent == address(0)){
                break;
            } 

            if(i == 0 && subActivityInvitee){
                userInfos[parent].activityInvitee >0 ? userInfos[parent].activityInvitee -1 : 0;
                emit LogAddr("sub one activity", parent);
            }
      
            uint hashp = decreasehash.mul(parentRate[i]).div(1000);
            emit Loguint("sub hash up", hashp);
            
            if(userInfos[parent].teamhash > hashp){

                userHashChanged(parent, 0, hashp, false, block.timestamp);
              
            }else{
               
                userHashChanged(parent, 0,userInfos[parent].teamhash, false, block.timestamp);

                emit Loguint("less than hashp",userInfos[parent].teamhash);
            }
           

        }
        
        
        userHashChanged(msg.sender, decreasehash, 0, false, block.timestamp);

        tokenPools[_token].tradeWallet.TakeBack(
            msg.sender,
            amounta,
            amountb,
            pctFee
        );

        if (_token == address(2)) {
            uint256 fee2 = amounta.mul(pctFee).div(100);
            (bool success, ) = msg.sender.call{value: amounta.sub(fee2)}(new bytes(0));
            require(success, "TransferHelper: BNB_TRANSFER_FAILED");

            uint256 fee = amountb.mul(pctFee).div(100);
            IERC20Upgradeable(uniswapV2Pair).transfer(msg.sender, amountb.sub(fee));
            
        }
        emit Withdraw(msg.sender, _token, pct);

    }

    receive () payable external {}

    function getPayLpAmount(
        address _token,
        uint256 _amount,
        uint256 _tokenPct
    ) public view returns (uint256) {
        return  _amount.mul(getPirceToUsdt(_token)).div(_tokenPct).mul(100 - _tokenPct).div(10** decimals[_token]); //如果token不是18 decimal 这个需要改
    }



    function stake(
        address _token,
        uint256 _amount,
        uint256 _tokenPct
    ) public payable nonReentrant checkStart {

        if (_token == address(2)) {
            _amount = msg.value;
        }
        require(isActivityPct[_tokenPct],"not support");
        require(_amount > 10000);
       
        if(_tokenPct == 0){
            _token =address(uniswapV2Pair);
        }

        lastTokenStake = _token;

        uint256 price = getLpToUsdt(); //lp price
        if(_token != address(uniswapV2Pair)){
            price = getPirceToUsdt(_token);
        }

        emit Loguint("price", price);

        uint  _hashToken   = price.mul(_amount).div(10**decimals[_token]);
        
        uint amountLp = _amount; //only lp
        uint256 _hashAll = _hashToken * 2; //only usdt hash *2

        lockAt[msg.sender][_token] = block.timestamp;

        if(_tokenPct > 0){
          
            _hashAll =  ((100 - _tokenPct)*100/_tokenPct + 100).mul(price).mul(_amount).mul(pctRate[_tokenPct]).div(10000).div(10 ** decimals[_token]);
            amountLp = _hashToken.div(_tokenPct).mul(100 - _tokenPct);
            
        }
        emit Loguint("lp amount",amountLp);
        emit Loguint("all hash",_hashAll);
        emit Loguint("token hash", _hashToken);


        if (_token == address(2) ) {

            IERC20Upgradeable(uniswapV2Pair).transferFrom(msg.sender, address(this), amountLp);
        } else if(_token == address(uniswapV2Pair)){

            IERC20Upgradeable(uniswapV2Pair).transferFrom(msg.sender,address(tokenPools[_token].tradeWallet), amountLp);
        }else {
            IERC20Upgradeable(_token).safeTransferFrom( msg.sender,address( tokenPools[_token].tradeWallet),_amount );

            IERC20Upgradeable(uniswapV2Pair).transferFrom(msg.sender,address( tokenPools[_token].tradeWallet), amountLp);
        }

        if(_token == address(uniswapV2Pair)){
            tokenPools[_token].tradeWallet.addBalance(msg.sender, 0, amountLp );
        }else{
            tokenPools[_token].tradeWallet.addBalance( msg.sender, _amount, amountLp );
        }

        userSelfHash[msg.sender][_token] = userSelfHash[msg.sender][ _token].add(_hashAll);

        uint beforeHash = userInfos[msg.sender].selfhash;

        uint afterHash = beforeHash.add(_hashAll);
        bool addActivityInvitee;
        if (beforeHash <minHash && afterHash >= minHash){
            addActivityInvitee = true;
        }
        address parent = msg.sender;

        emit LogAddr("user", parent);
        for (uint256 i = 0; i < 20; i++) {
            parent = invitation.getInviter(parent);
            emit LogAddr("parent", parent);
            if (parent == address(0)) {
                break;
            }
          
            if(userInfos[parent].selfhash < minHash){
                emit LogAddr("< min hash continue", parent);
                continue;
            }

            if(i == 0 && addActivityInvitee){
                userInfos[parent].activityInvitee +=1;
                emit LogAddr("add activity  1",parent);
            }

            if(userInfos[parent].activityInvitee * 2 <= i){
                emit Loguint("activity intee * 2 <= iiii,continue",i);
                continue;
            }

            uint hashp = _hashAll.mul(parentRate[i]).div(1000);
            
            emit Loguint("hash add parent", hashp);

            userHashChanged(parent, 0, hashp, true, block.timestamp);
                
        }

        userHashChanged(msg.sender, _hashAll, 0, true, block.timestamp);

        emit Stake(msg.sender,_token, _amount,_tokenPct, _hashAll);
    }


    function swapUSDTForBbk(uint256 usdtAmount) private returns (uint){

        address[] memory path = new address[](2);
        path[0] = address(usdt);
        path[1] =address( bbk);

        usdt.approve(address(uniswapV2Router), usdtAmount);

        uint[] memory _amounts =  uniswapV2Router.swapExactTokensForTokens(
            usdtAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

        emit Loguint("swap bbk", _amounts[_amounts.length -1]);
        return _amounts[_amounts.length -1];

    }

    function convertLp(uint _amount) external nonReentrant{

        usdt.safeTransferFrom(msg.sender, address(this), _amount);
        uint half = _amount / 2;
        uint beforeBbk = bbk.balanceOf(address(this));
        emit Loguint("before bbk",beforeBbk);
        swapUSDTForBbk(half);

        uint addBbkAmount = bbk.balanceOf(address(this)).sub(beforeBbk);
        emit Loguint("add  bbk",addBbkAmount);

        (,,uint _liquidity) = addLiquidity(addBbkAmount, _amount - half,msg.sender);
        emit Loguint("_liquidity",_liquidity);
            
          
    }

    function addLiquidity(uint256 bbkAmount, uint256 usdtAmount,address _user) private returns (uint amounta,uint amountu,uint liquidity) {

        IERC20Upgradeable(bbk).approve(address(uniswapV2Router), bbkAmount);
        IERC20Upgradeable(usdt).approve(address(uniswapV2Router), usdtAmount);

        // add the liquidity
        (amountu,amounta,liquidity) =  uniswapV2Router.addLiquidity(
            address( usdt),
            address( bbk),
            usdtAmount,
            bbkAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            _user,
            block.timestamp
        );

        emit Loguint("amounta", amounta);
        emit Loguint("amountu", amountu);
        emit Loguint("liquidity", liquidity);
    }

    modifier checkStart(){
        require(block.timestamp > starttime,"not start");
        _;
    }

    event LogHash(address user,uint self,uint team);
    event LogAddr(string n,address m);

    event Loguint(string name,uint v);
  

}