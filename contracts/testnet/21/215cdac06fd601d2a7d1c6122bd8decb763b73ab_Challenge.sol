/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

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

pragma solidity ^0.8.0;

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
}

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


// File @openzeppelin/contracts/utils/math/[email protected]

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
library SafeMath {
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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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


// File contracts/Adminable.sol

pragma solidity ^0.8.0;

contract Adminable is Ownable {
    mapping(address => bool) private admins;

    event AdminRemoved(address indexed admin);
    event AdminAdded(address indexed admin);

    /**
     * @dev Throws if called by any account other than the admin.
     */
    modifier onlyAdmin() {
        require(admins[_msgSender()], "Adminable: caller is not the admin");
        _;
    }

    /**
     * @dev Make owner is the first admin.
     */
    constructor() {
        admins[_msgSender()] = true;
        emit AdminAdded(_msgSender());
    }

    /**
     * @dev Add new account (`admin`) to admins.
     * Can only be called by the current owner.
     */
    function addAdmin(address admin) public onlyOwner {
        admins[admin] = true;
        emit AdminAdded(admin);
    }

    /**
     * @dev Remove an account (`admin`) from admins.
     * Can only be called by the current owner.
     */
    function removeAdmin(address admin) public onlyOwner {
        require(admins[admin], "Adminable: this wallet is not an admin");
        admins[admin] = false;
        emit AdminRemoved(admin);
    }

    /**
     * @dev Return this account is an admin or not.
     * Can only be called by the current owner.
     */
    function isAdmin(address wallet) public view onlyOwner returns (bool) {
        return admins[wallet];
    }
}


// File contracts/Challenge.sol

pragma solidity ^0.8.0;

// import "hardhat/console.sol";






contract Challenge is Ownable, Adminable, Pausable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    enum ChallengingStatus {
        DEFAULT,
        FINISHED,
        DESTROYED
    }
    enum TeamIndex {
        DEFAULT,
        ONE,
        TWO
    }
    struct Challenging {
        uint256 id;
        address creator;
        address team1;
        address team2;
        uint256 startTime;
        uint256 endTime;
        uint256 startInvestingTime;
        uint256 endInvestingTime;
        ChallengingStatus status;
        uint8 winnerRewardRate;
        TeamIndex winner;
        uint256 prize;
    }

    struct Claiming {
        uint256 reward;
        bool claimed;
    }

    mapping(uint256 => Challenging) public challengings;
    mapping(uint256 => mapping(TeamIndex => mapping(address => uint256)))
        public investings;
    mapping(uint256 => mapping(TeamIndex => uint256)) public totalInvestings;
    mapping(uint256 => mapping(TeamIndex => uint256)) public donations;
    mapping(uint256 => mapping(address => Claiming)) public claimings;

    uint256 private _totalChallenging = 0;
    address private _baseTokenAddress;

    IERC20 immutable token;

    // Events
    event ChallengingCreated(uint256 challengeId);
    event ChallengingFinished(uint256 challengeId);
    event Investing(
        uint256 challengeId,
        TeamIndex team,
        address fromAddress,
        uint256 amount
    );
    event Donation(
        uint256 challengeId,
        TeamIndex team,
        address fromAddress,
        uint256 amount
    );

    // Modifiers
    /**
     * @notice Checks if current id is a challenge
     */
    modifier isChallenge(uint256 challengeId) {
        require(
            challengings[challengeId].id > 0,
            "Challenge: not available challenge"
        );
        _;
    }
    /**
     * @notice Checks if challenge is in default status
     */
    modifier atDefault(uint256 challengeId) {
        require(
            challengings[challengeId].status == ChallengingStatus.DEFAULT,
            "Challenge: the challenge was finished"
        );
        _;
    }
    /**
     * @notice Checks if the msg.sender is a contract or a proxy
     */
    modifier notContract() {
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    /**
     * @notice Checks if address is a contract
     * @dev It prevents contract from being targetted
     */
    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    constructor(IERC20 baseToken) {
        token = baseToken;
    }

    function totalChallenging() external view whenNotPaused returns (uint256) {
        return _totalChallenging;
    }

    function addChallenge(
        address team1,
        address team2,
        uint256 startInvestingTime,
        uint256 endInvestingTime,
        uint8 winnerRewardRate, // Winner rate in range [0,100]
        uint256 prize
    ) external whenNotPaused onlyAdmin notContract {
        _addChallenge(
            _msgSender(),
            team1,
            team2,
            startInvestingTime,
            endInvestingTime,
            winnerRewardRate,
            prize
        );
    }

    function submitResult(uint256 challengeId, TeamIndex winner)
        external
        whenNotPaused
        onlyAdmin
    {
        _submitResult(challengeId, winner);
    }

    function prize(uint256 challengeId)
        external
        view
        whenNotPaused
        returns (uint256)
    {
        return _prize(challengeId);
    }

    function invest(
        uint256 challengeId,
        TeamIndex team,
        uint256 amount
    ) external whenNotPaused notContract {
        _invest(challengeId, team, _msgSender(), amount);
    }

    function batchInvest(
        uint256[] calldata challengeIds,
        TeamIndex[] calldata teams,
        uint256[] calldata amounts
    ) external whenNotPaused notContract {
        require(
            challengeIds.length == teams.length,
            "Challenge: Invalid input parameters"
        );
        require(
            challengeIds.length == amounts.length,
            "Challenge: Invalid input parameters"
        );

        for (uint256 indx = 0; indx < challengeIds.length; indx++) {
            require(
                _invest(
                    challengeIds[indx],
                    teams[indx],
                    _msgSender(),
                    amounts[indx]
                ),
                "Challenge: Unable invest to the challenge"
            );
        }
    }

    function claim(uint256 challengeId) external whenNotPaused notContract {
        _claim(challengeId, _msgSender());
    }

    function destroy(uint256 challengeId)
        external
        whenNotPaused
        notContract
        onlyAdmin
    {
        _destroy(challengeId, _msgSender());
    }

    function donate(
        uint256 challengeId,
        TeamIndex team,
        uint256 amount
    ) external whenNotPaused notContract {
        _donate(challengeId, team, _msgSender(), amount);
    }

    function estimateReward(uint256 challengeId)
        external
        view
        whenNotPaused
        notContract
        returns (uint256)
    {
        return _estimateReward(challengeId, _msgSender());
    }

    function _addChallenge(
        address creator,
        address team1,
        address team2,
        uint256 startInvestingTime,
        uint256 endInvestingTime,
        uint8 winnerRewardRate, // Winner rate in range [0,100]
        uint256 prize
    ) internal virtual {
        // Validation
        require(
            startInvestingTime > block.timestamp,
            "Challenge: start investing time must be greater than now"
        );
        require(
            endInvestingTime > block.timestamp,
            "Challenge: end investing time must be greater than now"
        );
        require(
            endInvestingTime > startInvestingTime,
            "Challenge: end investing time must be greater than start investing"
        );
        require(
            winnerRewardRate >= 0 && winnerRewardRate <= 100,
            "Challenge: winner rate is out of range 0 to 100"
        );
        require(
            team1 != address(0) && team2 != address(0),
            "Challenge: address must be different address 0"
        );

        // Transfer prize to this smct
        token.safeTransferFrom(_msgSender(), address(this), prize);

        uint256 newId = _totalChallenging + 1;

        Challenging memory newChallenge = Challenging(
            newId,
            creator,
            team1,
            team2,
            block.timestamp,
            0,
            startInvestingTime,
            endInvestingTime,
            ChallengingStatus.DEFAULT,
            winnerRewardRate,
            TeamIndex.DEFAULT,
            prize
        );
        challengings[newId] = newChallenge;
        _totalChallenging++;

        //emit event
        emit ChallengingCreated(newId);
    }

    function _submitResult(uint256 challengeId, TeamIndex winner)
        internal
        virtual
        isChallenge(challengeId)
        atDefault(challengeId)
    {
        challengings[challengeId].winner = winner;
        challengings[challengeId].status = ChallengingStatus.FINISHED;
        challengings[challengeId].endTime = block.timestamp;

        emit ChallengingFinished(challengeId);
    }

    function _prize(uint256 challengeId)
        internal
        view
        virtual
        isChallenge(challengeId)
        returns (uint256)
    {
        return challengings[challengeId].prize;
    }

    function _invest(
        uint256 challengeId,
        TeamIndex team,
        address fromAddress,
        uint256 amount
    )
        internal
        virtual
        isChallenge(challengeId)
        atDefault(challengeId)
        returns (bool)
    {
        require(
            challengings[challengeId].endInvestingTime > block.timestamp,
            "Challenge: investing time was over"
        );
        // Transfer prize to this smct
        token.safeTransferFrom(fromAddress, address(this), amount);

        investings[challengeId][team][fromAddress] += amount;
        totalInvestings[challengeId][team] += amount;

        emit Investing(challengeId, team, fromAddress, amount);

        return true;
    }

    function _destroy(uint256 challengeId, address from)
        internal
        virtual
        isChallenge(challengeId)
        atDefault(challengeId)
    {
        require(
            challengings[challengeId].creator == from,
            "Challenge: you are not creator"
        );
        challengings[challengeId].status = ChallengingStatus.DESTROYED;
        // Transfer prize to this smct
        token.safeTransfer(
            challengings[challengeId].creator,
            challengings[challengeId].prize
        );
    }

    function _donate(
        uint256 challengeId,
        TeamIndex team,
        address fromAddress,
        uint256 amount
    ) internal virtual isChallenge(challengeId) atDefault(challengeId) {
        // Transfer prize to this smct
        token.safeTransferFrom(fromAddress, address(this), amount);

        donations[challengeId][team] += amount;

        emit Donation(challengeId, team, fromAddress, amount);
    }

    function _estimateReward(uint256 challengeId, address fromAddress)
        internal
        view
        virtual
        isChallenge(challengeId)
        returns (uint256)
    {
        Challenging storage challenge = challengings[challengeId];
        require(
            challenge.status == ChallengingStatus.FINISHED ||
                challenge.status == ChallengingStatus.DESTROYED,
            "Challenge: this challenge is not finished"
        );

        uint256 refund = 0;
        uint256 winnerPrize = 0;
        uint256 investingPrize = 0;
        uint256 donatePrize = 0;

        if (challenge.status == ChallengingStatus.DESTROYED) {
            refund = refund
                .add(investings[challengeId][TeamIndex.ONE][fromAddress])
                .add(investings[challengeId][TeamIndex.TWO][fromAddress]);

            if (fromAddress == _winnerAddress(challengeId)) {
                donatePrize = donatePrize.add(
                    donations[challengeId][challenge.winner]
                );
            } else if (fromAddress == _loserAddress(challengeId)) {
                donatePrize = donatePrize.add(
                    donations[challengeId][_loserIndex(challengeId)]
                );
            }
        } else if (challenge.status == ChallengingStatus.FINISHED) {
            if (fromAddress == _winnerAddress(challengeId)) {
                refund = investings[challengeId][TeamIndex.ONE][fromAddress];
                winnerPrize = challenge.prize;
                donatePrize = donatePrize.add(
                    donations[challengeId][challenge.winner]
                );
            }
            if (investings[challengeId][challenge.winner][fromAddress] > 0) {
                refund = refund.add(
                    investings[challengeId][challenge.winner][fromAddress]
                );
                investingPrize = totalInvestings[challengeId][
                    _loserIndex(challengeId)
                ];
            }
            if (fromAddress == _loserAddress(challengeId)) {
                donatePrize = donatePrize.add(
                    donations[challengeId][_loserIndex(challengeId)]
                );
            }
        }

        uint256 ONE_HUNDRES = 100;
        uint256 winnerReward = winnerPrize.mul(challenge.winnerRewardRate).div(
            ONE_HUNDRES
        );
        uint256 fromPrize = winnerPrize
            .mul(ONE_HUNDRES.sub(challenge.winnerRewardRate))
            .div(ONE_HUNDRES);
        uint256 investing = investings[challengeId][challenge.winner][
            fromAddress
        ];
        uint256 totalInvesting = totalInvestings[challengeId][challenge.winner];
        uint256 investingReward = (fromPrize.add(investingPrize))
            .mul(investing)
            .div(totalInvesting);
        return refund.add(donatePrize.add(winnerReward.add(investingReward)));
    }

    function _claim(uint256 challengeId, address fromAddress) internal virtual {
        uint256 reward = _estimateReward(challengeId, fromAddress);

        require(reward > 0, "Challege: your reward must greater than 0");
        require(
            claimings[challengeId][fromAddress].claimed == false,
            "Challege: you claimed"
        );
        require(
            challengings[challengeId].status == ChallengingStatus.FINISHED ||
                challengings[challengeId].status == ChallengingStatus.DESTROYED,
            "Challege: the challenge is not finished"
        );

        claimings[challengeId][fromAddress] = Claiming(reward, true);

        token.safeTransfer(fromAddress, reward);
    }

    function _winnerAddress(uint256 challengeId)
        internal
        view
        virtual
        returns (address)
    {
        if (challengings[challengeId].winner == TeamIndex.ONE)
            return challengings[challengeId].team1;
        if (challengings[challengeId].winner == TeamIndex.TWO)
            return challengings[challengeId].team2;
        return address(0);
    }

    function _loserAddress(uint256 challengeId)
        internal
        view
        virtual
        returns (address)
    {
        if (challengings[challengeId].winner == TeamIndex.ONE)
            return challengings[challengeId].team2;
        if (challengings[challengeId].winner == TeamIndex.TWO)
            return challengings[challengeId].team1;
        return address(0);
    }

    function _loserIndex(uint256 challengeId)
        internal
        view
        virtual
        returns (TeamIndex)
    {
        if (challengings[challengeId].winner == TeamIndex.ONE)
            return TeamIndex.TWO;
        else if (challengings[challengeId].winner == TeamIndex.TWO)
            return TeamIndex.ONE;
        return TeamIndex.DEFAULT;
    }
}