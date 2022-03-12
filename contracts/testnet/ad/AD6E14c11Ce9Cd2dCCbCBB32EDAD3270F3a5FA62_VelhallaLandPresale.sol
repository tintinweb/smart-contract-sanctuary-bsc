/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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

// File: contracts/VelhallaLandPresale.sol



pragma solidity ^0.8.8;








abstract contract Presalable is Context {

    event Presaled(address account);
    event Unpresaled(address account);

    bool private _presaled;

    constructor() {
        _presaled = false;
    }

    function presaled() public view virtual returns (bool) {
        return _presaled;
    }

    modifier whenNotPresaled() {
        require(!presaled(), "Presalable: presaled");
        _;
    }
    modifier whenPresaled() {
        require(presaled(), "Presalable: not presaled");
        _;
    }
    function _presale() internal virtual whenNotPresaled {
        _presaled = true;
        emit Presaled(_msgSender());
    }

    function _unpresale() internal virtual whenPresaled {
        _presaled = false;
        emit Unpresaled(_msgSender());
    }
}

interface IVL721 {
    function openLandChest(address _to, uint256 _landChestType, uint256 i) external returns(uint256, uint256);
    function setTokenURI(uint256 _tokenId, string memory _uri) external;
    function tokenURI(uint256 _tokenId) external view returns (string memory);

    function setLandsChestNumber(uint256[4] memory _allocatedLandsChestNumber) external;
    function setPrOfCHL(uint256[4] memory _prOfCHL) external;
    function setLandsNumber(uint256[5] memory _allocatedLandsNumber) external;

    function getRemainingLandsChestNumber() external view returns(uint256[4] memory);
    function getPrOfCHL() external view returns(uint256[4] memory);
    function getLandTokenIds(address account) external view returns(uint256[] memory);
    function getLandTokenURIs(address account) external view returns(string[] memory);

    function pause() external;
    function unpause() external;
}
interface IVL1155 {
    function openLandChest(address to, uint256 landChestType) external returns(uint256[] memory);
    function getStarIDLength() external returns(uint256);
    function getVoucherTokenIds() external view returns(uint256[] memory);
    function getVoucherNumbers(address account) external view returns(uint256[] memory);
    function getVoucherTokenURIs() external view returns(string[] memory);
    function pause() external;
    function unpause() external;
}
interface IWagyuRouter {
    function getAmountsIn(uint256 amountOut, address[] memory path) external view returns (uint256[] memory amounts);
}

contract VelhallaLandPresale is Ownable, Pausable, Presalable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct CurrencyInfo {
        address payable currencyAddr;           // Address of token contract.
        string name;
        bool enable;
        bool isExchangeRateUsed;
        uint256[4] landChestPrice;  // 0: grasslandChest price, 1: tundraChestPrice, 2: moltenBarrensChestPrice, 3: wastelandChestPrice
    }
    
    IVL721 public velhallaLand721;
    IVL1155 public velhallaLand1155;
    IWagyuRouter wagyuRouter = IWagyuRouter(0x3D1c58B6d4501E34DF37Cf0f664A58059a188F00);    // Velas WagyuRouter address

    CurrencyInfo[] public currencyInfo;

    uint256 public constant MAX_INT = 2**256 - 1;
    
    uint256 public maxWhitelistPurchaseLimit = MAX_INT;
    uint256 public maxPurchaseLimit = MAX_INT;
    
    uint256[4] public allocatedLandsChestNumber;   // Number of landchest
    uint256[5] public allocatedLandsNumber;    // Number of land

    address[] private whitelistAddress;
    address[] private alreadyMintedAddress;
    mapping(address => uint256) private whitelist;    // for presale
    mapping(address => uint256) private alreadyMinted;    // for public sale
    


    event AddCurrencyInfo(address _currencyAddr, string _name, bool _enable, bool _isExchangeRateUsed, uint256[4] _landChestPrice);
    event RemoveCurrencyAddr(uint256 currencyIndex);
    event SetCurrencyInfoAddr(uint256 currencyIndex, address _currencyAddr);
    event SetCurrencyInfoName(uint256 currencyIndex, string _name);
    event SetCurrencyInfoEnable(uint256 currencyIndex, bool _enable);
    event SetCurrencyInfoIsExchangeRateUsed(uint256 currencyIndex, bool _isExchangeRateUsed);
    event SetCurrencyInfoLandChestPrice(uint256 currencyIndex, uint256[4] _landChestPrice);
    
    event SetAllocatedLandsChestNumber(uint256[4] _allocatedLandsChestNumber);
    event SetAllocatedLandsNumber(uint256[5] _allocatedLandsNumber);

    event SetMaxPurchaseLimit(uint256 _maxPurchaseLimit);
    event SetMaxWhitelistPurchaseLimit(uint256 _maxWhitelistPurchaseLimit);
    event SetWhitelist(address[] users, uint256[] numAllowedToMint);
    
    event PurchaseLandChest(address indexed user, uint256 indexed currencyIndex, uint256 price, uint256 number, uint256[], uint256[], uint256[]);
    event OwnerOpenLandChest(address indexed user, uint256 number, uint256[], uint256[], uint256[]);

    constructor(IVL721 _velhallaLand721, IVL1155 _velhallaLand1155) {
        velhallaLand721 = _velhallaLand721;
        velhallaLand1155 = _velhallaLand1155;
 
        // WVLX
        currencyInfo.push(CurrencyInfo({
            currencyAddr: payable(0xc579D1f3CF86749E05CD06f7ADe17856c2CE3126),  // Velas WVLX address
            name: "WVLX",
            enable: true,
            isExchangeRateUsed: true,
            landChestPrice: [uint256(MAX_INT),uint256(MAX_INT),uint256(MAX_INT),uint256(MAX_INT)]
        }));
        // BUSD
        currencyInfo.push(CurrencyInfo({
            currencyAddr: payable(0xc111c29A988AE0C0087D97b33C6E6766808A3BD3),  // Velas BUSD address
            name: "BUSD",
            enable: true,
            isExchangeRateUsed: false,
            landChestPrice: [uint256(5000),uint256(2500),uint256(1200),uint256(600)]
        }));
        // BSC-USD , USDT
        currencyInfo.push(CurrencyInfo({
            currencyAddr: payable(0x01445C31581c354b7338AC35693AB2001B50b9aE),  // Velas USDT address
            name: "USDT",
            enable: true,
            isExchangeRateUsed: false,
            landChestPrice: [uint256(5000),uint256(2500),uint256(1200),uint256(600)]
        }));
        // SCAR
        currencyInfo.push(CurrencyInfo({
            currencyAddr: payable(0x8d9fB713587174Ee97e91866050c383b5cEE6209),  //   Velas SCAR address
            name: "SCAR",
            enable: false,
            isExchangeRateUsed: true,
            landChestPrice: [uint256(MAX_INT),uint256(MAX_INT),uint256(MAX_INT),uint256(MAX_INT)]
        }));

        allocatedLandsChestNumber = [uint256(1500), uint256(1500), uint256(1500), uint256(1500)];
        allocatedLandsNumber = [uint256(1500), uint256(1500), uint256(1500), uint256(1500), uint256(87)];
    }

    // Owner withdraw
    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    // Add/Remove Currency Information 
    function addCurrencyInfo(address _currencyAddr, string memory _name, bool _enable, bool _isExchangeRateUsed, uint256[4] memory _landChestPrice) onlyOwner whenPaused external{
        currencyInfo.push(CurrencyInfo({
            currencyAddr: payable(_currencyAddr),
            name: _name,
            enable: _enable,
            isExchangeRateUsed: _isExchangeRateUsed,
            landChestPrice: _landChestPrice
        }));
        emit AddCurrencyInfo(_currencyAddr, _name, _enable, _isExchangeRateUsed, _landChestPrice);
    }
    
    function removeCurrencyAddr(uint256 currencyIndex) onlyOwner whenPaused external{
        delete currencyInfo[currencyIndex];
        emit RemoveCurrencyAddr(currencyIndex);
    }

    // Set Currency Information 
    function setCurrencyInfoAddr(uint256 currencyIndex, address  _currencyAddr) onlyOwner whenPaused external {
        require(currencyIndex < currencyInfo.length, "Crrency Index out of range");
        
        currencyInfo[currencyIndex].currencyAddr = payable(_currencyAddr);

        emit SetCurrencyInfoAddr(currencyIndex, _currencyAddr);
    }
    function setCurrencyInfoName(uint256 currencyIndex, string memory _name) onlyOwner whenPaused external {
        require(currencyIndex < currencyInfo.length, "Crrency Index out of range");
        
        currencyInfo[currencyIndex].name = _name;

        emit SetCurrencyInfoName(currencyIndex, _name);
    }
    function setCurrencyInfoEnable(uint256 currencyIndex, bool _enable) onlyOwner whenPaused external {
        require(currencyIndex < currencyInfo.length, "Crrency Index out of range");
        
        currencyInfo[currencyIndex].enable = _enable;

        emit SetCurrencyInfoEnable(currencyIndex, _enable);
    }
    function setCurrencyInfoIsExchangeRateUsed(uint256 currencyIndex, bool _isExchangeRateUsed) onlyOwner whenPaused external {
        require(currencyIndex < currencyInfo.length, "Crrency Index out of range");
        
        currencyInfo[currencyIndex].isExchangeRateUsed = _isExchangeRateUsed;

        emit SetCurrencyInfoIsExchangeRateUsed(currencyIndex, _isExchangeRateUsed);
    }

    // Set LandChest Price
    function setCurrencyInfoLandChestPrice(uint256 currencyIndex, uint256[4] memory _landChestPrice) onlyOwner whenPaused external {
        require(currencyIndex < currencyInfo.length, "Crrency Index out of range");
        
        currencyInfo[currencyIndex].landChestPrice = _landChestPrice;

        emit SetCurrencyInfoLandChestPrice(currencyIndex, _landChestPrice);
    }
    // Set allocated LandsChest Number
    function setAllocatedLandsChestNumber(uint256[4] memory _allocatedLandsChestNumber) onlyOwner whenPaused external {
 
        allocatedLandsChestNumber = _allocatedLandsChestNumber;
        velhallaLand721.setLandsChestNumber(_allocatedLandsChestNumber);

        emit SetAllocatedLandsChestNumber(_allocatedLandsChestNumber);
    }
    // Probability of CrystalHighlands in LandChest
    function setPrOfCHL(uint256[4] memory _prOfCHL) onlyOwner whenPaused external {

        velhallaLand721.setPrOfCHL(_prOfCHL);
    }
    function getPrOfCHL() onlyOwner external view returns(uint256[4] memory){
        return velhallaLand721.getPrOfCHL();
    }
    // Set allocated Lands Number
    function setAllocatedLandsNumber(uint256[5] memory _allocatedLandsNumber) onlyOwner whenPaused external {
 
        allocatedLandsNumber = _allocatedLandsNumber;
        velhallaLand721.setLandsNumber(_allocatedLandsNumber);

        emit SetAllocatedLandsNumber(_allocatedLandsNumber);
    }

    // Purchase Limit
    function setMaxPurchaseLimit(uint256 _maxPurchaseLimit) onlyOwner whenPaused external {
        maxPurchaseLimit = _maxPurchaseLimit;
        for (uint i = 0; i < alreadyMintedAddress.length; i++){
            alreadyMinted[alreadyMintedAddress[i]] = 0;
        }
        delete alreadyMintedAddress;
        emit SetMaxPurchaseLimit(_maxPurchaseLimit);
    }
    function getRemainingPurchase(address user) external view returns(uint256) {
        return maxPurchaseLimit - alreadyMinted[user];
    }
    
    // whitelist
    function setMaxWhitelistPurchaseLimit(uint256 _maxWhitelistPurchaseLimit) onlyOwner whenPaused external {
        maxWhitelistPurchaseLimit = _maxWhitelistPurchaseLimit;
        for (uint i = 0; i < whitelistAddress.length; i++){
            whitelist[whitelistAddress[i]] = 0;
        }
        delete whitelistAddress;
        emit SetMaxWhitelistPurchaseLimit(_maxWhitelistPurchaseLimit);
    }
    function setWhitelist (address[] calldata users, uint256[] calldata numAllowedToMint) external onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            require(numAllowedToMint[i] <= maxWhitelistPurchaseLimit, string(bytes.concat("Max number allowed To mint: ", bytes(Strings.toString(maxWhitelistPurchaseLimit)))));
            whitelist[users[i]] = numAllowedToMint[i];
            whitelistAddress.push(users[i]);
        }
        emit SetWhitelist(users, numAllowedToMint);
    }
    function isInWhitelist(address user) external view returns(bool) {
        return (whitelist[user] > 0);
    }
    function getCountInWhitelist(address user) external view returns(uint256) {
        return whitelist[user];
    }
    function getWhitelist() external view returns(address[] memory, uint256[] memory) {
        uint256[] memory whitelistAddressNumber = new uint256[](whitelistAddress.length);
        for (uint i = 0; i < whitelistAddress.length; i++){
            whitelistAddressNumber[i] = whitelist[whitelistAddress[i]];
        }
        return (whitelistAddress, whitelistAddressNumber);
    }
    
    // exchange rate
    function getAmountsIn(
        uint256 amountOut,
        address[] memory path
    ) public virtual view returns (uint256 amountsIn) {
        uint256[] memory amounts = wagyuRouter.getAmountsIn(amountOut, path);
        amountsIn = amounts[0];
    }

    // For presale
    function purchaseLandChestPresale(uint256 currencyIndex, uint256 landChestType, uint256 number) whenNotPaused whenPresaled nonReentrant external payable{
        require(whitelist[msg.sender] > 0, "STOP: user not in whitelist");
        require(whitelist[msg.sender] >= number, "STOP: Exceeds allowed mint number");

        purchaseLandChest(currencyIndex, landChestType, number);

        whitelist[msg.sender] -= number;
    }
    // For public sale
    function purchaseLandChestPublicSale(uint256 currencyIndex, uint256 landChestType, uint256 number) whenNotPaused whenNotPresaled nonReentrant external payable{
        require(number <= (maxPurchaseLimit - alreadyMinted[msg.sender]), string(bytes.concat("Purchese limit: ", bytes(Strings.toString(maxPurchaseLimit - alreadyMinted[msg.sender])))));
        
        purchaseLandChest(currencyIndex, landChestType, number);

        if(alreadyMinted[address(msg.sender)] == 0){
            alreadyMintedAddress.push(address(msg.sender));
        }
        alreadyMinted[address(msg.sender)] += number;
    }

    // purchase landchest function
    function purchaseLandChest(uint256 currencyIndex, uint256 landChestType, uint256 number) private {
        require(currencyInfo[currencyIndex].enable, "Payment method is disable");
        require(currencyIndex < currencyInfo.length, "Crrency Index out of range");
        require(landChestType < allocatedLandsChestNumber.length, "LandChest Index out of range");
        require(number < velhallaLand721.getRemainingLandsChestNumber()[landChestType], "LandChest is insufficient"); // check if soldout
        
        uint256[] memory landtypeArray = new uint256[](number);
        uint256[] memory tokenIDArray = new uint256[](number);
        // zeroStar:0 , oneStar:1, twoStar:2 , threeStar:3, fourStar:4
        uint256 starIDLength = velhallaLand1155.getStarIDLength();
        uint256[] memory heroTicketNumberArray = new uint256[](starIDLength);

        uint256 price;

        address[] memory path = new address[](2);
        path[0] = currencyInfo[currencyIndex].currencyAddr;
        path[1] = currencyInfo[2].currencyAddr;

        if(currencyIndex == 0){
            if(currencyInfo[currencyIndex].isExchangeRateUsed) {
                uint256 amountIn = getAmountsIn(currencyInfo[2].landChestPrice[landChestType], path);   // getAmountsIn retrun Mwei, 1 Mwei = 1,000,000 wei(10^6 wei)
                require(
                    amountIn.mul(number).mul(10**6).mul(95).div(100) <= msg.value &&
                    amountIn.mul(number).mul(10**6).mul(105).div(100) >= msg.value, 
                    "VLX value sent is not correct"
                    );
                currencyInfo[currencyIndex].landChestPrice[landChestType] = amountIn.div(10**12);   // landChestPrice store as ether, 1 ether = 10^18 wei
                price = currencyInfo[currencyIndex].landChestPrice[landChestType];
            }else{
                price = currencyInfo[currencyIndex].landChestPrice[landChestType];  // landChestPrice store as ether, 1 ether = 10^18 wei
                require(
                    price.mul(number).mul(10**18).mul(95).div(100) <= msg.value &&
                    price.mul(number).mul(10**18).mul(105).div(100) >= msg.value, 
                    "VLX value sent is not correct"
                    );
            }
            
        }else{
            IERC20 currency = IERC20(currencyInfo[currencyIndex].currencyAddr);
        
            if(currencyIndex > 2 && currencyInfo[currencyIndex].isExchangeRateUsed){
                uint256 amountIn = getAmountsIn(currencyInfo[2].landChestPrice[landChestType], path);   // getAmountsIn retrun Mwei, 1 Mwei = 1,000,000 wei(10^6 wei)
                currencyInfo[currencyIndex].landChestPrice[landChestType] = amountIn.div(10**12);   // landChestPrice store as ether, 1 ether = 10^18 wei
            }
            price = currencyInfo[currencyIndex].landChestPrice[landChestType];
            
            currency.safeTransferFrom(address(msg.sender), payable(address(owner())), price * number * 10**18);
        }

        for(uint i=0 ; i<number ; i++){
            uint256 landtype;
            uint256 landTokenID;
            uint256[] memory heroTicketNumber  = new uint256[](starIDLength);

            (landtype, landTokenID) = velhallaLand721.openLandChest(msg.sender, landChestType, i);
            landtypeArray[i] = landtype;
            tokenIDArray[i] = landTokenID;

            heroTicketNumber = velhallaLand1155.openLandChest(msg.sender, landChestType);
            for(uint j=0 ; j<starIDLength ; j++){
                heroTicketNumberArray[j] += heroTicketNumber[j];
            }
        }
        
        emit PurchaseLandChest(msg.sender, currencyIndex, price, number, landtypeArray, tokenIDArray, heroTicketNumberArray);
    }

    function getCurrencyInfoLength() external view returns (uint256) {
        return currencyInfo.length;
    }
    // get LandChest Price
    function getCurrencyInfoLandChestPrice(uint256 currencyIndex, uint256 landChestType) external view returns (uint256) {
        return currencyInfo[currencyIndex].landChestPrice[landChestType];
    }
    // get all landchest information
    function getLandChestInfo() external view returns (uint256[4] memory, uint256[4] memory, CurrencyInfo[] memory) {
        return (allocatedLandsChestNumber, velhallaLand721.getRemainingLandsChestNumber(), currencyInfo);
    }
    // get all land and Voucher information
    function getLandAndVoucherInfo(address account) external view returns (uint256[] memory landTokenIds, string[] memory landTokenURIs, uint256[] memory voucherTokenIds, uint256[] memory voucherNumbers, string[] memory voucherTokenURIs) {
        landTokenIds = velhallaLand721.getLandTokenIds(account);
        landTokenURIs = velhallaLand721.getLandTokenURIs(account);
        voucherTokenIds = velhallaLand1155.getVoucherTokenIds();
        voucherNumbers = velhallaLand1155.getVoucherNumbers(account);
        voucherTokenURIs = velhallaLand1155.getVoucherTokenURIs();
    }

    // Presale
    function presale() public onlyOwner {
        _presale();
    }
    // Unpause
    function unpresale() public onlyOwner{
        _unpresale();
    }

    // Pause
    function pause() public onlyOwner {
        _pause();
        velhallaLand721.pause();
        velhallaLand1155.pause();
    }
    // Unpause
    function unpause() public onlyOwner{
        _unpause();
        velhallaLand721.unpause();
        velhallaLand1155.unpause();
    }

    function ownerOpenLandChest(uint256 landChestType, uint256 number) onlyOwner whenNotPaused external{ 
        require(landChestType < allocatedLandsChestNumber.length, "LandChest Index out of range");
        require(number < velhallaLand721.getRemainingLandsChestNumber()[landChestType], "LandChest is insufficient");

        uint256[] memory landtypeArray = new uint256[](number);
        uint256[] memory tokenIDArray = new uint256[](number);
        // // zeroStar:0 , oneStar:1, twoStar:2 , threeStar:3, fourStar:4
        uint256 starIDLength = velhallaLand1155.getStarIDLength();
        uint256[] memory heroTicketNumberArray = new uint256[](starIDLength);

        for(uint i=0 ; i<number ; i++){
            uint256 landtype;
            uint256 landTokenID;
            uint256[] memory heroTicketNumber  = new uint256[](starIDLength);

            (landtype, landTokenID) = velhallaLand721.openLandChest(msg.sender, landChestType, i);
            landtypeArray[i] = landtype;
            tokenIDArray[i] = landTokenID;

            heroTicketNumber = velhallaLand1155.openLandChest(msg.sender, landChestType);
            for(uint j=0 ; j<starIDLength ; j++){
                heroTicketNumberArray[j] += heroTicketNumber[j];
            }
        }
        
        emit OwnerOpenLandChest(msg.sender, number, landtypeArray, tokenIDArray, heroTicketNumberArray);
    }
}